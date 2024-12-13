// 

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class ViewController: UIViewController {
    
    private let textField: UITextField = .init()
    private let searchButton: UIButton = .init()
    private let alertLabel: UILabel = .init()
    private let stackView: UIStackView = .init()
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
        view.addSubview(stackView)
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
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(resetButton.snp.top).inset(16)
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
        resetButton.setImage(.init(systemName: "arrow.clockwise"), for: .normal)
    }
    
    func bindUI() {
        textField.rx.text.orEmpty
            .bind(to: viewModel.searchInputSubject)
            .disposed(by: disposeBag)
        
        searchButton.rx.tap
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
    }
}
