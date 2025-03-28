package tabulate4cj.test

import tabulate4cj.runewidth.*
import std.os
import std.unittest.*
import std.unittest.testmacro.*

class RunewidthTest {
    // 源代码中in为关键字,此处改为input
    public let input: Rune
    public let output: Int64
    public let eaout: Int64
    public let nseout: Int64
    public init(input: Rune, output: Int64, eaout: Int64, nseout: Int64) {
        this.input = input
        this.output = output
        this.eaout = eaout
        this.nseout = nseout
    }
}

let runewidthtests: Array<RunewidthTest> = [
    RunewidthTest(r'世', 2, 2, 2),
    RunewidthTest(r'界', 2, 2, 2),
    RunewidthTest(r'ｾ', 1, 1, 1),
    RunewidthTest(r'ｶ', 1, 1, 1),
    RunewidthTest(r'ｲ', 1, 1, 1),
    RunewidthTest(r'☆', 1, 2, 2), // double width in ambiguous
    RunewidthTest(r'☺', 1, 1, 2),
    RunewidthTest(r'☻', 1, 1, 2),
    RunewidthTest(r'♥', 1, 2, 2),
    RunewidthTest(r'♦', 1, 1, 2),
    RunewidthTest(r'♣', 1, 2, 2),
    RunewidthTest(r'♠', 1, 2, 2),
    RunewidthTest(r'♂', 1, 2, 2),
    RunewidthTest(r'♀', 1, 2, 2),
    RunewidthTest(r'♪', 1, 2, 2),
    RunewidthTest(r'♫', 1, 1, 2),
    RunewidthTest(r'☼', 1, 1, 2),
    RunewidthTest(r'↕', 1, 2, 2),
    RunewidthTest(r'‼', 1, 1, 2),
    RunewidthTest(r'↔', 1, 2, 2),
    RunewidthTest(r'\u{0000}', 0, 0, 0),
    RunewidthTest(r'\u{0001}', 0, 0, 0),
    RunewidthTest(r'\u{0300}', 0, 0, 0),
    RunewidthTest(r'\u{2028}', 0, 0, 0),
    RunewidthTest(r'\u{2029}', 0, 0, 0),
    RunewidthTest(r'a', 1, 1, 1), // ASCII classified as "na" (narrow)
    RunewidthTest(r'⟦', 1, 1, 1), // non-ASCII classified as "na" (narrow)
    RunewidthTest(r'👁', 1, 1, 2)
]

class IsAmbiguousWidthTest {
    public var input: Rune
    public var output: Bool
    public init(input: Rune, output: Bool) {
        this.input = input
        this.output = output
    }
}

let isAmbiguousWidthTests: Array<IsAmbiguousWidthTest> = [
    IsAmbiguousWidthTest(r'世', false),
    IsAmbiguousWidthTest(r'■', true),
    IsAmbiguousWidthTest(r'界', false),
    IsAmbiguousWidthTest(r'○', true),
    IsAmbiguousWidthTest(r'㈱', false),
    IsAmbiguousWidthTest(r'①', true),
    IsAmbiguousWidthTest(r'②', true),
    IsAmbiguousWidthTest(r'③', true),
    IsAmbiguousWidthTest(r'④', true),
    IsAmbiguousWidthTest(r'⑤', true),
    IsAmbiguousWidthTest(r'⑥', true),
    IsAmbiguousWidthTest(r'⑦', true),
    IsAmbiguousWidthTest(r'⑧', true),
    IsAmbiguousWidthTest(r'⑨', true),
    IsAmbiguousWidthTest(r'⑩', true),
    IsAmbiguousWidthTest(r'⑪', true),
    IsAmbiguousWidthTest(r'⑫', true),
    IsAmbiguousWidthTest(r'⑬', true),
    IsAmbiguousWidthTest(r'⑭', true),
    IsAmbiguousWidthTest(r'⑮', true),
    IsAmbiguousWidthTest(r'⑯', true),
    IsAmbiguousWidthTest(r'⑰', true),
    IsAmbiguousWidthTest(r'⑱', true),
    IsAmbiguousWidthTest(r'⑲', true),
    IsAmbiguousWidthTest(r'⑳', true),
    IsAmbiguousWidthTest(r'☆', true)
]

class StringWidthTest {
    public let input: String
    public let output: Int64
    public let eaout: Int64
    public init(input: String, output: Int64, eaout: Int64) {
        this.input = input
        this.output = output
        this.eaout = eaout
    }
}

let stringWidthTests: Array<StringWidthTest> = [
    StringWidthTest("■㈱の世界①", 10, 12),
    StringWidthTest("スター☆", 7, 8),
    StringWidthTest("つのだ☆HIRO", 11, 12)
]

class truncateLeftTest {
    public let s: String
    public let w: Int64
    public let prefix: String
    public let out: String
    public init(s: String, w: Int64, prefix: String, out: String) {
        this.s = s
        this.w = w
        this.prefix = prefix
        this.out = out
    }
}

let truncateLeftTests: Array<truncateLeftTest> = [
    truncateLeftTest("source", 4, "", "ce"),
    truncateLeftTest("source", 4, "...", "...ce"),
    truncateLeftTest("あいうえお", 6, "", "えお"),
    truncateLeftTest("あいうえお", 6, "...", "...えお"),
    truncateLeftTest("あいうえお", 10, "", ""),
    truncateLeftTest("あいうえお", 10, "...", "..."),
    truncateLeftTest("あいうえお", 5, "", " えお"),
    truncateLeftTest("Aあいうえお", 5, "", "うえお")
]

class isNeutralWidthTest {
    public let input: Rune
    public let output: Bool
    public init(input: Rune, output: Bool) {
        this.input = input
        this.output = output
    }
}

let isNeutralWidthTests: Array<isNeutralWidthTest> = [
    isNeutralWidthTest(r'→', false),
    isNeutralWidthTest(r'┊', false),
    isNeutralWidthTest(r'┈', false),
    isNeutralWidthTest(r'～', false),
    isNeutralWidthTest(r'└', false),
    isNeutralWidthTest(r'⣀', true),
    isNeutralWidthTest(r'⣀', true)
]

class EmojiTest {
    public let input: String
    public let want: Int64
    public init(input: String, want: Int64) {
        this.input = input
        this.want = want
    }
}

let emojiTests: Array<EmojiTest> = [
    EmojiTest("✌🏿", 2),
    EmojiTest("👩\u{200d}", 2),
    EmojiTest("👩\u{200d}🍳", 2),
    EmojiTest("\u{200d}🍳", 2),
    EmojiTest("👨\u{200d}👨", 2),
    EmojiTest("👨\u{200d}👨\u{200d}👧", 2),
    // {"\u{200d}🌈", 1},
    EmojiTest("あ👩\u{200d}🍳い", 6),
    EmojiTest("あ\u{200d}🍳い", 6),
    EmojiTest("あ\u{200d}い", 4),
    EmojiTest("สวัสดี", 4)
]

@Test
public class RuneWidthTest {
    @TestCase
    func testRuneWidth() {
        let c = Condition()
        c.eastAsianWidth = false
        for (tt in runewidthtests) {
            @Expect(c.runeWidth(tt.input), tt.output)
        }
        c.eastAsianWidth = true
        for (tt in runewidthtests) {
            @Expect(c.runeWidth(tt.input), tt.eaout)
        }
        c.strictEmojiNeutral = false
        for (tt in runewidthtests) {
            @Expect(c.runeWidth(tt.input), tt.nseout)
        }
    }

    @TestCase
    func testIsAmbiguousWidth() {
        for (tt in isAmbiguousWidthTests) {
            @Expect(isAmbiguousWidth(tt.input), tt.output)
        }
    }

    @TestCase
    func testStringWidth() {
        let c = Condition()
        c.eastAsianWidth = false
        for (tt in stringWidthTests) {
            @Expect(c.stringWidth(tt.input), tt.output)
        }
        c.eastAsianWidth = true
        for (tt in stringWidthTests) {
            @Expect(c.stringWidth(tt.input), tt.eaout)
        }
    }

    @TestCase
    func testStringWidthInvalid() {
        let s = "こんにちわ\u{0000}世界"
        @Expect(stringWidth(s), 14)
    }

    @TestCase
    func testTruncateSmaller() {
        let s = "あいうえお"
        let expected = "あいうえお"
        @Expect(truncate(s, 10, "..."), expected)
    }

    @TestCase
    func testTruncate() {
        let s = "あいうえおあいうえおえおおおおおおおおおおおおおおおおおおおおおおおおおおおおおお"
        let expected = "あいうえおあいうえおえおおおおおおおおおおおおおおおおおおおおおおおおおおお..."
        let out = truncate(s, 80, "...")
        @Expect(out, expected)
        @Expect(stringWidth(out), 79)
    }

    @TestCase
    func testTruncateFit() {
        let s = "aあいうえおあいうえおえおおおおおおおおおおおおおおおおおおおおおおおおおおおおおお"
        let expected = "aあいうえおあいうえおえおおおおおおおおおおおおおおおおおおおおおおおおおおお..."
        let out = truncate(s, 80, "...")
        @Expect(out, expected)
        @Expect(stringWidth(out), 80)
    }

    @TestCase
    func testTruncateJustFit() {
        let s = "あいうえおあいうえおえおおおおおおおおおおおおおおおおおおおおおおおおおおおおお"
        let expected = "あいうえおあいうえおえおおおおおおおおおおおおおおおおおおおおおおおおおおおおお"
        let out = truncate(s, 80, "...")
        @Expect(out, expected)
        @Expect(stringWidth(out), 80)
    }

    @TestCase
    func testWrap() {
        let s = "東京特許許可局局長はよく柿喰う客だ/東京特許許可局局長はよく柿喰う客だ\n" +
            "123456789012345678901234567890\n" + "\n" + "END"
        let expected = "東京特許許可局局長はよく柿喰う\n" + "客だ/東京特許許可局局長はよく\n" + "柿喰う客だ\n" +
            "123456789012345678901234567890\n" + "\n" + "END"
        @Expect(wrap(s, 30), expected)
    }

    @TestCase
    func testTruncateNoNeeded() {
        let s = "あいうえおあい"
        let expected = "あいうえおあい"
        @Expect(truncate(s, 80, "..."), expected)
    }

    @TestCase
    func testTruncateLeft() {
        for (tt in truncateLeftTests) {
            @Expect(truncateLeft(tt.s, tt.w, tt.prefix), tt.out)
        }
    }

    @TestCase
    func testIsNeutralWidth() {
        for (tt in isNeutralWidthTests) {
            @Expect(isNeutralWidth(tt.input), tt.output)
        }
    }

    @TestCase
    func testFillLeft() {
        let s = "あxいうえお"
        let expected = "    あxいうえお"
        @Expect(fillLeft(s,15),expected)
    }

    @TestCase
    func testFillLeftFit() {
        let s = "あいうえお"
        let expected = "あいうえお"
        @Expect(fillLeft(s,10),expected)
    }

    @TestCase
    func testFillRight() {
        let s = "あxいうえお"
        let expected = "あxいうえお    "
        @Expect(fillRight(s,15),expected)
    }

    @TestCase
    func testFillRightFit() {
        let s = "あいうえお"
        let expected = "あいうえお"
        @Expect(fillRight(s,10),expected)
    }

    @TestCase
    func TestEnv() {
        if (let Some(old) <- os.getEnv("RUNEWIDTH_EASTASIAN")) {
            os.setEnv("RUNEWIDTH_EASTASIAN", old)
        }
        // defer os.Setenv("RUNEWIDTH_EASTASIAN", old)
        os.setEnv("RUNEWIDTH_EASTASIAN", "0")
        handleEnv()
        @Expect(runeWidth(r'|'), 1)
    }

    @TestCase
    func testZeroWidthJoiner() {
        let c = Condition()
        c.eastAsianWidth = true
        c.strictEmojiNeutral = false
        for (t in emojiTests) {
            @Expect(c.stringWidth(t.input), t.want)
        }
    }
}
