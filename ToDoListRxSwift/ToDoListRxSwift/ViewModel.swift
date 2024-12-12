// 

import RxSwift

final class ViewModel {
    
    /// Input Properties
    let addTaskSubject: PublishSubject<Void> = .init()
    let currentTaskSubject: PublishSubject<String> = .init()
    
    /// Output Properties
    let dataSource = Observable.of(["1", "2", "3", "4", "5"])
    var presentedAlert: Observable<Void> {
        addTaskSubject.asObservable()
    }
    
    private let disposeBag: DisposeBag = .init()
    
    init() {
        currentTaskSubject.asDriver(onErrorJustReturn: "")
            .drive(onNext: { task in print("Created task:", task) })
            .disposed(by: disposeBag)
    }
}
