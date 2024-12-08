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
