// 

protocol Coordinator: AnyObject {
    var coordinators: [Coordinator] { get }
    func start()
}
