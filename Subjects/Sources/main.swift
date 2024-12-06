// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import RxSwift

/// PublishSubject will re-emit their stop event to future subscribers
/// This is useful for bidding scenario that notifies the newcomers after the bidding event to see completed bidding event shown
example(of: "PublishSubject") {
    let subject = PublishSubject<String>()
    
    let subscriptionOne = subject
        .subscribe(onNext: { string in
            print(string)
        })
    
    subject.on(.next("Is anyone listening?"))
    subject.onNext("2")
    
    let subscriptionTwo = subject
        .subscribe { event in
            print("2)", event.element ?? event)
        }
    
    subject.onNext("3")
    
    subscriptionOne.dispose()
    
    subject.onNext("4")
    
    // 1
    subject.onCompleted()
    // 2
    subject.onNext("5")
    
    // 3
    subscriptionTwo.dispose()
    
    let disposeBag = DisposeBag()
    
    // 4
    subject
        .subscribe {
            print("3)", $0.element ?? $0)
        }
        .disposed(by: disposeBag)
    
    subject.onNext("?")
    
}

// 1
enum MyError: Error {
    case anError
}

// 2
func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
    print(label, (event.element ?? event.error) ?? event)
}

// 3
example(of: "BehaviorSubject") {
    // 4
    let subject = BehaviorSubject(value: "Initial value")
    let disposeBag = DisposeBag()
    
    subject.onNext("X")

    subject
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    
    // 1
    subject.onError(MyError.anError)

    // 2
    subject
      .subscribe {
        print(label: "2)", event: $0)
      }
      .disposed(by: disposeBag)

}
