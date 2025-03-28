package tabulate4cj.test

import tabulate4cj.tabulate.*
import std.fs.*
import std.collection.*
import std.format.*
import std.unittest.*
import std.unittest.testmacro.*

class TestCase <: ToString {
    public TestCase(
        private var name: String,
        private var age: Int64,
        private var score: Float64
    ) {
        this.name = name
        this.age = age
        this.score = score
    }
    public func toString(): String {
        return "name:${name},age:${age},score:${score}"
    }
}

let TESTFILE_PATH = "_tests"
let HEADERS = ["Header 1", "Header 2", "Header 3", "Header 4", "Header 5"]
let INT64_ARRAY: Array<Int64> = [-9223, -500, 0, 1000, 9223372]
let INT32_ARRAY: Array<Int32> = [-2183648, -1, 0, 12345, 214647]
let FLOAT64_ARRAY: Array<Float64> = [10.01, -123.456789, 200.123456789012, 1e15, 0.00000012345]
let FLOAT32_ARRAY: Array<Float32> = [13.01, -23.35, 98765.43, 0.1234567, 1.2345e10]
let FLOAT16_ARRAY: Array<Float16> = [19.01, -93.15, 1500.5, 0.0123, 3.14]
let MIX_ARRAY: Array<ToString> = [129.1, 100, "ahahahstr", TestCase("李华", 20, 3.99)]
let STRING_ARRAY = ["test string", "test string 2", "test", "row", "bndr"]
let EMPTY_ARRAY = ["4th element empty", "4th element empty", "4th element empty"]

// func writeToFile(path: String, content: String) {
//     let filePath: Path = Path(TESTFILE_PATH).join(Path(path))
//     if (File.exists(filePath)) {
//         File.delete(filePath)
//     }
//     var file: File = File(filePath, OpenOption.Create(false))
//     let bytes: Array<Byte> = content.toArray()
//     file.write(bytes)
//     file.close()
// }

@Test
public class TestTabulate {
    // Test Setters
    @TestCase
    func testSetFormat() {
        let testcase = [FLOAT64_ARRAY, FLOAT64_ARRAY, FLOAT64_ARRAY]
        let tabulate = create(testcase)
        tabulate.setHeaders(HEADERS)
        // writeToFile("table_float", tabulate.render(format: "grid"))
        @Expect(tabulate.render(format:"grid"), readTable("table_float"))
    }

    // Test Align Left, Align Right, Align Center
    @TestCase
    func testPads() {
        let tabulate = create([FLOAT64_ARRAY, FLOAT64_ARRAY, FLOAT64_ARRAY])
        tabulate.setHeaders(HEADERS)
        tabulate.setAlign("left")
        // writeToFile("table_float_right_pad", tabulate.render(format: "grid"))
        @Expect(tabulate.render(format:"grid"), readTable("table_float_right_pad"))
        tabulate.setAlign("right")
        // writeToFile("table_float", tabulate.render(format: "grid"))
        @Expect(tabulate.render(format:"grid"), readTable("table_float"))
        tabulate.setAlign("center")
        // writeToFile("table_float_center_pad", tabulate.render(format: "grid"))
        @Expect(tabulate.render(format:"grid"), readTable("table_float_center_pad"))
    }

    @TestCase
    func testSetHeaders() {
        let tabulate = create([STRING_ARRAY])
        tabulate.setHeaders(HEADERS)
        // writeToFile("test_headers",tabulate.render(format:"simple"))
        @Expect(tabulate.render(format:"simple"), readTable("test_headers"))
    }

    @TestCase
    func testHeadersFirstRow() {
        let tabulate = create([STRING_ARRAY, STRING_ARRAY])
        // writeToFile("test_first_row", tabulate.render(format: "grid"))
        @Expect(tabulate.render(format:"grid"), readTable("test_first_row"))
    }

    @TestCase
    func testEmptyString() {
        let tabulate = create([STRING_ARRAY, EMPTY_ARRAY])
        tabulate.setHeaders(HEADERS)
        tabulate.setEmptyString("None")
        // writeToFile("test_empty_element", tabulate.render(format: "grid"))
        @Expect(tabulate.render(format:"grid"), readTable("test_empty_element"))
    }

    @TestCase
    func testSingleColumn() {
        let tabulate = create([["test"]])
        tabulate.setMaxCellSize(20)
        tabulate.setWrapStrings(true)
        // writeToFile("test_single_column", tabulate.render(format: "grid"))
        @Expect(tabulate.render(format:"grid"), readTable("test_single_column"))
    }

    // Test Simple
    @TestCase
    func testSimpleFloats32() {
        let tabulate = create([FLOAT32_ARRAY, FLOAT32_ARRAY, FLOAT32_ARRAY[..FLOAT32_ARRAY.size - 1]])
        tabulate.setHeaders(HEADERS)
        tabulate.setEmptyString("None")
        // writeToFile("simple_floats32", tabulate.render(format: "simple"))
        @Expect(tabulate.render(format:"simple"), readTable("simple_floats32"))
    }

    @TestCase
    func testSimpleFloats16() {
        let tabulate = create([FLOAT16_ARRAY, FLOAT16_ARRAY, FLOAT16_ARRAY[..FLOAT16_ARRAY.size - 1]])
        tabulate.setHeaders(HEADERS)
        tabulate.setEmptyString("None")
        // writeToFile("simple_floats16", tabulate.render(format: "simple"))
        @Expect(tabulate.render(format:"simple"), readTable("simple_floats16"))
    }

    @TestCase
    func testSimpleInts32() {
        let tabulate = create([INT32_ARRAY, INT32_ARRAY, INT32_ARRAY[..INT32_ARRAY.size - 1]])
        tabulate.setHeaders(HEADERS)
        tabulate.setEmptyString("None")
        // writeToFile("simple_ints", tabulate.render(format: "simple"))
        @Expect(tabulate.render(format:"simple"), readTable("simple_ints"))
    }

    @TestCase
    func testSimpleInts64() {
        let tabulate = create([INT64_ARRAY, INT64_ARRAY, INT64_ARRAY[..INT64_ARRAY.size - 1]])
        tabulate.setHeaders(HEADERS)
        tabulate.setEmptyString("None")
        // writeToFile("simple_ints64", tabulate.render(format: "simple"))
        @Expect(tabulate.render(format:"simple"), readTable("simple_ints64"))
    }

    @TestCase
    func testSimpleString() {
        let tabulate = create([STRING_ARRAY, STRING_ARRAY, EMPTY_ARRAY])
        tabulate.setHeaders(HEADERS)
        tabulate.setEmptyString("None")
        // writeToFile("simple_strings", tabulate.render(format: "simple"))
        @Expect(tabulate.render(format:"simple"), readTable("simple_strings"))
    }

    // Test Grid
    @TestCase
    func testGridFloats() {
        let tabulate = create([FLOAT64_ARRAY, FLOAT64_ARRAY, FLOAT64_ARRAY[..FLOAT64_ARRAY.size - 1]])
        tabulate.setHeaders(HEADERS)
        tabulate.setEmptyString("None")
        // writeToFile("grid_floats", tabulate.render(format: "grid"))
        @Expect(tabulate.render(format:"grid"), readTable("grid_floats"))
    }

    @TestCase
    func testGridInts32() {
        let tabulate = create([INT32_ARRAY, INT32_ARRAY, INT32_ARRAY[..INT32_ARRAY.size - 1]])
        tabulate.setHeaders(HEADERS)
        tabulate.setEmptyString("None")
        // writeToFile("grid_ints", tabulate.render(format: "grid"))
        @Expect(tabulate.render(format:"grid"), readTable("grid_ints"))
    }

    @TestCase
    func testGridInts64() {
        let tabulate = create([INT64_ARRAY, INT64_ARRAY, INT64_ARRAY[..INT64_ARRAY.size - 1]])
        tabulate.setHeaders(HEADERS)
        tabulate.setEmptyString("None")
        // writeToFile("grid_ints64", tabulate.render(format: "grid"))
        @Expect(tabulate.render(format:"grid"), readTable("grid_ints64"))
    }

    @TestCase
    func testGridString() {
        let tabulate = create([STRING_ARRAY, STRING_ARRAY, EMPTY_ARRAY])
        tabulate.setHeaders(HEADERS)
        tabulate.setEmptyString("None")
        // writeToFile("grid_strings", tabulate.render(format: "grid"))
        @Expect(tabulate.render(format:"grid"), readTable("grid_strings"))
    }

    @TestCase
    func testPaddedHeader() {
        let tabulate = create([STRING_ARRAY, STRING_ARRAY, EMPTY_ARRAY])
        tabulate.setHeaders(["Header 1", "header 2", "header 3", "header 4"])
        tabulate.setEmptyString("None")
        // writeToFile("test_padded_headers", tabulate.render(format: "grid"))
        @Expect(tabulate.render(format:"grid"), readTable("test_padded_headers"))
    }

    @TestCase
    func testHideLineBelowHeader() {
        let tabulate = create([STRING_ARRAY, STRING_ARRAY, EMPTY_ARRAY])
        tabulate.setHeaders(["Header 1", "header 2", "header 3", "header 4"])
        tabulate.setHideLines(["belowheader"])
        // writeToFile("test_hide_lines", tabulate.render(format: "grid"))
        @Expect(tabulate.render(format:"grid"), readTable("test_hide_lines"))
    }

    @TestCase
    func testWrapCells() {
        let tabulate = create(
            [
                ["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus laoreet vestibulum pretium. Nulla et ornare elit. Cum sociis natoque penatibus et magnis",
                    "Vivamus laoreet vestibulum pretium. Nulla et ornare elit. Cum sociis natoque penatibus et magnis",
                    "zzLorem ipsum", " test", "test"],
                ["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus laoreet vestibulum pretium. Nulla et ornare elit. Cum sociis natoque penatibus et magnis",
                    "Vivamus laoreet vestibulum pretium. Nulla et ornare elit. Cum sociis natoque penatibus et magnis",
                    "zzLorem ipsum", " test", "test"],
                STRING_ARRAY,
                ["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus laoreet vestibulum pretium. Nulla et ornare elit. Cum sociis natoque penatibus et magnis",
                    "Vivamus laoreet vestibulum pretium. Nulla et ornare elit. Cum sociis natoque penatibus et magnis",
                    "zzLorem ipsum", " test", "test"],
                STRING_ARRAY
            ]
        )
        tabulate.setHeaders(["Header 1", "header 2", "header 3", "header 4"])
        tabulate.setMaxCellSize(16)
        tabulate.setWrapStrings(true)
        // writeToFile("test_string_wrap_grid", tabulate.render(format: "grid"))
        @Expect(tabulate.render(format:"grid"), readTable("test_string_wrap_grid"))
    }

    @TestCase
    func testWrapCellsSimple() {
        let tabulate = create(
            [
                ["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus laoreet vestibulum pretium. Nulla et ornare elit. Cum sociis natoque penatibus et magnis",
                    "Vivamus laoreet vestibulum pretium. Nulla et ornare elit. Cum sociis natoque penatibus et magnis",
                    "zzLorem ipsum", " test", "test"],
                ["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus laoreet vestibulum pretium. Nulla et ornare elit. Cum sociis natoque penatibus et magnis",
                    "Vivamus laoreet vestibulum pretium. Nulla et ornare elit. Cum sociis natoque penatibus et magnis",
                    "zzLorem ipsum", " test", "test"],
                STRING_ARRAY,
                ["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus laoreet vestibulum pretium. Nulla et ornare elit. Cum sociis natoque penatibus et magnis",
                    "Vivamus laoreet vestibulum pretium. Nulla et ornare elit. Cum sociis natoque penatibus et magnis",
                    "zzLorem ipsum", " test", "test"],
                STRING_ARRAY
            ]
        )
        tabulate.setHeaders(["Header 1", "header 2", "header 3", "header 4"])
        tabulate.setMaxCellSize(16)
        tabulate.setWrapStrings(true)
        // writeToFile("test_string_wrap_simple", tabulate.render(format: "simple"))
        @Expect(tabulate.render(format:"simple"), readTable("test_string_wrap_simple"))
    }

    @TestCase
    func testMultiByteString() {
        let tabulate = create([["朝", "おはようございます"], ["昼", "こんにちわ"], ["夜", "こんばんわ"]])
        tabulate.setHeaders(["時間帯", "挨拶"])
        tabulate.setMaxCellSize(10)
        tabulate.setWrapStrings(true)
        // writeToFile("test_multibyte_string", tabulate.render(format: "grid"))
        @Expect(tabulate.render(format:"grid"), readTable("test_multibyte_string"))
    }

    @TestCase
    func testSplitCell() {
        let tab = create(
            [
                ["header", "value"],
                ["test1",
                    "This is a really long string, yaaaay it works, Vivamus laoreet vestibulum pretium. Nulla et ornare elit. Cum sociis natoque penatibus et magnis Vivamus laoreet vestibulum pretium. Nulla et ornare elit. Cum sociis natoque penatibus et magnis"],
                ["test2",
                    "AAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCCCCCCCCCEEEEEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDd"]
            ]
        )
        tab.setMaxCellSize(20)
        tab.setWrapStrings(true)
        tab.setWrapDelimiter(r' ')
        tab.setSplitConcat("-")
        // writeToFile("smart_wrap", tab.render(format: "grid"))
        @Expect(tab.render(format:"grid"), readTable("smart_wrap"))
    }

    @TestCase
    func testTitlesGrid() {
        let tabulate = create([STRING_ARRAY, STRING_ARRAY, EMPTY_ARRAY])
        tabulate.setTitle("Title One", align: "center")
        tabulate.setHeaders(HEADERS)
        tabulate.setEmptyString("None")
        // writeToFile("grid_strings_titled", tabulate.render(format: "grid"))
        @Expect(tabulate.render(format:"grid"), readTable("grid_strings_titled"))
    }

    @TestCase
    func testTitlesPlain() {
        let tabulate = create([STRING_ARRAY, STRING_ARRAY, EMPTY_ARRAY])
        tabulate.setTitle("Make Titles Great Again", align: "left")
        tabulate.setHeaders(HEADERS)
        tabulate.setEmptyString("None")
        // writeToFile("plain_strings_titled", tabulate.render(format: "plain"))
        @Expect(tabulate.render(format:"plain"), readTable("plain_strings_titled"))
    }

    @TestCase
    func testTitlesSimple() {
        let tabulate = create([STRING_ARRAY, STRING_ARRAY, EMPTY_ARRAY])
        tabulate.setTitle("Simple Title", align: "right")
        tabulate.setHeaders(HEADERS)
        tabulate.setEmptyString("None")
        // writeToFile("simple_strings_titled", tabulate.render(format: "simple"))
        @Expect(tabulate.render(format:"simple"), readTable("simple_strings_titled"))
    }

    @TestCase
    func testMixDataToStringSimple() {
        let collection = ArrayList<ToString>(MIX_ARRAY)
        let tabulate = create([collection.toArray(), collection.toArray()])
        tabulate.setTitle("Student Info", align: "right")
        tabulate.setHeaders(HEADERS)
        tabulate.setEmptyString("None")
        // writeToFile("mix_data_simple", tabulate.render(format: "simple"))
        @Expect(tabulate.render(format:"simple"), readTable("mix_data_simple"))
    }

    @TestCase
    func testHashMapToStringGrid() {
        let testMap = HashMap<String, Array<ToString>>(
            ("time", ["11:00", 1923718, "190", "ttc"]),
            ("student", [TestCase("张三", 20, 3.99), TestCase("李华", 20, 3.99), TestCase("李华", 20, 3.9)])
        )
        let tabulate = create(testMap)
        // tabulate.setTitle("Student Info", align: "center")
        tabulate.setHeaders(HEADERS)
        tabulate.setEmptyString("None")
        // writeToFile("mix_hashmap_simple", tabulate.render(format: "grid"))
        @Expect(tabulate.render(format:"grid"), readTable("mix_hashmap_simple"))
    }

    @TestCase
    func testHashMapFormatterGrid() {
        let testMap = HashMap<String, Array<Float64>>(
            ("id", [178.1, 72.322, 337.3]),
            ("price", [1.321, 22.332, 3.353]),
            ("num", [12.1, 222.2, 32.3])
        )
        let tabulate = create(testMap)
        tabulate.setTitle("Student Info", align: "center")
        tabulate.setEmptyString("None")
        // writeToFile("formatter_hashmap_simple", tabulate.render(format: "grid"))
        @Expect(tabulate.render(format:"grid"), readTable("formatter_hashmap_simple"))
    }

    @TestCase
    func testDenseMode() {
        let tabulate = create([STRING_ARRAY, STRING_ARRAY, EMPTY_ARRAY])
        tabulate.setTitle("Student Info", align: "center")
        tabulate.setDenseMode()
        tabulate.setEmptyString("None")
        // writeToFile("test_densemode_grid", tabulate.render(format: "grid"))
        @Expect(tabulate.render(format:"grid"), readTable("densemode_grid"))
    }

    @TestCase
    func testNoneData() {
        let arr = Array<String>()
        let tabulate = create(arr)
        tabulate.setTitle("Student Info", align: "center")
        tabulate.setEmptyString("None")
        @ExpectThrows[Exception](tabulate.render())
    }
    
    @TestCase
    func testNoneHashMapData() {
        let map = HashMap<String, Array<String>>()
        @ExpectThrows[Exception](create(map))
    }
}
