// The Swift Programming Language
// https://docs.swift.org/swift-book

import RxSwift

example(of: "just, of, from") {
    // 1
    let one = 1
    let two = 2
    let three = 3
    
    // 2
    let observable = Observable<Int>.just(one)
    let observable2 = Observable.of(one, two, three)
}

