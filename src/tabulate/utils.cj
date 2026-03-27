package tabulate4cj.tabulate

import std.collection.*
import std.convert.*

// Create normalized Array from strings
public func createFromString(data: Array<Array<String>>): Array<TabulateRow> {
    let rows = ArrayList<TabulateRow>(data.size)
    for (d in data) {
        if (d.size < 1) {
            break
        }
        rows.add(TabulateRow(d.toArray()))
    }
    return rows.toArray()
}

// Create normalized Array from HashMap
func createFromHashMap(data: HashMap<String, Array<String>>): (Array<String>, Array<TabulateRow>) {
    let rowMaxSize = data.size
    let lineMaxSize = (data |> map {x: (String, Array<String>) => x[1].size} |> max) ?? 0

    let headers = ArrayList<String>(data.size)
    let graph = ArrayList<ArrayList<String>>(
        lineMaxSize,
        {_ => ArrayList<String>(rowMaxSize, {_ => ""})}
    )

    var i = 0
    for (tup in data) {
        headers.add(tup[0])
        var j = 0
        for (e in tup[1]) {
            graph[j][i] = e
            j++
        }
        i++
    }
    let row = graph |> map {x: ArrayList<String> => TabulateRow(x.toArray())} |> collectArray<TabulateRow>
    return (headers.toArray(), row.toArray())
}

// Check if element is present in a slice.
public func inSlice(a: String, list: Array<String>): Bool {
    for (b in list) {
        if (b == a) {
            return true
        }
    }
    return false
}
