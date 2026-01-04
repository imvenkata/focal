import SwiftUI

@Observable
final class TaskDragState {
    var isDragging: Bool = false
    var draggedTask: TaskItem? = nil
    var dragLocation: CGPoint = .zero
    var sourceColumnIndex: Int? = nil
    var targetColumnIndex: Int? = nil
    var targetHour: Int? = nil
    var targetMinute: Int = 0

    // Column frames for hit testing
    var columnFrames: [Int: CGRect] = [:]

    // Timeline configuration
    var timelineStartHour: Int = 6
    var timelineEndHour: Int = 23

    func startDrag(task: TaskItem, columnIndex: Int, location: CGPoint) {
        isDragging = true
        draggedTask = task
        sourceColumnIndex = columnIndex
        dragLocation = location
        targetColumnIndex = columnIndex
        targetHour = task.startTime.hour
        targetMinute = task.startTime.minute
        HapticManager.shared.dragActivated()
    }

    func updateDrag(location: CGPoint, in coordinateSpace: CoordinateSpace = .global) {
        dragLocation = location

        // Determine which column we're over
        var newTarget: Int? = nil
        var newHour: Int? = nil
        var newMinute: Int = 0

        for (index, frame) in columnFrames {
            if location.x >= frame.minX && location.x <= frame.maxX {
                newTarget = index

                // Calculate time based on Y position within the column
                let relativeY = location.y - frame.minY
                let totalHours = CGFloat(timelineEndHour - timelineStartHour)
                let hourHeight = frame.height / totalHours

                let hoursFromTop = relativeY / hourHeight
                let calculatedHour = timelineStartHour + Int(hoursFromTop)

                // Clamp to valid range
                newHour = max(timelineStartHour, min(timelineEndHour - 1, calculatedHour))

                // Calculate minutes (snap to 1-minute intervals)
                let fractionalHour = hoursFromTop - floor(hoursFromTop)
                let rawMinutes = Int(fractionalHour * 60)
                newMinute = min(rawMinutes, 59) // Snap to every minute: 0-59

                break
            }
        }

        // Haptic feedback when changing column
        if newTarget != targetColumnIndex && newTarget != nil {
            HapticManager.shared.dragMoved()
        }

        // Haptic feedback when changing hour
        if newHour != targetHour && newHour != nil {
            HapticManager.shared.selection()
        }

        targetColumnIndex = newTarget
        targetHour = newHour
        targetMinute = newMinute
    }

    func endDrag() -> (task: TaskItem, toIndex: Int, toHour: Int, toMinute: Int)? {
        guard let task = draggedTask,
              let to = targetColumnIndex,
              let hour = targetHour else {
            cancelDrag()
            return nil
        }

        // Check if anything actually changed
        let from = sourceColumnIndex ?? to
        let originalHour = task.startTime.hour
        let originalMinute = task.startTime.minute

        let dayChanged = from != to
        let timeChanged = hour != originalHour || targetMinute != originalMinute

        guard dayChanged || timeChanged else {
            cancelDrag()
            return nil
        }

        let result = (task: task, toIndex: to, toHour: hour, toMinute: targetMinute)
        reset()
        HapticManager.shared.dragDropped()
        return result
    }

    func cancelDrag() {
        HapticManager.shared.dragCancelled()
        reset()
    }

    private func reset() {
        isDragging = false
        draggedTask = nil
        dragLocation = .zero
        sourceColumnIndex = nil
        targetColumnIndex = nil
        targetHour = nil
        targetMinute = 0
    }

    func registerColumnFrame(index: Int, frame: CGRect) {
        columnFrames[index] = frame
    }

    func isTargetColumn(_ index: Int) -> Bool {
        guard isDragging else { return false }
        return targetColumnIndex == index
    }

    func isDraggedTask(_ task: TaskItem) -> Bool {
        draggedTask?.id == task.id
    }

    var formattedTargetTime: String {
        guard let hour = targetHour else { return "" }
        return String(format: "%02d:%02d", hour, targetMinute)
    }
}
