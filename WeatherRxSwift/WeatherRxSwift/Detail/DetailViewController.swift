// 

import RxCocoa
import RxSwift
import UIKit

final class DetailViewController: UIViewController {
    
    private let mainLabel: UILabel = .init()
    private let descriptionLabel: UILabel = .init()
    private let latitudeLabel: UILabel = .init()
    private let longtitudeLabel: UILabel = .init()
    private let tempLabel: UILabel = .init()
    private let feelLikesLabel: UILabel = .init()
    
    private let viewModel: DetailViewModel
    private let disposeBag: DisposeBag = .init()
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bindUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.viewDidDisappearSubject.onCompleted()
    }
}

// MARK: - Private
private extension DetailViewController {
    func configureUI() {
        [mainLabel, descriptionLabel, latitudeLabel, longtitudeLabel, tempLabel, feelLikesLabel]
            .forEach { view.addSubview($0) }
        
        mainLabel.snp.makeConstraints {
            $0.top.equalTo(view.snp.topMargin)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(mainLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        
        latitudeLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        
        longtitudeLabel.snp.makeConstraints {
            $0.top.equalTo(latitudeLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        
        tempLabel.snp.makeConstraints {
            $0.top.equalTo(longtitudeLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        
        feelLikesLabel.snp.makeConstraints {
            $0.top.equalTo(tempLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        
        view.backgroundColor = .white
    }
    
    func bindUI() {
        bindNavigation()
        bindWeather()
        bindCoordinate()
        bindDetails()
    }
    
    func bindNavigation() {
        viewModel.modelDriver.map(\.name)
            .drive(self.navigationItem.rx.title)
            .disposed(by: disposeBag)
    }
    
    func bindWeather() {
        let weatherDriver = viewModel.modelDriver.compactMap { $0.weather.first }
        weatherDriver
            .map(\.main)
            .map { "Main Type of Weather: \($0)" }
            .drive(mainLabel.rx.text)
            .disposed(by: disposeBag)
        weatherDriver
            .map(\.description)
            .map { "Weather description: \($0)" }
            .drive(descriptionLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    
    func bindCoordinate() {
        let coordinateDriver = viewModel.modelDriver.map(\.coordinate)
        coordinateDriver
            .map(\.lat)
            .map { "Latitude: \($0)" }
            .drive(latitudeLabel.rx.text)
            .disposed(by: disposeBag)
        coordinateDriver
            .map(\.lon)
            .map { "Longtitude: \($0)" }
            .drive(longtitudeLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    func bindDetails() {
        let detailsDriver = viewModel.modelDriver.map(\.details)
        detailsDriver.map(\.temp)
            .map { "Temperature is: \($0)" }
            .drive(tempLabel.rx.text)
            .disposed(by: disposeBag)
        detailsDriver.map(\.feelsLike)
            .map { "Temperature Feel Like: \($0)" }
            .drive(feelLikesLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
