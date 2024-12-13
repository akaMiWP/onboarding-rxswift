// 

import RxCocoa
import RxRelay
import RxSwift

final class ViewModel {
    
    /// Input Properties
    let addTaskSubject: PublishSubject<Void> = .init()
    let currentTaskSubject: PublishSubject<String> = .init()
    let selectedModelSubject: PublishSubject<(TodoModel, Bool)> = .init()
    
    /// Output Properties
    private let dataSourceSubject = BehaviorRelay<[TodoModel]>(value: [])
    
    var dataSourceDriver: Driver<[TodoModel]> {
        dataSourceSubject.asDriver()
    }
    
    var presentedAlert: Observable<Void> {
        addTaskSubject.asObservable()
    }
    
    private let disposeBag: DisposeBag = .init()
    
    init() {
        currentTaskSubject.asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] task in
                guard let self = self else { return }
                let model: TodoModel = .init(title: task)
                let newTasks: [TodoModel] = self.dataSourceSubject.value + [model]
                self.dataSourceSubject.accept(newTasks)
            })
            .disposed(by: disposeBag)
        
        selectedModelSubject
            .debug()
            .map { (model, isSelected) -> TodoModel in
                var model = model
                model.isCompleted = isSelected
                model.completedDate = isSelected ? .init() : nil
                return model
            }
            .map { [weak self] updatedModel -> [TodoModel] in
                guard let self = self else { return [] }
                var todoModels = dataSourceSubject.value
                if let updatedIndex = todoModels.firstIndex(where: { $0.id == updatedModel.id }) {
                    todoModels[updatedIndex] = updatedModel
                }
                return todoModels.sorted { first, second in
                    if first.completedDate != nil || second.completedDate != nil {
                        return first.completedDate ?? .init() > second.completedDate ?? .init()
                    } else {
                        return first.createdDate < second.createdDate
                    }
                }
            }
            .bind(to: dataSourceSubject)
            .disposed(by: disposeBag)
    }
}
