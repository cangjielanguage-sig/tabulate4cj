<div align="center">
<h1>Tabulate4cj</h1>
</div>


<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v1.0.0-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v0.53.18-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjcov-98.5%25-brightgreen" style="display: inline-block;" />
</p>



## 介绍

tabulate4cj 可以帮助你更轻松地打印出美观的文本表格，支持多种表格样式、左中右对齐、自动换行、表格标题设置等功能。同时还提供了字符串的字素迭代器和判断字符宽度的功能。

本项目基于Go版本的(https://github.com/bndr/gotabulate)和(https://github.com/rivo/uniseg)在仓颉语言的基础上，进行开发和改进。

### 项目特性

- **支持多种表格样式**：实现了设置多种表格样式、对齐方式、表格标题等属性进行表格生成的功能。
- **实际感知宽度判断**：实现了计算多种字符、字符串被用户感知的实际显示宽度的功能。
- **字符串字素迭代器**：实现了字符串中字素的迭代器，能够正确处理组合字符如表情符号、藏语等复杂Unicode序列。

## 项目架构

- `doc` 文档目录，用于存放接口文档
- `src` 源代码目录，用于存放源代码
- `_tests` 测试数据目录，用于存放测试数据文件
- `src/test` 测试文件目录，用于存放测试用例

### 源码目录

```
tabulate4cj
├─ src
│  ├─ grapheme							# 字素模块
│  │  ├─ grapheme.cj
│  │  └─ properties.cj
│  ├─ runewidth							# 字符宽度模块
│  │  ├─ runewidth.cj
│  │  ├─ runewidth_posix.cj				# linux平台环境规则判断
│  │  ├─ runewidth_table.cj
│  │  ├─ runewidth_windows.cj			# windows平台环境规则判断
│  │  └─ runwidth_else.cj				# 除windows和Linux平台其他环境规则判断
│  ├─ tabulate							# 表格渲染模块
│  │  ├─ cjpm_util.cj					# 读取文件工具
│  │  ├─ tabulate.cj
│  │  └─ utils.cj
│  ├─ test								# 测试模块
│  │  ├─ grapheme_test.cj
│  │  ├─ runewidth_test.cj
│  │  ├─ runwidth_posix_test.cj
│  │  ├─ tabulate_test.cj
│  │  └─ utf8_test.cj
│  └─ utf8
│     └─ utf8.cj
└─ _tests							# 测试用例文本存放路径
```

### 接口说明

主要类和函数接口说明如下，详见 [API](./doc/feature_api.md)


## 使用说明

### 依赖引入

于cjpm.toml文件内引入：

```
[dependencies]
  tabulate4cj = { git = "https://gitcode.com/Fufish_SKP/tabulate4cj.git" }
```

### 编译构建

Windows/Linux 编译：

```shell
cpm update
cpm build
```

### 功能示例

#### Tabulate 功能示例

功能示例描述：将给出的数据打印为美观的文本表格，支持具体功能如下：

- 数据内容与标题的左/中/右对齐
- 三种表格样式plain/simple/grid以及紧凑模式可以选择
- 数据过长时进行智能换行
- 设置单元格最大宽度
- 空单元格的内容自动填充
- 隐藏你不想要的表格线
- 设置字符宽度判断规则

示例代码如下：

```cangjie
// Tabulate Demo
import std.collection.*
import tabulate4cj.tabulate.*

// 只要你的类实现了ToString或Formatter就可以作为数据进行表格化输出
class Demo <: ToString{
    Demo(
        public let name: String,
        public let price: Float64
    ){}
    public func toString(): String {
        return "${name}:${price}"
    }
}

main() {
    let data: Array<Array<ToString>> = [
        ["ID", "demo", "note", "empty"],
        [1, Demo("test",56.8791), "short note"],
        [2, Demo("apple",56.8791), "This is a really long string, yaaaay it works, Vivamus laoreet vestibulum pretium."],
        [3, Demo("test",56.8791), "111"],
        ["Sum", 168 ]
    ]
    let tab = create(data)
    // 设置单元格最大宽度
    tab.setMaxCellSize(20)
    // 启用自动换行
    tab.setWrapStrings(true)
    // 换行时按空格分割
    tab.setWrapDelimiter(r' ')
    // 填补换行产生的空位
    tab.setSplitConcat("==")
    // 设置标题以及他的对齐方式
    tab.setTitle("Demo Case Info", align: "center")
    // 设置替换空单元格的字符串
    tab.setEmptyString("empty")
    // 设置数据内容为右对齐
    tab.setAlign("right")
    // 以grid样式渲染表格
    println(tab.render(format: "grid"))
}
```

执行结果如下：

```
+-----------+--------------------+------------------------+-----------+
|                            Demo Case Info                           |
+-----------+--------------------+------------------------+-----------+
|        ID |               demo |                   note |     empty |
+===========+====================+========================+===========+
|       001 |     test:56.879100 |             short note |     empty |
+-----------+--------------------+------------------------+-----------+
|       002 |    apple:56.879100 |       This is a really |     empty |
|           |                    |    long string, yaaaay |     empty |
|           |                    |      it works, Vivamus |     empty |
|           |                    |     laoreet vestibulum |     empty |
|           |                    |               pretium. |     empty |
+-----------+--------------------+------------------------+-----------+
|       003 |     test:56.879100 |                    111 |     empty |
+-----------+--------------------+------------------------+-----------+
|       Sum |                168 |                  empty |     empty |
+-----------+--------------------+------------------------+-----------+
```

#### Runewidth 功能示例

功能示例描述：根据字符串解析其字素组成，然后根据utf8官网中规则判断其字符在命令行终端中的显示宽度，支持组合字符（如藏文，带肤色emoji等）的宽度判断，支持具体功能如下：

- 计算字符与字符串的显示宽度
- 按照显示宽度截断过长字符串
- 按照显示宽度对过长字符串进行换行
- 按照显示宽度填充字符串至指定宽度

示例代码如下：

```cangjie
// Runewidth Demo
import tabulate4cj.runewidth.*

main(): Int64 {
    // 显示宽度
    let emoji = stringWidth("👩🏾💻,你好,世界!")
    println("字符串显示宽度：{${emoji}}\n")

    // 从左侧填补字符串至指定宽度
    let leftString = fillLeft("abcd", 10)
    println("填充后的字符串：{${leftString}}\n")
    
    // 右侧截断
    let truncateString = truncate("这是一条很长的字符串啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊", 30, "...")
    println("右侧截断后的字符串：\n{${truncateString}}\n")

    // 智能换行
    let wrapString = wrap(
        "東京特許許可局局長はよく柿喰う客だ/東京特許許可局局長はよく柿喰う客だ\n" + "123456789012345678901234567890\n\n" + "END",
        20
    )
    println("智能换行后的字符串：\n{${wrapString}}")

    return 0
}
```

执行结果如下：

```
字符串显示宽度：{15}

填充后的字符串：{      abcd}

右侧截断后的字符串：
{这是一条很长的字符串啊啊啊...}

智能换行后的字符串：
{東京特許許可局局長は
よく柿喰う客だ/東京
特許許可局局長はよく
柿喰う客だ
12345678901234567890
1234567890

END}
```

#### Grapheme 功能示例

功能示例描述：提供字符串的字素迭代器，根据字符串解析其字素组成，获取用户可见字符的字素组成。

示例代码如下：

```cangjie
// Grapheme Demo
import tabulate4cj.grapheme.*

main(): Int64 {
    let gr = newGraphemes("👍🏼!") // 带肤色emoji字素解析
    while (gr.next()) {
		println(gr.runes() ?? Array<Rune>())
	}
    return 0
}
```

执行结果如下：

```
[👍, 🏼]
[!]
```

## 约束与限制

本项目在Windows平台与Linux平台均于下述版本下通过验证：

```
Cangjie Version: 0.53.18
```

## 开源协议

本项目基于 [Apache License 2.0](./LICENSE) ，请自由的享受和参与开源。

## 参与贡献

本项目由 [SIGCANGJIE / 仓颉兴趣组](https://gitcode.com/SIGCANGJIE) 实现并维护。技术支持和意见反馈请提Issue。

欢迎给我们提交PR，欢迎参与任何形式的贡献。

本项目committer：[@Fufish_SKP](https://gitcode.com/Fufish_SKP)

This project is supervised by [@zhangyin_gitcode](https://gitcode.com/zhangyin_gitcode) (HUAWEI Developer Advocate).

![](https://raw.gitcode.com/SIGCANGJIE/homepage/attachment/uploads/9b648c07-efc2-4eb3-b02f-eab18c77beea/devadvocate.png)