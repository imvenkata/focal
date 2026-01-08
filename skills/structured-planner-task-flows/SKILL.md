---
name: structured-planner-task-flows
description: Use when working on task creation/editing sheets, picker sheets, and bottom navigation/FAB flows.
---

# Structured Planner Task Flows

## Read First
- `Focal/Views/Task/AddTaskSheet.swift`
- `Focal/Views/Task/PlannerTaskCreationSheet.swift`
- `Focal/Views/Task/TaskDetailView.swift`
- `Focal/Views/Pickers/TimePickerSheet.swift`
- `Focal/Views/Pickers/DatePickerSheet.swift`
- `Focal/Views/Pickers/EnergyPickerSheet.swift`
- `Focal/Views/Pickers/IconPickerView.swift`
- `Focal/Views/Pickers/ColorPickerView.swift`
- `Focal/Views/Navigation/BottomTabBar.swift`
- `Focal/Views/Navigation/FABButton.swift`

## Sheet Pattern
- Use medium/large detents with drag indicator.
- Corner radius `DS.Radius.xxl`.
- Provide keyboard avoidance and safe area padding.

## Interaction/Haptics
- Color/icon selection: `HapticManager.shared.impact(.light)` via helper.
- Delete: `HapticManager.shared.deleted()`.
- Use `DS.Animation.spring` for transitions.

## Accessibility
- Add labels/hints to all interactive elements.
- Confirm VoiceOver order for form fields and pickers.

## State
- Use `@State` for form inputs and `@Binding` for selected values.
- Use `TaskStore` actions for persistence.
