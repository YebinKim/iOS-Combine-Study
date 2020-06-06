//: [Previous](@previous)

import Foundation
import Combine

/*:
 # Publishers & Subscribers
 
 
 
 ## Publisher
 
 - Combine의 핵심 -> Publisher protocol
 - **하나 이상의 Subscribers에게 값을 방출할 수 있는 유형의 요구사항을 정의함**
 - 값을 포함할 수 있는 이벤트를 게시하거나 생성함
 */

example(of: "Publisher") {
    let myNotification = Notification.Name("MyNotification")
    let publisher = NotificationCenter.default
        .publisher(for: myNotification, object: nil)
    _ = publisher   // 워닝 제거
    
    let center = NotificationCenter.default
    
    let observer = center.addObserver(
        forName: myNotification,
        object: nil,
        queue: nil) { notification in
            print("Notification received!")
    }
    _ = observer
}

/*:
 ## Subscriber
 
 - **Publisher로부터 값을 입력받을 수 있는 유형의 요구사항을 정의함**
 */

example(of: "Subscriber") {
    let myNotification = Notification.Name("MyNotification")
    let publisher = NotificationCenter.default
        .publisher(for: myNotification, object: nil)
    
    let center = NotificationCenter.default
    _ = center
    
    let subscription = publisher
        .sink { _ in
            print("Notification received from a publisher!")
    }
    _ = subscription
}

/*:
 ## Cancellable

 - Subscriber가 완료된 후 더이상 Publisher로부터 값을 받고싶지 않을 경우 구독을 취소하기 위한 protocol
 - Subcriptions은 완료될 때 AnyCancellable 인스턴스를 "cancellation token"으로 반환함으로써 구독 취소 가능
 */

// var subscriptions = Set<AnyCancellable>()

example(of: "Publisher") {
    let myNotification = Notification.Name("MyNotification")
    let publisher = NotificationCenter.default
        .publisher(for: myNotification, object: nil)
    _ = publisher
    
    let center = NotificationCenter.default
    
    let observer = center.addObserver(
        forName: myNotification,
        object: nil,
        queue: nil) { notification in
            print("Notification received!")
    }
    
    // Cancellable
    center.post(name: myNotification, object: nil)
    center.removeObserver(observer)
}

example(of: "Subscriber") {
    let myNotification = Notification.Name("MyNotification")
    let publisher = NotificationCenter.default
        .publisher(for: myNotification, object: nil)
    
    let center = NotificationCenter.default
    
    let subscription = publisher
        .sink { _ in
            print("Notification received from a publisher!")
    }
    
    // Cancellable
    center.post(name: myNotification, object: nil)
    subscription.cancel()
}

//: [Next](@next)
