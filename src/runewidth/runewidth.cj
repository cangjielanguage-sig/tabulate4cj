package tabulate4cj.runewidth

import std.collection.*
import std.os
import tabulate4cj.grapheme.*

private func inTables(r: Rune, t: RrangeTable): Bool {
    for (rarr in t.getTable()) {
        if (inTable(r, rarr)) {
            return true
        }
    }
    return false
}

private func inTable(r: Rune, t: Array<Range<UInt32>>): Bool {
    let rUnicode = UInt32(r)

    if (rUnicode < t[0].start) {
        return false
    }

    var bot = 0
    var top = t.size - 1
    while (top >= bot) {
        var mid = (bot + top) >> 1
        match {
            case t[mid].end < rUnicode => bot = mid + 1
            case t[mid].start > rUnicode => top = mid - 1
            case _ => return true
        }
    }
    return false
}

public class RrangeTable {
    private var table: Array<Array<Range<UInt32>>>

    public init(table: Array<Array<Range<UInt32>>>) {
        this.table = table
    }

    public func getTable(): Array<Array<Range<UInt32>>> {
        return this.table
    }
}

public class Condition {
    public var eastAsianWidth: Bool = false
    public var strictEmojiNeutral: Bool = true

    public init() {}

    public init(
        eastAsianWidth: Bool,
        strictEmojiNeutral: Bool
    ) {
        this.eastAsianWidth = eastAsianWidth
        this.strictEmojiNeutral = strictEmojiNeutral
    }

    // RuneWidth returns the number of cells in r.
    public func runeWidth(r: Rune): Int64 {
        let rUnicode = UInt32(r)
        if (rUnicode < 0 || rUnicode > 0x10FFFF) {
            return 0
        }

        if (!this.eastAsianWidth) {
            match {
                case rUnicode < 0x20 => return 0
                case (rUnicode >= 0x7F && rUnicode <= 0x9F) || rUnicode == 0xAD => return 0
                case rUnicode < 0x300 => return 1
                case inTable(r, narrow) => return 1
                case inTables(r, RrangeTable([nonprint, combining])) => return 0
                case inTable(r, doublewidth) => return 2
                case _ => return 1
            }
        } else {
            match {
                case inTables(r, RrangeTable([nonprint, combining])) => return 0
                case inTable(r, narrow) => return 1
                case inTables(r, RrangeTable([ambiguous, doublewidth])) => return 2
                case !this.strictEmojiNeutral && inTables(r, RrangeTable([ambiguous, emoji, narrow])) => return 2
                case _ => return 1
            }
        }

        return 0
    }

    // StringWidth return width as you can see
    public func stringWidth(s: String): Int64 {
        // 老版本: 使用toRuneArray转换为字符数组,缺点为无法正确识别变体字符的真实长度
        // let runeArr: Array<Rune> = s.toRuneArray()
        // var width: Int64 = 0
        // for (r in  runeArr){
        // 	width += this.runeWidth(r)
        // }
        // return width

        // 新版本: 进行了unicode码点的分组,可以识别几乎所有变体字符的真实长度
        var width: Int64 = 0
        let g: Grapheme = newGraphemes(s)
        while (g.next()) {
            var chWidth = 0
            for (r in (g.runes() ?? [])) {
                chWidth = this.runeWidth(r)
                if (chWidth > 0) {
                    break
                }
            }
            width += chWidth
        }
        return width
    }

    // Truncate return string truncated with w cells
    public func truncate(s: String, w: Int64, tail: String): String {
        var twidth = w
        if (this.stringWidth(s) <= w) {
            return s
        }
        twidth -= this.stringWidth(tail)
        var width: Int64 = 0
        var pos = s.size
        let g = newGraphemes(s)
        while (g.next()) {
            var chWidth = 0
            for (r in (g.runes() ?? [])) {
                chWidth = this.runeWidth(r)
                if (chWidth > 0) {
                    break // See StringWidth() for details.
                }
            }
            if (width + chWidth > twidth) {
                (pos, _) = g.positions()
                break
            }
            width += chWidth
        }
        return s[0..pos] + tail
    }

    // TruncateLeft cuts w cells from the beginning of the `s`.
    public func truncateLeft(s: String, w: Int64, prefix: String): String {
        var tprefix = prefix
        if (this.stringWidth(s) <= w) {
            return tprefix
        }
        var width: Int64 = 0
        var pos = s.size
        let g = newGraphemes(s)
        while (g.next()) {
            var chWidth = 0
            for (r in (g.runes() ?? [])) {
                chWidth = this.runeWidth(r)
                if (chWidth > 0) {
                    break // See StringWidth() for details.
                }
            }
            if (width + chWidth > w) {
                if (width < w) {
                    (_, pos) = g.positions()
                    for (i in 0..(width + chWidth - w)) {
                        tprefix += " "
                    }
                // tprefix += Repeat(" ", width + chWidth - w)
                } else {
                    (pos, _) = g.positions()
                }

                break
            }
            width += chWidth
        }
        return tprefix + s[pos..]
    }

    // Wrap return string wrapped with w cells
    public func wrap(s: String, w: Int64): String {
        var width = 0
        var out = ""
        for (r in s.toRuneArray()) {
            let cw = this.runeWidth(r)
            if (r == r'\n') {
                out += String(r)
                width = 0
                continue
            } else if (width + cw > w) {
                out += "\n"
                width = 0
                out += String(r)
                width += cw
                continue
            }
            out += String(r)
            width += cw
        }
        return out
    }

    // FillLeft return string filled in left by spaces in w cells
    public func fillLeft(s: String, w: Int64): String {
        let width = this.stringWidth(s)
        let count = w - width
        if (count > 0) {
            let b = Array<Rune>(count, item: r' ')
            return String(b) + s
        }
        return s
    }

    // FillRight return string filled in left by spaces in w cells
    public func fillRight(s: String, w: Int64): String {
        let width = this.stringWidth(s)
        let count = w - width
        if (count > 0) {
            let b = Array<Rune>(count, item: r' ')
            return s + String(b)
        }
        return s
    }
}

public class StartClass {
    init() {
        handleEnv()
    }
}

let defaultCondition = Condition(false, true)
let sc = StartClass()

public func handleEnv() {
    let env = os.getEnv("RUNEWIDTH_EASTASIAN") ?? ""
    var eastAsianWidth = false
    // var strictEmojiNeutral = true
    if (env == "") {
        eastAsianWidth = isEastAsian()
    } else {
        eastAsianWidth = (env == "1")
    }
    // update defaultCondition
    if (defaultCondition.eastAsianWidth != eastAsianWidth) {
        defaultCondition.eastAsianWidth = eastAsianWidth
    }
}

// RuneWidth returns the number of cells in r.
// See http://www.unicode.org/reports/tr11/
public func runeWidth(r: Rune): Int64 {
    return defaultCondition.runeWidth(r)
}

// IsAmbiguousWidth returns whether is ambiguous width or not.
public func isAmbiguousWidth(r: Rune): Bool {
    return inTables(r, RrangeTable([privateT, ambiguous]))
}

// IsNeutralWidth returns whether is neutral width or not.
public func isNeutralWidth(r: Rune): Bool {
    return inTable(r, neutral)
}

// StringWidth return width as you can see
public func stringWidth(s: String): Int64 {
    return defaultCondition.stringWidth(s)
}

// Truncate return string truncated with w cells
public func truncate(s: String, w: Int64, tail: String): String {
    return defaultCondition.truncate(s, w, tail)
}

// TruncateLeft cuts w cells from the beginning of the `s`.
public func truncateLeft(s: String, w: Int64, prefix: String): String {
    return defaultCondition.truncateLeft(s, w, prefix)
}

// Wrap return string wrapped with w cells
public func wrap(s: String, w: Int64): String {
    return defaultCondition.wrap(s, w)
}

// FillLeft return string filled in left by spaces in w cells
public func fillLeft(s: String, w: Int64): String {
    return defaultCondition.fillLeft(s, w)
}

// FillRight return string filled in left by spaces in w cells
public func fillRight(s: String, w: Int64): String {
    return defaultCondition.fillRight(s, w)
}
