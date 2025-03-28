package tabulate4cj.runewidth

@When[os != "Windows" && os != "Linux"]
public func isEastAsian(): Bool {
    return false
}
