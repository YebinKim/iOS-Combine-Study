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
 - *setFailureType* : failure 타입이 Never인 Publisher에서만 사용되는 연산자, custom failure 타입을 지정할 수 있다. (단, Failure 타입은 Never 타입이어야 한다.)
 - *assign(to:on:)* : failure 타입이 Never인 Publisher에서만 사용되는 연산자, key path 중 오류가 있으면 결과값으로 unhandled error를 받거나 이상 동작 발생
 - *assertNoFailure* : Swift의 *fatalError*와 비슷한 동작, Upstream에서 failure 이벤트를 완료할 수 없을 때 Debug Error 출력
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
        .tryMap { _ in throw MyError.ohNo } // 오류 발생
        .assertNoFailure()
        .sink(receiveValue: { print("Got value: \($0) ")})
        .store(in: &subscriptions)
}

//: [Next](@next)
