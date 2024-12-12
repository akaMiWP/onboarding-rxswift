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


RunLoop.main.run(until: Date(timeIntervalSinceNow: 13))
