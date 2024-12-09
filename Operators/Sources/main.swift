import Foundation
import RxSwift

// MARK: - Filtering operators

example(of: "ignoreElements") {
    // 1
    let strikes = PublishSubject<String>()
    
    let disposeBag = DisposeBag()
    
    // 2
    strikes
        .ignoreElements()
        .subscribe { _ in
            print("You're out!")
        }
        .disposed(by: disposeBag)
    
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onCompleted()
    
}

example(of: "elementAt") {
    
    // 1
    let strikes = PublishSubject<String>()
    
    let disposeBag = DisposeBag()
    
    //  2
    strikes
        .elementAt(2)
        .subscribe(onNext: { _ in
            print("You're out!")
        })
        .disposed(by: disposeBag)
    
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onNext("X")
    
}

example(of: "filter") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(1, 2, 3, 4, 5, 6)
    // 2
        .filter { $0.isMultiple(of: 2) }
    // 3
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "skip") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of("A", "B", "C", "D", "E", "F")
    // 2
        .skip(3)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "skipWhile") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(2, 2, 3, 4, 4)
    // 2
        .skipWhile { $0.isMultiple(of: 2) }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "skipUntil") {
    let disposeBag = DisposeBag()
    
    // 1
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    // 2
    subject
        .skipUntil(trigger)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    subject.onNext("A")
    subject.onNext("B")
    
    trigger.onNext("X")
    subject.onNext("C")
}

example(of: "take") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(1, 2, 3, 4, 5, 6)
    // 2
        .take(3)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "takeWhile") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(2, 2, 4, 4, 6, 6)
    // 2
        .enumerated()
    // 3
        .takeWhile { index, integer in
            // 4
            integer.isMultiple(of: 2) && index < 3
        }
    // 5
        .map(\.element)
    // 6
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "takeUntil") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(1, 2, 3, 4, 5)
    // 2
        .takeUntil(.inclusive) { $0.isMultiple(of: 4) }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "takeUntil trigger") {
    let disposeBag = DisposeBag()
    
    // 1
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    // 2
    subject
        .takeUntil(trigger)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    // 3
    subject.onNext("1")
    subject.onNext("2")
    trigger.onNext("X")
    
    subject.onNext("3")
}

example(of: "distinctUntilChanged") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of("A", "A", "B", "B", "A")
    // 2
        .distinctUntilChanged()
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "distinctUntilChanged(_:)") {
    let disposeBag = DisposeBag()
    
    // 1
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    // 2
    Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
    // 3
        .distinctUntilChanged { a, b in
            print("A: ", a, "B: ", b)
            // 4
            guard
                let aWords = formatter
                    .string(from: a)?
                    .components(separatedBy: " "),
                let bWords = formatter
                    .string(from: b)?
                    .components(separatedBy: " ")
            else {
                return false
            }
            
            print("aWords:", aWords, "bWords: ", bWords)
            var containsMatch = false
            
            // 5
            for aWord in aWords where bWords.contains(aWord) {
                containsMatch = true
                break
            }
            
            return containsMatch
        }
    // 6
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

// MARK: - Challenges - Filtering operators

example(of: "Challenge 1 - Filtering operators") {
    let disposeBag = DisposeBag()
    
    let contacts = [
        "603-555-1212": "Florent",
        "212-555-1212": "Shai",
        "408-555-1212": "Marin",
        "617-555-1212": "Scott"
    ]
    
    func phoneNumber(from inputs: [Int]) -> String {
        var phone = inputs.map(String.init).joined()
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 3)
        )
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 7)
        )
        
        return phone
    }
    
    let input = PublishSubject<Int>()
    
    // Add your code here
    input
        .skipWhile { $0 == 0 }
        .filter { $0 < 10 }
        .take(10)
        .toArray()
        .subscribe(
            onSuccess: { numbers in
                let phone = phoneNumber(from: numbers)
                print("Phone: ", phone)
                if let contact = contacts[phone] {
                    print("Dialing \(contact) (\(phone))...")
                } else {
                    print("Contact not found")
                }
            },
            onError: { error in
            }
        )
    
    
    
    input.onNext(0)
    input.onNext(603)
    
    input.onNext(2)
    input.onNext(1)
    
    // Confirm that 7 results in "Contact not found",
    // and then change to 2 and confirm that Shai is found
    input.onNext(2)
    
    "5551212".forEach {
        if let number = (Int("\($0)")) {
            input.onNext(number)
        }
    }
    
    input.onNext(9)
}

// MARK: - Transforming operators

example(of: "toArray") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of("A", "B", "C")
    // 2
        .toArray()
        .subscribe(onSuccess: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "map") {
    let disposeBag = DisposeBag()
    
    // 1
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    // 2
    Observable<Int>.of(123, 4, 56)
    // 3
        .map {
            formatter.string(for: $0) ?? ""
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "enumerated and map") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(1, 2, 3, 4, 5, 6)
    // 2
        .enumerated()
    // 3
        .map { index, integer in
            index > 2 ? integer * 2 : integer
        }
    // 4
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}


struct Student {
    let score: BehaviorSubject<Int>
}

example(of: "flatMap") {
    let disposeBag = DisposeBag()
    
    // 1
    let laura = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 90))
    
    // 2
    let student = PublishSubject<Student>()
    
    // 3
    student
        .flatMap {
            $0.score
        }
    // 4
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    student.onNext(laura)
    laura.score.onNext(85)
    student.onNext(charlotte)
    laura.score.onNext(95)
    charlotte.score.onNext(100)
}

example(of: "flatMapLatest") {
    let disposeBag = DisposeBag()
    
    let laura = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 90))
    
    let student = PublishSubject<Student>()
    
    student
        .flatMapLatest {
            $0.score
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    student.onNext(laura)
    laura.score.onNext(85)
    student.onNext(charlotte)
    
    // 1
    laura.score.onNext(95)
    charlotte.score.onNext(100)
}

/// **Materialize** prevents an inner Observable to terminal outer Observable by converting it into Observable of its events
/// **Dematerialize** converts materialized observable back into its original form
example(of: "materialize and dematerialize") {
    // 1
    enum MyError: Error {
        case anError
    }
    
    let disposeBag = DisposeBag()
    
    // 2
    let laura = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 100))
    
    let student = BehaviorSubject(value: laura)
    
    // 1
    let studentScore = student
        .flatMapLatest {
            $0.score.materialize()
        }
    
    // 2
    studentScore
    // 1
        .filter {
            guard $0.error == nil else {
                print($0.error!)
                return false
            }
            
            return true
        }
    // 2
        .dematerialize()
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    // 3
    laura.score.onNext(85)
    
    laura.score.onError(MyError.anError)
    
    laura.score.onNext(90)
    
    // 4
    student.onNext(charlotte)
    
}

// MARK: - Challenges - Transforming operators

example(of: "Challenge 1 - Transforming operators") {
    let disposeBag = DisposeBag()
    
    let contacts = [
        "603-555-1212": "Florent",
        "212-555-1212": "Shai",
        "408-555-1212": "Marin",
        "617-555-1212": "Scott"
    ]
    
    let convert: (String) -> Int? = { value in
        if let number = Int(value),
           number < 10 {
            return number
        }
        
        let keyMap: [String: Int] = [
            "abc": 2, "def": 3, "ghi": 4,
            "jkl": 5, "mno": 6, "pqrs": 7,
            "tuv": 8, "wxyz": 9
        ]
        
        let converted = keyMap
            .filter { $0.key.contains(value.lowercased()) }
            .map(\.value)
            .first
        
        return converted
    }
    
    let format: ([Int]) -> String = {
        var phone = $0.map(String.init).joined()
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 3)
        )
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 7)
        )
        
        return phone
    }
    
    let dial: (String) -> String = {
        print("Dialing...", $0)
        if let contact = contacts[$0] {
            return "Dialing \(contact) (\($0))..."
        } else {
            return "Contact not found"
        }
    }
    
    let input = PublishSubject<String>()
    
    // Add your code here
    input
        .compactMap(convert)
        .skipWhile { $0 == 0 }
        .take(10)
        .toArray()
        .map(format)
        .map(dial)
        .subscribe(onSuccess: { string in print(string)}, onError: { error in print(error) })
        .disposed(by: disposeBag)
    
    input.onNext("")
    input.onNext("0")
    input.onNext("408")
    
    input.onNext("6")
    input.onNext("")
    input.onNext("0")
    input.onNext("3")
    
    "JKL1A1B".forEach {
        input.onNext("\($0)")
    }
    
    input.onNext("9")
}

// MARK: - Combining Operators

example(of: "startWith") {
    // 1
    let numbers = Observable.of(2, 3, 4)
    
    // 2
    let observable = numbers.startWith(1)
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
}

example(of: "Observable.concat") {
    // 1
    let first = Observable.of(1, 2, 3)
    let second = Observable.of(4, 5, 6)
    
    // 2
    let observable = Observable.concat([first, second])
    
    observable.subscribe(onNext: { value in
        print(value)
    })
}

example(of: "concat") {
    let germanCities = Observable.of("Berlin", "Münich", "Frankfurt")
    let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")
    
    let observable = germanCities.concat(spanishCities)
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
}

example(of: "concatMap") {
    // 1
    let sequences = [
        "German cities": Observable.of("Berlin", "Münich", "Frankfurt"),
        "Spanish cities": Observable.of("Madrid", "Barcelona", "Valencia")
    ]
    
    // 2
    let observable = Observable.of("German cities", "Spanish cities")
        .concatMap { country in sequences[country] ?? .empty() }
    
    // 3
    _ = observable.subscribe(onNext: { string in
        print(string)
    })
}

example(of: "merge") {
    // 1
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    // 2
    let source = Observable.of(left.asObservable(), right.asObservable())
    
    // 3
    let observable = source.merge()
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    // 4
    var leftValues = ["Berlin", "Munich", "Frankfurt"]
    var rightValues = ["Madrid", "Barcelona", "Valencia"]
    repeat {
        switch Bool.random() {
        case true where !leftValues.isEmpty:
            left.onNext("Left:  " + leftValues.removeFirst())
        case false where !rightValues.isEmpty:
            right.onNext("Right: " + rightValues.removeFirst())
        default:
            break
        }
    } while !leftValues.isEmpty || !rightValues.isEmpty
    // 5
    left.onCompleted()
    right.onCompleted()
}

example(of: "combineLatest") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    // 1
    let observable = Observable.combineLatest(left, right) {
        lastLeft, lastRight in
        "\(lastLeft) \(lastRight)"
    }
    
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    // 2
    print("> Sending a value to Left")
    left.onNext("Hello,")
    print("> Sending a value to Right")
    right.onNext("world")
    print("> Sending another value to Right")
    right.onNext("RxSwift")
    print("> Sending another value to Left")
    left.onNext("Have a good day,")
    
    left.onCompleted()
    right.onCompleted()
}

example(of: "combine user choice and value") {
    let choice: Observable<DateFormatter.Style> = Observable.of(.short, .long)
    let dates = Observable.of(Date())
    
    let observable = Observable.combineLatest(choice, dates) {
        format, when -> String in
        let formatter = DateFormatter()
        formatter.dateStyle = format
        return formatter.string(from: when)
    }
    
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
}

example(of: "zip") {
    enum Weather {
        case cloudy
        case sunny
    }
    let left: Observable<Weather> = Observable.of(.sunny, .cloudy, .cloudy, .sunny)
    let right = Observable.of("Lisbon", "Copenhagen", "London", "Madrid", "Vienna")
    
    let observable = Observable.zip(left, right) { weather, city in
        return "It's \(weather) in \(city)"
    }
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
}

example(of: "withLatestFrom") {
    // 1
    let button = PublishSubject<Void>()
    let textField = PublishSubject<String>()
    
    // 2
    let observable = button.withLatestFrom(textField)
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    // 3
    textField.onNext("Par")
    textField.onNext("Pari")
    textField.onNext("Paris")
    button.onNext(())
    button.onNext(())
}

example(of: "amb") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    // 1
    let observable = left.amb(right)
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    // 2
    left.onNext("Lisbon")
    right.onNext("Copenhagen")
    left.onNext("London")
    left.onNext("Madrid")
    right.onNext("Vienna")
    
    left.onCompleted()
    right.onCompleted()
}

example(of: "switchLatest") {
    // 1
    let one = PublishSubject<String>()
    let two = PublishSubject<String>()
    let three = PublishSubject<String>()
    
    let source = PublishSubject<Observable<String>>()
    // 2
    let observable = source.switchLatest()
    let disposable = observable.subscribe(onNext: { value in
        print(value)
    })
    // 3
    source.onNext(one)
    one.onNext("Some text from sequence one")
    two.onNext("Some text from sequence two")
    
    source.onNext(two)
    two.onNext("More text from sequence two")
    one.onNext("and also from sequence one")
    
    source.onNext(three)
    two.onNext("Why don't you see me?")
    one.onNext("I'm alone, help me")
    three.onNext("Hey it's three. I win.")
    
    source.onNext(one)
    one.onNext("Nope. It's me, one!")
    disposable.dispose()
}

example(of: "reduce") {
  let source = Observable.of(1, 3, 5, 7, 9)

  // 1
  let observable = source.reduce(0, accumulator: +)
  _ = observable.subscribe(onNext: { value in
    print(value)
  })
}

example(of: "scan") {
  let source = Observable.of(1, 3, 5, 7, 9)

  let observable = source.scan(0, accumulator: +)
  _ = observable.subscribe(onNext: { value in
    print(value)
  })
}

