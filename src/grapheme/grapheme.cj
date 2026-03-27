package tabulate4cj.grapheme

import std.collection.*

// 常量定义
private const grNoBoundary: UInt32 = 0
private const grBoundary: UInt32 = 1
private const grAny: UInt32 = 0
private const grCR: UInt32 = 1
private const grControlLF: UInt32 = 2
private const grL: UInt32 = 3
private const grLVV: UInt32 = 4
private const grLVTT: UInt32 = 5
private const grPrepend: UInt32 = 6
private const grExtendedPictographic: UInt32 = 7
private const grExtendedPictographicZWJ: UInt32 = 8
private const grRIOdd: UInt32 = 9
private const grRIEven: UInt32 = 10
// 把获取Map键封装为函数
private func getKeyOfGrTransitions(firstNum: UInt32, secondNum: UInt32): String {
    return (firstNum.toString() + "," + secondNum.toString())
}
// HashMap的键无法设置为数组
// 把键设置为String类型,然后每次取时都拼一个字符串来取值
// 保持了代码可读性的同时,避免了冗余
// 使用函数获取map的键
private let grTransitions = HashMap<String, Array<UInt32>>(
    // GB5
    (getKeyOfGrTransitions(grAny, prCR), [grCR, grBoundary, 50]),
    (getKeyOfGrTransitions(grAny, prLF), [grControlLF, grBoundary, 50]),
    (getKeyOfGrTransitions(grAny, prControl), [grControlLF, grBoundary, 50]),

    // GB4
    (getKeyOfGrTransitions(grCR, prAny), [grAny, grBoundary, 40]),
    (getKeyOfGrTransitions(grControlLF, prAny), [grAny, grBoundary, 40]),

    // GB3.
    (getKeyOfGrTransitions(grCR, prLF), [grAny, grNoBoundary, 30]),

    // GB6.
    (getKeyOfGrTransitions(grAny, prL), [grL, grBoundary, 9990]),
    (getKeyOfGrTransitions(grL, prL), [grL, grNoBoundary, 60]),
    (getKeyOfGrTransitions(grL, prV), [grLVV, grNoBoundary, 60]),
    (getKeyOfGrTransitions(grL, prLV), [grLVV, grNoBoundary, 60]),
    (getKeyOfGrTransitions(grL, prLVT), [grLVTT, grNoBoundary, 60]),

    // GB7.
    (getKeyOfGrTransitions(grAny, prLV), [grLVV, grBoundary, 9990]),
    (getKeyOfGrTransitions(grAny, prV), [grLVV, grBoundary, 9990]),
    (getKeyOfGrTransitions(grLVV, prV), [grLVV, grNoBoundary, 70]),
    (getKeyOfGrTransitions(grLVV, prT), [grLVTT, grNoBoundary, 70]),

    // GB8.
    (getKeyOfGrTransitions(grAny, prLVT), [grLVTT, grBoundary, 9990]),
    (getKeyOfGrTransitions(grAny, prT), [grLVTT, grBoundary, 9990]),
    (getKeyOfGrTransitions(grLVTT, prT), [grLVTT, grNoBoundary, 80]),

    // GB9.
    (getKeyOfGrTransitions(grAny, prExtend), [grAny, grNoBoundary, 90]),
    (getKeyOfGrTransitions(grAny, prZWJ), [grAny, grNoBoundary, 90]),

    // GB9a.
    (getKeyOfGrTransitions(grAny, prSpacingMark), [grAny, grNoBoundary, 91]),

    // GB9b.
    (getKeyOfGrTransitions(grAny, prPreprend), [grPrepend, grBoundary, 9990]),
    (getKeyOfGrTransitions(grPrepend, prAny), [grAny, grNoBoundary, 92]),

    // GB11.
    (getKeyOfGrTransitions(grAny, prExtendedPictographic), [grExtendedPictographic, grBoundary, 9990]),
    (getKeyOfGrTransitions(grExtendedPictographic, prExtend), [grExtendedPictographic, grNoBoundary, 110]),
    (getKeyOfGrTransitions(grExtendedPictographic, prZWJ), [grExtendedPictographicZWJ, grNoBoundary, 110]),
    (getKeyOfGrTransitions(grExtendedPictographicZWJ, prExtendedPictographic), [grExtendedPictographic, grNoBoundary,
            110]),

    // GB12 / GB13.
    (getKeyOfGrTransitions(grAny, prRegionalIndicator), [grRIOdd, grBoundary, 9990]),
    (getKeyOfGrTransitions(grRIOdd, prRegionalIndicator), [grRIEven, grNoBoundary, 120]),
    (getKeyOfGrTransitions(grRIEven, prRegionalIndicator), [grRIOdd, grBoundary, 120]),
)

public class Grapheme {
    public var codePoints: Array<Rune> = []
    public var indices: Array<Int64> = []
    public var start: Int64 = 0
    public var end: Int64 = 0
    public var pos: Int64 = 0
    public var state: UInt32 = 0

    public func next(): Bool {
        this.start = this.end
        // The state transition gives us a boundary instruction BEFORE the next code
        // point so we always need to stay ahead by one code point.
        // Parse the next code point.
        while (this.pos <= this.codePoints.size) {
            // GB2.
            if (this.pos == this.codePoints.size) {
                this.end = this.pos
                this.pos++
                break
            }

            // Determine the property of the next character.
            let nextProperty = property(this.codePoints[this.pos])
            this.pos++

            // Find the applicable transition.
            var boundary: Bool = true
            if (let Some(transition) <- grTransitions.get(getKeyOfGrTransitions(UInt32(this.state), nextProperty))) {
                // We have a specific transition. We'll use it.
                this.state = transition[0]
                boundary = (transition[1] == grBoundary)
            } else {
                // No specific transition found. Try the less specific ones.
                if (let Some(transAnyProp) <- grTransitions.get(getKeyOfGrTransitions(this.state, prAny))) {
                    if (let Some(transAnyState) <- grTransitions.get(getKeyOfGrTransitions(grAny, nextProperty))) {
                        // prop && state
                        // Both apply. We'll use a mix (see comments for grTransitions).
                        this.state = transAnyState[0]
                        boundary = transAnyState[1] == grBoundary
                        if (transAnyProp[2] < transAnyState[2]) {
                            this.state = transAnyProp[0]
                            boundary = (transAnyProp[1] == grBoundary)
                        }
                    } else {
                        // prop && !state
                        // We only have a specific state.
                        this.state = transAnyProp[0]
                        boundary = (transAnyProp[1] == grBoundary)
                        // This branch will probably never be reached because okAnyState will
                        // always be true given the current transition map. But we keep it here
                        // for future modifications to the transition map where this may not be
                        // true anymore.
                    }
                } else {
                    if (let Some(transAnyState) <- grTransitions.get(getKeyOfGrTransitions(grAny, nextProperty))) {
                        // !prop && state
                        // We only have a specific property.
                        this.state = transAnyState[0]
                        boundary = (transAnyState[1] == grBoundary)
                    } else {
                        // !prop && !state
                        // No known transition. GB999: Any x Any.
                        this.state = grAny
                        boundary = true
                    }
                }
            }
            // If we found a cluster boundary, let's stop here. The current cluster will
            // be the one that just ended.
            if (this.pos - 1 == 0 /* GB1 */ || boundary) {
                this.end = this.pos - 1
                break
            }
        }

        return this.start != this.end
    }

    public func runes(): ?Array<Rune> {
        if (this.start == this.end) {
            // return nil
            return None
        }
        return this.codePoints[this.start..this.end]
    }

    public func positions(): (Int64, Int64) {
        return (this.indices[this.start], this.indices[this.end])
    }
}

public func newGraphemes(s: String): Grapheme {
    let runarr = s.toRuneArray()
    let l = runarr.size
    let codePoints = Array<Rune>(l, repeat: r' ')
    let indices = Array<Int64>(l + 1, repeat: 0)
    var i = 0
    // 字符的字节位置
    var pos = 0
    for (r in runarr) {
        pos = s.indexOf(r.toString(), pos).getOrThrow()
        codePoints[i] = r
        indices[i] = pos
        i++
        pos++
    }
    indices[l] = s.size
    let g = Grapheme()
    g.codePoints = codePoints
    g.indices = indices
    g.next()
    return g
}
