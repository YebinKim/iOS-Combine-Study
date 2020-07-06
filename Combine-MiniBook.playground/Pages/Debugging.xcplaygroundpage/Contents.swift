//: [Previous](@previous)

import Foundation
import Combine

/*:
 # Debugging

 - Reactive flow를 파악하는 데 도움이 되는 연산자 제공
 */

/*:
 ## Printing events

 - *print(_:to:)* : Publisher 를 통해 전달되는 값과 관련 정보를 확인할 수 있게 해주는 연산자
 - passthrough publisher 로써 다음과 같은 정보 제공 가능
   - Subscription 을 받은 시점과 Upstream publisher 에 대한 설명
   - (요청받은 아이템의 개수를 알 수 있게 해주는) Subscriber 의 demand request
   - Upstream publisher 가 방출하는 모든 값
   - Completion 이벤트
 */

// Default debugging
//let subscription = (1...3).publisher
//    .print("publisher")
//    .sink { _ in }

class TimeLogger: TextOutputStream {

    private var previous = Date()
    private let formatter = NumberFormatter()

    init() {
        formatter.maximumFractionDigits = 5
        formatter.minimumFractionDigits = 5
    }

    func write(_ string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let now = Date()
        print("+\(formatter.string(for: now.timeIntervalSince(previous))!)s: \(string)")
        previous = now
    }
}

// Using logger to debugging
let subscription = (1...3).publisher
    .print("publisher", to: TimeLogger())
    .sink { _ in }

/*:
 ## Acting on events — performing side effects

 - *handleEvents(receiveSubscription:receiveOutput:receiveCompletion:receiveCancel:receiveRequest:)* : 특정 이벤트에 대해 액션을 수행할 수 있는 연산자 - 특정 이벤트에 대해 사이드 이펙트를 수행
 - Publisher의 라이프사이클에 있는 모든 이벤트를 가로채고 각 단계에서 액션을 수행
 */

let request = URLSession.shared
    .dataTaskPublisher(for: URL(string: "https://github.com/YebinKim/")!)

request
    .handleEvents(receiveSubscription: { _ in
        print("Network request will start")
    }, receiveOutput: { _ in
        print("Network request data received")
    }, receiveCancel: {
        print("Network request cancelled")
    })
    .sink(receiveCompletion: { completion in
        print("Sink received completion: \(completion)")
    }, receiveValue: { (data, _) in
        print("Sink received data: \(data)")
})

/*:
 ## Using the debugger as a last resort

 - *breakpointOnError()* : Upstream publisher에서 오류가 발생하면 break 시키는 연산자
 - *breakpoint(receiveSubscription:receiveOutput:receiveCompletion:)* : 다양한 종류의 이벤트를 가로채고 break 여부를 사례별로 결정할 수 있는 연산자
    - 각 state에서 true로 반환되는 단계에 브레이크포인트 설정
 */

let publisher = PassthroughSubject<String?, Never>()
let cancellable = publisher
    .breakpoint(
        receiveOutput: { value in return value == "DEBUGGER" })
    .sink { print("\(String(describing: $0))" , terminator: " ") }

publisher.send("DEBUGGER")
// playground 에서는 어떤 breakpoint publisher도 동작하지 않음 -> 실행이 중단되었지만 debugger에 들어가지 않는다는 오류 출력

//: [Next](@next)
