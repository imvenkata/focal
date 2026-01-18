import SwiftUI

// MARK: - Task Capsule View
/// A unified, configurable task capsule component that supports multiple sizes,
/// states, and contexts. Designed as a reference implementation of the design system spec.
///
/// Anatomy:
/// ```
/// ┌─────────────────────────────────────────────────────────┐
/// │ ┃  ○  │ 📝 │ Task Title Here          │ 9-10 AM │ ⋯ │
/// │ ┃     │    │ Optional subtitle        │  (1h)   │   │
/// └─────────────────────────────────────────────────────────┘
///   │  │    │              │                  │        │
///   │  │    │              │                  │        └── Overflow menu
///   │  │    │              │                  └── Time/duration badge
///   │  │    │              └── Title (+ optional subtitle)
///   │  │    └── Icon (emoji or SF Symbol)
///   │  └── Checkbox/completion indicator
///   └── Category color stripe (3pt)
/// ```

struct TaskCapsuleView: View {
    // MARK: - Properties

    let task: TaskItem
    var size: DS.CapsuleSize = .medium
    var context: DS.CapsuleContext = .list
    var showStripe: Bool = true
    var showOverflowMenu: Bool = true

    // Callbacks
    var onTap: () -> Void = {}
    var onComplete: () -> Void = {}
    var onDelete: (() -> Void)? = nil
    var onEdit: (() -> Void)? = nil

    // MARK: - State

    @State private var isPressed = false
    @State private var showConfetti = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Computed State

    private var capsuleState: DS.CapsuleState {
        if isPressed { return .pressed }
        if task.isCompleted { return .completed }
        if task.isPast && !task.isCompleted { return .overdue }
        if task.isActive { return .selected }
        return .default
    }

    // MARK: - Body

    var body: some View {
        Button {
            HapticManager.shared.buttonTapped()
            onTap()
        } label: {
            capsuleContent
        }
        .buttonStyle(CapsuleButtonStyle(state: capsuleState))
        .contextMenu {
            contextMenuContent
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                withAnimation(DS.Animation.spring) {
                    onComplete()
                }
                if !task.isCompleted {
                    HapticManager.shared.taskCompleted()
                }
            } label: {
                Label(
                    task.isCompleted ? "Undo" : "Complete",
                    systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark"
                )
            }
            .tint(task.isCompleted ? DS.Colors.textSecondary : DS.Colors.success)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if let onDelete {
                Button(role: .destructive) {
                    HapticManager.shared.deleted()
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to view details")
        .accessibilityAddTraits(task.isCompleted ? .isSelected : [])
    }

    // MARK: - Capsule Content

    @ViewBuilder
    private var capsuleContent: some View {
        HStack(spacing: 0) {
            // Category color stripe
            if showStripe {
                stripeView
            }

            HStack(spacing: DS.Spacing.md) {
                // Checkbox
                checkboxView

                // Icon
                iconView

                // Title & subtitle
                titleSection

                Spacer(minLength: DS.Spacing.sm)

                // Time badge
                timeBadge

                // Overflow menu
                if showOverflowMenu && context == .list {
                    overflowButton
                }
            }
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
        }
        .frame(minHeight: size.height)
        .background(backgroundView)
        .glassEffect(in: RoundedRectangle(cornerRadius: DS.Radius.md))
        .overlay(borderOverlay)
    }

    // MARK: - Stripe

    @ViewBuilder
    private var stripeView: some View {
        Rectangle()
            .fill(task.color.color)
            .frame(width: size.stripeWidth)
    }

    // MARK: - Checkbox

    @ViewBuilder
    private var checkboxView: some View {
        Button {
            withAnimation(DS.Animation.spring) {
                onComplete()
            }
            if !task.isCompleted {
                HapticManager.shared.taskCompleted()
            }
        } label: {
            ZStack {
                Circle()
                    .strokeBorder(
                        task.isCompleted ? Color.clear : task.color.color,
                        lineWidth: 2
                    )
                    .frame(width: size.checkboxSize, height: size.checkboxSize)

                if task.isCompleted {
                    Circle()
                        .fill(DS.Colors.success)
                        .frame(width: size.checkboxSize, height: size.checkboxSize)

                    Image(systemName: "checkmark")
                        .font(.system(size: size.checkboxSize * 0.5, weight: .bold))
                        .foregroundStyle(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(width: DS.Sizes.minTouchTarget, height: DS.Sizes.minTouchTarget)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(task.isCompleted ? "Mark incomplete" : "Mark complete")
    }

    // MARK: - Icon

    @ViewBuilder
    private var iconView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DS.Radius.sm)
                .fill(task.color.color)

            RoundedRectangle(cornerRadius: DS.Radius.sm)
                .fill(
                    LinearGradient(
                        colors: [
                            DS.Colors.textInverse.opacity(0.25),
                            Color.clear,
                            Color.black.opacity(0.15)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            RoundedRectangle(cornerRadius: DS.Radius.sm)
                .stroke(task.color.color.saturated(by: 1.2), lineWidth: 1)

            Text(task.icon)
                .font(.system(size: size.iconSize))
        }
        .frame(width: size.iconSize + 16, height: size.iconSize + 16)
        .shadowColored(task.color.color)
    }

    // MARK: - Title Section

    @ViewBuilder
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Title
            Text(task.title)
                .font(size.titleFont)
                .foregroundStyle(titleColor)
                .strikethrough(capsuleState.showStrikethrough, color: DS.Colors.textTertiary)
                .lineLimit(2)

            // Subtitle (subtasks or notes preview)
            if let subtitle = subtitleText {
                Text(subtitle)
                    .font(size.subtitleFont)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .lineLimit(1)
            }
        }
    }

    private var titleColor: Color {
        switch capsuleState {
        case .completed, .dimmed:
            return DS.Colors.textTertiary
        case .overdue:
            return DS.Colors.textPrimary
        default:
            return DS.Colors.textPrimary
        }
    }

    private var subtitleText: String? {
        if !task.subtasks.isEmpty {
            let completed = task.completedSubtasksCount
            let total = task.subtasks.count
            return "\(completed)/\(total) subtasks"
        } else if let notes = task.notes, !notes.isEmpty {
            return notes
        }
        return nil
    }

    // MARK: - Time Badge

    @ViewBuilder
    private var timeBadge: some View {
        VStack(alignment: .trailing, spacing: 2) {
            // Time range
            Text(task.timeRangeFormatted)
                .font(.system(size: size.subtitleSize, weight: .medium, design: .monospaced))
                .foregroundStyle(timeBadgeColor)

            // Duration
            if size != .small {
                Text("(\(task.durationFormatted))")
                    .font(.system(size: size.subtitleSize - 2, weight: .medium))
                    .foregroundStyle(DS.Colors.textTertiary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(DS.Colors.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xs))
            }
        }

        // Overdue warning badge
        if capsuleState == .overdue {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14))
                .foregroundStyle(DS.Colors.error)
                .transition(.scale.combined(with: .opacity))
        }
    }

    private var timeBadgeColor: Color {
        capsuleState == .overdue ? DS.Colors.error : DS.Colors.textSecondary
    }

    // MARK: - Overflow Button

    @ViewBuilder
    private var overflowButton: some View {
        Menu {
            contextMenuContent
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(DS.Colors.textTertiary)
                .frame(width: DS.Sizes.minTouchTarget, height: DS.Sizes.minTouchTarget)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Context Menu

    @ViewBuilder
    private var contextMenuContent: some View {
        Button {
            onComplete()
        } label: {
            Label(
                task.isCompleted ? "Mark Incomplete" : "Mark Complete",
                systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark.circle"
            )
        }

        if let onEdit {
            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
        }

        Divider()

        if let onDelete {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Background

    @ViewBuilder
    private var backgroundView: some View {
        switch capsuleState {
        case .selected:
            task.color.lightColor.opacity(0.5)
        case .overdue:
            DS.Colors.dangerLight
        case .disabled:
            DS.Colors.surfaceSecondary
        default:
            Color.clear
        }
    }

    // MARK: - Border Overlay

    @ViewBuilder
    private var borderOverlay: some View {
        switch capsuleState {
        case .selected:
            RoundedRectangle(cornerRadius: DS.Radius.md)
                .stroke(task.color.color, lineWidth: 1.5)
        case .overdue:
            RoundedRectangle(cornerRadius: DS.Radius.md)
                .stroke(DS.Colors.error, lineWidth: 1)
        default:
            EmptyView()
        }
    }

    // MARK: - Accessibility

    private var accessibilityLabel: String {
        var components: [String] = []
        components.append(task.title)
        components.append(task.timeRangeFormatted)

        if task.isCompleted {
            components.append("completed")
        } else if capsuleState == .overdue {
            components.append("overdue")
        } else if task.isActive {
            components.append("in progress")
        }

        return components.joined(separator: ", ")
    }
}

// MARK: - Capsule Button Style

private struct CapsuleButtonStyle: ButtonStyle {
    let state: DS.CapsuleState

    func makeBody(configuration: Configuration) -> some View {
        let currentState = configuration.isPressed ? DS.CapsuleState.pressed : state

        configuration.label
            .opacity(currentState.opacity)
            .scaleEffect(currentState.scale)
            .brightness(currentState.brightness)
            .animation(DS.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Draggable Capsule Modifier

struct DraggableCapsuleModifier: ViewModifier {
    @Binding var isDragging: Bool

    func body(content: Content) -> some View {
        let base = content
            .scaleEffect(isDragging ? 1.05 : 1.0)
            .animation(.interactiveSpring(response: 0.18, dampingFraction: 0.85), value: isDragging)

        if isDragging {
            base.shadowLifted()
        } else {
            base
        }
    }
}

extension View {
    func draggableCapsule(isDragging: Binding<Bool>) -> some View {
        modifier(DraggableCapsuleModifier(isDragging: isDragging))
    }
}

// MARK: - Dimmed Capsule Modifier

struct DimmedCapsuleModifier: ViewModifier {
    let isDimmed: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isDimmed ? DS.CapsuleState.dimmed.opacity : 1.0)
            .animation(DS.Animation.gentle, value: isDimmed)
    }
}

extension View {
    func dimmedCapsule(_ isDimmed: Bool) -> some View {
        modifier(DimmedCapsuleModifier(isDimmed: isDimmed))
    }
}

// MARK: - Add Animation Modifier

struct AddCapsuleAnimationModifier: ViewModifier {
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? 1 : 0.5)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(DS.Animation.bounce) {
                    isVisible = true
                }
                HapticManager.shared.notification(.success)
            }
    }
}

extension View {
    func addCapsuleAnimation() -> some View {
        modifier(AddCapsuleAnimationModifier())
    }
}

// MARK: - Preview

#Preview("Sizes") {
    VStack(spacing: DS.Spacing.lg) {
        let task = TaskItem(
            title: "Morning Workout",
            icon: "🏋️",
            colorName: "sage",
            startTime: Date(),
            duration: 3600
        )

        TaskCapsuleView(task: task, size: .small)
        TaskCapsuleView(task: task, size: .medium)
        TaskCapsuleView(task: task, size: .large)
    }
    .padding()
    .background(DS.Colors.bgPrimary)
}

#Preview("States") {
    ScrollView {
        VStack(spacing: DS.Spacing.lg) {
            let activeTask = TaskItem(
                title: "Active Task (In Progress)",
                icon: "🎯",
                colorName: "sky",
                startTime: Date().addingTimeInterval(-1800),
                duration: 3600
            )

            let completedTask: TaskItem = {
                let t = TaskItem(
                    title: "Completed Task",
                    icon: "✅",
                    colorName: "sage",
                    startTime: Date().addingTimeInterval(-7200),
                    duration: 3600
                )
                t.isCompleted = true
                return t
            }()

            let overdueTask = TaskItem(
                title: "Overdue Task",
                icon: "⚠️",
                colorName: "coral",
                startTime: Date().addingTimeInterval(-10800),
                duration: 3600
            )

            let normalTask = TaskItem(
                title: "Upcoming Task",
                icon: "📝",
                colorName: "lavender",
                startTime: Date().addingTimeInterval(3600),
                duration: 3600
            )

            Text("Active (Selected)").font(.caption).foregroundStyle(.secondary)
            TaskCapsuleView(task: activeTask)

            Text("Completed").font(.caption).foregroundStyle(.secondary)
            TaskCapsuleView(task: completedTask)

            Text("Overdue").font(.caption).foregroundStyle(.secondary)
            TaskCapsuleView(task: overdueTask)

            Text("Default").font(.caption).foregroundStyle(.secondary)
            TaskCapsuleView(task: normalTask)

            Text("Dimmed (Focus Mode)").font(.caption).foregroundStyle(.secondary)
            TaskCapsuleView(task: normalTask)
                .dimmedCapsule(true)
        }
        .padding()
    }
    .background(DS.Colors.bgPrimary)
}

#Preview("Without Stripe") {
    let task = TaskItem(
        title: "No Stripe Variant",
        icon: "🎨",
        colorName: "amber",
        startTime: Date(),
        duration: 1800
    )

    TaskCapsuleView(task: task, showStripe: false)
        .padding()
        .background(DS.Colors.bgPrimary)
}
