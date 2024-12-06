// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import RxSwift
import RxRelay

/// PublishSubject will re-emit their **stop event** to future subscribers
/// This is useful for bidding scenario that notifies the newcomers after the bidding event to see completed bidding event shown
/// or in transient state where the previous state doesn't matter such as tapping on a button before the subscriber is created
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

/// Behavior subjects work similarly to publish subjects, except they will replay the latest next event to new subscribers
/// Behavior subjects are useful when you want to pre-populate a view with the most recent data.
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

example(of: "ReplaySubject") {
    // 1
    let subject = ReplaySubject<String>.create(bufferSize: 2)
    let disposeBag = DisposeBag()
    
    // 2
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    
    // 3
    subject
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    
    subject
        .subscribe {
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
    
    subject.onNext("4")
    subject.onError(MyError.anError)
    subject.dispose()
    
    subject
        .subscribe {
            print(label: "3)", event: $0)
        }
        .disposed(by: disposeBag)
}

example(of: "PublishRelay") {
    let relay = PublishRelay<String>()
    
    let disposeBag = DisposeBag()
    
    relay.accept("Knock knock, anyone home?")
    relay
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    relay.accept("1")
    
}

example(of: "BehaviorRelay") {
    // 1
    let relay = BehaviorRelay(value: "Initial value")
    let disposeBag = DisposeBag()
    
    // 2
    relay.accept("New initial value")
    // 3
    relay
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    
    // 1
    relay.accept("1")
    
    // 2
    relay
        .subscribe {
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
    
    // 3
    relay.accept("2")
    
    print(relay.value)
}

// MARK: - Challenges

/// 1st challenge
example(of: "Create a blackjack card dealer using a publish subject") {
    
    let disposeBag = DisposeBag()
    
    let dealtHand = PublishSubject<[(String, Int)]>()
    
    func deal(_ cardCount: UInt) {
        var deck = cards
        var cardsRemaining = deck.count
        var hand = [(String, Int)]()
        
        for _ in 0..<cardCount {
            let randomIndex = Int.random(in: 0..<cardsRemaining)
            hand.append(deck[randomIndex])
            deck.remove(at: randomIndex)
            cardsRemaining -= 1
        }
        
        // Add code to update dealtHand here
        dealtHand.onNext(hand)
    }
    
    // Add subscription to dealtHand here
    dealtHand
        .subscribe(
            onNext: {
                print(cardString(for: $0), points(for: $0))
            },
            onError: {
                print($0)
            }
        )
        .disposed(by: disposeBag)
    
    deal(3)
}
