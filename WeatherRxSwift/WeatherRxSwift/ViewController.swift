// 

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class ViewController: UIViewController {
    
    private let textField: UITextField = .init()
    private let searchButton: UIButton = .init()
    private let alertLabel: UILabel = .init()
    private let latLongLabel: UILabel = .init()
    private let weatherOverallLabel: UILabel = .init()
    private let weatherDetailLabel: UILabel = .init()
    private let resetButton: UIButton = .init()
    
    private let disposeBag: DisposeBag = .init()
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        bindUI()
    }
}

// MARK: - Private
private extension ViewController {
    func setUpUI() {
        view.addSubview(textField)
        view.addSubview(searchButton)
        view.addSubview(alertLabel)
        view.addSubview(latLongLabel)
        view.addSubview(weatherOverallLabel)
        view.addSubview(weatherDetailLabel)
        view.addSubview(resetButton)
        
        textField.snp.makeConstraints {
            $0.top.equalTo(view.snp.topMargin).offset(8)
            $0.leading.equalToSuperview().inset(12)
            $0.trailing.equalTo(searchButton.snp.leading).offset(-8)
            $0.height.equalTo(48)
        }
        
        searchButton.snp.makeConstraints {
            $0.centerY.equalTo(textField)
            $0.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(48)
            $0.width.equalTo(80)
        }
        
        alertLabel.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        latLongLabel.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        weatherOverallLabel.snp.makeConstraints {
            $0.top.equalTo(latLongLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        weatherDetailLabel.snp.makeConstraints {
            $0.top.equalTo(weatherOverallLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        resetButton.snp.makeConstraints {
            $0.size.equalTo(48)
            $0.bottom.equalTo(view.snp.bottomMargin).offset(4)
            $0.trailing.equalToSuperview().inset(24)
        }
        
        textField.placeholder = "Enter City Name"
        
        searchButton.setTitle("Search", for: .normal)
        searchButton.setTitleColor(.black, for: .normal)
        searchButton.setTitleColor(.gray, for: .disabled)
        
        alertLabel.textColor = .red
        alertLabel.text = "Only letters allowed"
        alertLabel.isHidden = true
        
        resetButton.tintColor = .blue
        resetButton.setImage(.init(systemName: "checkmark.circle"), for: .normal)
        resetButton.setImage(.init(systemName: "arrow.clockwise"), for: .disabled)
    }
    
    func bindUI() {
        textField.rx.text.orEmpty
            .bind(to: viewModel.searchInputRelay)
            .disposed(by: disposeBag)
        
        searchButton.rx.tap
            .bind(to: viewModel.fetchAPISubject)
            .disposed(by: disposeBag)
        
        resetButton.rx.tap
            .bind(to: viewModel.fetchAPISubject)
            .disposed(by: disposeBag)
        
        viewModel.shouldShowAlertDriver
            .map { !$0 }
            .drive(searchButton.rx.isEnabled)
            .disposed(by: disposeBag)
            
        viewModel.shouldShowAlertDriver
            .map { !$0 }
            .drive(alertLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.isFetchingAPIFailedDriver
            .map { !$0 }
            .drive(resetButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.modelDriver
            .map { $0.coordinate }
            .map { "Latitude: \($0.lat)\n Longtitude: \($0.lon)" }
            .drive(weatherOverallLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.modelDriver
            .compactMap { $0.weather.first }
            .map { "Main: \($0.main)\n Description: \($0.description)" }
            .drive(weatherOverallLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.modelDriver
            .map { $0.details }
            .map { "Temperature: \($0.temp)\n Feel like: \($0.feelsLike)" }
            .drive(weatherDetailLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
