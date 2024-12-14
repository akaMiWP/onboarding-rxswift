// 

import Foundation
import RxCocoa
import RxSwift

enum NetworkError: Error {
    case notSuccess
}

struct WeatherModel: Decodable {
    
    struct Coordinate: Decodable {
        let lat: Double
        let lon: Double
    }
    
    struct Weather: Decodable {
        let main: String
        let description: String
    }
    
    struct Details: Decodable {
        let temp: Double
        let feelsLike: Double
    }
    
    enum CodingKeys: String, CodingKey {
        case coordinate="coord"
        case weather
        case details="main"
    }
    
    let coordinate: Coordinate
    let weather: [Weather]
    let details: Details
    
    static let defaultModel: WeatherModel = .init(
        coordinate: .init(lat: 0, lon: 0),
        weather: [.init(main: "unknown", description: "unknown")],
        details: .init(temp: 0, feelsLike: 0)
    )
}

final class MainViewModel {
    
    // Input properties
    let searchInputRelay = BehaviorRelay<String>(value: "")
    let fetchAPISubject = PublishSubject<Void>()
    let navigateToDetail = PublishSubject<Void>()
    
    // Output properties
    private let validateSearchInputSubject = PublishSubject<Bool>()
    private let isFetchingAPIFailedSubject = PublishSubject<Bool>()
    private let isFetchingAPISubject = PublishSubject<Bool>()
    private let modelSubject = BehaviorSubject<WeatherModel>(value: .defaultModel)
    var shouldShowAlertDriver: Driver<Bool> {
        validateSearchInputSubject.asDriver(onErrorJustReturn: false)
    }
    var isFetchingAPIFailedDriver: Driver<Bool> {
        isFetchingAPIFailedSubject.asDriver(onErrorJustReturn: true)
    }
    var isFetchingAPIDriver: Driver<Bool> {
        isFetchingAPISubject.asDriver(onErrorJustReturn: false)
    }
    var modelDriver: Driver<WeatherModel> {
        modelSubject.asDriver(onErrorJustReturn: .defaultModel)
    }
    
    let disposeBag: DisposeBag = .init()
    
    init() {
        let filteredSearchInputObservable = searchInputRelay
            .filter { !$0.isEmpty }
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
        
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
        
        filteredSearchInputObservable
            .subscribe(onNext: { print("Tapped:", $0)})
            .disposed(by: disposeBag)
        
        filteredSearchInputObservable
            .map { input -> Bool in
                return input.isEmpty || input.contains(where: { $0.isNumber })
            }
            .bind(to: validateSearchInputSubject)
            .disposed(by: disposeBag)
    }
}

func getURL(city: String) -> URL {
    let key = Bundle.main.infoDictionary?["API_KEY"] as! String
    var url = URL(string: "https://api.openweathermap.org/data/2.5/weather")!
    url.append(queryItems: [.init(name: "q", value: city)])
    url.append(queryItems: [.init(name: "appid", value: key)])
    return url
}
