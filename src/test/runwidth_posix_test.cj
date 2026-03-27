package tabulate4cj.test

import tabulate4cj.runewidth.*
import std.collection.*
import std.env.*
import std.unittest.*
import std.unittest.testmacro.*

@When[os == "Linux"]
class envVars {
    public envVars(
        public var lang!: String,
        public var lcall!: String,
        public var lcctype!: String
    ) {
        this.lang = lang
        this.lcall = lcall
        this.lcctype = lcctype
    }
}

@When[os == "Linux"]
func saveEnv(): envVars {
    return envVars(
        lang: getVariable("LANG") ?? "",
        lcall: getVariable("LC_ALL") ?? "",
        lcctype: getVariable("LC_CTYPE") ?? ""
    )
}

@When[os == "Linux"]
func restoreEnv(env: envVars) {
    setVariable("LANG", env.lang)
    setVariable("LC_ALL", env.lcall)
    setVariable("LC_CTYPE", env.lcctype)
}

@When[os == "Linux"]
@Test
class TestRunewidthPosix {
    @TestCase
    func testIsEastAsian() {
        let testcases = HashMap<String, Bool>(
            ("foo@cjk_narrow", false),
            ("foo@cjk", false),
            ("utf-8@cjk", false),
            ("ja_JP.CP932", true),
        )

        for (tt in testcases) {
            let got = isEastAsianLinux(tt[0])
            @Expect(got, tt[1])
        }
    }

    @TestCase
    func testIsEastAsianLCCTYPE() {
        let env = saveEnv()
        restoreEnv(env)
        setVariable("LC_ALL", "")

        let testcases = HashMap<String, Bool>(
            ("ja_JP.UTF-8", true),
            ("C", false),
            ("POSIX", false),
            ("en_US.UTF-8", false),
        )

        for (tt in testcases) {
            setVariable("LC_CTYPE", tt[0])
            let got = isEastAsian()
            @Expect(got, tt[1])
        }
    }

    @TestCase
    func testIsEastAsianLang() {
        let env = saveEnv()
        restoreEnv(env)
        setVariable("LC_ALL", "")
        setVariable("LC_CTYPE", "")
        let testcases = HashMap<String, Bool>(
            ("ja_JP.UTF-8", true),
            ("C", false),
            ("POSIX", false),
            ("en_US.UTF-8", false),
            ("C.UTF-8", false)
        )
        for (tt in testcases) {
            setVariable("LANG", tt[0])
            let got = isEastAsian()
            @Assert(got, tt[1])
        }
    }
}
