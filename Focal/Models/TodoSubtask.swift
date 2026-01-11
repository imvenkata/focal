import Foundation
import SwiftData

@Model
final class TodoSubtask {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var orderIndex: Int

    init(title: String, isCompleted: Bool = false, orderIndex: Int = 0) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.orderIndex = orderIndex
    }

    func toggle() {
        isCompleted.toggle()
    }
}
