// 

import Foundation
import RxCocoa
import RxSwift

final class MainViewModel {
    
    // Navigation properties
    let navigateToDetailWithModel = PublishSubject<WeatherModel>()
    
    // Input properties
    let searchInputRelay = BehaviorRelay<String>(value: "")
    let fetchAPISubject = PublishSubject<Void>()
    let navigateToDetail = PublishSubject<Void>()
    
    // Output properties
    private let isFetchingAPIFailedSubject = PublishSubject<Bool>()
    private let isFetchingAPISubject = PublishSubject<Bool>()
    var isFetchingAPIFailedDriver: Driver<Bool> {
        isFetchingAPIFailedSubject.asDriver(onErrorJustReturn: true)
    }
    var isFetchingAPIDriver: Driver<Bool> {
        isFetchingAPISubject.asDriver(onErrorJustReturn: false)
    }
    
    private let modelSubject = BehaviorRelay<WeatherModel>(value: .defaultModel)
    var modelDriver: Driver<WeatherModel> {
        modelSubject.asDriver(onErrorJustReturn: .defaultModel)
    }
    
    let invalidateSearchInputDriver: Driver<Bool>
    
    private let disposeBag: DisposeBag = .init()
    
    init() {
        let filteredSearchInputObservable = searchInputRelay
            .filter { !$0.isEmpty }
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
        
        invalidateSearchInputDriver = filteredSearchInputObservable
            .map { input -> Bool in
                return input.contains(where: { $0.isNumber })
            }
            .asDriver(onErrorJustReturn: false)
        
        let fetchAPIObservable = fetchAPISubject
            .flatMapLatest { _ in
                URLSession.shared.rx
                    .response(request: .init(url: getURL(city: self.searchInputRelay.value)))
                    .map { (response, data) in
                        guard 200..<300 ~= response.statusCode else { throw NetworkError.notSuccess }
                        return data
                    }
                    .map {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        return try decoder.decode(WeatherModel.self, from: $0)
                    }
                    .do(
                        onNext: { _ in
                            self.isFetchingAPISubject.on(.next(false))
                        },
                        onError: { _ in
                            self.isFetchingAPISubject.on(.next(false))
                            self.isFetchingAPIFailedSubject.on(.next(true))
                        }
                    )
                    .catchErrorJustReturn(.defaultModel)
            }
        
        fetchAPIObservable
            .bind(to: modelSubject)
            .disposed(by: disposeBag)
        
        navigateToDetail
            .map { self.modelSubject.value }
            .bind(to: navigateToDetailWithModel)
            .disposed(by: disposeBag)
    }
}
