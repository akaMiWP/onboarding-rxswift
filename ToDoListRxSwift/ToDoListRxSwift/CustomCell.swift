// 

import RxSwift
import SnapKit
import UIKit

final class CustomCell: UITableViewCell {
    
    let checkboxButton = UIButton(type: .custom)
    let checkBoxTapped = PublishSubject<Bool>()
    
    var disposeBag: DisposeBag = .init()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCheckbox()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Shouldn't be called")
    }
}

// MARK: - Private
private extension CustomCell {
    func setupCheckbox() {
        contentView.addSubview(checkboxButton)
        checkboxButton.setImage(UIImage(systemName: "square"), for: .normal)
        checkboxButton.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
        checkboxButton.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-22)
        }
    }
    
    func bindUI() {
        checkboxButton.rx.tap
            .debug()
            .map { _ in !self.checkboxButton.isSelected }
            .do(onNext: { [weak self] isSelected in
                self?.checkboxButton.isSelected = isSelected
            })
            .bind(to: checkBoxTapped)
            .disposed(by: disposeBag)
    }
}
