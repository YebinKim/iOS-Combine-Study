//: [Previous](@previous)

import Foundation
import Combine
import SwiftUI
import PlaygroundSupport

/*:
 # Time Manipulation Operators

 - 시간을 처리할 수 있는 Operator *(시간에 따라 값을 변형시키기 위한 Operator)*
 - 비동기 이벤트 흐름을 모델링할 수 있음
 */

private let valuesPerSecond = 1.0
private let delayInSeconds = 1.5

private let collectTimeStride = 4
private let collectMaxCount = 2

private let throttleDelay = 1.0

/*:
 ## Shifting time

 - **Publisher의 값 방출을 지연시키는 데 사용함**
 - *delay(for:scheduler:)* : 지연시키고자 하는 시간(for)과 해당 이벤트를 수행할 스케쥴러(scheduler)를 지정함
 */

// delay(for:scheduler:)

let delayedSourcePublisher = PassthroughSubject<Date, Never>()

let delayedPublisher = delayedSourcePublisher.delay(for: .seconds(delayInSeconds), scheduler: DispatchQueue.main)

let delayedSubscription = Timer
    .publish(every: 1.0 / valuesPerSecond, on: .main, in: .common)
    .autoconnect()
    .subscribe(delayedSourcePublisher)

let delayedSourceTimeline = TimelineView(title: "Emitted values (\(valuesPerSecond) per sec.):")
let delayedTimeline = TimelineView(title: "Delayed values (with a \(delayInSeconds)s delay):")

let delayedView = VStack(spacing: 50) {
    delayedSourceTimeline
    delayedTimeline
}

//PlaygroundPage.current.liveView = UIHostingController(rootView: delayedView)
//
//delayedSourcePublisher.displayEvents(in: delayedSourceTimeline)
//delayedPublisher.displayEvents(in: delayedTimeline)

/*:
 ## Collection values

 - **일정 시간동안 Publisher의 방출 값을 모으는 데 사용함**
 - *collect(_:Publishers.TimeGroupingStrategy<S>)* : 값을 모을 주기와 해당 이벤트를 수행할 스케쥴러를 지정함
   - Publishers.TimeGroupingStrategy<S> 의 종류
   - *.byTime(Context, Context.SchedulerTimeType.Stride)* : 주기(Stride)에 따라서만 값을 방출
   - *.byTimeOrCount(Context, Context.SchedulerTimeType.Stride, Int)* : 주기(Stride) 또는 최대 개수(Int)에 따라 값을 방출
 */

// collect(_:Publishers.TimeGroupingStrategy<S>)

let collectedSourcePublisher = PassthroughSubject<Date, Never>()

let collectedPublisher = collectedSourcePublisher
    .collect(.byTime(DispatchQueue.main, .seconds(collectTimeStride)))
    .flatMap { dates in dates.publisher }

let collectedPublisher2 = collectedSourcePublisher
    .collect(.byTimeOrCount(DispatchQueue.main, .seconds(collectTimeStride), collectMaxCount))
    .flatMap { dates in dates.publisher }

let collectedSubscription = Timer
    .publish(every: 1.0 / valuesPerSecond, on: .main, in: .common)
    .autoconnect()
    .subscribe(collectedSourcePublisher)

let collectedSourceTimeline = TimelineView(title: "Emitted values:")
let collectedTimeline = TimelineView(title: "Collected values (every \(collectTimeStride)s):")
let collectedTimeline2 = TimelineView(title: "Collected values (at most \(collectMaxCount) every \(collectTimeStride)s):")

let collectedView = VStack(spacing: 40) {
    collectedSourceTimeline
    collectedTimeline
    collectedTimeline2
}

//PlaygroundPage.current.liveView = UIHostingController(rootView: collectedView)
//
//collectedSourcePublisher.displayEvents(in: collectedSourceTimeline)
//collectedPublisher.displayEvents(in: collectedTimeline)
//collectedPublisher2.displayEvents(in: collectedTimeline2)

/*:
 ## Holding off on events

 - **일정 시간동안 Publisher의 값 방출을 보류하기 위해 사용함**
 - *debounce(for:scheduler:)* : 지정된 시간(for) 사이에 받는 값을 홀딩시키고 시간마다 값을 방출함
 - *throttle(for:scheduler:**latest:**)* : latest 가 false로 설정된 경우 지정된 시간 중 첫 번째 값을 방출하고, true로 설정된 경우 마지막 값을 방출함
 */

// debounce(for:scheduler:)

let debouncedSubject = PassthroughSubject<String, Never>()

let debounced = debouncedSubject
    .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
    .share()

let debouncedSubjectTimeline = TimelineView(title: "Emitted values")
let debouncedTimeline = TimelineView(title: "Debounced values")

let debouncedView = VStack(spacing: 100) {
    debouncedSubjectTimeline
    debouncedTimeline
}

//PlaygroundPage.current.liveView = UIHostingController(rootView: debouncedView)
//
//debouncedSubject.displayEvents(in: debouncedSubjectTimeline)
//debounced.displayEvents(in: debouncedTimeline)

let debouncedSubscription1 = debouncedSubject
    .sink { string in
        print("+\(deltaTime)s: Subject emitted: \(string)")
}
let debouncedSubscription2 = debounced
    .sink { string in
        print("+\(deltaTime)s: Debounced emitted: \(string)")
}

debouncedSubject.feed(with: typingHelloWorld)


// throttle(for:scheduler:latest:)

let throttledSubject = PassthroughSubject<String, Never>()

let throttled = throttledSubject
    .throttle(for: .seconds(throttleDelay), scheduler: DispatchQueue.main, latest: true)
    .share()

let throttledSubjectTimeline = TimelineView(title: "Emitted values")
let throttledTimeline = TimelineView(title: "Throttled values")

let throttledView = VStack(spacing: 100) {
    throttledSubjectTimeline
    throttledTimeline
}

//PlaygroundPage.current.liveView = UIHostingController(rootView: throttledView)
//
//throttledSubject.displayEvents(in: throttledSubjectTimeline)
//throttled.displayEvents(in: throttledTimeline)

let throttledSubscription1 = throttledSubject
    .sink { string in
        print("+\(deltaTime)s: Subject emitted: \(string)")
}
let throttledSubscription2 = throttled
    .sink { string in
        print("+\(deltaTime)s: Throttled emitted: \(string)")
}

throttledSubject.feed(with: typingHelloWorld)

/*:
 ## Timing out

 - **일정 시간동안 이벤트를 받지 않으면 시간 초과로 Publisher에 completion 이벤트를 보내는 역할**
 - *timeout(_:scheduler:)* : 일정 시간동안 이벤트를 받지 않아도 failure completion 이벤트가 발생하지 않음
 - *timeout(_:scheduler:**customError:**)* : 일정 시간동안 이벤트를 받지 않으면  failure completion 이벤트를 발생시킴
 */

// timeout(_:scheduler:)

enum TimeoutError: Error {
    case timedOut
}

let subject1 = PassthroughSubject<Void, TimeoutError>()

let timedOutSubject = subject1.timeout(.seconds(5), scheduler: DispatchQueue.main, customError: { .timedOut })

let timeline = TimelineView(title: "Button taps")

let timedOutView = VStack(spacing: 100) {
    Button(action: { subject1.send() }) {
        Text("Press me within 5 seconds")
    }
    timeline
}

//PlaygroundPage.current.liveView = UIHostingController(rootView: timedOutView)
//
//timedOutSubject.displayEvents(in: timeline)

/*:
 ## Measuring time

 - **시간을 측정하기 위한 Operator (변형시키는 동작 x)**
 - *measureInterval(using:)* : Publisher의 방출 값 사이의 시간을 측정하는 데 사용함
 */

// measureInterval(using:)

let subject2 = PassthroughSubject<String, Never>()

let measureSubject = subject2.measureInterval(using: DispatchQueue.main)
let measureSubject2 = subject2.measureInterval(using: RunLoop.main)

let subjectTimeline = TimelineView(title: "Emitted values")
let measureTimeline = TimelineView(title: "Measured values")

let view = VStack(spacing: 100) {
    subjectTimeline
    measureTimeline
}

PlaygroundPage.current.liveView = UIHostingController(rootView: view)

subject2.displayEvents(in: subjectTimeline)
measureSubject.displayEvents(in: measureTimeline)

let subscription1 = subject2.sink {
    print("+\(deltaTime)s: Subject emitted: \($0)")
}
let subscription2 = measureSubject.sink {
    print("+\(deltaTime)s: Measure emitted: \(Double($0.magnitude) / 1000000000.0)")
}
let subscription3 = measureSubject2.sink {
    print("+\(deltaTime)s: Measure2 emitted: \($0)")
}

subject2.feed(with: typingHelloWorld)

//: [Next](@next)
