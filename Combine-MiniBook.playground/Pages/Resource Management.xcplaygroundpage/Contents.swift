//: [Previous](@previous)

import Foundation
import Combine

/*:
 # Resource Management

 - Publisher의 생성 값을 다수의 Subscriber가 공유할 수 있게 함 *(relay 할 수 있게 함)*
 */

/*:
 ## The share() operator

 - **Publisher 가 값(Value)이 아닌 참조(Reference)를 가질 수 있게 하는 방법**
   - Publisher는 일반적으로 구조체이기 때문에 **값을 복사**해서 전달
 - *share()* 연산자를 사용하면 Publusher의 클래스 인스턴스를 반환하기 때문에 Upstream Publisher를 공유할 수 있음
 - Upstream Publisher의 요청이 완료된 이후에는 새로운 Publisher를 구독해도 아무것도 수신하지 않음
 */

let shared = URLSession.shared
    .dataTaskPublisher(for: URL(string: "https://github.com/YebinKim")!)
    .map(\.data)
    .print("shared")
    .share()

print("subscribing first")

let sharedSubscription1 = shared.sink(
    receiveCompletion: { _ in },
    receiveValue: { print("sharedSubscription1 received: '\($0)'") }
)

print("subscribing second")

let sharedSubscription2 = shared.sink(
    receiveCompletion: { _ in },
    receiveValue: { print("sharedSubscription2 received: '\($0)'") }
)

// 요청이 완료된 후 구독을 시작하면 sharedSubscription2 는 아무것도 수신하지 않음
// 5초 딜레이 시킴으로써 확인 가능
//var sharedSubscription2: AnyCancellable? = nil
//DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//    print("subscribing second")
//    subscription2 = shared.sink(
//        receiveCompletion: { print("sharedSubscription2 completion \($0)") },
//        receiveValue: { print("sharedSubscription2 received: '\($0)'") }
//    )
//}

/*:
 ## The multicast(_:) operator

 - **Upstream Publisher의 요청이 완료된 이후에도 값을 공유할 수 있게 하는 방법**
 - *shareReplay()* 또는 *multicast(_:)* 사용
 - multicast(_:) 연산자는 ConnectablePublisher 타입의 Publisher를 반환함
   - *connect()* 를 호출할 때 까지 구독을 시작하지 않음ㅎ
 */

let subject = PassthroughSubject<Data, URLError>()
let multicasted = URLSession.shared
    .dataTaskPublisher(for: URL(string: "https://github.com/YebinKim")!)
    .map(\.data)
    .print("shared")
    .multicast(subject: subject)

let multicastedSubscription1 = multicasted .sink(
    receiveCompletion: { _ in },
    receiveValue: { print("multicastedSubscription1 received: '\($0)'") }
)
let multicastedSubscription2 = multicasted .sink(
    receiveCompletion: { _ in },
    receiveValue: { print("multicastedSubscription2 received: '\($0)'") }
)

multicasted.connect()
subject.send(Data())

/*:
 ## Future

 - **구독 없이 Task를 시작하고, 값을 공유해야할 때 사용할 수 있는 방법**
 - Promise 인수를 받는 클로저를 전달하여 Future를 생성할 수 있음
 - Future 클래스는 생성과 동시에 클로저를 호출 -> 즉시 결과값을 반환함
 - Promise 의 값을 저장해뒀다가 구독될 때 값을 제공함
 */

/*
let future = Future<Int, Error> { fulfill in
    do {
        let result = try performSomeWork()
        fulfill(.success(result))
    } catch {
        fulfill(.failure(error))
    }
}
*/

//: [Next](@next)
