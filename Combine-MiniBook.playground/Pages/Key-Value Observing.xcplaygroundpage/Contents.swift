//: [Previous](@previous)

import Foundation
import Combine

/*:
 # Key-Value Observing (KVO)

 - *KVO* 에 호환되는 프로퍼티를 생성할 수 있는 Publisher
 - *ObservableObject* 프로토콜을 사용하면 다수의 값 변화를 다룰 수 있음
 */

/*:
 ## Introducing publisher(for:options:)

 - **publisher(for:options:) : for 매개변수 프로퍼티를 옵저빙하는 Publisher**
 - KVO 는 Objective-C 에서부터 사용하던 핵심 요소
 - Swift Standard Library의 Foundation, UIKit 및 AppKit 클래스의 많은 속성은 KVO를 준수함 -> KVO 메커니즘으로 값 변화를 관찰할 수 있음
 */

let queue = OperationQueue()
let queueSubscription = queue.publisher(for: \.operationCount)
    .sink {
        print("Outstanding operations in queue: \($0)")
}

/*:
 ## KVO-compliant properties

 - **KVO를 사용하기 위한 조건**
   - **NSObject를 상속받는 Class**
   - **@objc dynamic 속성 프로퍼티**
 - 오브젝트의 publisher에 옵저빙할 프로퍼티를 구독
 - *Property cannot be marked @objc because its type cannot be represented in Objective-C* 에러가 발생할 경우
   - 순수 스위프트 타입의 경우 발생, @objc dynamic var structProperty: PureSwift = .init(a: (0, false)) 추가
 */

/*:
 ## Observation options

 - publisher(for:options:) 의 options 매개변수 배열로 전달할 수 있는 *NSKeyValueObservingOptions* 옵션
 - Default - [.initial]
   - *.initial* : 초기값을 방출
   - *.prior* : 변화가 있을 때 이전 값과 새로 받은 값을 방출
   - *.new* : 적용 가능할 때, change dictionary에 새로운 속성 값을 제공해야 함
     - Indicates that the change dictionary should provide the new attribute value, if applicable
   - *.old* : 적용 가능할 때, change dictionary에 이후 속성 값이 포함되어야 함
     - Indicates that the change dictionary should contain the old attribute value, if applicable
 */

class TestObject: NSObject {
    @objc dynamic var integerProperty: Int = 0
    @objc dynamic var stringProperty: String = ""
    @objc dynamic var arrayProperty: [Float] = []
}

let obj = TestObject()

// TestObject의 Int 값 프로퍼티(integerProperty)의 변화를 옵저빙
//let intSubscription = obj.publisher(for: \.integerProperty)
let intSubscription = obj.publisher(for: \.integerProperty, options: [.prior])
    .sink {
        print("integerProperty changes to \($0)")
}
// TestObject의 String 값 프로퍼티(stringProperty)의 변화를 옵저빙
let stringSubscription = obj.publisher(for: \.stringProperty)
    .sink {
        print("stringProperty changes to \($0)")
}
// TestObject의 Array 값 프로퍼티(arrayProperty)의 변화를 옵저빙
let arraySubscription = obj.publisher(for: \.arrayProperty)
    .sink {
        print("arrayProperty changes to \($0)")
}

obj.integerProperty = 100
obj.integerProperty = 200

obj.stringProperty = "Hello😊"
obj.stringProperty = "Combine☘️"

obj.arrayProperty = [1.0]
obj.arrayProperty = [1.0, 2.0]

/*:
 ## ObservableObject

 - **NSObject 를 상속하지 않는 Swift 오브젝트에서 Combine KVO를 사용할 수 있게 하는 프로토콜**
 - *@Published* 속성 래퍼와 컴파일러에서 생성한 objectWillChange Publisher를 쌍으로 사용해 클래스를 만들 수 있음
 - ObservableObject 프로토콜을 준수하는 오브젝트는 objectWillChange 프로퍼티를 자동으로 생성
 */

class MonitorObject: ObservableObject {
    @Published var someProperty = false
    @Published var someOtherProperty = ""
}

let object = MonitorObject()
let subscription = object.objectWillChange.sink {
    print("object will change")
}

object.someProperty = true
object.someOtherProperty = "Hello Combine"

//: [Next](@next)
