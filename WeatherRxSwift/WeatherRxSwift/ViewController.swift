// 

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class ViewController: UIViewController {
    
    private let scrollView: UIScrollView = .init()
    private let contentView: UIView = .init()
    private let refreshControl: UIRefreshControl = .init()
    
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
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(textField)
        contentView.addSubview(searchButton)
        contentView.addSubview(alertLabel)
        contentView.addSubview(latLongLabel)
        contentView.addSubview(weatherOverallLabel)
        contentView.addSubview(weatherDetailLabel)
        contentView.addSubview(resetButton)
        
        scrollView.snp.makeConstraints {
            $0.topMargin.bottomMargin.equalToSuperview().inset(12)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        textField.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.leading.equalToSuperview().inset(24)
            $0.trailing.equalTo(searchButton.snp.leading).offset(-8)
            $0.height.equalTo(48)
        }
        
        searchButton.snp.makeConstraints {
            $0.centerY.equalTo(textField)
            $0.trailing.equalToSuperview().inset(24)
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
            $0.bottom.equalToSuperview()
        }
        
        resetButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.width.equalTo(100)
            $0.bottom.equalTo(view.snp.bottomMargin).offset(4)
            $0.trailing.equalToSuperview().inset(24)
        }
        
        scrollView.refreshControl = refreshControl
        
        textField.placeholder = "Enter City Name"
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = 16
        
        searchButton.setTitle("Search", for: .normal)
        searchButton.setTitleColor(.systemBlue, for: .normal)
        searchButton.setTitleColor(.gray, for: .disabled)
        
        alertLabel.textColor = .red
        alertLabel.text = "Only letters allowed"
        alertLabel.isHidden = true
        
        resetButton.setTitle("Refresh?", for: .normal)
        resetButton.setTitleColor(.systemBlue, for: .normal)
        resetButton.isHidden = true
    }
    
    func bindUI() {
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.fetchAPISubject)
            .disposed(by: disposeBag)
        
        textField.rx.text.orEmpty
            .bind(to: viewModel.searchInputRelay)
            .disposed(by: disposeBag)
        
        searchButton.rx.tap
            .bind(to: viewModel.fetchAPISubject)
            .disposed(by: disposeBag)
        
        resetButton.rx.tap
            .bind(to: viewModel.fetchAPISubject)
            .disposed(by: disposeBag)
        
        viewModel.isFetchingAPIDriver
            .drive(refreshControl.rx.isRefreshing)
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
            .drive(resetButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.modelDriver
            .map { $0.coordinate }
            .map { "Latitude: \($0.lat)\n Longtitude: \($0.lon)" }
            .drive(latLongLabel.rx.text)
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
