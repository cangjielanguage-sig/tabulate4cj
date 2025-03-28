package tabulate4cj.runewidth

import std.regex.*
import std.os
import std.collection.*

var reLoc = ##"^[a-z][a-z][a-z]?(?:_[A-Z][A-Z])?\.(.+)"##
let mblenTable = HashMap<String, Int64>(
    ("utf-8", 6),
    ("utf8", 6),
    ("jis", 8),
    ("eucjp", 3),
    ("euckr", 2),
    ("euccn", 2),
    ("sjis", 2),
    ("cp932", 2),
    ("cp51932", 2),
    ("cp936", 2),
    ("cp949", 2),
    ("cp950", 2),
    ("big5", 2),
    ("gbk", 2),
    ("gb2312", 2),
)

@When[os == "Linux"]
public func isEastAsianLinux(locale: String): Bool {
    var charset = locale.toAsciiLower()
    let rule = Regex(reLoc, RegexOption().multiLine())
    var r = rule.matcher(locale).findAll() ?? Array<MatchData>()

    if (r.size == 1) {
        let mstr = r[0].matchStr()
        let pointPos = mstr.indexOf(".") ?? 0
        charset = mstr[pointPos + 1..].toAsciiLower()
    }

    if (charset.endsWith("@cjk_narrow")) {
        return false
    }
    var pos = 0
    for (b in charset.toRuneArray()) {
        pos = charset.indexOf(b.toString(), pos).getOrThrow()
        if (b == r'@') {
            charset = charset[..pos]
            break
        }
        pos++
    }
    var max = 1
    if (let Some(m) <- mblenTable.get(charset)) {
        max = m
    }
    if (locale.startsWith("ja")) {
    }
    if (max > 1 && (Rune(charset[0]) != r'u' || locale.startsWith("ja") || locale.startsWith("ko") || locale.startsWith(
        "zh"))) {
        return true
    }
    return false
}

// IsEastAsian return true if the current locale is CJK
@When[os == "Linux"]
public func isEastAsian(): Bool {
    var locale = os.getEnv("LC_ALL") ?? ""
    if (locale == "") {
        locale = os.getEnv("LC_CTYPE") ?? ""
    }
    if (locale == "") {
        locale = os.getEnv("LANG") ?? ""
    }
    // ignore C locale
    if (locale == "POSIX" || locale == "C") {
        return false
    }
    if (locale.size > 1 && Rune(locale[0]) == r'C' && (Rune(locale[1]) == r'.' || Rune(locale[1]) == r'-')) {
        return false
    }
    return isEastAsianLinux(locale)
}
