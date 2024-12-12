// 

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = .init(title: "Add", style: .plain, target: self, action: nil)
    }
}

// MARK: - Private
private extension ViewController {
    @objc func didTapAddTaskButton() {
        
    }
}
