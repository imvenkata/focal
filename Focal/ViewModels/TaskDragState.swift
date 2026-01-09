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

        // Guard against race condition: frames must be registered before drag works
        guard !columnFrames.isEmpty else { return }

        // Determine which column we're over
        var newTarget: Int? = nil
        var newHour: Int? = nil
        var newMinute: Int = 0

        let horizontalTolerance: CGFloat = DS.Spacing.lg  // Reduced tolerance for precision

        for (index, frame) in columnFrames.sorted(by: { $0.key < $1.key }) {
            let minX = frame.minX - horizontalTolerance
            let maxX = frame.maxX + horizontalTolerance

            if location.x >= minX && location.x <= maxX {
                newTarget = index

                // Calculate time based on Y position within the column
                let relativeY = location.y - frame.minY
                let totalHours = CGFloat(timelineEndHour - timelineStartHour)
                let hourHeight = frame.height / totalHours

                let hoursFromTop = max(0, relativeY / hourHeight)
                let calculatedHour = timelineStartHour + Int(floor(hoursFromTop))

                // Clamp to valid range
                newHour = max(timelineStartHour, min(timelineEndHour - 1, calculatedHour))

                // Calculate minutes - snap to 15-minute intervals for cleaner times
                let fractionalHour = hoursFromTop - floor(hoursFromTop)
                let rawMinutes = Int(fractionalHour * 60)
                // Snap to 15-minute intervals: 0, 15, 30, 45
                newMinute = (rawMinutes / 15) * 15

                break
            }
        }

        // Only haptic on column or hour change (not every minute)
        let columnChanged = newTarget != targetColumnIndex && newTarget != nil
        let hourChanged = newHour != targetHour && newHour != nil

        if columnChanged {
            HapticManager.shared.impact(.medium)
        } else if hourChanged {
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
