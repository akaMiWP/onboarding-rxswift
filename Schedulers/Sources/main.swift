// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import RxSwift

print("\n\n\n===== Schedulers =====\n")

let globalScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())
let bag = DisposeBag()
let animal = BehaviorSubject(value: "[dog]")

animal
  .dump()
  .dumpingSubscription()
  .disposed(by: bag)

// Start coding here

let fruit = Observable<String>.create { observer in
  observer.onNext("[apple]")
  sleep(2)
  observer.onNext("[pineapple]")
  sleep(2)
  observer.onNext("[strawberry]")
  return Disposables.create()
}


fruit
    .subscribeOn(globalScheduler)
    .dump()
    .observeOn(MainScheduler.instance)
    .dumpingSubscription()
    .disposed(by: bag)


RunLoop.main.run(until: Date(timeIntervalSinceNow: 13))

