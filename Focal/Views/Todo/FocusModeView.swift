import SwiftUI

struct FocusModeView: View {
    @Environment(TodoStore.self) private var todoStore
    @Environment(\.dismiss) private var dismiss

    @State private var currentTask: TodoItem?
    @State private var showConfetti = false
    @State private var completedCount = 0
    @State private var isAllDone = false

    var body: some View {
        ZStack {
            // Background gradient based on current task color
            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: DS.Spacing.xxxl) {
                // Header with close button and session stats
                headerSection

                Spacer()

                if isAllDone {
                    // All done celebration state
                    allDoneView
                } else if let task = currentTask {
                    // Current task display
                    taskDisplayView(task)
                } else {
                    // No tasks state
                    noTasksView
                }

                Spacer()

                // Action button
                if !isAllDone && currentTask != nil {
                    doneButton
                }
            }
            .padding(DS.Spacing.xl)
        }
        .confetti(isPresented: $showConfetti)
        .onAppear {
            selectNextTask()
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        Group {
            if let task = currentTask {
                LinearGradient(
                    colors: [
                        task.color.lightColor.opacity(0.3),
                        task.color.lightColor.opacity(0.1),
                        DS.Colors.background
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else if isAllDone {
                LinearGradient(
                    colors: [
                        DS.Colors.sage.opacity(0.3),
                        DS.Colors.sage.opacity(0.1),
                        DS.Colors.background
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                DS.Colors.background
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            // Session stats
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text("Focus Mode")
                    .scaledFont(size: 13, weight: .semibold, relativeTo: .caption)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.8)

                if completedCount > 0 {
                    HStack(spacing: DS.Spacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(DS.Colors.success)
                        Text("\(completedCount) completed")
                            .scaledFont(size: 14, weight: .medium, relativeTo: .subheadline)
                            .foregroundStyle(DS.Colors.textSecondary)
                    }
                }
            }

            Spacer()

            // Close button
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(DS.Colors.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(DS.Colors.surfacePrimary)
                    .clipShape(Circle())
                    .shadowResting()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close focus mode")
        }
    }

    // MARK: - Task Display

    private func taskDisplayView(_ task: TodoItem) -> some View {
        VStack(spacing: DS.Spacing.xxl) {
            // Priority badge
            priorityBadge(for: task)

            // Large emoji
            Text(task.icon)
                .font(.system(size: 96))
                .shadow(color: task.color.lightColor.opacity(0.3), radius: 20, x: 0, y: 10)

            // Task title
            Text(task.title)
                .scaledFont(size: 28, weight: .bold, relativeTo: .title)
                .foregroundStyle(DS.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .padding(.horizontal, DS.Spacing.lg)

            // Duration badge if available
            if let duration = task.estimatedDuration, duration > 0 {
                durationBadge(minutes: Int(duration))
            }

            // Category tag
            categoryTag(for: task)
        }
    }

    private func priorityBadge(for task: TodoItem) -> some View {
        HStack(spacing: DS.Spacing.xs) {
            if let icon = task.priorityEnum.icon {
                Text(icon)
                    .font(.system(size: 10, weight: .bold))
            }
            Text(task.priorityEnum.displayName.uppercased())
                .scaledFont(size: 11, weight: .bold, relativeTo: .caption2)
                .tracking(0.8)
        }
        .foregroundStyle(task.priorityEnum.badgeTextColor)
        .padding(.horizontal, DS.Spacing.md)
        .padding(.vertical, DS.Spacing.sm)
        .background(task.priorityEnum.badgeBackground)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
    }

    private func durationBadge(minutes: Int) -> some View {
        HStack(spacing: DS.Spacing.xs) {
            Image(systemName: "clock")
                .font(.system(size: 12, weight: .medium))
            Text("\(minutes) min")
                .scaledFont(size: 14, weight: .medium, relativeTo: .subheadline)
        }
        .foregroundStyle(DS.Colors.textSecondary)
        .padding(.horizontal, DS.Spacing.md)
        .padding(.vertical, DS.Spacing.sm)
        .background(DS.Colors.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
    }

    private func categoryTag(for task: TodoItem) -> some View {
        let category = task.categoryEnum
        return HStack(spacing: DS.Spacing.xs) {
            Text(category.icon)
                .scaledFont(size: 12, relativeTo: .caption)
            Text(category.label)
                .scaledFont(size: 12, weight: .medium, relativeTo: .caption)
        }
        .foregroundStyle(category.tint)
        .padding(.horizontal, DS.Spacing.sm)
        .padding(.vertical, DS.Spacing.xs)
        .background(category.tint.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
    }

    // MARK: - All Done View

    private var allDoneView: some View {
        VStack(spacing: DS.Spacing.xxl) {
            Text("🎉")
                .font(.system(size: 96))

            VStack(spacing: DS.Spacing.md) {
                Text("All done!")
                    .scaledFont(size: 32, weight: .bold, relativeTo: .largeTitle)
                    .foregroundStyle(DS.Colors.textPrimary)

                Text("You completed \(completedCount) task\(completedCount == 1 ? "" : "s") this session.")
                    .scaledFont(size: 17, relativeTo: .body)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                dismiss()
            } label: {
                Text("Back to Todo")
                    .scaledFont(size: 16, weight: .semibold, relativeTo: .body)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: DS.Sizes.buttonHeight)
                    .background(DS.Colors.sage)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            }
            .buttonStyle(.plain)
            .padding(.top, DS.Spacing.lg)
        }
        .padding(.horizontal, DS.Spacing.xl)
    }

    // MARK: - No Tasks View

    private var noTasksView: some View {
        VStack(spacing: DS.Spacing.xl) {
            Text("📋")
                .font(.system(size: 64))

            VStack(spacing: DS.Spacing.sm) {
                Text("No tasks to focus on")
                    .scaledFont(size: 20, weight: .semibold, relativeTo: .title3)
                    .foregroundStyle(DS.Colors.textPrimary)

                Text("Add some tasks to get started!")
                    .scaledFont(size: 15, relativeTo: .body)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
        }
    }

    // MARK: - Done Button

    private var doneButton: some View {
        Button {
            completeCurrentTask()
        } label: {
            HStack(spacing: DS.Spacing.md) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24, weight: .semibold))
                Text("Done!")
                    .scaledFont(size: 20, weight: .bold, relativeTo: .title3)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                LinearGradient(
                    colors: [DS.Colors.sage, DS.Colors.sage.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xl))
            .shadowColored(DS.Colors.sage)
        }
        .buttonStyle(PressableStyle())
        .accessibilityLabel("Mark task as done")
        .accessibilityHint("Completes the current task and shows the next one")
    }

    // MARK: - Task Selection

    private func selectNextTask() {
        // Get highest priority incomplete task
        if let must = todoStore.highPriorityTodos.first {
            currentTask = must
        } else if let should = todoStore.mediumPriorityTodos.first {
            currentTask = should
        } else if let could = todoStore.lowPriorityTodos.first {
            currentTask = could
        } else if let unprioritized = todoStore.unprioritizedTodos.first {
            currentTask = unprioritized
        } else {
            currentTask = nil
            if completedCount > 0 {
                isAllDone = true
            }
        }
    }

    private func completeCurrentTask() {
        guard let task = currentTask else { return }

        // Trigger confetti
        showConfetti = true

        // Complete the task
        withAnimation(DS.Animation.spring) {
            todoStore.toggleCompletion(for: task)
            completedCount += 1
        }

        // Select next task after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(DS.Animation.gentle) {
                selectNextTask()
            }
        }
    }
}

#Preview {
    FocusModeView()
        .environment(TodoStore())
}
