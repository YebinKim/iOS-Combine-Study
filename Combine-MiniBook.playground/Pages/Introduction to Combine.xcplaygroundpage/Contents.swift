//: [Previous](@previous)

/*:
 # Introduction to Combine
 
 
 
 ## Combine 이란?

 - **선언적(Declarative)**이고 **반응적(Reactive)**인 iOS 앱을 개발할 수 있게 해주는 Apple의 프레임워크
 - 앱이 이벤트를 처리하는 방식에 대해 선언적인 접근 방식을 제공
 - 특정 이벤트 소스에 대해 단일 처리 체인을 만들 수 있음 *(Delegate callback 또는 Completion closure 대신)*
 
  
  
  
  
 ## Combine의 핵심 구성 요소
 
 ### Publishers
  
 - **값을 제공하는 요소. 시간이 지남에 따라 하나 이상의 subscribers 에게 값을 방출함**
 - 세 가지 유형의 이벤트 생성 가능
   - publisher의 출력 값 (0개 이상) - ***Output***
   - successful completion
   - publisher의 실패 타입 error completion - ***Failure***
 - completion으로 완료된 publisher는 다른 이벤트를 생성하지 않음
 - Subscriber가 없는 경우 값을 방출하지 않음
 - publisher protocol은 두 가지 타입의 generic을 준수함
   - Publisher.Output - publisher의 출력 값 타입
   - Publisher.Failure - publisher가 실패할 경우 발생하는 오류 타입
  
  
  
 ### Operators
  
 - **publisher protocol 에서 선언된 메서드**
 - 동일하거나 새로운 publisher 를 반환
 - 여러 연산자를 체이닝할 수 있음 (단, 정확한 입력 / 출력 타입을 지켜야 함)
 - 항상 Upstream(입력) 및 Downstream(출력)을 가짐
  
  
  
 ### Subscribers
  
 - **체이닝을 통해 최종적으로 수행하는 액션**
 - 체이닝의 출력 값 또는 completion 이벤트를 이용함
 - 두 종류의 Subscriber 이용 가능
   - Sink subscriber - 출력 값과 completion을 수행할 수 있는 closure 제공
   - Assign subscriber - 출력 값을 프로퍼티(데이터 모델 또는 UIControl)에 바인딩함으로써 화면에 직접 데이터 표시
  
  
  
 ### Subscriptions (구독)
  
 - **Subcription protocol 과 해당 객체, Publisher, Operator, Subscriber 로 구성되는 전체 체인**
 - Subcription이 끝날 때 Subscriber를 추가하면, Publisher는 항상 활성화 된 상태를 유지
 - 즉, 이벤트 체인을 한 번 생성하면 다시 데이터 또는 콜백을 가져오거나 호출할 필요가 없음
 - Subscriber 를 추가하는 것을 **"구독한다"**고 표현
 */

//: [Next](@next)
