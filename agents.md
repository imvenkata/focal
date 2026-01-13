# Focal - AI Development Agent Instructions

This file is used by GitHub Copilot and other coding agents. Keep it concise and current.

## Project Overview

You are helping build Focal (Structured Planner), a native iOS app for visual task management and scheduling inspired by Tiimo and Structured, focused on neurodivergent-friendly planning.

## Tech Stack
- Language: Swift 5.9+
- UI Framework: SwiftUI
- Minimum iOS: 17.0
- Architecture: MVVM
- Data Persistence: SwiftData
- State Management: @Observable, @State, @Binding

---

## Agent Notes
- Do not read or scan the DerivedData directory.
- Do not add new dependencies or change build settings without approval.
- Keep changes focused and avoid large refactors unless requested.

---

## Common Commands
- Open Xcode project: `open Focal.xcodeproj`
- Build (Debug): `xcodebuild -project Focal.xcodeproj -scheme Focal -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -configuration Debug build`
- Run tests: `xcodebuild -project Focal.xcodeproj -scheme Focal -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test`
- See `README.md` for full simulator boot/install/run steps.

---

## Project Structure
- App: `Focal/App/FocalApp.swift`, `Focal/App/ContentView.swift`
- Models: `Focal/Models/TaskItem.swift`, `Focal/Models/TaskColor.swift`, `Focal/Models/Subtask.swift`, `Focal/Models/EnergyLevel.swift`, `Focal/Models/TodoItem.swift`, `Focal/Models/TodoSubtask.swift`, `Focal/Models/TodoPriority.swift`
- ViewModels: `Focal/ViewModels/TaskStore.swift`, `Focal/ViewModels/TodoStore.swift`, `Focal/ViewModels/Tab.swift`, `Focal/ViewModels/TaskDragState.swift`
- Views:
  - Timeline: `Focal/Views/Timeline/WeeklyTimelineView.swift`, `Focal/Views/Timeline/DailyTimelineView.swift`, `Focal/Views/Timeline/PlannerView.swift`, `Focal/Views/Timeline/CurrentTimeIndicator.swift`
  - Task: `Focal/Views/Task/TaskPinView.swift`, `Focal/Views/Task/TaskCardView.swift`, `Focal/Views/Task/TaskDetailView.swift`, `Focal/Views/Task/TaskCapsuleView.swift`, `Focal/Views/Task/AddTaskSheet.swift`, `Focal/Views/Task/PlannerTaskCreationSheet.swift`
  - Pickers: `Focal/Views/Pickers/TimePickerSheet.swift`, `Focal/Views/Pickers/DatePickerSheet.swift`, `Focal/Views/Pickers/EnergyPickerSheet.swift`, `Focal/Views/Pickers/IconPickerView.swift`, `Focal/Views/Pickers/ColorPickerView.swift`, `Focal/Views/Pickers/WhenPickerSheet.swift`
  - Components: `Focal/Views/Components/WeekSelector.swift`, `Focal/Views/Components/StatsBar.swift`, `Focal/Views/Components/SubtaskRow.swift`, `Focal/Views/Components/EmptyIntervalView.swift`, `Focal/Views/Components/ProgressBar.swift`, `Focal/Views/Components/FloatingTaskInputCard.swift`, `Focal/Views/Components/TodoCard.swift`, `Focal/Views/Components/TodoPrioritySection.swift`, `Focal/Views/Components/TodoQuickAddBar.swift`, `Focal/Views/Components/TodoSubtaskRow.swift`
  - Navigation: `Focal/Views/Navigation/BottomTabBar.swift`, `Focal/Views/Navigation/FABButton.swift`
  - Todo: `Focal/Views/Todo/TodoView.swift`, `Focal/Views/Todo/TodoDetailView.swift`
- Utilities: `Focal/Utilities/DesignSystem.swift`, `Focal/Utilities/IconMapper.swift`, `Focal/Utilities/HapticManager.swift`, `Focal/Utilities/ScaledFont.swift`, `Focal/Utilities/DateExtensions.swift`
- Resources: `Focal/Resources/Assets.xcassets`
- Preview Content: `Focal/Preview Content/PreviewData.swift`
- Design docs: `DESIGN_SYSTEM.md`, `DESIGN_DOCUMENT.md`

---

## Design System Constants

Design tokens live in `Focal/Utilities/DesignSystem.swift`:
- `DS.Colors`: coral, sage, sky, lavender, amber, rose, slate, night, plus light variants, background, and cardBackground.
- `DS.Spacing`: xs, sm, md, lg, xl, xxl, xxxl.
- `DS.Radius`: sm, md, lg, xl, xxl, pill.
- `DS.Sizes`: iconButtonSize, taskPillDefault, taskPillLarge, fabSize, bottomNavHeight, sheetHandle.
- `DS.Animation`: spring, quick, gentle (spring-based).
- `Color(hex:)` initializer for 6-digit hex strings.

---

## Core Models

### TaskItem
- Fields: id, title, icon, colorName, startTime, duration, recurrenceOption, repeatDays, reminderOption, energyLevel, subtasks, notes, isCompleted, completedAt, createdAt, updatedAt.
- Derived: color (from TaskColor), endTime, durationFormatted, timeRangeFormatted.

### TaskColor
- Cases: coral, sage, sky, lavender, amber, rose, slate, night.
- Provides `color` and `lightColor` mapped to DS colors.

### TodoItem
- Fields: id, title, icon, colorName, priority, category, subtasks, notes, isCompleted, completedAt, createdAt, updatedAt, orderIndex, dueDate, dueTime, reminderOption, recurrenceOption, repeatDays, energyLevel, estimatedDuration, isArchived, tags.
- Derived: priorityEnum, categoryEnum, color, subtasksProgress.

---

## Key View Implementations

### IconMapper
- Maps task titles to icon, label, and suggested color based on keywords.
- Matching order: exact match, contains keyword, then word-by-word.

### HapticManager
- Singleton helper for impact, notification, and selection haptics.
- Use convenience methods where possible: `taskCompleted`, `deleted`, `colorSelected`, `iconSelected`, `timeSnapped`.

---

## View Implementation Guidelines

### General Rules
1. Use Design System constants (`DS.Colors`, `DS.Spacing`, `DS.Radius`, `DS.Sizes`) instead of hardcoded values.
2. Haptic feedback:
   - Task completion: `HapticManager.shared.taskCompleted()`
   - Delete: `HapticManager.shared.deleted()`
   - Color/icon selection: `HapticManager.shared.colorSelected()` / `HapticManager.shared.iconSelected()`
   - Time snap: `HapticManager.shared.timeSnapped()`
3. Animations: use `DS.Animation.spring` for most transitions.
4. Accessibility: add `.accessibilityLabel()` and `.accessibilityHint()` to interactive elements.
5. Dynamic Type: use `ScaledFont` or `.relativeTo` to scale text.

### Component Patterns
- Task pill/capsule: rounded rectangle with task color, centered icon, subtle shadow.
- Sheet presentation: medium/large detents, visible drag indicator, corner radius `DS.Radius.xxl`.
- Bottom navigation: tab buttons with selection haptics, horizontal padding, top padding, safe area bottom padding, and an ultraThinMaterial background.

---

## State Management

### TaskStore (Observable)
- State: tasks, selectedDate, viewMode (week/day).
- Computed: tasksForSelectedDate (sorted), tasksForWeek (7 days, sorted).
- Actions: toggleCompletion updates completion timestamps and fires success haptics; deleteTask fires warning and removes the task.

### TodoStore (Observable)
- State: todos, filters, selection, collapsed sections.
- Actions: supports filtering, undo, section collapse (selection haptics), and persistence via SwiftData.

---

## Testing Checklist

Before completing each screen, verify:
- [ ] Works in Light mode
- [ ] Works in Dark mode (future)
- [ ] Animations are smooth (60fps)
- [ ] Haptic feedback triggers correctly
- [ ] VoiceOver reads all elements
- [ ] Dynamic Type scales properly
- [ ] Works on iPhone SE (small screen)
- [ ] Works on iPhone 15 Pro Max (large screen)
- [ ] Keyboard avoidance works in sheets
- [ ] Pull to refresh works (if applicable)
- [ ] Empty states display correctly

---

## Development Order

Build screens in this order:
1. Core Models - TaskItem, Subtask, TaskColor
2. Design System - Colors, Spacing, Components
3. IconMapper - Auto icon selection
4. WeeklyTimelineView - Main week grid
5. DailyTimelineView - Day detail
6. TaskPinView / TaskCardView - Task display
7. AddTaskSheet - Task creation
8. TaskDetailView - Task editing
9. Picker Sheets - Time, Date, Energy
10. Bottom Navigation - Tab bar + FAB
11. Polish - Animations, haptics, accessibility
