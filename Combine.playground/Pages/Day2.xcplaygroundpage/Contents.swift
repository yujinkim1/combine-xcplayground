/*:
 [이전으로](@previous) [다음으로](@next)
 # Convenience Subscribers
 */

import Combine
import Foundation

private var cancellables = Set<AnyCancellable>()

// MARK: - Demand Subscriber Struct
//
/// 특정 타입의 값을 받을 수 있는 Subscribe 프로토콜
/// Subscriber 프로토콜을 채택
///
private class DemandSubscriber: Subscriber {
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

print("==== Demand Subscriber ====")

sequencePublisher.subscribe(demandSubscriber)

// MARK: - Assign Subscriber Class
//
/// key path로 표시된 프로퍼티에 수신된 값을 할당하는 간단한 Subscriber
/// - Parameters:
///   - object: 프로퍼티를 가지고 있는 어떠한 객체
///   - keyPath: 할당할 프로퍼티를 나타내는 key path
///
/// 예제
///
private class ExampleValue {
    var value: Int {
        didSet {
            print("value changed to \(value)")
        }
    }
    
    init(value: Int) {
        self.value = value
        
        print("initial value is \(value)")
    }
    
    deinit {
        print("==== deinit \(self) ====")
    }
}

private let object = ExampleValue(value: 0)

private let assignSubscriber = Subscribers.Assign<ExampleValue, Int>(object: object, keyPath: \.value)

private let exampleValuePublisher = (1...8).publisher

print("==== Assign Subscriber ====")

exampleValuePublisher
    .subscribe(assignSubscriber)

print(object.value)

/// 이미 Publishers의 Operator 중 assign이라는 메서드가 구현되어 있어 내부에서 바로 사용 가능
///
exampleValuePublisher
    .assign(to: \.value, on: object)
    .store(in: &cancellables) // 강한 참조로 인스턴스가 메모리에서 해제되지 않으면 메모리 누수가 발생하기 때문에 AnyCancellable 컨테이너에 저장

print(object.value)

// MARK: - Sink Subscriber Class
//
/// 횟수 제한 없이 구독을 통해 값을 요청하는 간단한 Subscriber
///
private let sinkPublisher = (1...8).publisher

private let sinkSubscriber = Subscribers.Sink<Int, Never>(
    receiveCompletion: { completion in
        print("Received completion: \(completion)")
    },
    receiveValue: { value in
        print("Received value: \(value)")
    }
)

print("==== Sink Subscriber ====")

sinkPublisher.subscribe(sinkSubscriber)

/// assign과 마찬가지로 sink도 Publisher 내부에 구현되어 있어서 바로 사용 가능
///
(1...8).publisher
    .sink { completion in
        print("Received completion: \(completion)")
    } receiveValue: { value in
        print("Received value: \(value)")
    }
