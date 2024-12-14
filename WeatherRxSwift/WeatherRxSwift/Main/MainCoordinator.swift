//

import RxSwift
import UIKit

final class MainCoordinator: Coordinator {
    private let disposeBag: DisposeBag = .init()
    private let navigationController: UINavigationController
    
    var coordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = MainViewModel()
        
        viewModel.navigateToDetailWithModel
            .subscribe(onNext: { [weak self] in
                self?.navigateToDetailScreen(with: $0)
            })
            .disposed(by: disposeBag)
        
        let viewController = MainViewController(viewModel: viewModel)
        viewController.view.backgroundColor = .white
        navigationController.pushViewController(viewController, animated: true)
    }
}

// MARK: - Private
private extension MainCoordinator {
    func navigateToDetailScreen(with model: WeatherModel) {
        let detailCoordinator = DetailCoordinator(navigationController: navigationController, model: model)
        detailCoordinator.didFinish.subscribe(onCompleted: { [weak self] in
            self?.removeCoordinators(detailCoordinator)
        })
        .disposed(by: disposeBag)
        detailCoordinator.start()
        coordinators.append(detailCoordinator)
    }
    
    func removeCoordinators(_ coordinator: Coordinator) {
        coordinators = coordinators.filter { $0 !== coordinator }
    }
}
