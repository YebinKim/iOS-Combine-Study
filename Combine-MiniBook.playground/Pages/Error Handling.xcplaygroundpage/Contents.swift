//: [Previous](@previous)

import Foundation
import Combine

/*:
 # Error Handling

 - Publisher의 방출 타입(Output)과 실패 타입(Failure) 중 실패 타입을 다루는 방법
 */

/*:
 ## Never

 - 실패하지 않음을 보장할 수 있는 Failure 타입
 - Failure 타입이 Never인 Publisher에서만 사용되는 연산자
   - *sink(receiveValue:)* : Publisher의 completion 이벤트는 무시하고 생성된 값만 처리
   - *setFailureType(to:)* : custom failure 타입을 지정할 수 있다. (단, Failure 타입은 Never 타입이어야 한다.)
   - *assign(to:on:)* : key path 중 오류가 있으면 결과값으로 unhandled error를 받거나 이상 동작 발생
   - *assertNoFailure()* : Swift의 *fatalError*와 비슷한 동작, Upstream에서 failure 이벤트를 완료할 수 없을 때 Debug Error 출력
 */

enum MyError: Error {
    case ohNo
}

/*
 // Just - 한 번 값을 방출하고 종료 이벤트를 보내는 Publisher, Failure 타입이 Never 타입이다.
 public struct Just<Output> : Publisher {
    public typealias Failure = Never
    ...
 }
 */
example(of: "Never sink") {
    Just("Hello")
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "setFailureType") {
    Just("Hello")
        .setFailureType(to: MyError.self)
//        .eraseToAnyPublisher()
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(.ohNo):
                    print("Finished with Oh No!") case .finished:
                        print("Finished successfully!")
                }
        },
            receiveValue: { value in
                print("Got value: \(value)")
        }
    )
        .store(in: &subscriptions)
}

example(of: "assign") {

    class Person {
        let id = UUID()
        var name = "Unknown"
    }

    let person = Person()
    print("1", person.name)
    Just("Shai")
//        .setFailureType(to: Error.self)   // Swift 표준 오류 타입인 Error 를 Failure 타입으로 지정할 경우 컴파일 에러 발생
        .handleEvents(receiveCompletion: { _ in print("2", person.name) } )
        .assign(to: \.name, on: person)
        .store(in: &subscriptions)
}

example(of: "assertNoFailure") {
    Just("Hello")
        .setFailureType(to: MyError.self)
//        .tryMap { _ in throw MyError.ohNo } // 오류 발생
        .assertNoFailure()
        .sink(receiveValue: { print("Got value: \($0) ")})
        .store(in: &subscriptions)
}


/*:
 ## Dealing with failure

 - 실패 가능한 Failure 타입의 이벤트를 처리하는 방법
 - try 계열 operators
   - 실패 가능한 Failure 타입을 가지는 Operator
   - failure 이벤트가 발생했을 때 completion block에서 처리할 수 있다.
   - **Subscription의 Custom Error 타입을 Swift 일반 Error 타입으로 변경시킨다.**
     - -> Custom Error 타입 처리 방법: Mapping errors
   - *tryMap(_:)* : 오류를 throw 할 수 있는 map 연산자
 - Mapping errors
   - *mapError(_:)* : mapError는 Upstream Publisher로부터 발생한 오류를 Custom Error 타입으로 매핑시킨다.
 */

example(of: "tryMap") {

    enum NameError: Error {
        case tooShort(String)
        case unknown
    }

    let names = ["Scott", "Marin", "Shai", "Florent"].publisher

    names
//        .map { value -> Int in    // map은 오류를 throw 할 수 없는 method기 때문에 (_) throws -> _ 을 수행할 수 없다.
        .tryMap { value -> Int in
            let length = value.count

            guard length >= 5 else {
                throw NameError.tooShort(value)
            }

            return value.count
    }
    .sink(receiveCompletion: {
        print("Completed with \($0)") },
          receiveValue: { print("Got value: \($0)") })
}

example(of: "map vs tryMap") {

    enum NameError: Error {
        case tooShort(String)
        case unknown
    }

    Just("Hello")
        .setFailureType(to: NameError.self)
//        .map { $0 + " World!" }
        .tryMap { $0 + " World!" }
//        .tryMap { throw NameError.tooShort($0) }  // 오류 발생
        .mapError { $0 as? NameError ?? .unknown }
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Done!")
                case .failure(.tooShort(let name)):
                    print("\(name) is too short!")
                case .failure(.unknown):
                    print("An unknown name error occurred")
                }
        },
            receiveValue: { print("Got value \($0)") }
    )
        .store(in: &subscriptions)
}

//: [Next](@next)
