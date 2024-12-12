// 

import RxRelay
import RxSwift

final class ViewModel {
    
    /// Input Properties
    let addTaskSubject: PublishSubject<Void> = .init()
    let currentTaskSubject: PublishSubject<String> = .init()
    let inputToDoModel: PublishSubject<(TodoModel, Bool)> = .init()
    
    /// Output Properties
    let dataSourceSubject = BehaviorRelay<[TodoModel]>(value: [])
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
        
        inputToDoModel
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
                return todoModels
            }
            .bind(to: dataSourceSubject)
            .disposed(by: disposeBag)
    }
}
