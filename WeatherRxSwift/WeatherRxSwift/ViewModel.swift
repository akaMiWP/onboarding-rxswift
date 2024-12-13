// 

import Foundation
import RxCocoa
import RxSwift

enum NetworkError: Error {
    case notSuccess
}

struct WeatherModel: Decodable {}

final class ViewModel {
    
    // Input properties
    let searchInputSubject = BehaviorSubject<String>(value: "")
    let fetchAPISubject = PublishSubject<Void>()
    
    // Output properties
    private let validateSearchInputSubject = PublishSubject<Bool>()
    var shouldShowAlertDriver: Driver<Bool> {
        validateSearchInputSubject.asDriver(onErrorJustReturn: false)
    }
    
    private let disposeBag: DisposeBag = .init()
    
    init() {
        let filteredSearchInputSubject = searchInputSubject
            .filter { !$0.isEmpty }
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
        
        fetchAPISubject
            .flatMap { _ in URLSession.shared.rx.response(request: .init(url: .init(string: "www.google.com")!)) }
            .retry(3)
            .map { (response, data) in
                guard 200..<300 ~= response.statusCode else { throw NetworkError.notSuccess }
                return data
            }
            .map { try JSONDecoder().decode(WeatherModel.self, from: $0) }
            .subscribe { model in
                print("WeatherModel:", model)
            } onError: { error in
                print("Error:", error.localizedDescription)
            }
            .disposed(by: disposeBag)
        
        filteredSearchInputSubject
            .subscribe(onNext: { print("Tapped:", $0)})
            .disposed(by: disposeBag)
        
        filteredSearchInputSubject
            .map { input -> Bool in
                return input.contains(where: { $0.isNumber })
            }
            .bind(to: validateSearchInputSubject)
            .disposed(by: disposeBag)
    }
}
