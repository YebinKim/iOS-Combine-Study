//: [Previous](@previous)

import Foundation
import Combine

/*:
 # Combining Operator

 - 서로 다른 publisher가 생성한 값들을 결합할 수 있는 Operator
 */

/*:
 ## Prepending

 - **publisher 가 생성한 값 목록의 앞에 값을 추가하는 데 사용함**
 - *prepend(Output...)* : 개별 값을 값 목록 **앞**에 추가
 - *prepend(Sequence)* : Array, Set 등의 시퀀스를 값 목록 **앞**에 추가
 - *prepend(Publisher)* : 다른 Publisher의 생성 값을 기존 Publisher가 생성한 값 목록 **앞**에 추가
 */

example(of: "prepend(Output...)") {
    
    let publisher = [3, 4].publisher
    
    publisher
        .prepend(1, 2)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "prepend(Sequence)") {
    
    let publisher = [6, 7].publisher
    
    publisher
        .prepend([3, 4, 5])
        .prepend(Set(1...2))
        .prepend(stride(from: 8, to: 13, by: 2))
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "prepend(Publisher)") {
    
    let publisher1 = [3, 4].publisher
    let publisher2 = [1, 2].publisher
    
    publisher1
        .prepend(publisher2)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "prepend(Publisher) #2") {
    
    let publisher1 = [3, 4].publisher
    let publisher2 = PassthroughSubject<Int, Never>()
    
    publisher1
        .prepend(publisher2)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    publisher2.send(1)
//    publisher2.send(2)
    publisher2.send(completion: .finished)
}

/*:
 ## Appending

 - **Publisher 가 생성한 값 목록의 뒤에 값을 추가하는 데 사용함**
 - *append(Output...)* : 개별 값을 값 목록 **뒤**에 추가
 - *append(Sequence)* : 시퀀스를 값 목록 **뒤**에 추가
 - *append(Publisher)* : 다른 Publisher의 생성 값을 기존 Publisher가 생성한 값 목록 **뒤**에 추가
 */

example(of: "append(Output...)") {
    
    let publisher = [1].publisher
    
    publisher
        .append(2, 3)
        .append(4)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "append(Output...) #2") {
    
    let publisher = PassthroughSubject<Int, Never>()
    
    publisher
        .append(3, 4)
        .append(5)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    publisher.send(1)
    publisher.send(2)
//    publisher.send(completion: .finished)
}

example(of: "append(Sequence)") {
    
    let publisher = [1, 2, 3].publisher
    
    publisher
        .append([4, 5])
        .append(Set([6, 7]))
        .append(stride(from: 8, to: 13, by: 2))
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "append(Publisher)") {
    
    let publisher1 = [1, 2].publisher
    let publisher2 = [3, 4].publisher
    
    publisher1
        .append(publisher2)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

/*:
 ## switchToLatest()

 - **구독하던 Publisher 의 완료 이벤트와 새로운 Publisher 구독을 동시에 수행하는 데 사용함**
 - 구독을 **전환**한다고 볼 수 있음
 - 이전에 구독하던 Publisher의 나머지 방출 값은 모두 취소됨
 - 나중에 구독한 Publusher의 방출 값만 방출됨
 - 반환 값이 있는 Publisher에 대해서만 사용 가능
 - 구독을 종료하려면 Publisher composition과 마지막으로 구독한 Publisher 에 완료 이벤트를 보내야 함
 - *switchToLatest()* 사용
 */

example(of: "switchToLatest") {
    
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<Int, Never>()
    let publisher3 = PassthroughSubject<Int, Never>()
    
    let publishers = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
    
    publishers
        .switchToLatest()
        .sink(receiveCompletion: { _ in print("Completed!") },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    publishers.send(publisher1)
    publisher1.send(1)
    publisher1.send(2)
    
    publishers.send(publisher2)
    publisher1.send(100)
    publisher2.send(4)
    publisher2.send(5)
    
    publishers.send(publisher3)
    publisher2.send(200)
    publisher3.send(7)
    publisher3.send(8)
    publisher3.send(9)
    
    publisher3.send(completion: .finished)
    publishers.send(completion: .finished)
}

/*:
 ## merge(with:)

 - **두 Publisher 간의 값들을 보낸 순서대로 통합하는 데 사용함**
 - 중간에 끼워넣은 값들이 순서에 맞게 통합됨
 - 구독을 종료하려면 모든 Publisher에 완료 이벤트를 보내야 함
 - *merge(with:)* 사용
 */

example(of: "merge(with:)") {
    
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<Int, Never>()
    
    publisher1
        .merge(with: publisher2)
        .sink(receiveCompletion: { _ in print("Completed") },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    publisher1.send(1)
    publisher1.send(2)
    
    publisher2.send(3)
    
    publisher1.send(4)
    
    publisher2.send(5)
    
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
}

/*:
 ## combineLatest()

 - **두 Publisher 간의 방출 값들을 하나의 tuple 쌍으로 만드는 데 사용함**
 - 두 Publisher가 최소 하나의 값을 받을 때 까지 값을 방출하지 않음
 - 각 Publisher의 **마지막 값**들을 조합
   - 즉, 앞에 보낸 값들은 방출되지 않을 수 있음
 - 구독을 종료하려면 모든 Publisher에 완료 이벤트를 보내야 함
 - *combineLatest()* 사용
 */

example(of: "combineLatest") {
    
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<String, Never>()
    
    publisher1
        .combineLatest(publisher2)
        .sink(receiveCompletion: { _ in print("Completed") },
              receiveValue: { print("P1: \($0), P2: \($1)") })
        .store(in: &subscriptions)
    
    publisher1.send(1)
    publisher1.send(2)
    
    publisher2.send("a")
    publisher2.send("b")
    
    publisher1.send(3)
    
    publisher2.send("c")
    
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
}

/*:
 ## Zip()

 - **두 Publisher 간의 방출 값들을 하나의 tuple 쌍으로 만드는 데 사용함**
 - 두 Publisher가 최소 하나의 값을 받을 때 까지 값을 방출하지 않음
 - 각 Publisher에 **값을 보낸 순서대로** 조합
   - 즉, 마지막에 보낸 값들은 방출되지 않을 수 있음
 - 구독을 종료하려면 모든 Publisher에 완료 이벤트를 보내야 함
 - Swift Standard Library의 Sequence 타입 메서드 *zip(::)*과 동작이 유사함
 - *zip()* 사용
 */

example(of: "zip") {
    
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<String, Never>()
    
    publisher1
        .zip(publisher2)
        .sink(receiveCompletion: { _ in print("Completed") },
              receiveValue: { print("P1: \($0), P2: \($1)") })
        .store(in: &subscriptions)
    
    publisher1.send(1)
    publisher1.send(2)
    publisher2.send("a")
    publisher2.send("b")
    publisher1.send(3)
    publisher2.send("c")
    publisher2.send("d")
    
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
}

//: [Next](@next)
