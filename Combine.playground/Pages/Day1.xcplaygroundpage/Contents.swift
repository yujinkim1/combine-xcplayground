/*:
 [Previous](@previous)
 # Publisher 종류
 */
//: [Next](@next)

import Foundation
import Combine

// MARK: - Just
//
/// 단일 값을 한 번만 방출하고 완료되는 publisher
/// 에러 타입은 항상 Never
///
private let justPublisher = Just(25)

/// 예제
/// 절대 실패하지 않는 publisher이기 때문에 아래 클로저 형태로 값을 방출
///
justPublisher.sink { value in
    print("**** justPublisher ****")
    print("value: \(value)")
}

// MARK: - Future
//
/// 비동기 작업의 결과를 나타내는 publisher
/// 비동기 작업이 완료되면 단일 값을 방출하고 완료
///
private let futurePublisher = Future<Int, Error> { promise in
    DispatchQueue.global().asyncAfter(deadline: .now() + 4) {
        let value = 25
        
        promise(.success(value))
    }
}

/// 예제
futurePublisher.sink { value in
    print("비동기 작업 결과: \(value)")
} receiveValue: { value in
    print("값을 수신했습니다. \(value)")
}

// MARK: - Empty
/// 아무런 값도 발신하지 않지만 즉시 완료되는 publisher
///
/// - Parameter completeImmediately: publisher가 즉시 완료되어야 하는지 지정 가능
private let emptyPublisher = Empty<Any, Error>(completeImmediately: true)

/// 예제
///
emptyPublisher.sink { completion in
    print("**** emptyPublisher ****")
    print("completion: \(completion)", separator: " ")
} receiveValue: { value in
    print("value: \(value)")
}

// MARK: - Fail
//
enum SomeError: Error {
    case notfound
    
    func description() -> String {
        switch self {
        case .notfound: return "아무것도 찾지 못했습니다."
        }
    }
}
/// 특정 에러와 함께 즉시 완료되는 publisher
/// 아무런 값도 방출하지 않고 오직 에러만 방출
///
private let failPublisher = Fail<String, SomeError>(error: SomeError.notfound)

/// 예제
///
failPublisher.sink { completion in
    switch completion {
    case .failure(let error):
        print("**** failPublisher ****")
        print("completion: \(completion) \(error.description())", separator: " ")
    case .finished: print()
    }
} receiveValue: { _ in }

// MARK: - Deferred
//
/// subscribe 전에는 대기 상태였다가 subscribe 이후 수행하는 publisher
/// 클로저 내부에 지연 수행할 publisher를 반환
private let defferedPublisher = Deferred {
    Just(50)
}

// MARK: - Sequence
//
/// 시퀀스를 반환하는 publisher
/// 시퀀스의 요소들을 각 하나씩 모두 방출하다가 모든 요소들이 방출되었을 때 완료
private let sequencePublisher = (1...10).publisher

/// 예제
///
sequencePublisher.sink { completion in
    print("**** sequencePublisher ****")
    print("completion: \(completion)")
} receiveValue: { value in
    print("value: \(value)")
}

// MARK: - Timer
//
/// 일정 시간 간격마다 Date를 방출하는 publisher
/// Timer 인스턴스 메서드 형태로 publisher를 생성하고 사용 가능
///
private let timerPublisher = Timer.publish(every: 1.0, on: .main, in: .common)

/// 예제
///
private let timerSubscription = timerPublisher.autoconnect()
    .sink { value in
        print("**** timerPublisher ****")
        print("\(value)")
    }

timerPublisher.connect()

DispatchQueue.main.asyncAfter(deadline: .now() +  5.0) {
    timerSubscription.cancel()
}

