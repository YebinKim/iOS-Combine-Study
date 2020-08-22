//: [Previous](@previous)

import Foundation
import Combine

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
