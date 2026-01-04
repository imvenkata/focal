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

```
StructuredPlanner/
├── App/
│   ├── StructuredPlannerApp.swift
│   └── ContentView.swift
├── Models/
│   ├── Task.swift
│   ├── Subtask.swift
│   ├── TaskColor.swift
│   └── UserPreferences.swift
├── ViewModels/
│   ├── TaskStore.swift
│   ├── WeekViewModel.swift
│   └── DayViewModel.swift
├── Views/
│   ├── Timeline/
│   │   ├── WeeklyTimelineView.swift
│   │   ├── DailyTimelineView.swift
│   │   ├── TimelineToggle.swift
│   │   └── CurrentTimeIndicator.swift
│   ├── Task/
│   │   ├── TaskPinView.swift
│   │   ├── TaskCardView.swift
│   │   ├── TaskDetailView.swift
│   │   └── AddTaskSheet.swift
│   ├── Pickers/
│   │   ├── TimePickerSheet.swift
│   │   ├── DatePickerSheet.swift
│   │   ├── EnergyPickerSheet.swift
│   │   ├── IconPickerView.swift
│   │   └── ColorPickerView.swift
│   ├── Components/
│   │   ├── WeekSelector.swift
│   │   ├── StatsBar.swift
│   │   ├── SubtaskRow.swift
│   │   └── EmptyIntervalView.swift
│   └── Navigation/
│       ├── BottomTabBar.swift
│       └── FABButton.swift
├── Utilities/
│   ├── IconMapper.swift
│   ├── DateFormatter+Extensions.swift
│   ├── Color+Extensions.swift
│   └── HapticManager.swift
├── Resources/
│   ├── Assets.xcassets
│   └── Localizable.strings
└── Preview Content/
    └── PreviewData.swift
```

---

## Design System Constants

Create a `DesignSystem.swift` file:

```swift
import SwiftUI

enum DS {
    // MARK: - Colors
    enum Colors {
        static let coral = Color(hex: "#E8847C")
        static let coralLight = Color(hex: "#FDF2F1")
        static let sage = Color(hex: "#7BAE7F")
        static let sageLight = Color(hex: "#F2F7F2")
        static let sky = Color(hex: "#6BA3D6")
        static let skyLight = Color(hex: "#F0F6FB")
        static let lavender = Color(hex: "#9B8EC2")
        static let lavenderLight = Color(hex: "#F5F3F9")
        static let amber = Color(hex: "#D4A853")
        static let amberLight = Color(hex: "#FBF7EE")
        static let rose = Color(hex: "#C97B8E")
        static let roseLight = Color(hex: "#FAF1F3")
        static let slate = Color(hex: "#64748B")
        static let night = Color(hex: "#5C6B7A")
        
        static let background = Color(hex: "#F8F7F4")
        static let cardBackground = Color.white
    }
    
    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }
    
    // MARK: - Radius
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let pill: CGFloat = 100
    }
    
    // MARK: - Sizes
    enum Sizes {
        static let iconButtonSize: CGFloat = 40
        static let taskPillDefault: CGFloat = 56
        static let taskPillLarge: CGFloat = 80
        static let fabSize: CGFloat = 56
        static let bottomNavHeight: CGFloat = 83
        static let sheetHandle: CGFloat = 36
    }
    
    // MARK: - Animation
    enum Animation {
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let quick = SwiftUI.Animation.spring(response: 0.25, dampingFraction: 0.7)
        static let gentle = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.85)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

---

## Core Models

### Task.swift

```swift
import Foundation
import SwiftData

@Model
final class Task {
    var id: UUID
    var title: String
    var icon: String
    var colorName: String
    var startTime: Date
    var duration: TimeInterval
    var isRoutine: Bool
    var repeatDays: [Int] // 0-6 for Sunday-Saturday
    var reminderOption: String?
    var energyLevel: Int
    var subtasks: [Subtask]
    var notes: String?
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        title: String,
        icon: String = "📝",
        colorName: String = "sage",
        startTime: Date = Date(),
        duration: TimeInterval = 3600,
        isRoutine: Bool = false,
        repeatDays: [Int] = [],
        reminderOption: String? = nil,
        energyLevel: Int = 2,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.icon = icon
        self.colorName = colorName
        self.startTime = startTime
        self.duration = duration
        self.isRoutine = isRoutine
        self.repeatDays = repeatDays
        self.reminderOption = reminderOption
        self.energyLevel = energyLevel
        self.subtasks = []
        self.notes = notes
        self.isCompleted = false
        self.completedAt = nil
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var color: TaskColor {
        TaskColor(rawValue: colorName) ?? .sage
    }
    
    var endTime: Date {
        startTime.addingTimeInterval(duration)
    }
    
    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
}
```

### TaskColor.swift

```swift
import SwiftUI

enum TaskColor: String, CaseIterable, Codable {
    case coral, sage, sky, lavender, amber, rose, slate, night
    
    var color: Color {
        switch self {
        case .coral: return DS.Colors.coral
        case .sage: return DS.Colors.sage
        case .sky: return DS.Colors.sky
        case .lavender: return DS.Colors.lavender
        case .amber: return DS.Colors.amber
        case .rose: return DS.Colors.rose
        case .slate: return DS.Colors.slate
        case .night: return DS.Colors.night
        }
    }
    
    var lightColor: Color {
        switch self {
        case .coral: return DS.Colors.coralLight
        case .sage: return DS.Colors.sageLight
        case .sky: return DS.Colors.skyLight
        case .lavender: return DS.Colors.lavenderLight
        case .amber: return DS.Colors.amberLight
        case .rose: return DS.Colors.roseLight
        case .slate: return Color(hex: "#F4F5F7")
        case .night: return Color(hex: "#F3F4F5")
        }
    }
}
```

---

## Key View Implementations

### IconMapper.swift (Auto Icon Selection)

```swift
import Foundation

struct IconMapping {
    let icon: String
    let label: String
    let suggestedColor: TaskColor
}

class IconMapper {
    static let shared = IconMapper()
    
    private let mappings: [String: IconMapping] = [
        // Fitness
        "gym": IconMapping(icon: "🏋️", label: "Gym", suggestedColor: .sage),
        "workout": IconMapping(icon: "🏋️", label: "Workout", suggestedColor: .sage),
        "exercise": IconMapping(icon: "🏃", label: "Exercise", suggestedColor: .sage),
        "run": IconMapping(icon: "🏃", label: "Run", suggestedColor: .sage),
        "running": IconMapping(icon: "🏃", label: "Running", suggestedColor: .sage),
        "yoga": IconMapping(icon: "🧘", label: "Yoga", suggestedColor: .lavender),
        "meditation": IconMapping(icon: "🧘", label: "Meditation", suggestedColor: .lavender),
        "swim": IconMapping(icon: "🏊", label: "Swim", suggestedColor: .sky),
        
        // Work
        "meeting": IconMapping(icon: "👥", label: "Meeting", suggestedColor: .sky),
        "call": IconMapping(icon: "📞", label: "Call", suggestedColor: .sky),
        "phone": IconMapping(icon: "📞", label: "Phone", suggestedColor: .sky),
        "work": IconMapping(icon: "💼", label: "Work", suggestedColor: .sky),
        "email": IconMapping(icon: "📧", label: "Email", suggestedColor: .sky),
        "office": IconMapping(icon: "🏢", label: "Office", suggestedColor: .sky),
        
        // Food
        "breakfast": IconMapping(icon: "🍳", label: "Breakfast", suggestedColor: .amber),
        "lunch": IconMapping(icon: "🍽️", label: "Lunch", suggestedColor: .amber),
        "dinner": IconMapping(icon: "🍽️", label: "Dinner", suggestedColor: .amber),
        "coffee": IconMapping(icon: "☕", label: "Coffee", suggestedColor: .amber),
        "cook": IconMapping(icon: "👨‍🍳", label: "Cook", suggestedColor: .amber),
        
        // Study
        "study": IconMapping(icon: "📚", label: "Study", suggestedColor: .lavender),
        "read": IconMapping(icon: "📖", label: "Read", suggestedColor: .lavender),
        "learn": IconMapping(icon: "🎓", label: "Learn", suggestedColor: .lavender),
        
        // Sleep
        "sleep": IconMapping(icon: "😴", label: "Sleep", suggestedColor: .lavender),
        "wake": IconMapping(icon: "☀️", label: "Wake", suggestedColor: .coral),
        "morning": IconMapping(icon: "🌅", label: "Morning", suggestedColor: .coral),
        "night": IconMapping(icon: "🌙", label: "Night", suggestedColor: .lavender),
        
        // Chores
        "clean": IconMapping(icon: "🧹", label: "Clean", suggestedColor: .amber),
        "laundry": IconMapping(icon: "👕", label: "Laundry", suggestedColor: .amber),
        "shopping": IconMapping(icon: "🛍️", label: "Shopping", suggestedColor: .rose),
        "grocery": IconMapping(icon: "🛒", label: "Grocery", suggestedColor: .amber),
        
        // Social
        "friends": IconMapping(icon: "👯", label: "Friends", suggestedColor: .rose),
        "party": IconMapping(icon: "🎉", label: "Party", suggestedColor: .rose),
        
        // Creative
        "write": IconMapping(icon: "✍️", label: "Write", suggestedColor: .lavender),
        "music": IconMapping(icon: "🎵", label: "Music", suggestedColor: .lavender),
        "code": IconMapping(icon: "💻", label: "Code", suggestedColor: .sky),
        
        // Travel
        "travel": IconMapping(icon: "✈️", label: "Travel", suggestedColor: .sky),
        "drive": IconMapping(icon: "🚗", label: "Drive", suggestedColor: .sky),
    ]
    
    func findMatch(for title: String) -> IconMapping? {
        let lower = title.lowercased().trimmingCharacters(in: .whitespaces)
        
        // 1. Exact match
        if let exact = mappings[lower] {
            return exact
        }
        
        // 2. Contains keyword
        for (keyword, mapping) in mappings {
            if lower.contains(keyword) {
                return mapping
            }
        }
        
        // 3. Word-by-word
        let words = lower.split(separator: " ").map(String.init)
        for word in words {
            if let match = mappings[word] {
                return match
            }
        }
        
        return nil
    }
}
```

### HapticManager.swift

```swift
import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
```

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

**Task Pill:**
```swift
struct TaskPillView: View {
    let task: Task
    let size: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: DS.Radius.lg)
            .fill(task.color.color)
            .frame(width: size, height: size)
            .overlay {
                Text(task.icon)
                    .font(.system(size: size * 0.5))
            }
            .shadow(color: task.color.color.opacity(0.3), radius: 8, y: 4)
    }
}
```

**Sheet Presentation:**
```swift
.sheet(isPresented: $showSheet) {
    SheetContent()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(DS.Radius.xxl)
}
```

**Bottom Navigation:**
```swift
struct BottomTabBar: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                TabButton(tab: tab, isSelected: selectedTab == tab) {
                    HapticManager.shared.selection()
                    selectedTab = tab
                }
            }
        }
        .padding(.horizontal, DS.Spacing.xl)
        .padding(.top, DS.Spacing.md)
        .padding(.bottom, 34) // Safe area
        .background(.ultraThinMaterial)
    }
}
```

---

## State Management

### TaskStore (Observable)

```swift
import SwiftUI
import SwiftData

@Observable
class TaskStore {
    var tasks: [Task] = []
    var selectedDate: Date = Date()
    var viewMode: ViewMode = .week
    
    enum ViewMode {
        case week, day
    }
    
    var tasksForSelectedDate: [Task] {
        tasks.filter { Calendar.current.isDate($0.startTime, inSameDayAs: selectedDate) }
            .sorted { $0.startTime < $1.startTime }
    }
    
    var tasksForWeek: [[Task]] {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart)!
            return tasks.filter { calendar.isDate($0.startTime, inSameDayAs: date) }
                .sorted { $0.startTime < $1.startTime }
        }
    }
    
    func toggleCompletion(for task: Task) {
        task.isCompleted.toggle()
        task.completedAt = task.isCompleted ? Date() : nil
        task.updatedAt = Date()
        HapticManager.shared.notification(task.isCompleted ? .success : .warning)
    }
    
    func deleteTask(_ task: Task) {
        HapticManager.shared.notification(.warning)
        tasks.removeAll { $0.id == task.id }
    }
}
```

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
