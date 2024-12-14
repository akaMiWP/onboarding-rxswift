// 

import RxCocoa
import RxSwift

final class DetailViewModel {
    
    // Input Properties
    let viewDidDisappearSubject = PublishSubject<Void>()
    
    // Output Properties
    private let modelObservable: Observable<WeatherModel>
    var modelDriver: Driver<WeatherModel> {
        modelObservable.asDriver(onErrorJustReturn: .defaultModel)
    }
    
    init(model: WeatherModel) {
        modelObservable = Observable<WeatherModel>.just(model)
    }
}
