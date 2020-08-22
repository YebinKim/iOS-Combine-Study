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

//: [Next](@next)
