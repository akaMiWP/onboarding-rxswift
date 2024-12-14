// 

protocol Coordinator {
    var coordinators: [Coordinator] { get }
    func start()
}
