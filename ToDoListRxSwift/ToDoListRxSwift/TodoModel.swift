// 

import Foundation

struct TodoModel: Codable {
    var id: UUID = .init()
    let title: String
    let createdDate: Date
    var isCompleted: Bool
    var completedDate: Date?
    
    init(isCompleted: Bool = false,
         title: String,
         createdDate: Date = .init(),
         completedDate: Date? = nil
    ) {
        self.isCompleted = isCompleted
        self.title = title
        self.createdDate = createdDate
        self.completedDate = completedDate
    }
}
