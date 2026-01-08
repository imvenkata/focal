---
name: structured-planner-timeline-ui
description: Use when building or modifying daily/weekly timeline views, task pills/cards, time labels, and timeline interactions.
---

# Structured Planner Timeline UI

## Read First
- `Focal/Views/Timeline/DailyTimelineView.swift`
- `Focal/Views/Timeline/WeeklyTimelineView.swift`
- `Focal/Views/Timeline/CurrentTimeIndicator.swift`
- `Focal/Views/Task/TaskCardView.swift`
- `Focal/Views/Components/EmptyIntervalView.swift`
- `Focal/ViewModels/TaskDragState.swift`
- `Focal/ViewModels/TaskStore.swift`

## Visual Rules
- Task pill default size 56x56, height scales with duration.
- Time labels: monospaced 11pt, DS stone400.
- Current time: pulsing dot + gradient line.
- Empty gaps can show CTA to add task and/or interval messaging.

## Interaction Rules
- Checkbox toggles completion and fires success haptic.
- Tap task pill opens details.
- Long press can initiate drag; use `HapticManager.shared.dragActivated()`.
- Swipe actions for quick complete/delete.
- Pull to refresh if applicable.

## Implementation Notes
- Use DS spacing/radius/colors, `DS.Animation.spring` for transitions.
- Align guideline/current-time indicator to pill centerline.
- Provide accessibility labels/hints for all interactive elements.

## Haptic Map
- Completion: `HapticManager.shared.taskCompleted()`
- Delete: `HapticManager.shared.deleted()`
- Selection/time snap: `HapticManager.shared.selection()`
- Drag: `dragActivated` / `dragMoved` / `dragDropped`
