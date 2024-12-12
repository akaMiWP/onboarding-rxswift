// 

import RxSwift
import RxRelay
import SnapKit
import UIKit

final class CustomCell: UITableViewCell {
    
    let checkBoxTapped = PublishSubject<Bool>()
    
    private let checkboxButton = UIButton(type: .custom)
    private let strikeThroughLine: UIView = .init()
    private var disposeBag: DisposeBag = .init()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCheckbox()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Shouldn't be called")
    }
}

// MARK: - Private
extension CustomCell {
    private func setupCheckbox() {
        contentView.addSubview(checkboxButton)
        contentView.addSubview(strikeThroughLine)
        checkboxButton.setImage(UIImage(systemName: "square"), for: .normal)
        checkboxButton.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
        checkboxButton.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-22)
        }
        strikeThroughLine.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(4)
            $0.height.equalTo(1)
            $0.centerY.equalToSuperview()
        }
        strikeThroughLine.backgroundColor = .lightGray
    }
    
    func bind(item: TodoModel, selectedCellSubject: PublishSubject<(TodoModel, Bool)>) {
        // Reset disposeBag for fresh bindings
        disposeBag = DisposeBag()
        
        // Set viewModel
        checkboxButton.isSelected = item.isCompleted
        strikeThroughLine.isHidden = !item.isCompleted
        textLabel?.text = item.title
        selectionStyle = .none
        
        // Emit checkbox tap events with the current model
        checkboxButton.rx.tap
            .map { !self.checkboxButton.isSelected } // Toggle checkbox state
            .do(onNext: { [weak self] isSelected in
                self?.checkboxButton.isSelected = isSelected
                self?.strikeThroughLine.isHidden = !isSelected
            })
            .map { (item, $0) } // Map to (TodoModel, isSelected)
            .bind(to: selectedCellSubject) // Emit to parent
            .disposed(by: disposeBag)
    }
}
