//: [Previous](@previous)

import Foundation
import Combine

/*:
 # Backpressure

 - Subscription의 역방향 수행 결과
   - 현재 Downstream에서 처리할 수 있는 값의 수를 반환
 - Reactive와는 다르게 pull방식으로 동작할 수 있게 된다
 */

protocol Pausable { // --> BackPressure
    // pause() 메서드를 사용하지 않는 대신
    // 값을 받을 때마다 중지여부를 결정
    var paused: Bool { get }
    func resume()
}

// Cancellable 프로토콜을 채택하고 있다
// --> Subscriber를 커스텀을 하는 경우에는 Cancellable을 채택해야 Cancellable을 반환할 수 있기 때문
final class PausableSubscriber<Input, Failure: Error>: Subscriber, Pausable, Cancellable {

    // MARK: Properties
    let combineIdentifier = CombineIdentifier()

    // true -> 값을 받을 수 있는 상태
    // false -> 값을 받을 수 없는 상태
    let receiveValue: (Input) -> Bool
    let receiveCompletion: (Subscribers.Completion<Failure>) -> Void

    private var subscription: Subscription? = nil

    var paused = false

    // MARK: Initializing
    init(receiveValue: @escaping (Input) -> Bool,
         receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void) {
        self.receiveValue = receiveValue
        self.receiveCompletion = receiveCompletion
    }

    func cancel() {
        subscription?.cancel()
        subscription = nil
    }

    func receive(subscription: Subscription) {
        self.subscription = subscription
        subscription.request(.max(1))   // 값을 하나씩만 요청
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        paused = receiveValue(input) == false
        return paused ? .none : .max(1)
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        receiveCompletion(completion)
        subscription = nil
    }

    func resume() {
        guard paused else {
            return
        }

        paused = false
        subscription?.request(.max(1))
    }
}

extension Publisher {

    func pausableSink(
        receiveCompletion: @escaping ((Subscribers.Completion<Failure>) -> Void),
        receiveValue: @escaping ((Output) -> Bool))
        -> Pausable & Cancellable {

            let pausable = PausableSubscriber(
                receiveValue: receiveValue,
                receiveCompletion: receiveCompletion)

            self.subscribe(pausable)
            return pausable
    }
}

// MARK: PausableSubscriber 동작 테스트
let subscription = [1, 2, 3, 4, 5, 6]
    .publisher
    .pausableSink(receiveCompletion: { completion in
        print("Pausable subscription completed: \(completion)")
    }) { value -> Bool in
        print("Receive value: \(value)")
        if value % 2 == 1 {
            print("Pausing")
            return false
        }
        return true
}

let timer = Timer.publish(every: 1, on: .main, in: .common)
    .autoconnect()
    .sink { _ in
        guard subscription.paused else { return }
        print("Subscription is paused, resuming")
        subscription.resume()
}
//: [Next](@next)
