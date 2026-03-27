package tabulate4cj.tabulate

import tabulate4cj.utf8.*
import tabulate4cj.runewidth.*
import std.collection.*
import std.io.*
import std.math.*
import std.convert.*

/**
表格样式
 */
public class TableFormat {
    public TableFormat(
        public var lineTop!: Line = Line(),
        public var lineBelowHeader!: Line = Line(),
        public var lineBetweenRows!: Line = Line(),
        public var lineBottom!: Line = Line(),
        public var headerRow!: Row = Row(),
        public var dataRow!: Row = Row(),
        public var titleRow!: Row = Row(),
        public var padding!: Int64 = 1,
        public var headerHide!: Bool = true,
        public var fitScreen!: Bool = true
    ) {
        this.lineTop = lineTop
        this.lineBelowHeader = lineBelowHeader
        this.lineBetweenRows = lineBetweenRows
        this.lineBottom = lineBottom
        this.headerRow = headerRow
        this.dataRow = dataRow
        this.titleRow = titleRow
        this.padding = padding
        this.headerHide = headerHide
        this.fitScreen = fitScreen
    }
}
/**
   定义行样式
 */
public class Line {
    public Line(
        public var begin: String,
        public var hline: String,
        public var sep: String,
        public var end: String
    ) {
        this.begin = begin
        this.hline = hline
        this.sep = sep
        this.end = end
    }

    public init() {
        this("", "", "", "")
    }
}
/**
   定义列样式
 */
public class Row {
    public Row(
        public var begin: String,
        public var sep: String,
        public var end: String
    ) {
        this.begin = begin
        this.sep = sep
        this.end = end
    }

    public init() {
        this("", "", "")
    }
}
/**
    预设样式
 */
var TableFormats = HashMap<String, TableFormat>(
    ("simple", TableFormat(
            lineTop: Line("", "-", "  ", ""),
            lineBelowHeader: Line("", "-", "  ", ""),
            lineBottom: Line("", "-", "  ", ""),
            headerRow: Row("", "  ", ""),
            dataRow: Row("", "  ", ""),
            titleRow: Row("", "  ", ""),
            padding: 1
        )),
    ("plain", TableFormat(
            headerRow: Row("", "  ", ""),
            dataRow: Row("", "  ", ""),
            titleRow: Row("", "  ", ""),
            padding: 1
        )),
    ("grid", TableFormat(
            lineTop: Line("+", "-", "+", "+"),
            lineBelowHeader: Line("+", "=", "+", "+"),
            lineBetweenRows: Line("+", "-", "+", "+"),
            lineBottom: Line("+", "-", "+", "+"),
            headerRow: Row("|", "|", "|"),
            dataRow: Row("|", "|", "|"),
            titleRow: Row("|", " ", "|"),
            padding: 1
        )),
)
// Minimum padding that will be applied
const MIN_PADDING = 5
/**
   对齐方式泛型
   左对齐，居中，右对齐
 */
// const left = "left"
// const center = "center"
// const right = "right"

public class TabulateRow {
    public let elements: Array<String>

    public var continuos: Bool = false

    public init(elements: Array<String>) {
        this.elements = elements
    }
}
/**
    写入缓冲工具
 */
public class WriteBuffer {
    private let buffer: StringBuilder

    public WriteBuffer() {
        buffer = StringBuilder()
    }

    public func write(str: String, count: Int64) {
        for (_ in 0..count) {
            buffer.append(str)
        }
    }

    public func getString(): String {
        return buffer.toString()
    }
}

public class Tabulate {
    public var data: Array<TabulateRow> = []
    public var headers: Array<String> = []
    private var condition: Option<Condition> = None
    private var title: String = ""
    private var titleAlign: String = "left"
    private var tableFormat: TableFormat = TableFormat()
    private var align: String = "right"
    private var emptyVar: String = ""
    private var hideLines: Array<String> = []
    private var maxSize: Int64 = 30
    private var wrapStrings: Bool = false
    private var wrapDelimiter: Rune = r'\u{0}'
    private var splitConcat: String = ""
    private var denseMode: Bool = false

    public init() {}

    // Add padding to each cell
    private func padRow(arr: Array<String>, padding: Int64): Array<String> {
        if (arr.size < 1) {
            return arr
        }
        let padded = ArrayList<String>(arr.size)
        for (el in arr) {
            let b = WriteBuffer()
            b.write(" ", padding)
            b.write(el, 1)
            b.write(" ", padding)
            padded.add(b.getString())
        }

        return padded.toArray()
    }

    // Align right (Add padding left)
    private func padLeft(width: Int64, str: String): String {
        let b = WriteBuffer()
        b.write(" ", (width - stringWidthByCondition(str)))
        b.write(str, 1)
        return b.getString()
    }

    // Align Left (Add padding right)
    private func padRight(width: Int64, str: String): String {
        let b = WriteBuffer()
        b.write(str, 1)
        b.write(" ", (width - stringWidthByCondition(str)))
        return b.getString()
    }

    // Center the element in the cell
    private func padCenter(width: Int64, str: String): String {
        let b = WriteBuffer()
        let padding = Int64(ceil(Float64(width - stringWidthByCondition(str)) / 2.0))

        b.write(" ", padding)
        b.write(str, 1)
        let paddingDownSide = width - stringWidthByCondition(b.getString())
        b.write(" ", paddingDownSide)

        return b.getString()
    }

    // Build Line based on padded_widths from t.GetWidths()
    private func buildLine(paddedWidths: Array<Int64>, padding: Array<Int64>, l: Line): String {
        let cells = ArrayList<String>(paddedWidths.size)

        for (i in 0..paddedWidths.size) {
            let b = WriteBuffer()
            b.write(l.hline, padding[i] + MIN_PADDING)
            cells.add(b.getString())
        }
        let buffer = StringBuilder()
        buffer.append(l.begin)

        // Print contents
        for (i in 0..paddedWidths.size) {
            buffer.append(cells[i])
            if (i != cells.size - 1) {
                buffer.append(l.sep)
            }
        }

        buffer.append(l.end)

        return buffer.toString()
    }

    // Build Row based on padded_widths from t.GetWidths()
    // 原方法中参数为:
    // elements: Array<String>, paddedWidths: Array<Int64>, paddings: Array<Int64>, d: Row
    // 但是其中的padding从未被使用过(疑似是想跟buildLine方法参数列表统一)
    // 由于仓颉不好使用NULL,所以这里把这个没有使用的参数去除了
    private func buildRow(elements: Array<String>, paddedWidths: Array<Int64>, d: Row): String {
        let buffer = StringBuilder()
        buffer.append(d.begin)
        let padFunc = getAlignFunc()
        // Print contents
        for (i in 0..paddedWidths.size) {
            var output = ""
            if (elements.size <= i || (elements.size > i && elements[i] == "")) {
                output = padFunc(paddedWidths[i], this.emptyVar)
            } else if (elements.size > i) {
                output = padFunc(paddedWidths[i], elements[i])
            }
            buffer.append(output)
            if (i != paddedWidths.size - 1) {
                buffer.append(d.sep)
            }
        }

        buffer.append(d.end)

        return buffer.toString()
    }

    //SetWrapDelimiter assigns the character ina  string that the rednderer
    //will attempt to split strings on when a cell must be wrapped
    public func setWrapDelimiter(r: Rune) {
        this.wrapDelimiter = r
    }

    //SetSplitConcat assigns the character that will be used when a WrapDelimiter is
    //set but the renderer cannot abide by the desired split.  This may happen when
    //the WrapDelimiter is a space ' ' but a single word is longer than the width of a cell
    public func setSplitConcat(r: String) {
        this.splitConcat = r
    }

    // format需要从grid,plain,simple中进行三选一
    public func render(format!: String = "simple"): String {
        let lines = ArrayList<String>()

        // If headers are set use them, otherwise pop the first row
        if (this.headers.size < 1 && this.data.size > 1) {
            this.headers = this.data[0].elements
            this.data = this.data[1..]
        }

        // Use the format that was passed as parameter, otherwise
        // use the format defined in the struct
        if (let Some(f) <- TableFormats.get(format)) {
            this.tableFormat = f
        }

        // If Wrap Strings is set to True,then break up the string to multiple cells
        if (this.wrapStrings) {
            this.data = this.wrapCellData()
        }

        // Check if Data is present
        if (this.data.size < 1) {
            // 源代码为返回空字符串
            throw Exception("data is null")
        }

        // 如果表头长度比数据长度小，那么前diff个元素置为空
        // 此处与原代码有区别,是因为go中make出的字符串数组,默认前几个为"",append时会自动追加长度
        // 但是cangjie中的数组初始化后append时是从0开始
        if (this.headers.size < this.data[0].elements.size) {
            let diff: Int64 = this.data[0].elements.size - this.headers.size
            let paddedHeader = ArrayList<String>(this.data[0].elements.size)
            for (_ in 0..diff) {
                paddedHeader.add("")
            }
            for (e in this.headers) {
                paddedHeader.add(e)
            }
            this.headers = paddedHeader.toArray()
        }

        // Get Column widths for all columns
        let cols = this.getWidth(this.headers, this.data)

        let paddedWidths = ArrayList<Int64>(cols.size)
        for (i in 0..cols.size) {
            paddedWidths.add(cols[i] + MIN_PADDING * this.tableFormat.padding)
        }

        // Calculate total width of the table
        var totalWidth = this.tableFormat.dataRow.sep.size * (cols.size - 1) // Include all but the final separator
        for (w in paddedWidths) {
            totalWidth += w
        }

        // Start appending lines
        if (this.title.size > 1) {
            if (!inSlice("aboveTitle", this.hideLines)) {
                lines.add(this.buildLine(paddedWidths.toArray(), cols, this.tableFormat.lineTop))
            }
            let savedAlign = this.align
            if (this.titleAlign.size > 0) {
                this.setAlign(this.titleAlign) // Temporary replace alignment with the title alignment
            }
            lines.add(this.buildRow([this.title], [totalWidth], this.tableFormat.titleRow))
            this.setAlign(savedAlign)
        }

        // Append top line if not hidden
        if (!inSlice("top", this.hideLines)) {
            lines.add(this.buildLine(paddedWidths.toArray(), cols, this.tableFormat.lineTop))
        }

        // Add Header
        lines.add(
            this.buildRow(this.padRow(this.headers, this.tableFormat.padding).toArray(), paddedWidths.toArray(),
                this.tableFormat.headerRow))

        // Add Line Below Header if not hidden
        if (!inSlice("belowheader", this.hideLines)) {
            lines.add(this.buildLine(paddedWidths.toArray(), cols, this.tableFormat.lineBelowHeader))
        }

        // Add Data Rows
        var index = 0
        for (element in this.data) {
            lines.add(
                this.buildRow(this.padRow(element.elements, this.tableFormat.padding), paddedWidths.toArray(),
                    this.tableFormat.dataRow))
            if (!this.denseMode && index < this.data.size - 1) {
                if (element.continuos != true && !inSlice("betweenLine", this.hideLines)) {
                    lines.add(this.buildLine(paddedWidths.toArray(), cols, this.tableFormat.lineBetweenRows))
                }
            }
            index++
        }
        // Add Line Below Header if not hidden
        if (!inSlice("bottomLine", this.hideLines)) {
            lines.add(this.buildLine(paddedWidths.toArray(), cols, this.tableFormat.lineBottom))
        }
        // Join lines

        let buffer = StringBuilder()

        for (line in lines) {
            buffer.append(line + "\n")
        }

        return buffer.toString()
    }

    // Calculate the max column width for each element
    private func getWidth(headers: Array<String>, data: Array<TabulateRow>): Array<Int64> {
        let widths = ArrayList<Int64>(headers.size, {_: Int64 => 0})
        var currentMax = this.emptyVar.size
        for (i in 0..headers.size) {
            currentMax = max(stringWidthByCondition(headers[i]), this.emptyVar.size)
            for (item in data) {
                if (item.elements.size > i && widths.size > i) {
                    let element = item.elements[i]
                    let strLength = stringWidthByCondition(element)
                    // 根据数据宽度更新最大列宽
                    if (strLength > currentMax) {
                        widths[i] = strLength
                        currentMax = strLength
                    } else {
                        widths[i] = currentMax
                    }
                } else if (widths.size > i) {
                    widths[i] = currentMax
                }
            }
        }
        return widths.toArray()
    }

    // SetTitle sets the title of the table can also accept a second string to define an alignment for the title
    public func setTitle(title: String, align!: String = "left"): Tabulate {
        this.title = title
        this.titleAlign = align
        return this
    }

    // Set Headers of the table
    // If Headers count is less than the data row count, the headers will be padded to the right
    public func setHeaders(headers: Array<String>): Tabulate {
        this.headers = headers
        return this
    }

    // Set Float Formatting
    // will be used in strconv.FormatFloat(element, format, -1, 64)
    // public func setFloatFormat(format: Byte): Tabulate {
    //     this.floatFormat = format
    //     return this
    // }

    // Set Align Type, Available options: left, right, center
    public func setAlign(align: String) {
        this.align = align
    }

    // Select the padding function based on the align type
    public func getAlignFunc(): (Int64, String) -> String {
        if (this.align.size < 1 || this.align == "right") {
            return this.padLeft
        } else if (this.align == "left") {
            return this.padRight
        } else {
            return this.padCenter
        }
    }

    // Set how an empty cell will be represented
    public func setEmptyString(empty: String) {
        this.emptyVar = empty + " "
    }

    // Set which lines to hide.
    // Can be:
    // top - Top line of the table,
    // belowheader - Line below the header,
    // bottomLine - Bottom line of the table
    // betweenLine - Between line of the table
    public func setHideLines(hide: Array<String>) {
        this.hideLines = hide
    }

    public func setWrapStrings(wrap: Bool) {
        this.wrapStrings = wrap
    }

    // Sets the maximum size of cell
    // If WrapStrings is set to true, then the string inside
    // the cell will be split up into multiple cell
    public func setMaxCellSize(max: Int64) {
        this.maxSize = max
    }

    // Sets dense mode
    // Under dense mode, no space line between rows
    public func setDenseMode() {
        this.denseMode = true
    }

    public func setSelfCondition(eastAsianWidth: Bool, strictEmojiNeutral: Bool) {
        this.condition = Condition(eastAsianWidth, strictEmojiNeutral)
    }

    private func stringWidthByCondition(str: String): Int64 {
        if (!this.condition.isNone()) {
            return this.condition.getOrThrow().stringWidth(str)
        } else {
            return stringWidth(str)
        }
    }

    private func truncateByCondition(s: String, w: Int64, tail: String): String {
        if (!this.condition.isNone()) {
            return this.condition.getOrThrow().truncate(s, w, tail)
        } else {
            return truncate(s, w, tail)
        }
    }

    private func splitElement(e: String): (Bool, String) {
        //check if we are not attempting to smartly wrap
        if (this.wrapDelimiter == Rune(0)) {
            if (this.splitConcat == "") {
                return (false, truncateByCondition(e, this.maxSize, ""))
            } else {
                return (false, truncateByCondition(e, this.maxSize, this.splitConcat))
            }
        }
        //we are attempting to wrap
        //grab the current width
        var i = this.maxSize
        while (i > 1) {
            //loop through our proposed truncation size looking for one that ends on
            //our requested delimiter
            let x = truncateByCondition(e, i, "")
            //check if the NEXT string is a
            //delimiter, if it IS, then we truncate and tell the caller to shrink
            let (r, _) = decodeRuneInString(decodeStringToBytesArray(e[i..]))
            if (r == Rune(0) || r == Rune(1)) {
                //decode failed, take the truncation as is
                return (false, x)
            }
            if (r == this.wrapDelimiter) {
                return (true, x) //inform the caller that they can remove the next rune
            }
            i--
        }
        //didn't find a good length, truncate at will
        if (this.splitConcat != "") {
            return (false, truncateByCondition(e, this.maxSize, this.splitConcat))
        }
        return (false, truncateByCondition(e, this.maxSize, ""))
    }

    // If string size is larger than t.MaxSize, then split it to multiple cells (downwards)
    func wrapCellData(): Array<TabulateRow> {
        var arr = ArrayList<TabulateRow>()
        var cleanSplit: Bool = false
        var addr: Int64 = 0
        if (this.data.size == 0) {
            return arr.toArray()
        }
        var next = this.data[0]
        var index = 0
        while (index <= this.data.size) {
            let elements = next.elements
            let newElements = ArrayList<String>(elements.size, {_: Int64 => ""})

            var i = 0
            for (e in elements) {
                if (stringWidthByCondition(e) > this.maxSize) {
                    elements[i] = truncateByCondition(e, this.maxSize, "")
                    (cleanSplit, elements[i]) = this.splitElement(e)
                    if (cleanSplit) {
                        //remove the next rune
                        let (r, w) = decodeRuneInString(decodeStringToBytesArray(e[elements[i].size..]))
                        if (UInt32(r) != 0 && UInt32(r) != 1) {
                            addr = w
                        }
                    } else {
                        addr = 0
                    }
                    newElements[i] = e[(elements[i].size + addr)..]
                    next.continuos = true
                }
                i++
            }

            if (next.continuos) {
                arr.add(next)
                next = TabulateRow(newElements.toArray())
                index--
            } else if (index + 1 < this.data.size) {
                arr.add(next)
                next = this.data[index + 1]
            } else if (index >= this.data.size) {
                arr.add(next)
            }
            index++
        }
        return arr.toArray()
    }
}

interface Stringable {
    func mapToString(): String
}

class ToStringStringable <: Stringable {
    ToStringStringable(public let value: ToString) {}
    public func mapToString(): String {
        return value.toString()
    }
}

class FormatterStringable <: Stringable {
    FormatterStringable(public let value: Formattable, public let formateString: String) {}
    public func mapToString(): String {
        return value.format(formateString)
    }
}

public func create<T>(
    d: Array<Array<T>>,
    numFormat!: String = ".3"
): Tabulate {
    let t = Tabulate()

    if (d.size < 1) {
        throw Exception("data is null")
    }

    let data = d |>
        map {
        p: Array<T> => p |>
            map {
            q: T => match (q) {
                case v: Formattable => FormatterStringable(v, numFormat).mapToString()
                case v: ToString => ToStringStringable(v).mapToString()
                case _ => throw Exception("expect type is ToString OR Formattable")
            }
        } |> collectArray<String>
    } |> collectArray<Array<String>>

    t.data = createFromString(data)

    return t
}

public func create<K, V>(
    d: HashMap<K, Array<V>>,
    numFormat!: String = ".3"
): Tabulate where K <: Hashable & Equatable<K> & ToString {
    let t = Tabulate()

    if (d.size < 1) {
        throw Exception("data is null")
    }

    let data = d |>
        map {
        p: (K, Array<V>) => (p[0].toString(),
            p[1] |>
                map {
                q: V => match (q) {
                    case v: Formattable => FormatterStringable(v, numFormat).mapToString()
                    case v: ToString => ToStringStringable(v).mapToString()
                    case _ => throw Exception("expect type is Array<Array<ToString>>")
                }
            } |> collectArray<String>)
    } |> collectHashMap<String, Array<String>>

    (t.headers, t.data) = createFromHashMap(data)

    return t
}
