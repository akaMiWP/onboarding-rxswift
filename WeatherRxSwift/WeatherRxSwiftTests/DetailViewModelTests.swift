// 

import RxSwift
import RxTest
import XCTest
@testable import WeatherRxSwift

/// Test output subscription given input
final class DetailViewModelTests: XCTestCase {
    
    var testScheduler: TestScheduler!
    var viewModel: DetailViewModel!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        testScheduler = TestScheduler(initialClock: 0)
        viewModel = .init(model: .init(coordinate: .init(lat: 10, lon: 10), weather: [], details: .init(temp: 100, feelsLike: 100), name: "name"))
        disposeBag = .init()
    }
    
    override func tearDown() {
        testScheduler = nil
        viewModel = nil
        disposeBag = nil
        super.tearDown()
    }
    
    func testModelDriverHaveCorrectValue() {
        let observer = testScheduler.createObserver(WeatherModel.self)
        
        viewModel.modelDriver
            .drive(observer)
            .disposed(by: disposeBag)
        
        XCTAssertEqual(
            observer.events,
            [.next(
                0,
                WeatherModel(coordinate: .init(lat: 10, lon: 10), weather: [], details: .init(temp: 100, feelsLike: 100), name: "name")
            ), .completed(0)]
        )
    }
}
