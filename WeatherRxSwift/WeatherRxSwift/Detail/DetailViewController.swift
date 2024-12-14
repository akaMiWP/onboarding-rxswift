// 

import RxCocoa
import RxSwift
import UIKit

final class DetailViewController: UIViewController {
    
    private let viewModel: DetailViewModel
    private let disposeBag: DisposeBag = .init()
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bindUI()
    }
}

// MARK: - Private
private extension DetailViewController {
    func configureUI() {
        view.backgroundColor = .white
    }
    
    func bindUI() {
        viewModel.modelDriver.map { $0.name }
            .drive(self.navigationItem.rx.title)
            .disposed(by: disposeBag)
    }
}
