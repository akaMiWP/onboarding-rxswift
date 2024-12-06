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
        let points = hand.map { $0.1 }.reduce(0, +)
        if points > 21 {
            dealtHand.onError(HandError.busted(points: points))
        } else {
            dealtHand.onNext(hand)
        }
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

/// 2nd challenge
example(of: "Observe and check user session state using a behavior relay") {
    enum UserSession {
        case loggedIn, loggedOut
    }
    
    enum LoginError: Error {
        case invalidCredentials
    }
    
    let disposeBag = DisposeBag()
    
    // Create userSession BehaviorRelay of type UserSession with initial value of .loggedOut
    let behaviorRelay = BehaviorRelay<UserSession>(value: .loggedOut)
    
    // Subscribe to receive next events from userSession
    behaviorRelay
        .subscribe(
            onNext: { session in
                print(session)
            },
            onError: { error in
                print(error)
            }
        )
        .disposed(by: disposeBag)
    
    func logInWith(username: String, password: String, completion: (Error?) -> Void) {
        guard username == "johnny@appleseed.com",
              password == "appleseed" else {
            completion(LoginError.invalidCredentials)
            return
        }
        
        // Update userSession
        behaviorRelay.accept(.loggedIn)
    }
    
    func logOut() {
        // Update userSession
        behaviorRelay.accept(.loggedOut)
    }
    
    func performActionRequiringLoggedInUser(_ action: () -> Void) {
        // Ensure that userSession is loggedIn and then execute action()
        if behaviorRelay.value == .loggedIn {
            action()
        }
    }
    
    for i in 1...2 {
        let password = i % 2 == 0 ? "appleseed" : "password"
        
        logInWith(username: "johnny@appleseed.com", password: password) { error in
            guard error == nil else {
                print(error!)
                return
            }
            
            print("User logged in.")
        }
        
        performActionRequiringLoggedInUser {
            print("Successfully did something only a logged in user can do.")
        }
    }
}
