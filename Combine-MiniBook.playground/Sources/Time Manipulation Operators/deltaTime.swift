import Foundation

let start = Date()
let deltaFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.negativePrefix = ""
    f.minimumFractionDigits = 1
    f.maximumFractionDigits = 1
    return f
}()

/// Playground 에서 현재 실행 날짜를 출력시키는 포맷
public var deltaTime: String {
    return deltaFormatter.string(for: Date().timeIntervalSince(start))!
}
