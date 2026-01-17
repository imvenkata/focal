import SwiftUI
import SwiftData

/// Calm Mode view for the Todo tab.
/// Shows one hero task at a time with gentle messaging and progressive disclosure.
/// Designed to reduce cognitive load for neurodivergent users.
struct CalmTodoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(TodoStore.self) private var todoStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var userEnergy: UserEnergy = .medium
    @State private var showAllTasks = false
    @State private var showFilters = false
    @State private var skippedTaskIds: Set<UUID> = []
    @State private var selectedTodo: TodoItem?
    @State private var showAddSheet = false

    // Number of "up next" tasks to show before expansion
    private let upNextLimit = 5

    var body: some View {
        ScrollView {
            VStack(spacing: DS.Spacing.xl) {
                // 1. Gentle greeting
                greetingSection

                // 2. Energy selector
                EnergySelector(selection: $userEnergy)

                // 3. Hero task card or empty state
                if let heroTask = nextTask(for: userEnergy) {
                    HeroTaskCard(
                        task: heroTask,
                        onComplete: { completeTask(heroTask) },
                        onLater: { skipTask(heroTask) },
                        onTap: { selectedTodo = heroTask }
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                        removal: .opacity.combined(with: .move(edge: .leading))
                    ))
                } else {
                    emptyHeroState
                }

                // 4. Divider
                if !upNextTasks.isEmpty {
                    dividerSection
                }

                // 5. "Up next" simple list
                if !upNextTasks.isEmpty {
                    upNextSection
                }

                // 6. Show all button (progressive disclosure)
                if !showAllTasks && remainingTaskCount > 0 {
                    showAllButton
                }

                // 7. Encouragement footer
                encouragementSection

                // 8. Add task button
                addTaskButton
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.top, DS.Spacing.xl)
            .padding(.bottom, 120)
        }
        .background(DS.Colors.background)
        .animation(reduceMotion ? DS.Animation.reduced : DS.Animation.gentle, value: userEnergy)
        .animation(reduceMotion ? DS.Animation.reduced : DS.Animation.gentle, value: showAllTasks)
        .sheet(item: $selectedTodo) { todo in
            TodoDetailView(todo: todo)
        }
        .sheet(isPresented: $showAddSheet) {
            TodoQuickAddSheet()
        }
    }

    // MARK: - Greeting Section

    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Text(CalmMessages.greeting(for: Calendar.current.component(.hour, from: Date())))
                .scaledFont(size: 28, weight: .bold, relativeTo: .largeTitle)
                .foregroundStyle(DS.Colors.textPrimary)

            if let firstName = userName {
                Text(firstName)
                    .scaledFont(size: 28, weight: .bold, relativeTo: .largeTitle)
                    .foregroundStyle(DS.Colors.primary.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var userName: String? {
        // Could be pulled from user settings in the future
        nil
    }

    // MARK: - Empty Hero State

    private var emptyHeroState: some View {
        VStack(spacing: DS.Spacing.lg) {
            Text("🎉")
                .font(.system(size: 56))

            VStack(spacing: DS.Spacing.sm) {
                Text("All caught up!")
                    .scaledFont(size: 20, weight: .semibold, relativeTo: .title3)
                    .foregroundStyle(DS.Colors.textPrimary)

                Text("You've handled everything.\nTake a break or add something new.")
                    .scaledFont(size: 15, relativeTo: .body)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Spacing.xxxl)
        .padding(.horizontal, DS.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.xxxl, style: .continuous)
                .fill(DS.Colors.success.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.xxxl, style: .continuous)
                .stroke(DS.Colors.success.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Divider Section

    private var dividerSection: some View {
        HStack(spacing: DS.Spacing.md) {
            Rectangle()
                .fill(DS.Colors.divider)
                .frame(height: 1)

            Text("Up next")
                .scaledFont(size: 13, weight: .medium, relativeTo: .caption)
                .foregroundStyle(DS.Colors.textTertiary)

            Rectangle()
                .fill(DS.Colors.divider)
                .frame(height: 1)
        }
    }

    // MARK: - Up Next Section

    private var upNextSection: some View {
        VStack(spacing: DS.Spacing.sm) {
            ForEach(upNextTasks) { task in
                SimpleTaskRow(
                    task: task,
                    onTap: { selectedTodo = task },
                    onComplete: { completeTask(task) }
                )
            }
        }
    }

    private var upNextTasks: [TodoItem] {
        let tasks = filteredTasks(for: userEnergy)
            .filter { !skippedTaskIds.contains($0.id) }
            .dropFirst() // Exclude the hero task

        if showAllTasks {
            return Array(tasks)
        } else {
            return Array(tasks.prefix(upNextLimit))
        }
    }

    private var remainingTaskCount: Int {
        let total = filteredTasks(for: userEnergy)
            .filter { !skippedTaskIds.contains($0.id) }
            .count
        // Subtract hero (1) and shown up next tasks
        let shown = 1 + min(upNextLimit, max(0, total - 1))
        return max(0, total - shown)
    }

    // MARK: - Show All Button

    private var showAllButton: some View {
        Button {
            withAnimation(reduceMotion ? DS.Animation.reduced : DS.Animation.spring) {
                showAllTasks = true
            }
            HapticManager.shared.selection()
        } label: {
            HStack(spacing: DS.Spacing.sm) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 14, weight: .medium))
                Text("Show all \(remainingTaskCount + upNextLimit + 1) tasks")
                    .scaledFont(size: 14, weight: .medium, relativeTo: .callout)
            }
            .foregroundStyle(DS.Colors.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                    .fill(DS.Colors.primary.opacity(0.08))
            )
        }
        .buttonStyle(PressableStyle())
        .accessibilityLabel("Show all tasks")
        .accessibilityHint("Expands the list to show all remaining tasks")
    }

    // MARK: - Encouragement Section

    private var encouragementSection: some View {
        Text(CalmMessages.completed(todoStore.todayCompletedCount))
            .scaledFont(size: 15, weight: .medium, relativeTo: .subheadline)
            .foregroundStyle(DS.Colors.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Spacing.lg)
            .accessibilityLabel("Progress: \(CalmMessages.completed(todoStore.todayCompletedCount))")
    }

    // MARK: - Add Task Button

    private var addTaskButton: some View {
        Button {
            showAddSheet = true
            HapticManager.shared.selection()
        } label: {
            HStack(spacing: DS.Spacing.md) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22, weight: .medium))
                Text("Add task")
                    .scaledFont(size: 16, weight: .semibold, relativeTo: .body)
            }
            .foregroundStyle(DS.Colors.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                    .fill(DS.Colors.surfacePrimary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                    .foregroundStyle(DS.Colors.primary.opacity(0.3))
            )
            .shadowResting()
        }
        .buttonStyle(PressableStyle())
        .accessibilityLabel("Add new task")
    }

    // MARK: - Task Selection Logic

    /// Returns the next task based on the user's current energy level.
    private func nextTask(for energy: UserEnergy) -> TodoItem? {
        filteredTasks(for: energy)
            .filter { !skippedTaskIds.contains($0.id) }
            .first
    }

    /// Filters and sorts tasks based on user energy.
    private func filteredTasks(for energy: UserEnergy) -> [TodoItem] {
        let candidates = todoStore.activeTodos

        // Filter by energy match
        let matched: [TodoItem]
        switch energy {
        case .low:
            // Show only low-effort tasks (short duration or low priority)
            matched = candidates.filter { task in
                let isShortTask = (task.estimatedDuration ?? 0) <= 15 * 60 // 15 minutes or less
                let isLowEnergy = task.energyLevel <= 1
                let isLowPriority = task.priorityEnum == .low || task.priorityEnum == .none
                return isShortTask || isLowEnergy || isLowPriority
            }
        case .medium:
            // Show low and medium effort tasks
            matched = candidates.filter { task in
                task.energyLevel <= 2 || task.priorityEnum != .high
            }
        case .high:
            // Show all tasks when high energy
            matched = candidates
        }

        // Sort: highest priority first, then by due date, then by creation date
        return matched.sorted { a, b in
            // Priority first
            if a.priorityEnum.sortOrder != b.priorityEnum.sortOrder {
                return a.priorityEnum.sortOrder < b.priorityEnum.sortOrder
            }
            // Then overdue tasks
            if a.isOverdue != b.isOverdue {
                return a.isOverdue
            }
            // Then due today
            if a.isDueToday != b.isDueToday {
                return a.isDueToday
            }
            // Then by due date
            if let aDate = a.dueDate, let bDate = b.dueDate {
                return aDate < bDate
            }
            // Finally by creation date
            return a.createdAt < b.createdAt
        }
    }

    // MARK: - Actions

    private func completeTask(_ task: TodoItem) {
        withAnimation(reduceMotion ? DS.Animation.reduced : DS.Animation.spring) {
            todoStore.toggleCompletion(for: task)
            // Remove from skipped if it was skipped
            skippedTaskIds.remove(task.id)
        }
    }

    private func skipTask(_ task: TodoItem) {
        withAnimation(reduceMotion ? DS.Animation.reduced : DS.Animation.spring) {
            skippedTaskIds.insert(task.id)
        }
        HapticManager.shared.selection()
    }
}

// MARK: - Quick Add Sheet (Simplified)

private struct TodoQuickAddSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TodoStore.self) private var todoStore
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: DS.Spacing.xl) {
                // Simple text field
                TextField("What do you need to do?", text: $title)
                    .scaledFont(size: 18, relativeTo: .body)
                    .foregroundStyle(DS.Colors.textPrimary)
                    .padding(DS.Spacing.lg)
                    .background(DS.Colors.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                    .focused($isFocused)

                Spacer()

                // Add button
                Button {
                    addTask()
                } label: {
                    Text("Add Task")
                        .scaledFont(size: 16, weight: .semibold, relativeTo: .body)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: DS.Radius.lg)
                                .fill(title.isEmpty ? DS.Colors.slate : DS.Colors.primary)
                        )
                }
                .disabled(title.isEmpty)
                .buttonStyle(PressableStyle())
            }
            .padding(DS.Spacing.xl)
            .background(DS.Colors.background)
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            isFocused = true
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private func addTask() {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let newTodo = TodoItem(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            icon: IconMapper.shared.suggestIcon(for: title),
            priority: .medium
        )

        todoStore.addTodo(newTodo)
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: TodoItem.self,
        configurations: config
    )

    let store = TodoStore(modelContext: container.mainContext)
    store.loadSampleData()

    return CalmTodoView()
        .environment(store)
        .modelContainer(container)
}
