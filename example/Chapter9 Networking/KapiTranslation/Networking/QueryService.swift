//
//  QueryService.swift
//  KapiTranslation
//
//  Created by Yebin Kim on 2020/02/27.
//  Copyright © 2020 김예빈. All rights reserved.
//

import Foundation
import Combine

class QueryService {
    
    // MARK: - Properties
    
    let apiKey = "7083584b8cb4305eb7610d0a8aedf340"
    
    var errorMessage = ""
    
    var cancelBag = Set<AnyCancellable>()
    
    typealias QueryResult = (String) -> Void
    
    // MARK: - Actions
    
    func getTransResults(_ text: String, srcLan: String, targetLan: String, completion: @escaping QueryResult) {
        
        let headers = ["Authorization": "KakaoAK \(apiKey)"]
        let text = text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let urlString = "https://kapi.kakao.com/v1/translation/translate"
        let query = "?query=\(text)&src_lang=\(srcLan)&target_lang=\(targetLan)"

        var request = URLRequest(url: NSURL(string: urlString + query)! as URL,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers

        URLSession.shared
            .dataTaskPublisher(for: request)    // * 비동기로 동작하기 때문에
            .map(\.data)
            .decode(type: Translated.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { received in
                switch received {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { object in
                completion(object.translatedText.first?.first ?? self.errorMessage)
            })
            .store(in: &self.cancelBag)         // * 스트림을 cancelBag에 저장해줘야 함
            // => 현재 코드 범위를 벗어날 때 Publisher는 해제되고 Subscription은 취소되기 때문에,
            //    모든 Cancellable은 저장해야 함
    }
    
}

