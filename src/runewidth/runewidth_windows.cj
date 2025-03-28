package tabulate4cj.runewidth

foreign func GetConsoleOutputCP(): UInt

// IsEastAsian return true if the current locale is CJK
@When[os == "Windows"]
public func isEastAsian(): Bool {
    let cp = unsafe { GetConsoleOutputCP() }
    if (cp == 0) {
        return false
    }
    match {
        case (cp == 932 || cp == 51932 || cp == 936 || cp == 949 || cp == 950) => return true
        case _ => return false
    }
}
