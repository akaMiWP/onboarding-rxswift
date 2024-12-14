// 

import RxSwift
import UIKit

final class DetailCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    let didFinish = PublishSubject<Void>()
    
    private let navigationController: UINavigationController
    private let model: WeatherModel
    private let disposeBag: DisposeBag = .init()
    
    init(navigationController: UINavigationController, model: WeatherModel) {
        self.navigationController = navigationController
        self.model = model
    }
    
    deinit { print("Deinit") }
    
    func start() {
        let viewModel = DetailViewModel(model: model)
        
        viewModel.viewDidDisappearSubject
            .subscribe(onCompleted: { [weak self] in
                self?.didFinish.onCompleted()
            })
            .disposed(by: disposeBag)
        
        let viewController = DetailViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
