//: [Previous](@previous)

import Foundation
import Combine

/*:
 # Custom Publisher

 - 세 가지 방법으로 커스텀 Publisher를 만들 수 있다
   1. Publisher extension - 기존 Operator를 활용해 필요한 Operator를 구현
   2. Publishers extension - 값을 생성하는 Subscription을 구현
   3. Publishers extension - Upstream Publisher의 값을 반환하는 Subscription 구현
 */

/*:
 ## Publishers as extension methods

 - Publisher extension - 기존 Operator를 활용해 필요한 Operator를 구현
 - 가장 간단하게 커스텀 Publisher를 생성하는 방법
 */

extension Publisher {

    func unwrap<T>() -> Publishers.CompactMap<Self, T> where Output == Optional<T> {
        compactMap { $0 }
    }
}

let integerValues: [Int?] = [nil, nil, 1, 2, nil, 3, nil, 4]
let stringValues: [String?] = [nil, "one", "two", nil, "three"]

integerValues.publisher
    .unwrap()
    .sink {
        print("Received integer value: \($0)")
}

stringValues.publisher
    .unwrap()
    .sink {
        print("Received string value: \($0)")
}

/*:
 ## The subscription mechanism

 - Publisher를 구독하면 Subscription으로부터 요청을 받고 이벤트(values and completion)를 생성하는 구독을 인스턴스화 함
 - **Subscription의 생명 주기**
   - Subscriber가 Publisher를 **구독**
   - Publusher가 **Subscription을 만들고** Subscriber에게 넘김 - ***receive(subscription:)* 메서드 호출**
   - Subscriber는 Subscription에서 **원하는 값들을 request함** - Subscription의 *request(_:)* 메서드 호출
   - Subscription이 작업을 시작하고 값을 내보내기 시작, Subscriber로부터 요구받은 값을 하나씩 전송 - Subscriber의 *receive(_:)* 메서드 호출
   - 값을 받은 Subscriber는 이전까지 받았던 총 Demand에 새로 받은 값을 추가한 *Subscribers.Demand*를 반환
   - Subscription은 전송한 값의 수가 받은 request 수에 도달할 때까지 값을 계속 전송
     - 요청받았던 만큼의 값을 보냈다면 Subscription은 새 request를 기다림
   - 위 과정 중 오류가 있거나 Subscription 값 소스가 완료되면 Subscription은 Subscriber의 ***receive(completion:)* 호출**
 - **Subscription의 역할**
   - Subscriber의 첫 Demand를 수락
   - Demand를 받으면 타이머 이벤트를 생성
   - Subscriber가 값을 받고 Demand를 반환할 때마다 처리 완료한 Demand count를 추가
   - configuration에서 요청한 값보다 더 많은 값을 제공하지 않는지 확인
 */

/*:
 ## Publishers extension - 값을 생성하는 Subscription을 구현

 - Publishers emitting values
 - Building your subscription
 */

struct DispatchTimerConfiguration {
    let queue: DispatchQueue?               // 타이머가 실행될 큐
    let interval: DispatchTimeInterval      // 구독 시간부터 시작하여 타이머가 실행되는 간격
    let leeway: DispatchTimeInterval        // 시스템이 타이머 이벤트의 전달을 지연시킬 수 있는 최대 시간
    let times: Subscribers.Demand           // 수신하려는 타이머 이벤트 수
}

extension Publishers {

    struct DispatchTimer: Publisher {
        // 타이머는 현재 시간을 DispatchTime 값으로 내보냄
        typealias Output = DispatchTime
        typealias Failure = Never       // 실패하지 않는 유형!

        // 주어진 configuration의 복사본을 유지 - Subscriber를 받을 때 필요
        let configuration: DispatchTimerConfiguration

        init(configuration: DispatchTimerConfiguration) {
            self.configuration = configuration
        }

        // generic 타입의 receive 메서드 구현
        func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            // 작업의 대부분은 DispatchTimerSubscription 안에서 발생
            let subscription = DispatchTimerSubscription(
                subscriber: subscriber,
                configuration: configuration
            )
            // Subscriber는 Subscription을 수신한 다음 값에 대한 요청을 보낼 수 있다.
            // 요청을 보내면 실제 작업은 Subscription 안에서 이루어짐!!
            subscriber.receive(subscription: subscription)
        }
    }
}

private final class DispatchTimerSubscription<S: Subscriber>: Subscription where S.Input == DispatchTime {

    // Subscriber가 전달한 configuration
    let configuration: DispatchTimerConfiguration

    // configuration에서 복사한 타이머가 실행되는 최대 횟수
    // 값을 보낼 때마다 감소하는 카운터로 사용
    var times: Subscribers.Demand

    // Subscriber의 현재 Demand
    // 값을 보낼 때마다 감소
    var requested: Subscribers.Demand = .none

    // 타이머 이벤트를 생성할 DispatchSourceTimer
    var source: DispatchSourceTimer? = nil

    var subscriber: S?

    init(subscriber: S,
         configuration: DispatchTimerConfiguration) {
        self.configuration = configuration
        self.subscriber = subscriber
        self.times = configuration.times
    }

    func request(_ demand: Subscribers.Demand) {
    }

    func cancel() {
    }
}

//: [Next](@next)
