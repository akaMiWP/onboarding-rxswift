// 

import RxSwift
import RxCocoa
import SnapKit
import UIKit

class ViewController: UIViewController {
    
    private let tableView: UITableView = .init()
    private let disposeBag: DisposeBag = .init()
    
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Shouldn't be called")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        bindUI()
    }
}

// MARK: - Private
private extension ViewController {
    func setUpUI() {
        setUpNavigationBar()
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        tableView.register(CustomCell.self, forCellReuseIdentifier: "CustomCell")
    }
    
    func setUpNavigationBar() {
        navigationItem.title = "To Do List"
        /// With RxSwift, no need to handle tap action here
        navigationItem.rightBarButtonItem = .init(title: "Add", style: .plain, target: self, action: nil)
    }
    
    func bindUI() {
        navigationItem.rightBarButtonItem?.rx.tap
            .bind(to: viewModel.addTaskSubject)
            .disposed(by: disposeBag)
        
        viewModel.dataSourceDriver
            .drive(tableView.rx.items(cellIdentifier: "CustomCell", cellType: CustomCell.self)) { (row, item, cell) in
                cell.bind(item: item, selectedCellSubject: self.viewModel.selectedModelSubject)
            }
            .disposed(by: disposeBag)
        
        viewModel.presentedAlert
            .subscribe(onNext: { [weak self] in self?.presentAlert() })
            .disposed(by: disposeBag)
    }
    
    func presentAlert() {
        let alertController = UIAlertController(
            title: "Add Task",
            message: "It's time to be productive",
            preferredStyle: .alert
        )
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            alertController.textFields?.first?.text.map { self?.viewModel.currentTaskSubject.onNext($0) }
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
