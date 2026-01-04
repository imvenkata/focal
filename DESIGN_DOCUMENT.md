# Structured Planner - Product Design Document

## Overview

**App Name:** Structured Planner  
**Platform:** iOS (Native Swift/SwiftUI)  
**Target:** iPhone (iOS 17+)  
**Inspiration:** Tiimo, Structured  
**Purpose:** Visual task management and scheduling tool for productivity-focused users

---

## Design System

### Color Palette

| Name | Hex | Usage |
|------|-----|-------|
| Coral | `#E8847C` | Morning routines, alerts, fitness |
| Sage | `#7BAE7F` | Wellness, gym, nature activities |
| Sky | `#6BA3D6` | Work, meetings, professional tasks |
| Lavender | `#9B8EC2` | Creative, study, meditation |
| Amber | `#D4A853` | Meals, breaks, chores |
| Rose | `#C97B8E` | Social, personal, shopping |
| Slate | `#64748B` | Neutral, general tasks |
| Night | `#5C6B7A` | Sleep, evening routines |

#### Light Variants (for backgrounds)
```swift
extension Color {
    static let coralLight = Color(hex: "#FDF2F1")
    static let sageLight = Color(hex: "#F2F7F2")
    static let skyLight = Color(hex: "#F0F6FB")
    static let lavenderLight = Color(hex: "#F5F3F9")
    static let amberLight = Color(hex: "#FBF7EE")
    static let roseLight = Color(hex: "#FAF1F3")
}
```

### Typography

| Style | Font | Size | Weight |
|-------|------|------|--------|
| Large Title | SF Pro Display | 28pt | Semibold |
| Title | SF Pro Display | 22pt | Semibold |
| Headline | SF Pro Text | 18pt | Semibold |
| Body | SF Pro Text | 16pt | Regular |
| Subhead | SF Pro Text | 14pt | Medium |
| Caption | SF Pro Text | 12pt | Medium |
| Time Labels | SF Mono | 10pt | Medium |

### Spacing & Sizing

| Element | Value |
|---------|-------|
| Screen padding | 20pt |
| Card padding | 16pt |
| Card radius | 16pt |
| Button radius | 12-16pt |
| Icon button size | 40pt |
| Task pill size | 56pt (default) |
| FAB size | 56pt |
| Bottom nav height | 83pt (including safe area) |

### Shadows

```swift
// Card shadow
.shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)

// Elevated shadow
.shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 8)

// Color tinted shadow
.shadow(color: taskColor.opacity(0.3), radius: 12, x: 0, y: 6)
```

---

## Screen Specifications

### 1. Weekly Timeline View

**Purpose:** Display 7-day overview with task pins on vertical columns

**Layout:**
```
┌─────────────────────────────────────┐
│  January 2026 ›          [Week/Day] │
├─────────────────────────────────────┤
│  M   T   W   T   F   S   S         │
│  29  30  31  1   2  (3)  4         │
│  ●●  ●●  ●●  ●●  ●●  ●●● ●●        │
├─────────────────────────────────────┤
│ 🔥20 ═══════════════════ 12/20     │
├─────────────────────────────────────┤
│ 06│  ☀  ☀  ☀  ☀  ☀  ☀  ☀          │
│   │  │   │   │   │   │   │          │
│ 09│  │   │   │   │   │   │          │
│   │  💼 💼 💼 💼 💼 │   │          │
│ 12│  │   │   │   │   🏋  │          │
│   │  │   │   │   │   │   │          │
│ 15│  │   │   │   │   │   │          │
│   │  │   │   🏋  │   │   │          │
│ 18│  │   │   │   🎉 │   │          │
│   │  │   │   │   │   │   │          │
│ 22│  🌙 🌙 🌙 🌙 🌙 🌙 🌙          │
└─────────────────────────────────────┘
│ 📥    📅    ✨    ⚙️         [+]  │
└─────────────────────────────────────┘
```

**Components:**
- `WeekHeader` - Month/year with navigation
- `WeekSelector` - 7-day horizontal picker with task indicators
- `ProgressBar` - Daily/weekly completion
- `TimelineGrid` - Vertical time labels + 7 columns
- `TaskPin` - Colored rounded square with icon
- `CurrentTimeIndicator` - Red dot with horizontal line
- `BottomNavigation` - 4 tabs + FAB

**Interactions:**
- Tap day → Switch to Day view
- Tap task pin → Open Task Detail
- Pinch → Toggle Week/Day view
- Scroll vertical → Navigate time range

---

### 2. Daily Timeline View

**Purpose:** Single day vertical timeline with detailed task cards

**Layout:**
```
┌─────────────────────────────────────┐
│  3 January 2026 ›        [Week/Day] │
├─────────────────────────────────────┤
│  M   T   W   T   F  (S)  S         │
│  29  30  31  1   2   3   4         │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ 🔥 20/100   │ 3 Tasks │ 1 Done │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│                                     │
│ 06:00  ┌──────┐  06:00 ↻           │
│    ┄┄┄┄│  ☀️  │  Rise and Shine  ○ │
│        └──────┘                     │
│    ┄┄┄┄                             │
│ 09:00      💤 A well-spent interval │
│    ┄┄┄┄                             │
│ 12:00  ┌──────┐  12:00-13:00 (1hr) │
│    ┄┄┄┄│  🏋️ │  Gym              ○ │
│    ┄┄┄┄│      │                     │
│ 13:00  └──────┘                     │
│    ┄┄┄┄                             │
│ ─●────────────── 17:32             │
│    ┄┄┄┄  ⏱ Use 4h 28m, task approaching │
│          [+ Add Task]               │
│    ┄┄┄┄                             │
│ 22:00  ┌──────┐  22:00 ↻           │
│    ┄┄┄┄│  🌙  │  Wind Down        ○ │
│        └──────┘                     │
└─────────────────────────────────────┘
```

**Components:**
- `DayHeader` - Date with Week/Day toggle
- `StatsBar` - Energy level, task count, completed count
- `VerticalTimeline` - Dashed line connecting tasks
- `TaskCard` - Pill + title + time + checkbox
- `EmptyInterval` - Message + Add Task CTA
- `CurrentTimeLine` - Pulsing dot + gradient line

**Task Card States:**
- Default: Full color pill
- Completed: Muted + strikethrough
- Past: Reduced opacity
- Active: Highlighted border

---

### 3. Add Task Sheet

**Purpose:** Bottom sheet for creating new tasks

**Layout:**
```
┌─────────────────────────────────────┐
│            ─────                    │
│  Cancel      New Task         Save  │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ [🏋️]  Task name              │ │
│ │  ✨    09:00 · 1h               │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ COLOR                               │
│ (●)(●)(●)(●)(●)(●)                 │
├─────────────────────────────────────┤
│ WHEN                                │
│ ┌─────────────────────────────────┐ │
│ │ 📅  Date         Today    ›    │ │
│ │ ⏰  Start Time   09:00    ›    │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ DURATION                            │
│ [15m][30m][45m](1h)[1.5h][2h]      │
├─────────────────────────────────────┤
│ REPEAT                         [○─] │
│ ┌─────────────────────────────────┐ │
│ │ (M)(T)(W)(T)(F)( )( )          │ │
│ │ [Weekdays][Weekends][Every day]│ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ REMINDER                            │
│ [None][5m][15m][30m][1h]           │
├─────────────────────────────────────┤
│ NOTES                               │
│ ┌─────────────────────────────────┐ │
│ │ Add notes...                    │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │        Create Task              │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

**Features:**
- Live preview card (updates as user types)
- Auto icon suggestion based on title
- Color auto-selection by task category
- Sheet detents: `.medium`, `.large`
- Keyboard avoidance

---

### 4. Task Detail View

**Purpose:** Full-screen task editing

**Layout:**
```
┌─────────────────────────────────────┐
│░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│ ← Task color light
│ [✕]                          [...] │
│   ┄                                 │
│   ┄ ┌────────┐  12:00-13:00 (1hr)  │
│   ┄ │   🏋️  │  Gym            [○] │
│   ┄ │        │                      │
│   ┄ └────────┘                      │
│   ┄  [🎨]                           │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ 📅  Sat, 3 Jan 2026   Today › │ │
│ │ ⏰  12:00 – 13:00      1 hr › │ │
│ │ 🔔  3 Alerts          Nudge › │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [↻ Repeat PRO][🔥 Energy]          │
├─────────────────────────────────────┤
│ SUBTASKS                            │
│ ┌─────────────────────────────────┐ │
│ │ [✓] Warm up - 10 min           │ │
│ │ [ ] Strength training          │ │
│ │ [+] Add Subtask                │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ NOTES                               │
│ ┌─────────────────────────────────┐ │
│ │ Add notes, meeting links...    │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │    🗑️  Delete Task             │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

**Features:**
- Colored header matches task color
- Inline title editing
- Color picker on pill
- Subtask management (add, check, reorder, delete)
- More menu (Duplicate, Share, Pin, Move)

---

### 5. Time Picker Sheet

**Layout:**
```
┌─────────────────────────────────────┐
│  Time                    [...] [✕] │
├─────────────────────────────────────┤
│         ░░░░░░░░░░░░░░░            │ ← Gradient fade
│              11:30                  │
│              11:45                  │
│         ┌──────────────┐            │
│         │ 12:00 – 13:00│ ← Selected │
│         └──────────────┘            │
│              13:15                  │
│              13:30                  │
│         ░░░░░░░░░░░░░░░            │
├─────────────────────────────────────┤
│  Duration                    [...] │
│ ┌─────────────────────────────────┐ │
│ │ [1][15][30][45](1h)[1.5h]      │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

---

### 6. Date Picker Sheet

**Layout:**
```
┌─────────────────────────────────────┐
│  Date              [Today]    [✕]  │
├─────────────────────────────────────┤
│  [‹]        January 2026       [›] │
├─────────────────────────────────────┤
│   S   M   T   W   T   F   S        │
│               1   2  (3)  4        │
│   5   6   7   8   9  10  11        │
│  12  13  14  15  16  17  18        │
│  19  20  21  22  23  24  25        │
│  26  27  28  29  30  31            │
└─────────────────────────────────────┘
```

---

### 7. Energy Picker Sheet

**Layout:**
```
┌─────────────────────────────────────┐
│  Energy                 🔥 2   [✕] │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ [🌿] [◎] [🔥] [🔥🔥] [🔥🔥🔥] │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ 🔥 Moderate                     │ │
│ │                                 │ │
│ │ The energy monitor helps you   │ │
│ │ get a better overview of what  │ │
│ │ you can handle in a day.       │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

**Energy Levels:**
| Level | Icon | Label | Description |
|-------|------|-------|-------------|
| 0 | 🌿 | Restful | Low effort, recovery |
| 1 | ◎ | Light | Easy, minimal focus |
| 2 | 🔥 | Moderate | Regular effort |
| 3 | 🔥🔥 | High | Demanding, full attention |
| 4 | 🔥🔥🔥 | Intense | Maximum effort |

---

### 8. Auto Icon Selection

**Purpose:** Automatically suggest icons based on task title keywords

**Keyword Mappings:**

| Category | Keywords | Icon | Color |
|----------|----------|------|-------|
| Fitness | gym, workout, exercise | 🏋️ | Sage |
| Fitness | run, running, jog | 🏃 | Sage |
| Fitness | yoga, meditation | 🧘 | Lavender |
| Work | meeting, call, phone | 👥 📞 | Sky |
| Work | email, office, work | 📧 💼 | Sky |
| Food | breakfast, lunch, dinner | 🍳 🍽️ | Amber |
| Food | coffee, cook | ☕ 👨‍🍳 | Amber |
| Study | study, read, learn | 📚 📖 🎓 | Lavender |
| Sleep | sleep, wake, morning | 😴 ☀️ 🌅 | Coral |
| Sleep | night, bedtime | 🌙 | Lavender |
| Chores | clean, laundry | 🧹 👕 | Amber |
| Shopping | shop, grocery | 🛍️ 🛒 | Rose |
| Social | friends, party | 👯 🎉 | Rose |
| Creative | write, draw, music | ✍️ 🎨 🎵 | Lavender |
| Travel | travel, flight, drive | ✈️ 🚗 | Sky |

**Algorithm:**
```swift
func findMatchingIcon(_ title: String) -> IconData? {
    let lower = title.lowercased()
    
    // 1. Exact match
    if let exact = iconMappings[lower] { return exact }
    
    // 2. Contains keyword
    for (keyword, data) in iconMappings {
        if lower.contains(keyword) { return data }
    }
    
    // 3. Word-by-word
    for word in lower.split(separator: " ") {
        if let match = iconMappings[String(word)] { return match }
    }
    
    return nil
}
```

---

## Data Models

### Task

```swift
struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var icon: String
    var color: TaskColor
    var startTime: Date
    var duration: TimeInterval // in seconds
    var isRoutine: Bool
    var repeatDays: Set<Weekday>
    var reminder: ReminderOption?
    var energyLevel: Int // 0-4
    var subtasks: [Subtask]
    var notes: String?
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date
    var updatedAt: Date
}

struct Subtask: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
}

enum TaskColor: String, Codable, CaseIterable {
    case coral, sage, sky, lavender, amber, rose, slate, night
    
    var color: Color { ... }
    var lightColor: Color { ... }
}

enum Weekday: Int, Codable, CaseIterable {
    case sunday = 0, monday, tuesday, wednesday, thursday, friday, saturday
}

enum ReminderOption: String, Codable {
    case none, fiveMin, fifteenMin, thirtyMin, oneHour
}
```

### User Preferences

```swift
struct UserPreferences: Codable {
    var defaultTaskDuration: TimeInterval
    var defaultReminderOption: ReminderOption
    var weekStartsOn: Weekday
    var showCompletedTasks: Bool
    var hapticFeedbackEnabled: Bool
    var preferredColorScheme: ColorScheme?
}
```

---

## Navigation Flow

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  ┌─────────┐      ┌─────────┐      ┌─────────────────┐ │
│  │  Week   │ ←──► │   Day   │ ───► │  Task Detail    │ │
│  │  View   │      │  View   │      │  (Full Screen)  │ │
│  └────┬────┘      └────┬────┘      └────────┬────────┘ │
│       │                │                     │          │
│       │                │                     ▼          │
│       │                │           ┌─────────────────┐ │
│       │                │           │  Time Picker    │ │
│       │                │           │  Date Picker    │ │
│       │                │           │  Energy Picker  │ │
│       │                │           └─────────────────┘ │
│       │                │                               │
│       ▼                ▼                               │
│  ┌─────────────────────────┐                          │
│  │     Add Task Sheet      │                          │
│  │   (Bottom Sheet)        │                          │
│  └─────────────────────────┘                          │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Gestures & Interactions

| Gesture | Location | Action |
|---------|----------|--------|
| Tap | Day circle | Select day + switch to Day view |
| Tap | Task pin/card | Open Task Detail |
| Tap | FAB | Open Add Task sheet |
| Tap | Checkbox | Toggle completion |
| Long press | Task | Drag to reschedule |
| Swipe left | Task card | Quick actions (delete, skip) |
| Swipe down | Day view panel | Collapse to Week view |
| Pinch out | Timeline | Switch to Week view |
| Pinch in | Timeline | Switch to Day view |
| Pull down | Any list | Refresh |

---

## Animations

```swift
// View transitions
.animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewMode)

// Task completion
.animation(.spring(response: 0.3, dampingFraction: 0.6), value: isCompleted)

// Sheet presentation
.animation(.spring(response: 0.35, dampingFraction: 0.85))

// Icon auto-suggest
.animation(.spring(response: 0.25, dampingFraction: 0.7), value: currentIcon)

// Current time indicator pulse
.animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true))
```

---

## Haptic Feedback

| Action | Feedback Type |
|--------|---------------|
| Task completion | `.success` |
| Color selection | `.light` |
| Icon selection | `.light` |
| Time snap | `.selection` |
| Delete | `.warning` |
| Error | `.error` |
| FAB tap | `.medium` |

---

## Accessibility

- VoiceOver labels for all interactive elements
- Dynamic Type support
- Minimum touch targets of 44pt
- Color not sole indicator (icons + labels)
- Reduced motion support
- High contrast mode support

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Jan 2026 | Initial design specification |

