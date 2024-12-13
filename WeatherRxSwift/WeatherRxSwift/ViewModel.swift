// 

import RxCocoa
import RxSwift

final class ViewModel {
    
    // Input properties
    let searchInputSubject = BehaviorSubject<String>(value: "")
    
    // Output properties
    private let validateSearchInputSubject = PublishSubject<Bool>()
    var shouldShowAlertDriver: Driver<Bool> {
        validateSearchInputSubject.asDriver(onErrorJustReturn: false)
    }
    
    private let disposeBag: DisposeBag = .init()
    
    init() {
        let filteredSearchInputSubject = searchInputSubject
            .filter { !$0.isEmpty }
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
        
        filteredSearchInputSubject
            .subscribe(onNext: { print("Tapped:", $0)})
            .disposed(by: disposeBag)
        
        filteredSearchInputSubject
            .map { input -> Bool in
                return input.contains(where: { $0.isNumber })
            }
            .bind(to: validateSearchInputSubject)
            .disposed(by: disposeBag)
    }
}
