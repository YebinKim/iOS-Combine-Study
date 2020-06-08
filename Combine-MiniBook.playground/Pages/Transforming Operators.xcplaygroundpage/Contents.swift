//: [Previous](@previous)

import Foundation
import Combine

/*:
 # Transforming Operator
 
 - Publisher의 출력 값 또는 이벤트를 변형시키는 Operator
 - Swift standard library의 고차함수들과 동작이 유사함
 */
 
/*:
 ## Collecting values

 - **Subscriber에게 전달할 Publisher의 값을 collection으로 만들어주는 역할**
 - *collect()* : pubisher의 방출 값을 여러개의 array로 만들어줌
 - 매개변수를 전달하지 않으면 모든 값을 하나의 array로, 매개변수를 n개 전달하면 n개만큼 묶어 여러개의 array로 만들어줌
 */

example(of: "collect") {
    
    ["A", "B", "C", "D", "E"].publisher
        .collect()
//        .collect(3)
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}

/*:
 ## Mapping values

 - **특정 방법(포맷, 식)으로 값들을 일괄 변형시켜주는 역할**
 - *map(_:)* : upstream publisher로부터 전달받은 값을 클로저로 변형시켜 downstream publisher로 방출함
 - Swift standard library의 *map(_:)* 과 유사한 동작
 */

example(of: "map") {
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    [1, 23, 456].publisher
        .map {
            formatter.string(for: NSNumber(integerLiteral: $0)) ?? "" }
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

/*:
 ## Map key paths

 - **key paths 를 사용해 값을 전달해 map(_:) 과 유사한 동작을 수행하는 Operator**
 - *map<T>(_:)*, *map<T0, T1>(_:_:)*, *map<T0, T1, T2>(::_:)* : key paths를 통해 전달받은 값을 변형시킴
   - T는 key paths 를 통해 전달받는 값의 타입
 - *tryMap(_:)* : 오류가 발생했을 때 downstream으로 failure completion 이벤트를 방출함
 */

example(of: "map key paths") {
    
    let publisher = PassthroughSubject<Coordinate, Never>()
    
    publisher
        .map(\.x, \.y) .sink(receiveValue: { x, y in
            print(
                "The coordinate at (\(x), \(y)) is in quadrant",
                quadrantOf(x: x, y: y)
            )
        })
        .store(in: &subscriptions)
    
    publisher.send(Coordinate(x: 10, y: -8))
    publisher.send(Coordinate(x: 0, y: 5))
}

example(of: "tryMap") {
    
    Just("Directory name that does not exist")
        .tryMap { try FileManager.default.contentsOfDirectory(atPath: $0) }
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}

/*:
 ## Flattening publishers

 - **여러개의 upstream publisher를 하나의 downstream publisher로 만들어주는 operator**
   - 여러 방출 값들을 하나로 모아주는 것
 - downstream publisher는 upstream publisher와 다른 타입일 수 있음
 - *flatMap(maxPublisher:_:)* 사용
 - maxPublishers 에 전달하는 값에 따라 최대 전달받을 publisher의 개수를 지정할 수 있음
 */

example(of: "flatMap") {
    
    let charlotte = Chatter(name: "Charlotte", message: "Hi, I'm Charlotte!")
    let james = Chatter(name: "James", message: "Hi, I'm James!")
    
    let chat = CurrentValueSubject<Chatter, Never>(charlotte)
    
    chat
        .flatMap { $0.message }
//        .flatMap(maxPublishers: .max(2)) { $0.message }
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    charlotte.message.value = "Charlotte: How's it going?"
    chat.value = james
    
    let morgan = Chatter(name: "Morgan", message: "Hey guys, what are you up to?")
    chat.value = morgan
    
    charlotte.message.value = "Did you hear something?"
}

/*:
 ## Replacing upstream output

 - **nil 값을 non-nil 값으로 대체해주는 operator, 값 전달을 보장받을 수 있다**
 - *replaceNil(with:)* : publisher로 부터 전달받은 값 중 nil 값은 with 매개변수 값으로 대체함
 - *replaceEmpty(with:)* : 방출 값이 없는 publisher에 대해 finish completion 이벤트를 받았다면 with 매개변수 값을 방출함
 */

example(of: "replaceNil") {
    
    ["A", nil, "C"].publisher
        .replaceNil(with: "-")
//        .replaceNil(with: "-" as String?)
        .map { $0! }
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "replaceEmpty(with:)") {
    
    let empty = Empty<Int, Never>()
    
    empty
        .replaceEmpty(with: 1)
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}

/*:
 ## Incrementally transforming output

 - *upstream publisher로 부터 전달받은 값을 변형시킬 수 있는 operator
 - *scan(::)* : upstream publisher의 방출 값을 클로저에서 반환된 마지막 값과 함께 반환함
   - Swift standard library의 reduce 와 동작이 비슷함
 - tryScan(_:_:) : 오류가 발생했을 때 값 방출을 중단하고 failure completion 이벤트를 방출함
 */

example(of: "scan") {
    
    var dailyGainLoss: Int { .random(in: -10...10) }
    
    let june2020 = (0..<22)
        .map { _ in dailyGainLoss }
        .publisher
    
    june2020
        .scan(50) { latest, current in
            max(0, latest + current)
    }
    .sink(receiveValue: { _ in })
    .store(in: &subscriptions)
}

//: [Next](@next)
