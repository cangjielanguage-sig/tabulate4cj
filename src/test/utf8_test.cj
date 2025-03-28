package tabulate4cj.test

import tabulate4cj.utf8.*
import std.unittest.*
import std.unittest.testmacro.*
import std.io.*

class Utf8Map {
    public Utf8Map(
        public var r: Rune,
        public var str: String
    ) {
        this.r = r
        this.str = str
    }
}

var utf8map: Array<Utf8Map> = [
    Utf8Map(Rune(0x0000), String.fromUtf8([0x00])),
    Utf8Map(Rune(0x0001), String.fromUtf8([0x01])),
    Utf8Map(Rune(0x007e), String.fromUtf8([0x7e])),
    Utf8Map(Rune(0x007f), String.fromUtf8([0x7f])),
    Utf8Map(Rune(0x0080), String.fromUtf8([0xc2, 0x80])),
    Utf8Map(Rune(0x0081), String.fromUtf8([0xc2, 0x81])),
    Utf8Map(Rune(0x00bf), String.fromUtf8([0xc2, 0xbf])),
    Utf8Map(Rune(0x00c0), String.fromUtf8([0xc3, 0x80])),
    Utf8Map(Rune(0x00c1), String.fromUtf8([0xc3, 0x81])),
    Utf8Map(Rune(0x00c8), String.fromUtf8([0xc3, 0x88])),
    Utf8Map(Rune(0x00d0), String.fromUtf8([0xc3, 0x90])),
    Utf8Map(Rune(0x00e0), String.fromUtf8([0xc3, 0xa0])),
    Utf8Map(Rune(0x00f0), String.fromUtf8([0xc3, 0xb0])),
    Utf8Map(Rune(0x00f8), String.fromUtf8([0xc3, 0xb8])),
    Utf8Map(Rune(0x00ff), String.fromUtf8([0xc3, 0xbf])),
    Utf8Map(Rune(0x0100), String.fromUtf8([0xc4, 0x80])),
    Utf8Map(Rune(0x07ff), String.fromUtf8([0xdf, 0xbf])),
    Utf8Map(Rune(0x0400), String.fromUtf8([0xd0, 0x80])),
    Utf8Map(Rune(0x0800), String.fromUtf8([0xe0, 0xa0, 0x80])),
    Utf8Map(Rune(0x0801), String.fromUtf8([0xe0, 0xa0, 0x81])),
    Utf8Map(Rune(0x1000), String.fromUtf8([0xe1, 0x80, 0x80])),
    Utf8Map(Rune(0xd000), String.fromUtf8([0xed, 0x80, 0x80])),
    Utf8Map(Rune(0xd7ff), String.fromUtf8([0xed, 0x9f, 0xbf])), // last code point before surrogate half.
    Utf8Map(Rune(0xe000), String.fromUtf8([0xee, 0x80, 0x80])), // first code point after surrogate half.
    Utf8Map(Rune(0xfffe), String.fromUtf8([0xef, 0xbf, 0xbe])),
    Utf8Map(Rune(0xffff), String.fromUtf8([0xef, 0xbf, 0xbf])),
    Utf8Map(Rune(0x10000), String.fromUtf8([0xf0, 0x90, 0x80, 0x80])),
    Utf8Map(Rune(0x10001), String.fromUtf8([0xf0, 0x90, 0x80, 0x81])),
    Utf8Map(Rune(0x40000), String.fromUtf8([0xf1, 0x80, 0x80, 0x80])),
    Utf8Map(Rune(0x10fffe), String.fromUtf8([0xf4, 0x8f, 0xbf, 0xbe])),
    Utf8Map(Rune(0x10ffff), String.fromUtf8([0xf4, 0x8f, 0xbf, 0xbf])),
    Utf8Map(Rune(0xFFFD), String.fromUtf8([0xef, 0xbf, 0xbd]))
]

@Test
public class TestUtf8 {
    @TestCase
    func testDecodeRune() {
        for (m in utf8map) {
            let b = decodeStringToBytesArray(m.str)
            var s = m.str
            let (r1, size1) = decodeRuneInString(decodeStringToBytesArray(s))
            @Assert(r1, m.r)
            @Assert(size1, b.size)

            // there's an extra byte that bytes left behind - make sure trailing byte works
            s = m.str + String.fromUtf8([0x00])
            let (r2, size2) = decodeRuneInString(decodeStringToBytesArray(s))
            @Assert(r2, m.r)
            @Assert(size2, b.size)

            // make sure missing bytes fail
            var wantsize = 1
            if (wantsize >= b.size) {
                wantsize = 0
            }
            let bb = decodeStringToBytesArray(m.str)[0..(m.str.size - 1)]
            let (r3, size3) = decodeRuneInString(bb)
            @Assert(r3, RuneError)
            @Assert(size3, wantsize)

            // make sure bad sequences fail
            if (b.size == 1) {
                b[0] = 0x80
            } else {
                b[b.size - 1] = 0x7F
            }

            let (r4, size4) = decodeRuneInString(b)
            @Assert(r4, RuneError)
            @Assert(size4, 1)
        }
    }
}
