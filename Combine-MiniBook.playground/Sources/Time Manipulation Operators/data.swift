import Foundation
import Combine

/// "Hello World" 타이핑 시뮬레이션 데이터
public let typingHelloWorld: [(TimeInterval, String)] = [
    (0.0, "H"),
    (0.1, "He"),
    (0.2, "Hel"),
    (0.3, "Hell"),
    (0.5, "Hello"),
    (0.6, "Hello "),
    (2.0, "Hello W"),
    (2.1, "Hello Wo"),
    (2.2, "Hello Wor"),
    (2.4, "Hello Worl"),
    (2.5, "Hello World")
]

public extension Subject where Output == String {
    /// 데이터 지연 전달 시뮬레이션 데이터
    func feed(with data: [(TimeInterval, String)]) {
        var lastDelay: TimeInterval = 0
        for entry in data {
            lastDelay = entry.0
            DispatchQueue.main.asyncAfter(deadline: .now() + entry.0) { [unowned self] in
                self.send(entry.1)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + lastDelay + 1.5) { [unowned self] in
            self.send(completion: .finished)
        }
    }
}
