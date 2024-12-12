// 

import RxSwift
import RxCocoa
import SnapKit
import UIKit

class ViewController: UIViewController {
    
    let addTaskSubject: PublishSubject<Void> = .init()
    let currentTaskSubject: PublishSubject<String> = .init()
    
    private let disposeBag: DisposeBag = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        
        navigationItem.rightBarButtonItem?.rx.tap
            .bind(to: addTaskSubject)
            .disposed(by: disposeBag)
        
        addTaskSubject.asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.presentAlert()
            })
            .disposed(by: disposeBag)
        
        currentTaskSubject.asDriver(onErrorJustReturn: "")
            .drive(onNext: { task in print("Created task:", task) })
            .disposed(by: disposeBag)
    }
}

// MARK: - Private
private extension ViewController {
    func setUpUI() {
        setUpNavigationBar()
    }
    
    func setUpNavigationBar() {
        navigationItem.title = "To Do List"
        navigationItem.rightBarButtonItem = .init(title: "Add", style: .plain, target: self, action: nil) /// With RxSwift, no need to handle tap action here
    }
    
    func presentAlert() {
        let alertController = UIAlertController(
            title: "Add Task",
            message: "It's time to be productive",
            preferredStyle: .alert
        )
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            alertController.textFields?.first?.text.map { self?.currentTaskSubject.onNext($0) }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addTextField { [weak self] textField in
            guard let self = self else { return }
            textField.placeholder = "Add Your Task Here"
            textField.rx.text
                .orEmpty
                .map { !$0.isEmpty }
                .bind(to: addAction.rx.isEnabled)
                .disposed(by: self.disposeBag)
        }
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
