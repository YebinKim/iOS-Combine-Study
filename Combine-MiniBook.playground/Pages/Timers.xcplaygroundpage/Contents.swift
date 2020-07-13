//: [Previous](@previous)

import Foundation
import Combine

/*:
 # Timers

 - 코드를 비동기적으로 수행하거나, 반복 작업을 수행할 때 빈도를 제어하기 위해 사용하는 연산자
 */

/*:
 ## Using RunLoop

 - 기본 스레드와 스레드 클래스를 사용해 생성한 스레드는 자체 RunLoop를 가짐
   - RunLoop.current 를 호출하면 Foundation 에서 자동으로 생성됨
   - RunLoop는 *Scheduler* 프로토콜을 구현함
   - 메인 스레드가 아닌 경우 RunLoop가 없을 수 있음 (RunLoop가 생성되는 타이밍은 OS가 결정하기 때문에) 사용에 주의
 */

let runLoop = RunLoop.main
let runLoopSubscription = runLoop.schedule(after: runLoop.now, interval: .seconds(1), tolerance: .milliseconds(100)) {
    print("Timer fired")
}

// 3초 후 구독 종료
runLoop.schedule(after: .init(Date(timeIntervalSinceNow: 3.0))) {
    runLoopSubscription.cancel()
}

/*:
 ## Using the Timer class

 - ***Timer.publish(every: 1.0, on: .main, in: .common)***
   - *every* : 타이머가 반복되는 주기
   - *on* : 타이머가 연결된 RunLoop
   - *in* : 타이머가 실행되는 Loop mode
 */

let timerClassSubscription = Timer
    .publish(every: 1.0, on: .main, in: .common)
    .autoconnect()
    .scan(0) { counter, _ in counter + 1 }
    .sink { counter in
        print("Counter is \(counter)")
    }

/*:
 ## Using DispatchQueue

 - DispatchQueue를 사용해 타이머 이벤트를 생성
   - 타이머 인터페이스를 제공하지 않지만 다른 방법으로 대기열(queue)에서 타이머 이벤트 생성
 - Interval 마다 queue에서 반복 작업 수행
 */

//let queue = DispatchQueue.main
let queue = OperationQueue()
let source = PassthroughSubject<Int, Never>()

var counter = 0

let cancellable = queue.schedule(after: queue.now, interval: .seconds(1)) {
    source.send(counter)
    counter += 1
}

let subscription = source.sink {
    print("Timer emitted \($0)")
}

//: [Next](@next)
