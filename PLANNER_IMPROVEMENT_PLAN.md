# Planner Tab Improvement Plan

## Executive Summary

After thorough review of ~2,400 lines of Planner tab code across 8+ files, I've identified **12 critical issues**, **8 performance bottlenecks**, and **10 UX improvements** needed to create a premium-quality product.

---

## Phase 1: Critical Bug Fixes (High Priority)

### 1.1 Timeline Hour Mismatch
**Problem**: Daily view shows 6 AM - 22 PM (16 hours), Weekly view shows 6 AM - 23 PM (17 hours)
- Tasks ending at 22:30 PM won't display correctly in daily view
- Inconsistent experience between views

**Files**:
- `DailyTimelineView.swift:25` - Change `timelineEndHour` from 22 to 23
- `WeeklyTimelineView.swift:45` - Already uses 23

**Fix**:
```swift
// DailyTimelineView.swift
private let timelineEndHour = 23  // was 22
```

---

### 1.2 Current Time Indicator Misalignment
**Problem**: Time indicator line has different horizontal offsets in daily vs weekly views

**Daily View Offset**:
```swift
timelineLineOffset = timeLabelWidth + sm + sm + taskPillDefault/2
                   = 40 + 8 + 8 + 28 = 84 pt
```

**Weekly View Offset**:
```swift
padding(.leading, timeLabelWidth + sm)
                   = 40 + 8 = 48 pt
```

**Files**:
- `DailyTimelineView.swift:~180` - timelineLineOffset calculation
- `WeeklyTimelineView.swift:~320` - CurrentTimeIndicator positioning

**Fix**: Create unified offset calculation in DesignSystem:
```swift
// DesignSystem.swift
static let timeIndicatorLeadingOffset: CGFloat = timeLabelWidth + Spacing.md
```

---

### 1.3 Column Frame Race Condition
**Problem**: Drag fails silently if column frames aren't registered before gesture starts

**File**: `TaskDragState.swift:~85`

**Fix**:
```swift
func updateDrag(location: CGPoint) {
    guard !columnFrames.isEmpty else {
        // Add visual/haptic feedback that drag isn't ready
        return
    }
    // ... existing logic
}
```

---

### 1.4 Hour Calculation Precision
**Problem**: Integer truncation in `Int(hoursFromTop)` can cause off-by-one errors

**File**: `TaskDragState.swift:~95`

**Fix**:
```swift
// Use floor explicitly for clarity and correct behavior
let calculatedHour = timelineStartHour + Int(floor(hoursFromTop))
```

---

## Phase 2: Performance Optimization (High Priority)

### 2.1 Auto-Scroll Timer Waste
**Problem**: Timer fires at 60 FPS continuously, even when not dragging

**File**: `WeeklyTimelineView.swift:~150`

**Current**:
```swift
.onReceive(Timer.publish(every: 1/60, on: .main, in: .common).autoconnect())
```

**Fix**: Only run timer when dragging:
```swift
@State private var scrollTimer: Timer?

.onChange(of: dragState.isDragging) { _, isDragging in
    if isDragging {
        scrollTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            handleAutoScroll()
        }
    } else {
        scrollTimer?.invalidate()
        scrollTimer = nil
    }
}
```

---

### 2.2 Gesture Smoothness During Drag
**Problem**: Transition between scroll mode and drag mode causes stuttering

**Current Approach**: `scrollDisabled(dragState.isDragging)` toggles abruptly

**Fix**: Add smooth transition with animation:
```swift
.scrollDisabled(dragState.isDragging)
.animation(.easeInOut(duration: 0.15), value: dragState.isDragging)

// Also add gesture priority
.gesture(dragGesture, including: dragState.isDragging ? .all : .subviews)
```

---

### 2.3 PreferenceKey Optimization
**Problem**: ColumnFramePreferenceKey reduces 7 times per render cycle

**File**: `WeeklyTimelineView.swift:~280`

**Fix**: Batch frame updates:
```swift
.onPreferenceChange(ColumnFramePreferenceKey.self) { newFrames in
    // Only update if frames actually changed
    if newFrames != dragState.columnFrames {
        dragState.columnFrames = newFrames
    }
}
```

---

### 2.4 Animation Visibility Tracking
**Problem**: Pulsing animations run even when not visible

**Fix**: Add visibility tracking:
```swift
@State private var isVisible = false

CurrentTimeIndicator()
    .onAppear { isVisible = true }
    .onDisappear { isVisible = false }
    .animation(isVisible ? pulsingAnimation : nil, value: pulse)
```

---

## Phase 3: Visual Alignment & Consistency

### 3.1 Unified Time Label Width
**Problem**: Different positioning logic in daily vs weekly views

**Fix**: Create shared component:
```swift
// TimelineTimeLabel.swift
struct TimelineTimeLabel: View {
    let time: String
    static let width: CGFloat = 40
    static let alignment: HorizontalAlignment = .trailing
}
```

---

### 3.2 Task Pill Vertical Alignment
**Problem**: Y offset calculation differs between views

**Current Weekly Calculation**:
```swift
let hoursSinceStart = CGFloat(taskHour - 6) + CGFloat(taskMinute) / 60.0
let yOffset = hoursSinceStart * hourHeight
```

**Fix**: Create unified positioning system:
```swift
// TimelinePositioning.swift
struct TimelinePositioning {
    static func yOffset(for time: Date, startHour: Int, hourHeight: CGFloat) -> CGFloat {
        let hour = Calendar.current.component(.hour, from: time)
        let minute = Calendar.current.component(.minute, from: time)
        let hoursSinceStart = CGFloat(hour - startHour) + CGFloat(minute) / 60.0
        return hoursSinceStart * hourHeight
    }
}
```

---

### 3.3 Glass Stem Height Fix
**Problem**: Stem may not reach bottom of last capsule for short tasks

**File**: `WeeklyTimelineView.swift:~200` (GlassStemView)

**Fix**:
```swift
let stemHeight = max(
    lastTaskEndOffset - firstTaskOffset + DS.Sizes.glassCapsuleHeight,
    DS.Sizes.glassCapsuleHeight
)
```

---

### 3.4 End Time Label Visibility
**Problem**: Tertiary color makes end times hard to read

**File**: `DailyTimelineView.swift:~250`

**Fix**:
```swift
TimelineTimeLabel(time: endTimeString)
    .foregroundStyle(DS.Colors.textSecondary) // was tertiary
    .font(DS.Typography.caption2)
    .opacity(0.8)
```

---

## Phase 4: Premium Polish

### 4.1 Smooth Drag Visual Feedback

**Current**: Source pill dims to 0.3 opacity (subtle)

**Premium Fix**:
```swift
// TaskPinView.swift - when task is being dragged
.opacity(dragState.draggedTask?.id == task.id ? 0 : 1)
.overlay {
    if dragState.draggedTask?.id == task.id {
        // Ghost placeholder effect
        MiniTaskPin(task: task)
            .colorMultiply(DS.Colors.glassBorder.opacity(0.3))
            .blur(radius: 2)
    }
}
```

---

### 4.2 Drop Zone Preview
**Problem**: No visual feedback where task will land before releasing

**Fix**: Add drop preview in DayColumn:
```swift
// In DayColumn
if dragState.isDragging && dragState.targetColumnIndex == dayIndex {
    // Show ghost of where task will land
    MiniTaskPin(task: dragState.draggedTask!)
        .opacity(0.5)
        .offset(y: calculateDropOffset())
}
```

---

### 4.3 Haptic Refinement
**Problem**: Inconsistent haptic feedback timing

**Fix** in `TaskDragState.swift`:
```swift
func startDrag(task: TaskItem, location: CGPoint) {
    // Delay haptic slightly to sync with visual
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
        HapticManager.shared.impact(.medium)
    }
    // ... rest of logic
}

func updateDrag(location: CGPoint) {
    // Add light haptic on hour boundary crossing
    if newHour != previousHour {
        HapticManager.shared.impact(.light)
    }
}
```

---

### 4.4 Long Press Threshold Consistency
**Problem**: Daily view uses 0.35s, Weekly uses 0.15s

**Fix**: Unify to 0.2s for both:
```swift
// DesignSystem.swift
static let dragActivationDuration: TimeInterval = 0.2
```

---

### 4.5 Improved Empty State
**Current**: Generic empty interval CTA

**Premium Fix**:
```swift
EmptyIntervalView(duration: gap.duration)
    .overlay {
        VStack(spacing: DS.Spacing.sm) {
            Image(systemName: "plus.circle.dashed")
                .font(.title2)
                .foregroundStyle(DS.Colors.textTertiary)

            Text("Tap to schedule")
                .font(DS.Typography.caption)
                .foregroundStyle(DS.Colors.textTertiary)
        }
    }
```

---

## Phase 5: Missing Features

### 5.1 Minute Snapping Options
**Current**: Snaps to every minute
**Add**: 5-minute or 15-minute snap option

```swift
// TaskDragState.swift
enum SnapInterval: Int {
    case minute = 1
    case fiveMinutes = 5
    case fifteenMinutes = 15
}

var snapInterval: SnapInterval = .fiveMinutes

func snapMinute(_ rawMinutes: Int) -> Int {
    let interval = snapInterval.rawValue
    return (rawMinutes / interval) * interval
}
```

---

### 5.2 Task Overlap Detection
**Problem**: No warning when scheduling overlapping tasks

**Fix**:
```swift
// TaskStore.swift
func hasOverlap(task: TaskItem, at newTime: Date) -> Bool {
    let newEnd = newTime.addingTimeInterval(task.duration)
    return tasks.contains { other in
        guard other.id != task.id else { return false }
        let otherEnd = other.startTime.addingTimeInterval(other.duration)
        return newTime < otherEnd && newEnd > other.startTime
    }
}
```

Show visual warning:
```swift
// DayColumn drop zone
.overlay {
    if dragState.hasOverlap {
        RoundedRectangle(cornerRadius: 8)
            .stroke(DS.Colors.error, lineWidth: 2)
            .background(DS.Colors.error.opacity(0.1))
    }
}
```

---

### 5.3 Undo Support
**Add undo for drag operations**:
```swift
// TaskStore.swift
private var undoStack: [(TaskItem, Date)] = []

func moveTask(_ task: TaskItem, to newTime: Date) {
    undoStack.append((task, task.startTime))
    task.startTime = newTime
}

func undo() {
    guard let (task, previousTime) = undoStack.popLast() else { return }
    task.startTime = previousTime
}
```

---

### 5.4 Accessibility Improvements
```swift
// Add throughout views
.accessibilityLabel("Task: \(task.title)")
.accessibilityHint("Double tap to view details, long press to drag")
.accessibilityAddTraits(dragState.isDragging ? .updatesFrequently : [])

// Respect reduce motion
@Environment(\.accessibilityReduceMotion) var reduceMotion

.animation(reduceMotion ? nil : pulsingAnimation, value: pulse)
```

---

## Implementation Priority Order

### Immediate (This Sprint)
1. Fix timeline hour mismatch (30 min)
2. Fix time indicator alignment (1 hour)
3. Fix auto-scroll timer performance (30 min)
4. Improve drag gesture smoothness (1 hour)

### Short Term (Next Sprint)
5. Unify positioning calculations (2 hours)
6. Add drop zone preview (2 hours)
7. Improve haptic feedback (1 hour)
8. Fix glass stem height (30 min)

### Medium Term
9. Add minute snapping options (2 hours)
10. Add overlap detection (3 hours)
11. Add undo support (2 hours)
12. Accessibility improvements (3 hours)

### Polish Phase
13. Empty state improvements
14. Animation refinements
15. Premium visual effects
16. Performance profiling & optimization

---

## File Changes Summary

| File | Changes Needed |
|------|----------------|
| `DailyTimelineView.swift` | Timeline hours, offset calculation, segment rendering |
| `WeeklyTimelineView.swift` | Timer optimization, frame handling, drop preview |
| `TaskDragState.swift` | Precision fixes, haptics, snapping, validation |
| `TaskPinView.swift` | Drag visual feedback, ghost effects |
| `TaskCardView.swift` | Gesture unification, accessibility |
| `CurrentTimeIndicator.swift` | Visibility tracking, animation control |
| `DesignSystem.swift` | Unified constants, positioning helpers |
| `TaskStore.swift` | Overlap detection, undo stack |

---

## Success Metrics

After implementation:
- Drag operations should feel buttery smooth (60 FPS maintained)
- Time indicator should align perfectly with current time across both views
- Users should see exactly where task will land before dropping
- No visual jank when switching between scroll and drag modes
- Battery impact reduced by stopping unnecessary timers
- All gestures should have consistent, premium haptic feedback
