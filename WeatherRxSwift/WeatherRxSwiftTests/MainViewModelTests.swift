// 

import RxSwift
import RxTest
import XCTest
@testable import WeatherRxSwift

/// Test output subscription given input
final class MainViewModelTests: XCTestCase {
    
    var testScheduler: TestScheduler!
    var viewModel: MainViewModel!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        testScheduler = TestScheduler(initialClock: 0)
        viewModel = .init()
        disposeBag = .init()
    }
    
    override func tearDown() {
        testScheduler = nil
        viewModel = nil
        disposeBag = nil
        super.tearDown()
    }
    
    func testInvalidateSearchInputDriverIsFalse() {
        let observer = testScheduler.createObserver(Bool.self)
        
        viewModel.invalidateSearchInputDriver
            .drive(observer)
            .disposed(by: disposeBag)
        
        testScheduler.scheduleAt(10) {
            self.viewModel.searchInputRelay.accept("London")
        }
        
        testScheduler.start()
        
        XCTAssertEqual(observer.events, [.next(10, false)])
    }
    
    func testInvalidateSearchInputDriverIsTrue() {
        let observer = testScheduler.createObserver(Bool.self)
        
        viewModel.invalidateSearchInputDriver
            .drive(observer)
            .disposed(by: disposeBag)
        
        testScheduler.scheduleAt(20) {
            self.viewModel.searchInputRelay.accept("12345")
        }
        
        testScheduler.start()
        
        XCTAssertEqual(observer.events, [.next(20, true)])
    }
}
