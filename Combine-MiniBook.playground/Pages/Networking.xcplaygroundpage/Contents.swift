//: [Previous](@previous)

import Foundation
import Combine

/*:
 # Networking

 - URLSession 을 이용한 URL 기반 네트워킹
 - Codable 프로토콜을 사용한 JSON 인코딩 & 디코딩
 - example - Chapter9 Networking 참고
 */

/*:
 ## URLSession extensions

 - **URLSession은 Apple의 Foundation framework에 포함된 클래스**
   - 표준 인터넷 프로토콜을 사용해 URL과 통신할 수 있는 API를 제공
   - **Data transfer task**: URL의 내용을 얻음 -> *유일하게 Combine Publisher 반환 가능한 task*
   - **Download task**: URL의 내용을 얻어서 파일로 저장
   - **Upload task**: URL에 파일 및 데이터를 업로드
   - **Stream task**: 송수신자 간의 데이터를 스트리밍
   - **Websocket task**: Websocket에 연결
 */

if let url = URL(string: "https://github.com/YebinKim/mydata.json") {
    let subscription = URLSession.shared   // AnyCancellable
        .dataTaskPublisher(for: url)
        .sink(receiveCompletion: { completion in
            if case .failure(let err) = completion {
                print("Retrieving data failed with error \(err)")
            }
        }, receiveValue: { data, response in
            print("Retrieved data of size \(data.count), response = \(response)")
        })
    
    subscription.cancel()
}

/*:
 ## Codable support

 - **Codable은 Swift의 Encodable 프로토콜과 Decodable 프로토콜을 모두 준수하는 타입**
   -  JSON과 같은 외부 데이터를 swift 커스텀 타입과 호환할 수 있게 만든다
 - *map(_:)* 과 *decode(type:decoder:)* 를 이용해 처리할 수 있음
   - map 데이터를 디코딩하는 것이기 때문에, 반드시 decode 전 map 해야함
 */

if let url = URL(string: "https://example.com/mydata.json") {
    let subscription = URLSession.shared   // AnyCancellable
        .dataTaskPublisher(for: url)
//        .tryMap { data, _ in
//            try JSONDecoder().decode(Int.self, from: data)    // Int -> 디코딩할 데이터 타입
//        }
        .map(\.data)
        .decode(type: Int.self, decoder: JSONDecoder())         // Int -> 디코딩할 데이터 타입
        .sink(receiveCompletion: { completion in
            if case .failure(let err) = completion {
                print("Retrieving data failed with error \(err)")
            }
        }, receiveValue: { object in
            print("Retrieved object \(object)")
        })
    
    subscription.cancel()
}

/*:
 ## Publishing network data to multiple subscribers

 - **다수의 Subscriber가 각 다른 네트워크 데이터를 요청할 때 사용**
 - *multicast(_:)* : ConnectablePublisher를 생성하고 Publisher의 connect() 를 연결할 때 값을 주입 및 동작
 - *store(in:)* : 현재 코드 범위를 벗어날 때 Publisher는 해제되고 Subscription은 취소되기 때문에 모든 Cancellable은 저장해야 함
 */

if let url = URL(string: "https://github.com/YebinKim/") {
    let publisher = URLSession.shared
        .dataTaskPublisher(for: url)
        .map(\.data)
        .multicast { PassthroughSubject<Data, URLError>() }
    
    let subscription1 = publisher
        .sink(receiveCompletion: { completion in
        if case .failure(let err) = completion {
            print("Sink1 Retrieving data failed with error \(err)")
        }
    }, receiveValue: { object in
        print("Sink1 Retrieved object \(object)")
    })
    
    let subscription2 = publisher
        .sink(receiveCompletion: { completion in
        if case .failure(let err) = completion {
            print("Sink2 Retrieving data failed with error \(err)")
        }
    }, receiveValue: { object in
        print("Sink2 Retrieved object \(object)")
    })
    
    let subscription = publisher.connect()
    
    subscription1.cancel()
    subscription2.cancel()
    subscription.cancel()
}

//: [Next](@next)
