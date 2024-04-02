/*:
 [이전으로](@previous) [다음으로](@next)
 # Convenience Publishers
 */

import Combine
import Foundation

// MARK: - Just Struct
//
/// 단일 값을 한 번만 방출하고 완료되는 publisher
/// 자신을 구독하고 있는 subscriber에게 값을 방출하고 finished 컴플리션 이벤트 발생
/// Failure 타입은 항상 Never
///
private let justPublisher = Just(25)

/// 예제
///
print("**** justPublisher ****")

justPublisher.sink { completion in
    print("Received completion: \(completion)")
} receiveValue: { value in
    print("Received value: \(value)")
}

// MARK: - Future Class
//
/// 단일 작업의 결과를 비동기 이벤트로 생성하는 publisher
/// 비동기 작업이 완료되면 subscriber에게 단일 값을 방출하고 컴플리션 이벤트 발생
/// Promise는 값을 전달할 때 호출되는 클로저
/// Failure 타입은 Error 또는 Never
///
private var delay: TimeInterval = 4
private var cancellables = Set<AnyCancellable>()

private let futurePublisher = Future<Int, Error> { promise in
    delay -= 1
    DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
        let value = 25
        promise(.success(value))
    }
}

/// 예제
///
print("**** futurePublisher ****")

for i in 1...4 {
    futurePublisher.sink { completion in
        print("Received completion \(i)회: \(completion)")
    } receiveValue: { value in
        print("Received value \(i)회: \(value)")
    }
    .store(in: &cancellables)
}

// MARK: - Empty Struct
/// 아무런 값도 전달하지  않지만 즉시 컴플리션 이벤트를 발생하는  publisher
///
/// - Parameter completeImmediately: 컴플리션 이벤트를 바로 전달할지 지정 가능
private let emptyPublisher = Empty<Any, Error>(completeImmediately: true)

/// 예제
///
print("**** emptyPublisher ****")

emptyPublisher.sink { completion in
    print("Received completion: \(completion)")
} receiveValue: { value in
    print("Received value: \(value)")
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
/// 특정 에러를 즉시 전달할 수 있는 publisher
/// 아무런 값도 전달하지 않고 오직 에러만 전달
///
private let failPublisher = Fail<String, SomeError>(error: SomeError.notfound)

/// 예제
///
print("**** failPublisher ****")

failPublisher.sink { completion in
    switch completion {
    case .failure(let error):
        print("Received completion: \(completion), description: \(error.description())")
    case .finished: return
    }
} receiveValue: { value in
    print("Received value: \(value)")
}

// MARK: - Deferred Struct
//
/// subscribe 전에는 대기 상태였다가 subscribe 이후 수행하는 publisher
/// 클로저 내부에 지연 수행할 publisher를 반환
private let defferedPublisher = Deferred {
    Just(50)
}

defferedPublisher
    .sink { completion in
        switch completion {
        case .finished:
            print("Received completion: \(completion)")
        case .failure(let error):
            print("Received completion: \(error)")
        }
    } receiveValue: { value in
        print("Received value: \(value)")
    }

// MARK: - Sequence Struct
//
/// 시퀀스를 반환하는 publisher
/// 시퀀스의 요소들을 각 하나씩 모두 방출하다가 모든 요소들이 방출되었을 때 완료
private let sequencePublisher = (1...10).publisher

/// 예제
///
print("**** sequencePublisher ****")

sequencePublisher.sink { completion in
    print("Received completion: \(completion)")
} receiveValue: { value in
    print("Received value: \(value)")
}

// MARK: - Record Struct
//
/// Input과 컴플리션을 기록하고 나중에 각 subscriber에게 전달하는 publisher
///
private let recordPublisher = Record<String, Never>(
    output: ["first", "second", "third"],
    completion: .finished
)

/// 예제
///
print("**** recordPublisher ****")

recordPublisher.sink { completion in
    print("Received completion: \(completion)")
} receiveValue: { value in
    print("Received value: \(value)")
}

// MARK: - Timer publish method
//
/// 일정 시간 간격마다 Date를 방출하는 publisher
/// Timer 인스턴스 메서드 형태로 publisher를 생성하고 사용 가능
///
private let timerPublisher = Timer.publish(every: 1.0, on: .main, in: .common)

/// 예제
///
print("**** timerPublisher ****")

private let timerSubscription = timerPublisher.autoconnect()
    .sink { value in
        print("Received value: \(value)")
    }

timerPublisher.connect()

DispatchQueue.main.asyncAfter(deadline: .now() +  4) {
    timerSubscription.cancel()
}
