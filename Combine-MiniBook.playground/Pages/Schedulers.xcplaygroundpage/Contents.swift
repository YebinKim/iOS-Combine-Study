//: [Previous](@previous)

import Foundation
import Combine

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

 - *subscribe(on:)/subscribe(on:options:)* : 특정 scheduler에서 subscription을 생성한다.
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

let subscription = computationPublisher
    .subscribe(on: queue)
    .receive(on: DispatchQueue.main)
    .sink { value in
        let thread = Thread.current.number
        print("Received computation result on thread \(thread): '\(value)'")
}

//: [Next](@next)
