import Foundation
import SwiftData

/// Records the completion of a specific instance of a recurring task.
/// This allows tracking completion independently for each occurrence of a recurring task.
@Model
final class TaskCompletionRecord {
    /// Unique identifier for this record
    var id: UUID

    /// The ID of the source TaskItem this completion belongs to
    var taskId: UUID

    /// The date of the specific occurrence that was completed
    var completedDate: Date

    /// When the user marked this instance as completed
    var completedAt: Date

    init(taskId: UUID, completedDate: Date) {
        self.id = UUID()
        self.taskId = taskId
        self.completedDate = completedDate
        self.completedAt = Date()
    }
}
