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

//    func unwrap<T>() -> Publishers.CompactMap<Self, T> where Output == Optional<T> {
//        compactMap { $0 }
//    }

    func unwrap<T>() -> AnyPublisher<T, Never> where Optional<T> == Output {
        compactMap { $0 }
        .assertNoFailure()
        .eraseToAnyPublisher()
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
   - Publusher가 **Subscription을 만들고** Subscriber에게 넘김
     - ***receive(subscription:)* 메서드 호출**
   - Subscriber는 Subscription에서 **원하는 값들을 request함**
     - Subscription의 *request(_:)* 메서드 호출
   - Subscription이 작업을 시작하고 값을 내보내기 시작, Subscriber로부터 요구받은 값을 하나씩 전송
     - Subscriber의 *receive(_:)* 메서드 호출
   - 값을 받은 Subscriber는 이전부터 누적된 Demand에 새로 받은 값을 추가한 *Subscribers.Demand*를 반환
     - **Subscriber의 Demand는 누적됨**
   - Subscription은 전송한 값의 수가 받은 request 수에 도달할 때까지 값을 계속 전송
     - 요청받았던 만큼의 값을 보냈다면 Subscription은 새 request를 기다림
   - 위 과정 중 오류가 있거나 Subscription 값 소스가 완료되면 Subscription은 Subscriber의 ***receive(completion:)* 호출**



 - **Subscription의 역할**
   - Subscriber의 첫 Demand를 수락
   - Demand를 받으면 타이머 이벤트를 생성
   - Subscriber가 값을 받고 Demand를 반환할 때마다 처리 완료한 Demand count를 추가
   - configuration에서 요청한 값보다 더 많은 값을 제공하지 않는지 확인



 - Subscription은 Subscriber와 Publisher 사이의 링크
   - Subscription이 해제되면 Subscriber는 값을 받지 못한다. -> Subscription이 해제되면 모든 게 해제되기 때문
 */

/*:
 ## Emitting Values Example - Timer Operator
 */
//: [Timer Operator](Timers)

// MARK: Publisher가 방출할 값 정의
struct DispatchTimerConfiguration {
    let queue: DispatchQueue?               // 타이머가 실행될 큐
    let interval: DispatchTimeInterval      // 구독 시간부터 시작하여 타이머가 실행되는 간격
    let leeway: DispatchTimeInterval        // 시스템이 타이머 이벤트의 전달을 지연시킬 수 있는 최대 시간
    let times: Subscribers.Demand           // 수신하려는 타이머 이벤트 수
}

// MARK: DispatchTimer publisher를 Publishers extension에 추가
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

// MARK: Subscription 클래스 생성
private final class DispatchTimerSubscription<S: Subscriber>: Subscription where S.Input == DispatchTime {

    // MARK: Required Properties
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

    // Subscription이 Subscriber를 유지할 책임을 가진다.
    // -> Subscription이 완료, 실패 또는 취소되지 않는 한 Subscriber를 유지할 책임이 있음을 분명히 알 수 있음
    // subscriber은 강한 참조를 가지고 있음을 잘 볼 것
    var subscriber: S?

    // MARK: Initializing and canceling
    init(subscriber: S,
         configuration: DispatchTimerConfiguration) {
        self.configuration = configuration
        self.subscriber = subscriber
        self.times = configuration.times
    }

    func cancel() {
        source = nil
        subscriber = nil
    }

    // MARK: request(_:) - Subscriber로부터 요구를 받는 메서드 (요청 값을 허용하는 메서드)
    // protocol required method
    // Demand가 합산되어 Subscriber가 요청한 총 값 수를 생성함
    func request(_ demand: Subscribers.Demand) {
        // 첫 번째 검증은 configuration에 지정된 대로 Subscriber에 충분한 값을 이미 전송했는지 확인하는 것
        // 즉, Publisher가 받은 Demand와 상관없이 최대 예상 값을 보낸 경우
        guard times > .none else {
            // 이 경우 완료 이벤트를 보냄으로써 Publisher가 값 전송을 완료했음을 Subscriber에 알릴 수 있음
            subscriber?.receive(completion: .finished)
            return
        }

        // 새 Demand를 추가하여 받은 요청된 값(requested)의 카운터를 늘림
        requested += demand

        // 타이머가 존재하지 않고, 요청 된 값이 있다면 작업 진행
        if source == nil, requested > .none {
            // MARK: Custom Timer 구성
            // 큐에서 DispatchSourceTimer를 생성
            let source = DispatchSource.makeTimerSource(queue: configuration.queue)
            // timer가 모든 configuration.interval 시간 이후에 실행되도록 예약
            // Subscriber가 Subscription을 취소하거나 Subscription의 할당을 해제할 때까지 유지
            source.schedule(deadline: .now() + configuration.interval,
                            repeating: configuration.interval,
                            leeway: configuration.leeway)

            // 타이머에 대한 이벤트 처리기를 설정
            // 약한 참조를 유지해야 이후 Subscription이 할당 해제될 수 있음
            // 계속 루프돌고 있다고 생각하고 있으면 이해하기 쉽다
            source.setEventHandler { [weak self] in
                // 현재 요청 된 값이 있는지 확인
                // Publisher는 현재 Demand없이 일시 중지 될 수 있음
                guard let self = self,
                    self.requested > .none else { return }

                // Subscriber에 값을 보낼 것이므로 두 카운터를 모두 줄임
                self.requested -= .max(1)
                self.times -= .max(1)
                _ = self.subscriber?.receive(.now())

                // 전송할 총 값 수가 configuration에서 지정한 최대 값을 충족하면 Publisher가 완료된 것으로 생각 -> 완료 이벤트를 생성
                if self.times == .none {
                    self.subscriber?.receive(completion: .finished)
                }
            }

            // MARK: Custom Timer 활성화
            // source timer에 대한 참조를 저장
            self.source = source
            // 타이머 실행
            source.activate()
        }
    }
}

// Publisher와 Subscription을 쉽게 연결할 수 있는 Operator를 정의
extension Publishers {

    static func timer(queue: DispatchQueue? = nil,
                      interval: DispatchTimeInterval,
                      leeway: DispatchTimeInterval = .nanoseconds(0),
                      times: Subscribers.Demand = .unlimited)
        -> Publishers.DispatchTimer {

            return Publishers.DispatchTimer(
                configuration: .init(queue: queue,
                                     interval: interval,
                                     leeway: leeway,
                                     times: times)
            )
    }
}

// MARK: Custom Timer 테스트
example(of: "DispatchTimer") {
    var logger = TimeLogger(sinceOrigin: true)
    let publisher = Publishers.timer(interval: .seconds(1), times: .max(6))
    let subscription = publisher
        .sink { time in
        print("Timer emits: \(time)", to: &logger)
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
        subscription.cancel()
    }
}

//: [Next](@next)
