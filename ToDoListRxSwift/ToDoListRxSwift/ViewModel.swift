// 

import RxRelay
import RxSwift

final class ViewModel {
    
    /// Input Properties
    let addTaskSubject: PublishSubject<Void> = .init()
    let currentTaskSubject: PublishSubject<String> = .init()
    
    /// Output Properties
    let dataSoureSubject = BehaviorRelay<[TodoModel]>(value: [])
    var presentedAlert: Observable<Void> {
        addTaskSubject.asObservable()
    }
    
    private let disposeBag: DisposeBag = .init()
    
    init() {
        currentTaskSubject.asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] task in
                guard let self = self else { return }
                let model: TodoModel = .init(title: task)
                let newTasks: [TodoModel] = self.dataSoureSubject.value + [model]
                self.dataSoureSubject.accept(newTasks)
            })
            .disposed(by: disposeBag)
    }
}
