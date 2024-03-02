/*:
 [이전으로](@previous) [다음으로](@next)
 # Convenience Subscribers
 */

import Combine
import Foundation

// MARK: - Demand Struct
//
/// 특정 타입의 값을 받을 수 있는 Subscribe 프로토콜
/// Subscriber 프로토콜을 채택

fileprivate class DemandSubscriber: Subscriber {
    typealias Input = Int
    typealias Failure = Never
    
    // subscription을 시작할 때 호출되는 메서드
    //
    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }
    
    // 새로운 값을 받을 때 호출되는 메서드
    //
    func receive(_ input: Int) -> Subscribers.Demand {
        print("Received value: \(input)")
        
        return .none
    }
    
    // subscription이 완료되었을 때 호출되는 메서드
    //
    func receive(completion: Subscribers.Completion<Never>) {
        print("Subscription completed")
    }
}

/// 예제
///
private let sequencePublisher = (1...4).publisher
private let demandSubscriber = DemandSubscriber()

sequencePublisher.subscribe(demandSubscriber)

