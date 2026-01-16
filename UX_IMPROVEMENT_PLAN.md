# Focal UX Improvement Architecture Plan

## Executive Summary

After comprehensive UX evaluation against Tiimo and Structured, Focal has significant friction points that prevent matching competitor ease of use. This plan addresses the top priorities through targeted architectural changes.

---

## Critical UX Gaps vs Competitors

| Feature | Tiimo | Structured | Focal (Current) |
|---------|-------|------------|-----------------|
| Tap timeline to add | Yes | Yes | No |
| Drag tasks in day view | Yes | Yes | No (week only) |
| Inline quick edit | Yes | Yes | No |
| Pinch-to-zoom timeline | Yes | No | No |
| Swipe gestures iOS-standard | Yes | Yes | Partially |
| Touch target compliance | Yes | Yes | No (28pt checkbox) |
| Single entry point | Yes | Yes | No (3 competing) |
| Visual gesture hints | Yes | No | No |

---

## Phase 1: Foundation Fixes (Highest Impact)

### 1.1 Standardize Touch Targets (44pt minimum)

**Problem**: Checkboxes are 28pt, below Apple's 44pt minimum.

**Files to modify**:
- `Focal/Views/Task/TaskCardView.swift` (line 112-128)
- `Focal/Views/Todo/TodoView.swift` - CompletedTodoCard checkbox
- `Focal/Views/Todo/TodoDetailView.swift` (line 615-637)

**Change**:
```swift
// Current
.frame(width: 28, height: 28)

// New: Visual size stays small, tap area expanded
ZStack {
    Circle()
        .strokeBorder(...)
        .frame(width: 28, height: 28)
    // ...
}
.frame(width: DS.Sizes.minTouchTarget, height: DS.Sizes.minTouchTarget) // 44pt
.contentShape(Circle().size(width: 44, height: 44))
```

**Impact**: Immediate usability improvement for all users.

---

### 1.2 Single Entry Point for Task/Todo Creation

**Problem**: 3 competing add buttons create confusion:
1. FAB in bottom bar
2. Plus button in header
3. "Add it to your list" card at scroll bottom

**Architecture**:
- Keep FAB as PRIMARY entry point (centered, always visible)
- Remove header plus button
- Convert bottom card to contextual "empty state" hint only

**Files to modify**:
- `Focal/Views/Todo/TodoView.swift`
  - Remove headerSection plus button (lines 42-54)
  - Make quickAddSection only visible when list is empty

---

### 1.3 Fix Swipe Gesture Directions (iOS Convention)

**Problem**: Mixed swipe directions confuse muscle memory.

**iOS Standard**:
- Swipe LEFT reveals TRAILING actions (destructive: delete)
- Swipe RIGHT reveals LEADING actions (positive: complete)

**Current State**:
- TaskCardView: Correct (swipe left = delete, swipe right = complete)
- CompletedTodoCard: Custom gesture, swipe left = delete (correct)
- Need to audit all swipe actions for consistency

**Files to audit**:
- `Focal/Views/Task/TaskCardView.swift` - Lines 142-158 (correct)
- `Focal/Views/Todo/TodoView.swift` - CompletedTodoCard (lines 828-845)

---

## Phase 2: Core Interaction Improvements

### 2.1 Tap-to-Create on Timeline

**Problem**: Must use FAB to create tasks. Competitors allow tapping empty timeline slots.

**New Architecture**:

```swift
// In DailyTimelineView.swift - EmptyIntervalView
struct EmptyIntervalView: View {
    // Add tap gesture to create task at this time slot
    .onTapGesture {
        // Create new task starting at this slot's time
        let startTime = gap.startTime
        onTapToCreate(startTime)
    }

    // Visual feedback on hover/press
    .overlay {
        if isPressed {
            RoundedRectangle(cornerRadius: DS.Radius.sm)
                .fill(DS.Colors.accent.opacity(0.1))
        }
    }
}
```

**Files to modify**:
- `Focal/Views/Timeline/DailyTimelineView.swift`
  - Add onTapToCreate callback to EmptyIntervalView
  - Pass preset time to PlannerTaskCreationSheet
- `Focal/Views/Components/EmptyIntervalView.swift` (if separate)

**User Flow**:
1. User taps empty timeline slot (e.g., 2pm gap)
2. PlannerTaskCreationSheet opens with time pre-filled to 2pm
3. User types task name and taps Continue
4. Task appears in timeline at tapped slot

---

### 2.2 Drag Tasks in Day View

**Problem**: Day view tasks can't be dragged. Only week view supports drag.

**Architecture**:
- Reuse `TaskDragState` from week view
- Add drag gesture to `TaskCardView` in day view
- Allow vertical drag to reschedule time within same day

**Implementation Pattern**:
```swift
// TaskCardView.swift - Add to day view usage
.gesture(
    LongPressGesture(minimumDuration: 0.25)
        .sequenced(before: DragGesture())
        .onChanged { ... }
        .onEnded { value in
            // Calculate new time from Y position
            let newHour = calculateHourFromDrag(yOffset)
            taskStore.rescheduleTask(task, to: newHour)
        }
)
```

**Files to modify**:
- `Focal/Views/Task/TaskCardView.swift` - Add drag gesture
- `Focal/Views/Timeline/DailyTimelineView.swift` - Support drop zones
- `Focal/ViewModels/TaskStore.swift` - Add `rescheduleTask` method

---

### 2.3 Inline Quick Edit for Common Actions

**Problem**: Editing any attribute requires opening detail sheet.

**New Architecture**: Long-press context menu for quick actions

```swift
// TaskCardView / TodoCard
.contextMenu {
    // Quick time change
    Menu("Reschedule") {
        Button("In 1 hour") { reschedule(+1) }
        Button("Tomorrow") { rescheduleToTomorrow() }
        Button("Pick time...") { showTimePicker = true }
    }

    // Quick priority change
    Menu("Priority") {
        ForEach(TodoPriority.allCases) { priority in
            Button(priority.displayName) { changePriority(priority) }
        }
    }

    Divider()

    Button(role: .destructive) { delete() } label: {
        Label("Delete", systemImage: "trash")
    }
}
```

**Files to modify**:
- `Focal/Views/Task/TaskCardView.swift` - Add context menu
- `Focal/Views/Todo/TodoView.swift` - TodoPrioritySection cards

---

## Phase 3: Delight & Polish

### 3.1 Visual Gesture Hints (Onboarding)

**Problem**: Users don't discover swipe/drag gestures.

**Architecture**: First-use hints with animation

```swift
// New file: Focal/Views/Components/GestureHintOverlay.swift
struct GestureHintOverlay: View {
    @AppStorage("hasSeenSwipeHint") var hasSeenHint = false

    var body: some View {
        if !hasSeenHint {
            VStack {
                // Animated hand swiping left
                SwipeHintAnimation()

                Text("Swipe left to delete")
                    .font(.caption)
            }
            .onTapGesture { hasSeenHint = true }
        }
    }
}
```

**Files to create**:
- `Focal/Views/Components/GestureHintOverlay.swift`
- `Focal/Views/Components/DragHintOverlay.swift`

---

### 3.2 Reduce Sheet Cascade Depth

**Problem**: Detail view opens sheets which open more sheets (3 levels deep).

**Architecture**: Inline expandable sections instead of sheets

```swift
// TodoDetailView - Replace sheet pickers with inline expansion
@State private var expandedSection: DetailSection?

enum DetailSection {
    case date, time, reminder, repeat
}

// In scheduleSection
DisclosureGroup(isExpanded: expandedSection == .date) {
    DatePicker("", selection: $dueDate)
        .datePickerStyle(.graphical)
} label: {
    TodoDetailInfoRow(...)
}
```

**Alternative**: Use `.sheet(item:)` with navigation stack for back button

---

### 3.3 Week View Task Pin Improvements

**Problem**: Tiny pins are hard to distinguish.

**Improvements**:
- Show first 3 characters of task title on hover/press
- Color-coded glow for current task
- Pulse animation for upcoming tasks (within 15 min)

**Files to modify**:
- `Focal/Views/Components/MiniTaskPin.swift`
- `Focal/Views/Timeline/WeeklyTimelineView.swift`

---

## Phase 4: Competitive Parity Features

### 4.1 Pinch-to-Zoom Timeline (Tiimo Feature)

**Architecture**:
```swift
// DailyTimelineView - Add MagnificationGesture
@State private var timelineScale: CGFloat = 1.0
@State private var hourHeight: CGFloat = DS.Sizes.hourHeight

.gesture(
    MagnificationGesture()
        .onChanged { value in
            hourHeight = DS.Sizes.hourHeight * value
        }
        .onEnded { value in
            // Snap to reasonable zoom levels
            hourHeight = snapToZoomLevel(value)
        }
)
```

### 4.2 Widget Support (Tiimo Feature)

- Interactive widget showing today's tasks
- Quick-complete from widget
- Requires WidgetKit implementation

---

## Implementation Priority Matrix

| Priority | Feature | Effort | Impact | Files |
|----------|---------|--------|--------|-------|
| P0 | Touch target fix | Low | High | 3 files |
| P0 | Single entry point | Low | High | 1 file |
| P0 | Swipe consistency | Low | Medium | 2 files |
| P1 | Tap-to-create timeline | Medium | High | 2 files |
| P1 | Day view drag | Medium | High | 3 files |
| P1 | Context menu quick edit | Medium | High | 2 files |
| P2 | Gesture hints | Low | Medium | 2 new files |
| P2 | Reduce sheet depth | Medium | Medium | 1 file |
| P3 | Pinch-to-zoom | High | Medium | 1 file |
| P3 | Widgets | High | High | New target |

---

## Recommended Implementation Order

### Sprint 1: Foundation (P0)
1. Fix touch targets (1 hour)
2. Consolidate entry points (30 min)
3. Audit swipe consistency (30 min)

### Sprint 2: Core Interactions (P1)
4. Tap-to-create on timeline (2 hours)
5. Context menu quick edit (2 hours)
6. Day view drag-to-reschedule (3 hours)

### Sprint 3: Polish (P2)
7. Gesture hint overlays (2 hours)
8. Inline pickers vs sheet cascade (3 hours)

### Sprint 4: Competitive (P3)
9. Pinch-to-zoom (4 hours)
10. Widget target (8 hours)

---

## Success Metrics

After implementation, Focal should:

1. **Zero clicks to complete task** - Tap checkbox (already met with proper touch targets)
2. **One tap to add task** - Tap timeline slot or FAB
3. **One gesture to reschedule** - Drag task to new time
4. **Zero sheets for common edits** - Context menu for priority/reschedule
5. **Discoverable interactions** - First-use hints for gestures

---

## Files Summary

**Modified (10 files)**:
- `Focal/Views/Task/TaskCardView.swift`
- `Focal/Views/Todo/TodoView.swift`
- `Focal/Views/Todo/TodoDetailView.swift`
- `Focal/Views/Timeline/DailyTimelineView.swift`
- `Focal/Views/Timeline/WeeklyTimelineView.swift`
- `Focal/Views/Components/EmptyIntervalView.swift`
- `Focal/Views/Components/MiniTaskPin.swift`
- `Focal/ViewModels/TaskStore.swift`
- `Focal/ViewModels/TodoStore.swift`
- `Focal/Utilities/DesignSystem.swift`

**New (2 files)**:
- `Focal/Views/Components/GestureHintOverlay.swift`
- `Focal/Views/Components/DragHintOverlay.swift`
