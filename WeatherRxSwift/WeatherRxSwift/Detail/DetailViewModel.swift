// 

import RxCocoa
import RxSwift

final class DetailViewModel {
    
    // Output Properties
    private let modelObservable: Observable<WeatherModel>
    var modelDriver: Driver<WeatherModel> {
        modelObservable.asDriver(onErrorJustReturn: .defaultModel)
    }
    
    init(model: WeatherModel) {
        modelObservable = Observable<WeatherModel>.from(optional: model)
    }
}
