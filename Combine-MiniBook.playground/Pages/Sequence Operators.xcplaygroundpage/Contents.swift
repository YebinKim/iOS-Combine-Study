//: [Previous](@previous)

import Foundation
import Combine

/*:
 # Sequence Operators

 - Publisher의 내부 값들을 Sequence로 처리하기 위한 Operator
   - *Publisher 자체는 하나의 Sequence로 볼 수 있음*
 */

/*:
 ## Finding values
 
 - **Sequence 내에서 특정 조건에 일치하는 값을 찾는 데 사용함**
 - Swift Sequence의 *Collection method*와 유사한 동작
 - *min()* : sequence 내의 가장 작은 값을 찾음, greedy 하게 동작
 - *max()* : sequence 내의 가장 큰 값을 찾음, greedy 하게 동작
 - *first()* : sequence 내의 첫 번째 값을 찾음, lazy 하게 동작
 - *last()* : sequence 내의 마지막 값을 찾음, greedy 하게 동작
 - ouput(at:) : sequence 내의 특정 인덱스(at)까지만 값을 방출함, greedy 하게 동작
 - ouput(in:) : sequence 내의 특정 범위(in)에 해당하는 값만 방출함, greedy 하게 동작
 */

/*:
 - *greedy 동작 : publisher 가 finish completion 이벤트를 받을 때 까지 기다리는 동작*
 - *lazy 동작 : 특정 조건을 충족하면 바로 구독을 취소시키는 동작*
 */

example(of: "min") {
    
    let publisher = [1, -234, 567, 0].publisher
    
    publisher
        .print("publisher")
        .min()
        .sink(receiveValue: { print("Lowest value is \($0)") })
        .store(in: &subscriptions)
}

example(of: "min non-Comparable") {
    
    let publisher = ["12345",
                     "ab",
                     "hello world"]
        .compactMap { $0.data(using: .utf8) } // [Data]
        .publisher // Publisher<Data, Never>
    
    publisher
        .print("publisher")
        .min(by: { $0.count < $1.count })
        .sink(receiveValue: { data in
            let string = String(data: data, encoding: .utf8)!
            print("Smallest data is \(string), \(data.count) bytes")
        })
        .store(in: &subscriptions)
}

example(of: "max") {
    
    let publisher = ["F", "O", "U", "R"].publisher
    
    publisher
        .print("publisher")
        .max()
        .sink(receiveValue: { print("Highest value is \($0)") })
        .store(in: &subscriptions)
}

example(of: "first") {
    
    let publisher = ["A", "B", "C", "D", "E", "F", "G"].publisher
    
    publisher
        .print("publisher")
        .first()
        .sink(receiveValue: { print("First value is \($0)") })
        .store(in: &subscriptions)
}

example(of: "first(where:)") {
    
    let publisher = ["A", "B", "C", "D", "E", "F", "G"].publisher
    
    publisher
        .print("publisher")
        .first(where: { "Hello World".contains($0) })
        .sink(receiveValue: { print("First match is \($0)") })
        .store(in: &subscriptions)
}

example(of: "last") {
    
    let publisher = ["A", "B", "C", "D", "E", "F", "G"].publisher
    
    publisher
        .print("publisher")
        .last()
        .sink(receiveValue: { print("Last value is \($0)") })
        .store(in: &subscriptions)
}

example(of: "output(at:)") {
    
    let publisher = ["A", "B", "C", "D", "E", "F", "G"].publisher
    
    publisher
        .print("publisher")
        .output(at: 1)
        .sink(receiveValue: { print("Value at index 1 is \($0)") })
        .store(in: &subscriptions)
}

example(of: "output(in:)") {
    
    let publisher = ["A", "B", "C", "D", "E", "F", "G"].publisher
    
    publisher
        .output(in: 1...3)
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print("Value in range: \($0)") })
        .store(in: &subscriptions)
}

/*:
 ## Querying the publisher
 
 - **Publisher 의 Sequence 로부터 query를 통해 새로운 값을 만드는 데 사용함**
 - *count()* : sequence 내의 방출되는 값의 수를 셈, greedy 하게 동작
 - *contains(_:)* : sequence 내에 특정 값이 포함되어 있는 지 확인, greedy 하게 동작
 - allSatisfy(_:) : sequence 내의 값들이 모두 특정 조건을 만족하는 지 확인, greedy(모두 조건을 만족하는 경우) / lazy (하나라도 조건을 만족하지 않는 경우) 하게 동작
 - reduce(_:_:) : sequence 내의 값들을 누적 연산해 단일 값으로 결합시킴, greedy 하게 동작
 */

example(of: "count") {
    
    let publisher = ["A", "B", "C", "D", "E"].publisher
    
    publisher
        .print("publisher")
        .count()
        .sink(receiveValue: { print("I have \($0) items") })
        .store(in: &subscriptions)
}

example(of: "contains") {
    
    let publisher = ["A", "B", "C", "D", "E"].publisher
    let letter = "F"
    
    publisher
        .print("publisher")
        .contains(letter)
        .sink(receiveValue: { contains in
            print(contains ? "Publisher emitted \(letter)!"
                : "Publisher never emitted \(letter)!")
        })
        .store(in: &subscriptions)
}

example(of: "contains(where:)") {
    
    struct Person {
        let id: Int
        let name: String
    }
    
    let people = [
        (456, "Scott Gardner"),
        (123, "Shai Mishali"),
        (777, "Marin Todorov"),
        (214, "Florent Pillet")
        ]
        .map(Person.init)
        .publisher
    
    people
        .contains(where: { $0.id == 800 || $0.name == "Marin Todorov" })
        .sink(receiveValue: { contains in
            print(contains ? "Criteria matches!"
                : "Couldn't find a match for the criteria")
        })
        .store(in: &subscriptions)
}

example(of: "allSatisfy") {
    
//    let publisher = stride(from: 0, to: 5, by: 1).publisher     // lazy
    let publisher = stride(from: 0, to: 5, by: 2).publisher     // greedy
    
    publisher
        .print("publisher")
        .allSatisfy { $0 % 2 == 0 }
        .sink(receiveValue: { allEven in
            print(allEven ? "All numbers are even"
                : "Something is odd...")
        })
        .store(in: &subscriptions)
}

example(of: "reduce") {
    
    let publisher = ["Hel", "lo", " ", "Wor", "ld", "!"].publisher
    
    publisher
        .print("publisher")
        .reduce("", +)
        .sink(receiveValue: { print("Reduced into: \($0)") })
        .store(in: &subscriptions)
}

//: [Next](@next)
