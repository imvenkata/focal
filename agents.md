# Structured Planner - AI Development Agent Instructions

## Project Overview

You are helping build **Structured Planner**, a native iOS app built with Swift and SwiftUI. The app is a visual task management and scheduling tool inspired by Tiimo and Structured.

**Tech Stack:**
- Language: Swift 5.9+
- UI Framework: SwiftUI
- Minimum iOS: 17.0
- Architecture: MVVM
- Data Persistence: SwiftData
- State Management: @Observable, @State, @Binding

---

## Project Structure

- App: StructuredPlannerApp.swift, ContentView.swift
- Models: Task.swift, Subtask.swift, TaskColor.swift, UserPreferences.swift
- ViewModels: TaskStore.swift, WeekViewModel.swift, DayViewModel.swift
- Views:
  - Timeline: WeeklyTimelineView.swift, DailyTimelineView.swift, TimelineToggle.swift, CurrentTimeIndicator.swift
  - Task: TaskPinView.swift, TaskCardView.swift, TaskDetailView.swift, AddTaskSheet.swift
  - Pickers: TimePickerSheet.swift, DatePickerSheet.swift, EnergyPickerSheet.swift, IconPickerView.swift, ColorPickerView.swift
  - Components: WeekSelector.swift, StatsBar.swift, SubtaskRow.swift, EmptyIntervalView.swift
  - Navigation: BottomTabBar.swift, FABButton.swift
- Utilities: IconMapper.swift, DateFormatter+Extensions.swift, Color+Extensions.swift, HapticManager.swift
- Resources: Assets.xcassets, Localizable.strings
- Preview Content: PreviewData.swift

---

## Design System Constants

Create `DesignSystem.swift` with:
- `DS.Colors`: coral, sage, sky, lavender, amber, rose, slate, night, plus light variants, background, and cardBackground.
- `DS.Spacing`: xs, sm, md, lg, xl, xxl, xxxl.
- `DS.Radius`: sm, md, lg, xl, xxl, pill.
- `DS.Sizes`: iconButtonSize, taskPillDefault, taskPillLarge, fabSize, bottomNavHeight, sheetHandle.
- `DS.Animation`: spring, quick, gentle (spring-based).
- `Color(hex:)` initializer for 6-digit hex strings.

---

## Core Models

### Task
- Fields: id, title, icon, colorName, startTime, duration, isRoutine, repeatDays, reminderOption, energyLevel, subtasks, notes, isCompleted, completedAt, createdAt, updatedAt.
- Derived: color (from TaskColor), endTime, durationFormatted.

### TaskColor
- Cases: coral, sage, sky, lavender, amber, rose, slate, night.
- Provides `color` and `lightColor` mapped to DS colors.

---

## Key View Implementations

### IconMapper
- Maps task titles to icon, label, and suggested color based on keywords.
- Matching order: exact match, contains keyword, then word-by-word.

### HapticManager
- Singleton helper for impact, notification, and selection haptics.

---

## View Implementation Guidelines

### General Rules

1. **Use Design System constants** - Always use `DS.Colors`, `DS.Spacing`, `DS.Radius` instead of hardcoded values

2. **Haptic feedback** - Add haptics for:
   - Task completion: `.notification(.success)`
   - Color/icon selection: `.impact(.light)`
   - Time snap: `.selection()`
   - Delete: `.notification(.warning)`

3. **Animations** - Use `DS.Animation.spring` for most transitions

4. **Accessibility** - Add `.accessibilityLabel()` and `.accessibilityHint()` to all interactive elements

### Component Patterns

- Task pill: rounded rectangle with task color, centered icon, and a subtle shadow.
- Sheet presentation: medium/large detents, visible drag indicator, corner radius `DS.Radius.xxl`.
- Bottom navigation: tab buttons with selection haptics, horizontal padding, top padding, safe area bottom padding, and an ultraThinMaterial background.

---

## State Management

### TaskStore (Observable)

- State: tasks, selectedDate, viewMode (week/day).
- Computed: tasksForSelectedDate (sorted), tasksForWeek (7 days, sorted).
- Actions: toggleCompletion updates completion timestamps and fires success/warning haptics; deleteTask fires warning and removes the task.

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

1. **Core Models** - Task, Subtask, TaskColor
2. **Design System** - Colors, Spacing, Components
3. **IconMapper** - Auto icon selection
4. **WeeklyTimelineView** - Main week grid
5. **DailyTimelineView** - Day detail
6. **TaskPinView / TaskCardView** - Task display
7. **AddTaskSheet** - Task creation
8. **TaskDetailView** - Task editing
9. **Picker Sheets** - Time, Date, Energy
10. **Bottom Navigation** - Tab bar + FAB
11. **Polish** - Animations, haptics, accessibility

---

## Common Issues & Solutions

**Issue:** Sheet doesn't animate smoothly
**Solution:** Use `.interactiveDismissDisabled()` sparingly, ensure no heavy computation in sheet body

**Issue:** Timeline scroll jumps
**Solution:** Use `ScrollViewReader` with `.scrollPosition(id:)` in iOS 17+

**Issue:** Auto icon not updating
**Solution:** Ensure `@State` or `@Published` property is being observed correctly

**Issue:** Current time indicator not visible
**Solution:** Check z-index with `.zIndex()` modifier, ensure parent isn't clipping

---

## Resources

- [Apple HIG - Planning Apps](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [SF Symbols](https://developer.apple.com/sf-symbols/)

---

## Contact

For design questions, refer to `DESIGN_DOCUMENT.md`
For implementation questions, ask the AI assistant with context from this file.
