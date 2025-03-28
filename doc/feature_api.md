# Tabulate4cj 库

### 介绍

tabulate4cj 可以帮助你更轻松地打印出美观的文本表格，支持多种表格样式、左中右对齐、自动换行、表格标题设置等功能。同时还提供了字符串的字素迭代器和判断字符宽度的功能。

### 1 表格渲染相关API

#### 1.1 获取实例化表格类

```cangjie
/**
* 使用二维数组渲染表格并返回字符串结果
*
* @Type T 应当实现ToString或Formatter，若同时实现将会优先对齐格式化
* @param d Array<Array<T>> 表格中的数据内容
* @param numFormat! String 如果数据中有Formatter时，作为进行格式化时的参数
* @return Tabulate 返回Tabulate实体类
* @throws 当T没有实现ToString、Formatter时会抛出异常，当数据为空时会抛出异常
*/
public func create<T>(
	d: Array<Array<T>>,
	numFormat!: String = ".3"
): Tabulate

/**
* 使用HashMap渲染表格并返回字符串结果，Map中的键会作为表格的表头，键对应的值会作为该列的值
*
* @Type K 应当同时实现Hashable、Equatable和ToString
* @Type V 应当实现ToString或Formatter，若同时实现将会优先对齐格式化
* @param d Array<Array<T>> 表格中的数据内容
* @param numFormat! String 如果数据中有Formatter时，作为进行格式化时的参数
* @return Tabulate 返回Tabulate实体类
* @throws 当V没有实现ToString、Formatter时会抛出异常，当数据为空时会抛出异常
*/
public func create<K, V>(
    d: HashMap<K, Array<V>>,
    numFormat!: String = ".3"
): Tabulate where K <: Hashable & Equatable<T> & ToString
```

示例代码如下：

```cangjie
// API Demo 1
import std.collection.*
import tabulate4cj.tabulate.*

main() {
    // 使用二维数组获取Tabulate实例
    let arrData = [
        ["title1", "title2", "title3"],
        ["test string 1", "test string 2", "test string 3"],
        ["tabulate4cj", "tabulate4cj", "tabulate4cj"]
    ]
    let tabArr = create(arrData)
    println(tabArr.render(format: "grid"))
    
    // 使用HashMap获取Tabulate实例
    let mapData = HashMap<String, Array<ToString>>(
        ("ID", [1, 2, 3]),
        ("Name", ["Abernethy", "Ashbur", "Beryl"]),
        ("Float64", [1.228219, 2.222, 321.111])
    )
    let tabMap = create(mapData)
    println(tabMap.render(format: "grid"))
}
```

执行结果如下：

```
+------------------+------------------+------------------+
|           title1 |           title2 |           title3 |
+==================+==================+==================+
|    test string 1 |    test string 2 |    test string 3 |
+------------------+------------------+------------------+
|      tabulate4cj |      tabulate4cj |      tabulate4cj |
+------------------+------------------+------------------+

+--------+--------------+------------+
|     ID |         Name |    Float64 |
+========+==============+============+
|    001 |    Abernethy |      1.228 |
+--------+--------------+------------+
|    002 |       Ashbur |      2.222 |
+--------+--------------+------------+
|    003 |        Beryl |    321.111 |
+--------+--------------+------------+
```

#### 1.2 Tabulate类 成员函数接口

##### 1.2.1 Tabulate类

```cangjie
/**
* 表格类，存储了渲染一个表格的各种数据
*/
public class Tabulate {
    public var data: Array<TabulateRow> = [] // 表格数据内容
    public var headers: Array<String> = [] // 表头数据内容
    private var title: String = "" // 表格标题内容数据
    private var titleAlign: String = left // 表格标题对齐方式，默认为左对齐
    private var tableFormat: TableFormat = TableFormat() // 表格样式
    private var align: String = right // 表格数据内容对齐方式，默认为右对齐
    private var emptyVar: String = "" // 替换空单元格内容的字符串
    private var hideLines: Array<String> = [] // 设置需要隐藏的表格线
    private var maxSize: Int64 = 30 // 表格单元格最大长度，默认为30
    private var wrapStrings: Bool = false // 是否启用自动换行
    private var wrapDelimiter: Rune = r'\u{0}' // 启用换行时的换行分隔符
    private var splitConcat: String = "" // 启用换行时的换行填充符
    private var denseMode: Bool = false // 是否启动紧凑模式，移除行间空白
}
```

##### 1.2.2 渲染普通的文本表格

```cangjie
/**
* 渲染表格并返回字符串结果
*
* @param format String 表格的样式，可选grid/plain/simple，默认为simple
* @return String 返回格式化后的表格字符串
* @throws 当数据为空时会抛出异常
*/
public func render(format!: String = "simple"): String

/**
* 设置表头内容，如果没有调用该函数设置表头会默认取用数据的第一行作为表头
*
* @param headers Array<String> 表格的表头字符串数组
* @return Tabulate 返回该表格对象
*/
func setHeaders(headers: Array<String>): Tabulate

/**
* 设置表格标题及标题的对齐方式
*
* @param title String 表格标题内容
* @param align! String 表格内容对齐方式,默认为左对齐
* @return Tabulate 返回该表格对象
*/
func setTitle(title: Array<String>, align!: String = left): Tabulate

/**
* 设置空单元格的显示内容
*
* @param empty String 替换空单元格内容的字符串
*/
func setEmptyString(empty: String): Unit
```

示例代码如下：

```cangjie
// API Demo 2
import std.collection.*
import tabulate4cj.tabulate.*

main() {
    // 使用二维数组获取Tabulate实例
    let arrData = [
        ["header1", "header2", "header3"],
        ["test string 1", "test string 2", "test string 3"],
        ["tabulate4cj", "tabulate4cj", "tabulate4cj"]
    ]
    let tabArr = create(arrData)
    // 设置表格表头
    tabArr.setHeaders(["true header1", "true header2", "true header3", "empty header"])
    // 设置表格标题，并设置为居中
    tabArr.setTitle("TEST CASE TABLE", align: "center")
    // 设置空单元格显示内容
    tabArr.setEmptyString("Empty")
    println(tabArr.render(format: "grid"))
}
```

执行结果如下：

```
+------------------+------------------+------------------+-----------------+
|                              TEST CASE TABLE                             |
+------------------+------------------+------------------+-----------------+
|     true header1 |     true header2 |     true header3 |    empty header |
+==================+==================+==================+=================+
|          header1 |          header2 |          header3 |           Empty |
+------------------+------------------+------------------+-----------------+
|    test string 1 |    test string 2 |    test string 3 |           Empty |
+------------------+------------------+------------------+-----------------+
|      tabulate4cj |      tabulate4cj |      tabulate4cj |           Empty |
+------------------+------------------+------------------+-----------------+
```

##### 1.2.3 渲染左/中/右对齐表格

```cangjie
/**
* 设置数据内容的对齐方式
*
* @param align String 数据内容对齐方式,可选值：
* left（左对齐）/right（右对齐）/center（居中）
*/
func setAlign(align: String): Unit
```

示例代码如下：

```cangjie
// API Demo 3
import std.collection.*
import tabulate4cj.tabulate.*

main() {
    // 使用二维数组获取Tabulate实例
    let arrData = [
        ["title1", "title2", "title3"],
        ["test string 1", "test string 2", "test string 3"],
        ["tabulate4cj", "tabulate4cj", "tabulate4cj"]
    ]
    let tabArr = create(arrData)

    // 居中
    tabArr.setAlign("center")
    println(tabArr.render(format: "grid"))

    // 左对齐
    tabArr.setAlign("left")
    println(tabArr.render(format: "grid"))

    // 右对齐
    tabArr.setAlign("right")
    println(tabArr.render(format: "grid"))
}
```

执行结果如下：

```
+------------------+------------------+------------------+
|      title1      |      title2      |      title3      |
+==================+==================+==================+
|   test string 1  |   test string 2  |   test string 3  |
+------------------+------------------+------------------+
|    tabulate4cj   |    tabulate4cj   |    tabulate4cj   |
+------------------+------------------+------------------+

+------------------+------------------+------------------+
| title1           | title2           | title3           |
+==================+==================+==================+
| test string 1    | test string 2    | test string 3    |
+------------------+------------------+------------------+
| tabulate4cj      | tabulate4cj      | tabulate4cj      |
+------------------+------------------+------------------+

+------------------+------------------+------------------+
|           title1 |           title2 |           title3 |
+==================+==================+==================+
|    test string 1 |    test string 2 |    test string 3 |
+------------------+------------------+------------------+
|      tabulate4cj |      tabulate4cj |      tabulate4cj |
+------------------+------------------+------------------+
```

##### 1.2.4 渲染长文本智能换行表格

```cangjie
/**
* 设置单元格最大宽度，需配合自动换行使用
*
* @param max Int64 单元格最大字符数限制
*/
func setMaxCellSize(max: Int64): Unit

/**
* 设置换行分隔符，当数据字数过多，单元格需要换行时，渲染器将尝试按此字符进行分割
*
* @param r Rune 换行时按此字符进行分割
*/
func setWrapDelimiter(r: Rune): Unit

/**
* 当 WrapDelimiter 被设置了，并且根据 WrapDelimiter 分割后某单词过长，导致
* 无法进行正常分割，会使用该字符进行填补该行的空缺
*
* @param r String 用于填补换行产生的空白
*/
func setSplitConcat(r: String): Unit

/**
* 启用/禁用字符串自动换行
*
* @param wrap Bool 是否启用自动换行
*/
func setWrapStrings(wrap: Bool): Unit
```

示例代码如下：

```cangjie
// API Demo 4
import std.collection.*
import tabulate4cj.tabulate.*

main() {
    let tabWrap = create(
        [
            ["header", "value"],
            ["test1",
                "This is a really long string, yaaaay it works, Vivamus laoreet vestibulum pretium. Nulla et ornare elit. Cum sociis natoque penatibus et magnis Vivamus laoreet vestibulum pretium. Nulla et ornare elit. Cum sociis natoque penatibus et magnis"],
            ["test2",
       "AAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCCCCCCCCCEEEEEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDd"]
        ]
    )
    // 设置单元格最大宽度
    tabWrap.setMaxCellSize(20)
    // 启用自动换行
    tabWrap.setWrapStrings(true)
    // 换行时按空格分割
    tabWrap.setWrapDelimiter(r' ')
    // 填补换行产生的空位
    tabWrap.setSplitConcat("-")
    println(tabWrap.render(format:"grid"))
}
```

执行结果如下：

```
+-----------+-------------------------+
|    header |                   value |
+===========+=========================+
|     test1 |        This is a really |
|           |     long string, yaaaay |
|           |       it works, Vivamus |
|           |      laoreet vestibulum |
|           |       pretium. Nulla et |
|           |        ornare elit. Cum |
|           |          sociis natoque |
|           |     penatibus et magnis |
|           |         Vivamus laoreet |
|           |     vestibulum pretium. |
|           |         Nulla et ornare |
|           |        elit. Cum sociis |
|           |    natoque penatibus et |
|           |                  magnis |
+-----------+-------------------------+
|     test2 |    AAAAAAAAAAAAAAAAAAA- |
|           |    ABBBBBBBBBBBBBBBBBB- |
|           |    BBBBBBBCCCCCCCCCCCC- |
|           |    CCCCCCCCCCCCCEEEEEE- |
|           |    EEEEEEEEEEEEEEDDDDD- |
|           |               DDDDDDDDd |
+-----------+-------------------------+
```

##### 1.2.5 渲染隐藏指定表格线表格

```cangjie
/**
* 设置需要隐藏的表格线
*
* @param hide Array<String> 需要隐藏的线类型数组，可选值：
* top（顶部线）/belowheader（表头下划线）/bottomLine（底部线）/betweenLine（行间线）
*/
func setHideLines(hide: Array<String>): Unit
```

示例代码如下：

```cangjie
// API Demo 5
import std.collection.*
import tabulate4cj.tabulate.*

main() {
    let arrData = [
        ["title1", "title2", "title3"],
        ["test string 1", "test string 2", "test string 3"],
        ["tabulate4cj", "tabulate4cj", "tabulate4cj"]
    ]
    let tabArr = create(arrData)
    // 隐藏顶部线
    tabArr.setHideLines(["top"])
    println(tabArr.render(format: "grid"))
    // 隐藏表头下划线
    tabArr.setHideLines(["belowheader"])
    println(tabArr.render(format: "grid"))
    // 隐藏底部线
    tabArr.setHideLines(["bottomLine"])
    println(tabArr.render(format: "grid"))
    // 隐藏行间线
    tabArr.setHideLines(["betweenLine"])
    println(tabArr.render(format: "grid"))
}
```

执行结果如下：

```
|           title1 |           title2 |           title3 |
+==================+==================+==================+
|    test string 1 |    test string 2 |    test string 3 |
+------------------+------------------+------------------+
|      tabulate4cj |      tabulate4cj |      tabulate4cj |
+------------------+------------------+------------------+

+------------------+------------------+------------------+
|           title1 |           title2 |           title3 |
|    test string 1 |    test string 2 |    test string 3 |
+------------------+------------------+------------------+
|      tabulate4cj |      tabulate4cj |      tabulate4cj |
+------------------+------------------+------------------+

+------------------+------------------+------------------+
|           title1 |           title2 |           title3 |
+==================+==================+==================+
|    test string 1 |    test string 2 |    test string 3 |
+------------------+------------------+------------------+
|      tabulate4cj |      tabulate4cj |      tabulate4cj |

+------------------+------------------+------------------+
|           title1 |           title2 |           title3 |
+==================+==================+==================+
|    test string 1 |    test string 2 |    test string 3 |
|      tabulate4cj |      tabulate4cj |      tabulate4cj |
+------------------+------------------+------------------+
```

##### 1.2.6 渲染紧凑模式表格

```cangjie
/**
* 启用紧凑模式，移除行间空白
*/
func setDenseMode(): Unit
```

示例代码如下：

```cangjie
// API Demo 6
import std.collection.*
import tabulate4cj.tabulate.*

main() {
    let arrData = [
        ["title1", "title2", "title3"],
        ["test string 1", "test string 2", "test string 3"],
        ["tabulate4cj", "tabulate4cj", "tabulate4cj"]
    ]
    let tabArr = create(arrData)
    // 启用紧凑模式
    tabArr.setDenseMode()
    println(tabArr.render(format: "grid"))
}
```

执行结果如下：

```
+------------------+------------------+------------------+
|           title1 |           title2 |           title3 |
+==================+==================+==================+
|    test string 1 |    test string 2 |    test string 3 |
|      tabulate4cj |      tabulate4cj |      tabulate4cj |
+------------------+------------------+------------------+
```

### 2 字符宽度相关API

#### 2.1 Condition类 成员函数接口

##### 2.1.1 Condition类

使用说明：

使用时如果不实例化Condition类，则可以直接调用以下提供的成员函数接口，此时使用的为已经实例化好的DefaultCondition，此类是根据系统文件以及环境变量自动判断得到的规则，此规则适用于控制台输出时的字符宽度判断。（仅支持Windows平台和Linux平台的自动判断）

如果有特殊需求可以手动实例化Condition类设置判断规则，并且调用其中的成员函数。

```
/**
* 字符宽度判断类，存储了宽度判断规则
*/
public class Condition {
    public var eastAsianWidth: Bool = false // 是否启用东亚字符宽度规则
    public var strictEmojiNeutral: Bool = true // 是否严格将Emoji视为中性宽度
}
```

##### 2.2.2 计算字符与字符串宽度

```cangjie
/**
* 计算单个字符的显示宽度
*
* @param r Rune 需要计算的字符
* @return Int64 字符显示宽度
*/
public func runeWidth(r: Rune): Int64

/**
* 计算字符串的显示总宽度
*
* @param s String 待计算的字符串
* @return Int64 字符串显示宽度
*/
public func stringWidth(s: String): Int64
```

示例代码如下：

```
// API Demo 7
import tabulate4cj.runewidth.*

main() {
    let rune =  runeWidth(r"中") // 字符打印显示宽度
    println(rune)

    let helloWorld = stringWidth("👩🏾💻,你好,世界!") // 字符串打印显示宽度
    println(helloWorld)
}
```

执行结果如下：

```
2
15
```

##### 2.2.3 截断过长字符串

```cangjie
/**
* 截断字符串至指定显示宽度
*
* @param s String 原始字符串
* @param w Int64 目标显示宽度
* @param tail String 截断后追加的尾部标记
* @return String 截断处理后的字符串
*/
public func truncate(s: String, w: Int64, tail: String): String

/**
* 从左侧截断字符串至指定宽度
*
* @param s String 原始字符串
* @param w Int64 目标显示宽度
* @param prefix String 截断后添加的前缀
* @return String 截断处理后的字符串
*/
public func truncateLeft(s: String, w: Int64, prefix: String): String
```

示例代码如下：

```
// API Demo 8
import tabulate4cj.runewidth.*

main() {
    // 右侧截断
    let truncateString = truncate("这是一条很长的字符串啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊", 30, "...")
    println(truncateString)

    // 左侧截断
    let truncateLeftString = truncateLeft("啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊这是一条很长的字符串", 30, "...")
    println(truncateLeftString)
}
```

执行结果如下：

```
这是一条很长的字符串啊啊啊...
...啊这是一条很长的字符串
```

##### 2.2.4 智能换行过长字符串

```cangjie
/**
* 按指定宽度自动换行
*
* @param s String 原始字符串
* @param w Int64 每行显示最大宽度
* @return String 换行处理后的字符串
*/
public func wrap(s: String, w: Int64): String
```

示例代码如下：

```
// API Demo 9
import tabulate4cj.runewidth.*

main() {
    // 智能换行
    let wrapString = wrap(
        "東京特許許可局局長はよく柿喰う客だ/東京特許許可局局長はよく柿喰う客だ\n" + "123456789012345678901234567890\n\n" + "END",
        20
    )
    println(wrapString)
}
```

执行结果如下：

```
東京特許許可局局長は
よく柿喰う客だ/東京
特許許可局局長はよく
柿喰う客だ
12345678901234567890
1234567890

END
```

##### 2.2.5 填充字符串至指定宽度

```cangjie
/**
* 从左侧填充空格至指定宽度
*
* @param s String 原始字符串
* @param w Int64 目标显示宽度
* @return String 填充后的字符串
*/
public func fillLeft(s: String, w: Int64): String

/**
* 右侧填充空格至指定宽度
*
* @param s String 原始字符串
* @param w Int64 目标显示宽度
* @return String 填充后的字符串
*/
public func fillRight(s: String, w: Int64): String
```

示例代码如下：

```
// API Demo 10
import tabulate4cj.runewidth.*

main() {
    // 从左侧填补字符串至指定宽度
    let leftString = fillLeft("abcd", 10)
    println("{${leftString}}")

    // 从右侧填补字符串至指定宽度
    let rightString = fillRight("abcd", 10)
    println("{${rightString}}")
}
```

执行结果如下：

```
{      abcd}
{abcd      }
```

##### 2.2.6 判断字符类型

```
/**
* 判断字符是否为模糊宽度字符
*
* @param r Rune 待检测字符
* @return Bool 是否为模糊宽度
*/
public func isAmbiguousWidth(r: Rune): Bool

/**
* 判断字符是否为中性宽度字符（如标点符号）
*
* @param r Rune 待检测字符
* @return Bool 是否为中性宽度
*/
public func isNeutralWidth(r: Rune): Bool
```

示例代码如下：

```
// API Demo 11
import tabulate4cj.runewidth.*

main() {
    // 判断模糊宽度字符
    let isAmbiguous = isAmbiguousWidth(r"⑥")
    println(isAmbiguous)

    // 判断中性宽度字符
    let isNeutral = isNeutralWidth(r"⣀")
    println(isNeutral)
}
```

执行结果如下：

```
true
true
```

### 3 字素迭代器相关API

#### 3.1 获取实例化 Grapheme类

```cangjie
/**
* 构建给定字符串的字素迭代器
*
* @param s String 需要处理的原始字符串
* @return Grapheme 初始化后的迭代器，返回该字符串构造的Grapheme实例
*/
public func newGraphemes(s: String): Grapheme
```

#### 3.2 Grapheme类 成员函数接口

##### 3.2.1 Grapheme类

```cangjie
/**
* 字素簇迭代器，用于处理组合字符的分割
*/
public class Grapheme {
    public var codePoints: Array<Rune> = [] // Unicode码点序列
    public var indices: Array<Int64> = [] // 对应字节位置索引
    public var start: Int64 = 0 // 当前字素起始位置
    public var end: Int64 = 0 // 当前字素结束位置
    public var pos: Int64 = 0 // 解析游标位置
    public var state: UInt32 = 0 // 状态机当前状态
}
```

##### 3.2.2 使用迭代器遍历字符串获取字素

```cangjie
/**
* 移动到下一个字素的起始位置，如果手动初始化迭代器，在首次访问字素数据前，需要优先调用该方法（请使用
* newGraphemes获取迭代器，它会返回给你一个可以直接使用的迭代器）
*
* @return Bool 是否还有字素簇
*/
public func next(): Bool

/**
* 获取当前字素的码点数组，如果迭代器已经移动到了末尾或者还没有调用过next方法会返回None，next方法会返回
* None
*
* @return ?Array<Rune> 当前字素包含的码点序列
*/
public func runes(): ?Array<Rune>

/**
* 获取当前字素的字节位置范围
*
* @return (Int64, Int64) 起始和结束字节位置
*/
public func positions(): (Int64, Int64)
```

示例代码如下：

```cangjie
// API Demo 12
import tabulate4cj.grapheme.*

main() {
    // 带肤色emoji字素解析
    let gr = newGraphemes("👦🏾👍🏼!")
    while (gr.next()) {
        println(gr.runes() ?? Array<Rune>())
	}
}
```

执行结果如下：

```
[👦, 🏾]
[👍, 🏼]
[!]
```

