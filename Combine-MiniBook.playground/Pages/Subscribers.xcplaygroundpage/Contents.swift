//: [Previous](@previous)

import Foundation
import Combine

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

//: [Next](@next)
