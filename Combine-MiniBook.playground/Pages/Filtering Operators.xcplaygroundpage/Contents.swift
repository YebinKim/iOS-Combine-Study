//: [Previous](@previous)

import Foundation
import Combine

/*:
 # Filtering Operator
 
 - Publisher의 출력 값 또는 이벤트를 조건에 부합하는 일부만 사용하고자 할 때 사용할 수 있는 Operator
 - Swift의 filter와 유사한 점이 많음
 */

/*:
 ## Basic
 
 - **Subscriber에게 전달할 Publisher의 값을 조건부로 결정**
 - Swift Sequence의 *Filter*와 유사한 동작
 */

example(of: "filtering") {
    let numbers = PassthroughSubject<Int, Never>()
    
    numbers
        .filter { ($0 % 2) == 0 }
        .sink(receiveCompletion: { print("Completed with: \($0)") },
              receiveValue: { print("필터링 완료: \($0)") })
        .store(in: &subscriptions)
    
    print("emits 22")
    numbers.send(22)
    print("emits 33")
    numbers.send(33)
    print("emits 44")
    numbers.send(44)
    numbers.send(completion: .finished)
}

example(of: "removeDuplicates") {
    let words = "버즈 비비 비비 비비 조슈아 제이크 제이크! 😊 😊 ☘️"
        .components(separatedBy: " ")
        .publisher
    
    words
        .removeDuplicates()
        .sink(receiveValue: { print("Filtering: \($0)") })
        .store(in: &subscriptions)
}

/*:
 ## Compacting and ignoring
 
 - **Optional 출력 값을 가지는 publisher에 대해 nil 값에 대한 처리를 무시할 수 있게 함**
 - Swift Sequence의 *CompactMap* 과 유사한 동작
 - ignoreOutput 연산자를 사용해 publisher를 바로 완료시킬 수 있음
 */

example(of: "compactMap") {
    let strings = ["a", "1.24", "3",
                   "☘️", "45", "0.23"].publisher
    
    strings
        .compactMap { Int($0) }
        .sink(receiveValue: {
            print($0)
        })
        .store(in: &subscriptions)
}

example(of: "ignoreOutput") {
    let numbers = (1...10000).publisher
    
    numbers
        .ignoreOutput()
        .sink(receiveCompletion: { print("Completed with: \($0)") },
              receiveValue: { print("Filtering: \($0)") })
        .store(in: &subscriptions)
}

/*:
 ## Finding values
 
 - **특정 조건에 일치하는 첫 번째 / 마지막 항목을 찾는 데 사용함**
 - Swift standard library의 *first(where:)*, *last(where:)* 과 유사한 동작
 - *first(where:)* Operator는 lazy 방식으로 동작하기 때문에 일치하는 항목을 찾을 때 까지 필요한 만큼의 값만 사용함
 - *last(where:)* Operator는 모든 값이 방출될 때 까지 기다리므로 greedy 하게 동작함
 - 일치하는 값을 찾으면 구독을 취소하고 완료 이벤트를 보냄
 */

example(of: "first(where:)") {
    let numbers = (1...9).publisher
    
    numbers
        .print("numbers")
        .first(where: { $0 % 2 == 0 })
//        .last(where: { $0 % 2 == 0 })
        .sink(receiveCompletion: { print("Completed with: \($0)") },
              receiveValue: { print("Filtering: \($0)") })
        .store(in: &subscriptions)
}

example(of: "last(where:)") {
    let numbers = PassthroughSubject<Int, Never>()
    
    numbers
        .last(where: { $0 % 2 == 0 })
        .sink(receiveCompletion: { print("Completed with: \($0)") },
              receiveValue: { print("Filtering: \($0)") })
        .store(in: &subscriptions)
    
    numbers.send(1)
    numbers.send(2)
    numbers.send(3)
    numbers.send(4)
    numbers.send(5)
    numbers.send(completion: .finished)
}

/*:
 ## Dropping values
 
 - **Publisher 스트림 시작 시 조건을 만족하지 않는 일부 값을 무시하는 데 사용함**
 - 여러 Publisher의 협력 관계에서 유용하게 사용할 수 있음
 - 세 종류의 Operator 사용: *dropFirst*, *drop(while:)*, *drop(untilOutputFrom:)*
 */

example(of: "dropFirst") {
    let numbers = (1...10).publisher
    
    numbers
        .dropFirst(8)
        .sink(receiveValue: { print("Filtering: \($0)") })
        .store(in: &subscriptions)
}

example(of: "drop(while:)") {
    let numbers = (1...10).publisher
    
    numbers
        .drop(while: {
            print("x")
            return $0 % 5 != 0
        })
        .sink(receiveValue: { print("Filtering: \($0)") })
        .store(in: &subscriptions)
}

example(of: "drop(untilOutputFrom:)") {
    let isReady = PassthroughSubject<Void, Never>()
    let taps = PassthroughSubject<Int, Never>()
    
    taps
        .drop(untilOutputFrom: isReady)
        .sink(receiveValue: { print("Filtering: \($0)") })
        .store(in: &subscriptions)
    
    (1...5).forEach { n in
        taps.send(n)
        
        if n == 3 {
            isReady.send()
        }
    }
}

/*:
 ## Limiting values
 
 - **Publisher가 특정 조건이 충족될 때 까지 값을 수신한 후 완료할 수 있게 함**
 - Prefix 계열의 연산자 사용: *prefix(_:)*, *prefix(while:)*, *prefix(untilOutputFrom:)*
 - lazy 방식으로 동작
 - Prefix 조건을 검증하기 위해 클로저 사용
 */

example(of: "prefix") {
    let numbers = (1...10).publisher
    
    numbers
        .prefix(2)
        .sink(receiveCompletion: { print("Completed with: \($0)") },
              receiveValue: { print("Filtering: \($0)") })
        .store(in: &subscriptions)
}

example(of: "prefix(while:)") {
    let numbers = (1...10).publisher
    
    numbers
        .prefix(while: { $0 % 3 != 0 })
        .sink(receiveCompletion: { print("Completed with: \($0)") },
              receiveValue: { print("Filtering: \($0)") })
        .store(in: &subscriptions)
}

example(of: "prefix(untilOutputFrom:)") {
    let isReady = PassthroughSubject<Void, Never>()
    let taps = PassthroughSubject<Int, Never>()
    
    taps
        .prefix(untilOutputFrom: isReady)
        .sink(receiveCompletion: { print("Completed with: \($0)") },
              receiveValue: { print("Filtering: \($0)") })
        .store(in: &subscriptions)
    
    (1...5).forEach { n in
        taps.send(n)
        
        if n == 3 {
            isReady.send()
        }
    }
}

//: [Next](@next)
