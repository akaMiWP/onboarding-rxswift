// 

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class ViewController: UIViewController {
    
    private let textField: UITextField = .init()
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
        view.addSubview(alertLabel)
        view.addSubview(stackView)
        view.addSubview(resetButton)
        
        textField.snp.makeConstraints {
            $0.top.equalTo(view.snp.topMargin).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(48)
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
        
        viewModel.shouldShowAlertDriver
            .map { !$0 }
            .debug()
            .drive(alertLabel.rx.isHidden)
            .disposed(by: disposeBag)
    }
}
