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
        // Slight delay for haptic to sync with visual scale animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            HapticManager.shared.dragActivated()
        }
    }

    func updateDrag(location: CGPoint, in coordinateSpace: CoordinateSpace = .global) {
        dragLocation = location

        // Guard against race condition: frames must be registered before drag works
        guard !columnFrames.isEmpty else { return }

        // Determine which column we're over
        var newTarget: Int? = nil
        var newHour: Int? = nil
        var newMinute: Int = 0

        let horizontalTolerance: CGFloat = DS.Spacing.xxl

        for (index, frame) in columnFrames {
            let minX = frame.minX - horizontalTolerance
            let maxX = frame.maxX + horizontalTolerance

            if location.x >= minX && location.x <= maxX {
                newTarget = index

                // Calculate time based on Y position within the column
                let relativeY = location.y - frame.minY
                let totalHours = CGFloat(timelineEndHour - timelineStartHour)
                let hourHeight = frame.height / totalHours

                let hoursFromTop = relativeY / hourHeight
                // Use floor explicitly for correct hour calculation
                let calculatedHour = timelineStartHour + Int(floor(hoursFromTop))

                // Clamp to valid range
                newHour = max(timelineStartHour, min(timelineEndHour - 1, calculatedHour))

                // Calculate minutes with 5-minute snapping for smoother UX
                let fractionalHour = hoursFromTop - floor(hoursFromTop)
                let rawMinutes = Int(fractionalHour * 60)
                // Snap to 5-minute intervals: 0, 5, 10, 15, ... 55
                newMinute = min((rawMinutes / 5) * 5, 55)

                break
            }
        }

        // Detect snap events for haptic feedback
        let columnChanged = newTarget != targetColumnIndex && newTarget != nil
        let hourChanged = newHour != targetHour && newHour != nil
        let minuteChanged = newMinute != targetMinute && newTarget != nil

        // Strong haptic for column or hour change, light for minute change
        if columnChanged || hourChanged {
            HapticManager.shared.selection()
        } else if minuteChanged {
            HapticManager.shared.impact(.light)
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
