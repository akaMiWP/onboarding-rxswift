// 

import RxCocoa
import RxSwift

final class DetailViewModel {
    
    // Input Properties
    let viewDidDisappearSubject = PublishSubject<Void>()
    
    // Output Properties
    let modelDriver: Driver<WeatherModel>
    
    init(model: WeatherModel) {
        modelDriver = Observable<WeatherModel>
            .just(model)
            .asDriver(onErrorJustReturn: .defaultModel)
    }
}
