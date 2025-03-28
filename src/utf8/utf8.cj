package tabulate4cj.utf8

import std.collection.*
import std.io.*

public const RuneError = r'\u{FFFD}' // the "error" Rune or "Unicode replacement character"
// const RuneSelf = 0x80 // characters below RuneSelf are represented as themselves in a single byte.
// const MaxRune = r'\u{10FFFF}' // Maximum valid Unicode code point.
// const UTFMax = 4 // maximum number of bytes of a UTF-8 encoded Unicode character.

// const t1: UInt8 = 0b00000000
// const tx: UInt8 = 0b10000000
// const t2: UInt8 = 0b11000000
// const t3: UInt8 = 0b11100000
// const t4: UInt8 = 0b11110000
// const t5: UInt8 = 0b11111000
const maskx: UInt32 = 0b00111111
const mask2: UInt32 = 0b00011111
const mask3: UInt32 = 0b00001111
const mask4: UInt32 = 0b00000111

const xx: UInt8 = 0xF1 // invalid: size 1
const _as: UInt8 = 0xF0 // ASCII: size 1
const s1: UInt8 = 0x02 // accept 0, size 2
const s2: UInt8 = 0x13 // accept 1, size 3
const s3: UInt8 = 0x03 // accept 0, size 3
const s4: UInt8 = 0x23 // accept 2, size 3
const s5: UInt8 = 0x34 // accept 3, size 4
const s6: UInt8 = 0x04 // accept 0, size 4
const s7: UInt8 = 0x44 // accept 4, size 4

const locb: UInt8 = 0b10000000
const hicb: UInt8 = 0b10111111

let first: Array<UInt8> = [
    //   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
    _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, // 0x00-0x0F
    _as, _as, _as,
    _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, // 0x10-0x1F
        _as, _as, _as, _as, _as, _as, _as, _as, _as, _as,
    _as, _as, _as, _as, _as, _as, // 0x20-0x2F
        _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, // 0x30-0x3F
        _as,
    _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, // 0x40-0x4F
        _as, _as, _as, _as, _as, _as, _as, _as,
    _as, _as, _as, _as, _as, _as, _as, _as, // 0x50-0x5F
        _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as,
    _as, // 0x60-0x6F
        _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, _as, // 0x70-0x7F
        //   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
        xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, // 0x80-0x8F
        xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, // 0x90-0x9F
        xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, // 0xA0-0xAF
        xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, // 0xB0-0xBF
        xx, xx,
    s1, s1, s1, s1, s1, s1, s1, s1, s1, s1, s1, s1, s1, s1, // 0xC0-0xCF
        s1, s1, s1, s1, s1, s1, s1, s1, s1, s1, s1, s1, s1, s1, s1,
    s1, // 0xD0-0xDF
        s2, s3, s3, s3, s3, s3, s3, s3, s3, s3, s3, s3, s3, s4, s3, s3, // 0xE0-0xEF
        s5, s6, s6, s6, s7, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx // 0xF0-0xFF
]

let acceptRanges = HashMap<UInt8, Range<UInt8>>(
    (0, locb..=hicb),
    (1, 0xA0..=hicb),
    (2, locb..=0x9F),
    (3, 0x90..=hicb),
    (4, locb..=0x8F),
)

public func decodeStringToBytesArray(s: String): Array<Byte> {
    let byteArrayStream = ByteArrayStream()
    let stringWriter = StringWriter(byteArrayStream)
    stringWriter.write(s)
    stringWriter.flush()
    return byteArrayStream.bytes()
}

// DecodeRuneInString is like [DecodeRune] but its input is a string. If s is
// empty it returns ([RuneError], 0). Otherwise, if the encoding is invalid, it
// returns (RuneError, 1). Both are impossible results for correct, non-empty
// UTF-8.
//
// An encoding is invalid if it is incorrect UTF-8, encodes a rune that is
// out of range, or is not the shortest possible UTF-8 encoding for the
// value. No other validation is performed.
func decodeRuneInStringByByteArray(s: Array<Byte>): (r: Rune, size: Int) {
    let n = s.size
    if (n < 1) {
        return (RuneError, 0)
    }
    let s0 = s[0]
    let x = first[Int64(s0)]
    if (x >= _as) {
        // The following code simulates an additional check for x == xx and
        // handling the ASCII and invalid cases accordingly. This mask-and-or
        // approach prevents an additional branch.
        let mask = Int32(x) << 31 >> 31 // Create 0x0000 or 0xFFFF.
        return (Rune((Int32(s[0]) & (!mask)) | (Int32(UInt32(RuneError)) & mask)), 1)
    }
    let sz = Int64(x & 7)
    let accept = acceptRanges[x >> 4]
    if (n < sz) {
        return (RuneError, 1)
    }
    let s1 = s[1]
    if (s1 < accept.start || accept.end < s1) {
        return (RuneError, 1)
    }
    if (sz <= 2) { // <= instead of == to help the compiler eliminate some bounds checks
        return (Rune(((UInt32(s0) & mask2) << 6) | (UInt32(s1) & maskx)), 2)
    }
    let s2 = s[2]
    if (s2 < locb || hicb < s2) {
        return (RuneError, 1)
    }
    if (sz <= 3) {
        // rune(s0&mask3)<<12 | rune(s1&maskx)<<6 | rune(s2&maskx)

        return (Rune(((UInt32(s0) & mask3) << 12) | ((UInt32(s1) & maskx) << 6) | (UInt32(s2) & maskx)), 3)
    }
    let s3 = s[3]
    if (s3 < locb || hicb < s3) {
        return (RuneError, 1)
    }
    return (Rune(((UInt32(s0) & mask4) << 18) | ((UInt32(s1) & maskx) << 12) | ((UInt32(s2) & maskx) << 6) | (UInt32(s3) &
            maskx)), 4)
}

public func decodeRuneInString(s: String): (r: Rune, size: Int) {
    return decodeRuneInStringByByteArray(decodeStringToBytesArray(s))
}

public func decodeRuneInString(b: Array<Byte>): (r: Rune, size: Int) {
    return decodeRuneInStringByByteArray(b)
}
