import Foundation
import SwiftData
import SwiftUI

@Model
final class TodoItem {
    var id: UUID
    var title: String
    var icon: String
    var colorName: String
    var priority: String
    @Relationship(deleteRule: .cascade) var subtasks: [TodoSubtask]
    var notes: String?
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date
    var updatedAt: Date
    var orderIndex: Int

    init(
        title: String,
        icon: String = "📝",
        colorName: String = "sky",
        priority: TodoPriority = .medium,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.icon = icon
        self.colorName = colorName
        self.priority = priority.rawValue
        self.subtasks = []
        self.notes = notes
        self.isCompleted = false
        self.completedAt = nil
        self.createdAt = Date()
        self.updatedAt = Date()
        self.orderIndex = 0
    }

    // MARK: - Computed Properties

    var priorityEnum: TodoPriority {
        TodoPriority(rawValue: priority) ?? .medium
    }

    var color: TaskColor {
        TaskColor(rawValue: colorName) ?? .sky
    }

    var completedSubtasksCount: Int {
        subtasks.filter { $0.isCompleted }.count
    }

    var totalSubtasks: Int {
        subtasks.count
    }

    var subtasksProgress: Double {
        guard !subtasks.isEmpty else { return 0 }
        return Double(completedSubtasksCount) / Double(totalSubtasks)
    }

    var hasSubtasks: Bool {
        !subtasks.isEmpty
    }

    // MARK: - Methods

    func toggleCompletion() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
        updatedAt = Date()
    }

    func addSubtask(_ title: String) {
        let orderIndex = subtasks.count
        let subtask = TodoSubtask(title: title, orderIndex: orderIndex)
        subtasks.append(subtask)
        updatedAt = Date()
    }

    func removeSubtask(_ subtask: TodoSubtask) {
        subtasks.removeAll { $0.id == subtask.id }
        // Reindex remaining subtasks
        for (index, subtask) in subtasks.enumerated() {
            subtask.orderIndex = index
        }
        updatedAt = Date()
    }

    func setPriority(_ priority: TodoPriority) {
        self.priority = priority.rawValue
        updatedAt = Date()
    }
}
