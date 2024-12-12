// 

import Foundation

struct TodoModel: Codable {
    let isCompleted: Bool
    let title: String
    let createdDate: Date
    let completedDate: Date?
    
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
