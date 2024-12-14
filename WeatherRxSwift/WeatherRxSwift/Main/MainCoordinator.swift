//

import RxSwift
import UIKit

final class MainCoordinator: Coordinator {
    private let window: UIWindow?
    private let disposeBag: DisposeBag = .init()
    private var navigationController: UINavigationController?
    
    var coordinators: [Coordinator] = []
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func start() {
        let viewModel = MainViewModel()
        
        viewModel.navigateToDetailWithModel
            .subscribe(onNext: { [weak self] in
                self?.navigateToDetailScreen(with: $0)
            })
            .disposed(by: viewModel.disposeBag)
        
        let viewController = MainViewController(viewModel: viewModel)
        viewController.view.backgroundColor = .white
        navigationController = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

// MARK: - Private
private extension MainCoordinator {
    func navigateToDetailScreen(with model: WeatherModel) {
        guard let navigationController = navigationController else { return }
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
