// 

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class MainViewController: UIViewController {
    
    private let scrollView: UIScrollView = .init()
    private let contentView: UIView = .init()
    private let refreshControl: UIRefreshControl = .init()
    
    private let textField: UITextField = .init()
    private let searchButton: UIButton = .init()
    private let alertLabel: UILabel = .init()
    private let latLongLabel: UILabel = .init()
    private let weatherOverallLabel: UILabel = .init()
    private let weatherDetailLabel: UILabel = .init()
    private let seeMoreButton: UIButton = .init()
    private let resetButton: UIButton = .init()
    
    private let disposeBag: DisposeBag = .init()
    private let viewModel: MainViewModel
    
    init(viewModel: MainViewModel) {
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
private extension MainViewController {
    func setUpUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(textField)
        contentView.addSubview(searchButton)
        contentView.addSubview(alertLabel)
        contentView.addSubview(latLongLabel)
        contentView.addSubview(weatherOverallLabel)
        contentView.addSubview(weatherDetailLabel)
        contentView.addSubview(seeMoreButton)
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
            $0.trailing.equalToSuperview().inset(8)
            $0.height.equalTo(48)
            $0.width.equalTo(80)
        }
        
        alertLabel.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        latLongLabel.snp.makeConstraints {
            $0.top.equalTo(alertLabel.snp.bottom).offset(12)
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
        
        seeMoreButton.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(weatherDetailLabel.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(48)
            $0.width.equalTo(150)
            $0.bottom.equalToSuperview().inset(24)
        }
        
        resetButton.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.bottom.equalTo(view.snp.bottomMargin).inset(8)
            $0.trailing.equalToSuperview().inset(8)
        }
        
        scrollView.refreshControl = refreshControl
        
        textField.placeholder = "Enter City Name"
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = 16
        
        searchButton.setTitle("Search", for: .normal)
        searchButton.setTitleColor(.systemBlue, for: .normal)
        searchButton.setTitleColor(.gray, for: .disabled)
        searchButton.isEnabled = false
        
        alertLabel.textColor = .red
        alertLabel.text = "Only letters allowed"
        alertLabel.isHidden = true
        
        seeMoreButton.setTitle("See More", for: .normal)
        seeMoreButton.setTitleColor(.systemBlue, for: .normal)
        
        resetButton.tintColor = .systemBlue
        resetButton.setImage(.init(systemName: "checkmark.circle"), for: .normal)
        resetButton.setImage(.init(systemName: "icloud.slash"), for: .disabled)
        
        [latLongLabel, weatherOverallLabel, weatherDetailLabel].forEach {
            $0.numberOfLines = 2
        }
    }
    
    func bindUI() {
        bindInputs()
        bindOutputs()
    }
    
    func bindInputs() {
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.fetchAPISubject)
            .disposed(by: disposeBag)
        
        textField.rx.text.orEmpty
            .bind(to: viewModel.searchInputRelay)
            .disposed(by: disposeBag)
        
        searchButton.rx.tap
            .bind(to: viewModel.fetchAPISubject)
            .disposed(by: disposeBag)
        
        seeMoreButton.rx.tap
            .bind(to: viewModel.navigateToDetail)
            .disposed(by: disposeBag)
    }
    
    func bindOutputs() {
        viewModel.isFetchingAPIDriver
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        let reactUpOnError = viewModel.invalidateSearchInputDriver.map { !$0 }
        
        reactUpOnError
            .drive(searchButton.rx.isEnabled)
            .disposed(by: disposeBag)
            
        reactUpOnError
            .drive(alertLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.isFetchingAPIFailedDriver
            .map { !$0 }
            .drive(resetButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.modelDriver
            .map { $0.coordinate }
            .map { "Latitude: \($0.lat)\nLongtitude: \($0.lon)" }
            .drive(latLongLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.modelDriver
            .compactMap { $0.weather.first }
            .map { "Main: \($0.main)\nDescription: \($0.description)" }
            .drive(weatherOverallLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.modelDriver
            .map { $0.details }
            .map { "Temperature: \($0.temp)\nFeel like: \($0.feelsLike)" }
            .drive(weatherDetailLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
