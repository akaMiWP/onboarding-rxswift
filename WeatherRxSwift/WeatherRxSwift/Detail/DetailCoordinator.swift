// 

import RxSwift
import UIKit

final class DetailCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    private let navigationController: UINavigationController
    private let model: WeatherModel
    
    init(navigationController: UINavigationController, model: WeatherModel) {
        self.navigationController = navigationController
        self.model = model
    }
    
    func start() {
        let viewModel = DetailViewModel(model: model)
        let viewController = DetailViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
