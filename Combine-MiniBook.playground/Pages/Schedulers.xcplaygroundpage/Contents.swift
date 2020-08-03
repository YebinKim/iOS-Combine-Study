//: [Previous](@previous)

import Foundation
import Combine
import SwiftUI
import PlaygroundSupport

/*:
 # Schedulars

 - **scheduler** : 클로저의 실행시기(when, how)를 정의하는 프로토콜 (Apple Document 정의)
   - 코드 실행을 예약하는 데 사용할 수 있음
 - 작업에 대한 excution context를 정의하는 역할
 - scheduler는 context의 실행 위치를 정의할 뿐, 실제 실행되는 thread가 무엇이 될지는 모른다. thread와는 다르다!!
 - scheduler의 구현에 따라 작업이 직렬화(serialized)하거나 병렬화(parallelized) 할 수 있다.
 */

/*:
 ## Operators for scheduling

 - *subscribe(on:)/subscribe(on:options:)* : 특정 scheduler에서 subscription을 생성한다. **(작업을 수행한다.)**
 - *receive(on:)/receive(on:options:)* : 특정 scheduler에서 값을 전달한다.
 - Publisher에 Subscriber을 수행했을 때 일어나는 과정
   1. Publisher가 Subscriber를 수신하고 Subscription을 생성
   2. Subscriber는 Subscription을 수신하고 Publisher에 값 요청
   3. Publisher는 **Subscription을 통해** 작업 시작
   4. Publisher는 **Subscription을 통해** 값을 방출
   5. Operator가 값을 변환
   6. Subscriber는 최종 값을 수신
 */

let computationPublisher = Publishers.ExpensiveComputation(duration: 3)
let queue = DispatchQueue(label: "serial queue")
let currentThread = Thread.current.number

print("Start computation publisher on thread \(currentThread)")

let schedulingSubscription = computationPublisher
    .subscribe(on: queue)
    .receive(on: DispatchQueue.main)
    .sink { value in
        let thread = Thread.current.number
        print("Received computation result on thread \(thread): '\(value)'")
}

/*:
 ## Scheduler implementations

 - *ImmediateScheduler* : 현재 실행 thread에서 즉시 코드를 실행하는 간단한 스케줄러
   - subscribe (on :), receive (on :) 또는 scheduler를 매개 변수로 사용하는 다른 operator를 사용하여 다른 thread에서 실행 가능
 - *RunLoop* : Foundation의 Thread 개체에 연결
 - *DispatchQueue* : serial 또는 concurrent 하게 작업 수행
 - *OperationQueue* : 작업 항목의 실행을 조절하는 대기열
 */

/*:
 ## ImmediateScheduler scheduler

 - options: ImmediateScheduler를 사용할 때는 옵션 매개 변수 값을 전달할 수 없음 (타입이 Never로 정의되기 때문)
 - pitfalls: **즉시 작업을 시작**하기 때문에 Scheduler 프로토콜의 지연 연산자인 schedule(after:) 를 사용할 수 없음
 */

let immediateSchedulerSource = Timer
  .publish(every: 1.0, on: .main, in: .common)
  .autoconnect()
  .scan(0) { counter, _ in counter + 1 }

let immediateSchedulerSetupPublisher = { recorder in
  immediateSchedulerSource
    .recordThread(using: recorder)
    .receive(on: ImmediateScheduler.shared)

    .receive(on: DispatchQueue.global())
    .recordThread(using: recorder)

    .eraseToAnyPublisher()
}

//let view = ThreadRecorderView(title: "Using ImmediateScheduler", setup: immediateSchedulerSetupPublisher)
//PlaygroundPage.current.liveView = UIHostingController(rootView: view)

/*:
 ## RunLoop scheduler

 - options: 옵션 매개 변수 값을 전달할 수 없음
 - pitfalls: **DispatchQueue에서 실행되는 코드에서는 RunLoop.current를 사용할 수 없음** (DispatchQueue thread는 일시적으로 생성되어있을 수 있으므로 RunLoop를 사용하는 것이 불가능하기 때문)
 */

var threadRecorder: ThreadRecorder? = nil

let runLoopSource = Timer
    .publish(every: 1.0, on: .main, in: .common)
    .autoconnect()
    .scan(0) { (counter, _) in counter + 1 }

let runLoopSetupPublisher = { recorder in
    runLoopSource
        .handleEvents(receiveSubscription: { _ in threadRecorder = recorder })

        .subscribe(on: DispatchQueue.global())
        .recordThread(using: recorder)

        .receive(on: RunLoop.current)
        .recordThread(using: recorder)

        .eraseToAnyPublisher()
}

//let view = ThreadRecorderView(title: "Using RunLoop", setup: runLoopSetupPublisher)
//PlaygroundPage.current.liveView = UIHostingController(rootView: view)

RunLoop.current.schedule(after: .init(Date(timeIntervalSinceNow: 4.5)),
                         tolerance: .milliseconds(500)) {
                            threadRecorder?.subscription?.cancel()
}

/*:
 ## DispatchQueue scheduler

 - options: **옵션 매개 변수 값을 전달할 수 있음**, DispatchQueue에 이미 설정된 값과 독립적으로 QoS(Quality of Service) 값 지정 가능
 */

let serialQueue = DispatchQueue(label: "Serial queue")
let sourceQueue = serialQueue // DispatchQueue.main

let dispatchQueueSource = PassthroughSubject<Void, Never>()
let subscription = sourceQueue.schedule(after: sourceQueue.now,
                                        interval: .seconds(1)) {
                                            dispatchQueueSource.send()
}

let dispatchQueueSetupPublisher = { recorder in
    dispatchQueueSource
        .recordThread(using: recorder)
        .receive(on: serialQueue,
                 options: DispatchQueue.SchedulerOptions(qos: .userInteractive) )

        .recordThread(using: recorder)
        .eraseToAnyPublisher()
}

let view = ThreadRecorderView(title: "Using DispatchQueue", setup: dispatchQueueSetupPublisher)
PlaygroundPage.current.liveView = UIHostingController(rootView: view)

/*:
 ## OperationQueue

 - options: 옵션 매개 변수 값을 전달할 수 없음
 - pitfalls: DispatchQueue와 유사하지만 큐들 간에 의존성을 가짐으로써 실행 순서를 제어할 수 있으며, maxConcurrentOperationCount 매개 변수를 조정하여 로드를 제어 할 수 있음
 */

let operationQueue = OperationQueue()
operationQueue.maxConcurrentOperationCount = 1

let operationSubscription = (1...10).publisher
    .receive(on: operationQueue)
    .sink { value in
        print("Received \(value) on thread \(Thread.current.number)")
}

//: [Next](@next)
