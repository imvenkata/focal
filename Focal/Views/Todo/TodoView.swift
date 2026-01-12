import SwiftUI
import SwiftData
import UIKit

struct TodoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(TodoStore.self) private var todoStore

    @State private var showFloatingInput = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var dragTargetPriority: TodoPriority?
    @State private var selectedTodo: TodoItem?
    @State private var showingSearch = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: DS.Spacing.xl) {
                    // Header with stats
                    headerSection

                    // Search bar (when active)
                    if showingSearch {
                        searchBar
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Filter chips
                    filterChips
                    categoryChips

                    // Title
                    HStack {
                        Text("To-do")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(DS.Colors.textPrimary)
                            .tracking(-0.5)

                        Spacer()

                        HStack(spacing: DS.Spacing.sm) {
                            Button {
                                openFloatingInput()
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(DS.Colors.textSecondary)
                                    .frame(width: 36, height: 36)
                                    .background(DS.Colors.surfaceSecondary)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Open quick add")
                            .accessibilityHint("Opens the floating input")

                            // Search button
                            Button {
                                withAnimation(DS.Animation.spring) {
                                    showingSearch.toggle()
                                }
                            } label: {
                                Image(systemName: showingSearch ? "xmark" : "magnifyingglass")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(DS.Colors.textSecondary)
                                    .frame(width: 36, height: 36)
                                    .background(DS.Colors.surfaceSecondary)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(showingSearch ? "Close search" : "Search todos")
                        }
                    }

                    // Empty state or content
                    if !todoStore.hasAnyTodos {
                        emptyState
                    } else if todoStore.filteredTodos.isEmpty && !todoStore.searchText.isEmpty {
                        noResultsState
                    } else {
                        // Priority sections
                        prioritySections

                        // Completed section
                        if !todoStore.filteredCompletedTodos.isEmpty {
                            completedSection
                        }
                    }

                    // Quick add launcher
                    quickAddSection
                }
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.top, DS.Spacing.xl)
                .padding(.bottom, 140)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(DS.Colors.background)
            .blur(radius: showFloatingInput ? 2 : 0)
            .opacity(showFloatingInput ? 0.7 : 1)
            .animation(DS.Animation.spring, value: showFloatingInput)

            if showFloatingInput {
                DS.Colors.overlay.opacity(0.2)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        closeFloatingInput()
                    }
                    .accessibilityLabel("Dismiss quick add")
                    .accessibilityHint("Closes the floating input")
            }

            // Undo toast
            if todoStore.canUndo && !showFloatingInput {
                undoToast
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            if showFloatingInput {
                FloatingTaskInputCard(
                    onSubmit: handleFloatingSubmit,
                    onClose: closeFloatingInput
                )
                .padding(.horizontal, DS.Spacing.md)
                .padding(.bottom, keyboardHeight > 0 ? max(0, keyboardHeight - DS.Spacing.sm) : DS.Spacing.lg)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(DS.Animation.spring, value: todoStore.canUndo)
        .animation(DS.Animation.spring, value: showFloatingInput)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { notification in
            guard showFloatingInput,
                  let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }
            let screenHeight = UIScreen.main.bounds.height
            let height = max(0, screenHeight - frame.origin.y)
            withAnimation(DS.Animation.quick) {
                keyboardHeight = height
            }
        }
        .sheet(item: $selectedTodo) { todo in
            TodoDetailView(todo: todo)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: DS.Spacing.md) {
            // Progress badge
            HStack(spacing: DS.Spacing.xs) {
                Text("🌿")
                    .font(.system(size: 16))

                Text("\(todoStore.completedTodos.count) / \(todoStore.activeTodos.count + todoStore.completedTodos.count)")
                    .scaledFont(size: 14, weight: .semibold, relativeTo: .subheadline)
                    .foregroundStyle(DS.Colors.textPrimary)
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
            .background(DS.Colors.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.pill))
            .shadowResting()

            // Stats badges
            if todoStore.overdueCount > 0 {
                StatBadge(
                    icon: "exclamationmark.circle.fill",
                    count: todoStore.overdueCount,
                    color: DS.Colors.danger,
                    label: "Overdue"
                )
            }

            if todoStore.dueTodayCount > 0 {
                StatBadge(
                    icon: "sun.max.fill",
                    count: todoStore.dueTodayCount,
                    color: DS.Colors.amber,
                    label: "Due today"
                )
            }

            Spacer()
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: DS.Spacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(DS.Colors.textTertiary)

            TextField("Search todos...", text: Binding(
                get: { todoStore.searchText },
                set: { todoStore.searchText = $0 }
            ))
            .scaledFont(size: 16, relativeTo: .body)
            .foregroundStyle(DS.Colors.textPrimary)
            .submitLabel(.search)

            if !todoStore.searchText.isEmpty {
                Button {
                    todoStore.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(DS.Colors.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.sm) {
                ForEach(TodoFilter.allCases) { filter in
                    FilterChip(
                        filter: filter,
                        isSelected: todoStore.selectedFilter == filter,
                        count: countForFilter(filter)
                    ) {
                        withAnimation(DS.Animation.spring) {
                            todoStore.selectedFilter = filter
                        }
                        HapticManager.shared.selection()
                    }
                }
            }
        }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.sm) {
                CategoryChip(
                    label: "All",
                    icon: "🗂️",
                    tint: DS.Colors.textSecondary,
                    isSelected: todoStore.selectedCategory == nil
                ) {
                    withAnimation(DS.Animation.spring) {
                        todoStore.selectedCategory = nil
                    }
                    HapticManager.shared.selection()
                }

                ForEach(TodoCategory.allCases) { category in
                    CategoryChip(
                        label: category.label,
                        icon: category.icon,
                        tint: category.tint,
                        isSelected: todoStore.selectedCategory == category
                    ) {
                        withAnimation(DS.Animation.spring) {
                            todoStore.selectedCategory = category
                        }
                        HapticManager.shared.selection()
                    }
                }
            }
        }
        .accessibilityLabel("Category filters")
    }

    private func countForFilter(_ filter: TodoFilter) -> Int {
        switch filter {
        case .all: return todoStore.activeTodos.count
        case .today: return todoStore.dueTodayCount
        case .upcoming:
            return todoStore.activeTodos.filter { todo in
                guard let dueDate = todo.dueDate else { return false }
                return dueDate > Date() && !todo.isDueToday
            }.count
        case .overdue: return todoStore.overdueCount
        case .noDueDate: return todoStore.activeTodos.filter { $0.dueDate == nil }.count
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: DS.Spacing.xl) {
            Text("📝")
                .font(.system(size: 64))

            VStack(spacing: DS.Spacing.sm) {
                Text("No todos yet")
                    .scaledFont(size: 20, weight: .semibold, relativeTo: .title3)
                    .foregroundStyle(DS.Colors.textPrimary)

                Text("Add your first todo to get started.\nOrganize by priority, set due dates, and more.")
                    .scaledFont(size: 15, relativeTo: .body)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Spacing.xxxl)
    }

    private var noResultsState: some View {
        VStack(spacing: DS.Spacing.lg) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(DS.Colors.textTertiary)

            VStack(spacing: DS.Spacing.sm) {
                Text("No results found")
                    .scaledFont(size: 18, weight: .semibold, relativeTo: .headline)
                    .foregroundStyle(DS.Colors.textPrimary)

                Text("Try a different search term")
                    .scaledFont(size: 14, relativeTo: .callout)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Spacing.xxxl)
    }

    // MARK: - Quick Add Section

    private var quickAddSection: some View {
        Button {
            openFloatingInput()
        } label: {
            HStack(spacing: DS.Spacing.md) {
                Text("Add it to your list")
                    .scaledFont(size: 15, weight: .medium, relativeTo: .body)
                    .foregroundStyle(DS.Colors.textSecondary)

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(DS.Colors.primary)
                    .frame(width: 44, height: 44)
                    .background(DS.Colors.primary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            }
            .padding(.leading, DS.Spacing.lg)
            .padding(.trailing, DS.Spacing.xs)
            .padding(.vertical, DS.Spacing.xs)
            .background(DS.Colors.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.lg)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                    .foregroundStyle(DS.Colors.divider)
            )
            .shadowResting()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open quick add from list")
        .accessibilityHint("Opens the floating input card")
    }

    // MARK: - Priority Sections

    private var prioritySections: some View {
        VStack(spacing: DS.Spacing.xl) {
            if !todoStore.filteredHighPriorityTodos.isEmpty || todoStore.selectedFilter == .all {
                prioritySection(for: .high, todos: todoStore.filteredHighPriorityTodos)
            }

            if !todoStore.filteredMediumPriorityTodos.isEmpty || todoStore.selectedFilter == .all {
                prioritySection(for: .medium, todos: todoStore.filteredMediumPriorityTodos)
            }

            if !todoStore.filteredLowPriorityTodos.isEmpty || todoStore.selectedFilter == .all {
                prioritySection(for: .low, todos: todoStore.filteredLowPriorityTodos)
            }

            if !todoStore.filteredUnprioritizedTodos.isEmpty || todoStore.selectedFilter == .all {
                prioritySection(for: .none, todos: todoStore.filteredUnprioritizedTodos)
            }
        }
    }

    private func prioritySection(for priority: TodoPriority, todos: [TodoItem]) -> some View {
        TodoPrioritySection(
            priority: priority,
            todos: todos,
            isCollapsed: todoStore.isSectionCollapsed(priority),
            isDropTarget: dragTargetPriority == priority,
            onToggleCollapse: { todoStore.toggleSectionCollapse(priority) },
            onToggleCompletion: { todoStore.toggleCompletion(for: $0) },
            onTap: { selectedTodo = $0 },
            onDelete: { todoStore.deleteTodo($0) },
            onAddItem: { addTodo(title: $0, priority: priority) },
            onDropItem: { moveTodo($0, to: priority) }
        )
        .dropDestination(for: String.self) { items, _ in
            guard let idString = items.first,
                  let uuid = UUID(uuidString: idString),
                  let todo = todoStore.todos.first(where: { $0.id == uuid }) else {
                return false
            }

            withAnimation(DS.Animation.spring) {
                moveTodo(todo, to: priority)
            }
            return true
        } isTargeted: { isTargeted in
            withAnimation(DS.Animation.quick) {
                dragTargetPriority = isTargeted ? priority : nil
            }
        }
    }

    // MARK: - Completed Section

    private var completedSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            // Header
            Button {
                withAnimation(DS.Animation.spring) {
                    todoStore.isCompletedSectionCollapsed.toggle()
                }
                HapticManager.shared.selection()
            } label: {
                HStack(spacing: DS.Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(DS.Colors.success)

                    Text("COMPLETED")
                        .scaledFont(size: 11, weight: .bold, relativeTo: .caption2)
                        .foregroundStyle(DS.Colors.success)
                        .tracking(0.8)

                    Text("(\(todoStore.filteredCompletedTodos.count))")
                        .scaledFont(size: 11, weight: .semibold, relativeTo: .caption2)
                        .foregroundStyle(DS.Colors.success.opacity(0.7))

                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(DS.Colors.success.opacity(0.6))
                        .rotationEffect(.degrees(todoStore.isCompletedSectionCollapsed ? -90 : 0))

                    Spacer()

                    // Archive all button
                    if !todoStore.isCompletedSectionCollapsed {
                        Button {
                            todoStore.archiveAllCompleted()
                        } label: {
                            HStack(spacing: DS.Spacing.xs) {
                                Image(systemName: "archivebox")
                                    .font(.system(size: 11, weight: .semibold))
                                Text("Archive all")
                                    .scaledFont(size: 11, weight: .medium, relativeTo: .caption2)
                            }
                            .foregroundStyle(DS.Colors.textSecondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.sm)
                .background(DS.Colors.success.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            }
            .buttonStyle(.plain)

            // Completed items
            if !todoStore.isCompletedSectionCollapsed {
                VStack(spacing: DS.Spacing.sm) {
                    ForEach(todoStore.filteredCompletedTodos.prefix(5)) { todo in
                        CompletedTodoCard(
                            todo: todo,
                            onTap: { selectedTodo = todo },
                            onUncomplete: { todoStore.toggleCompletion(for: todo) },
                            onDelete: { todoStore.deleteTodo(todo) }
                        )
                    }

                    if todoStore.filteredCompletedTodos.count > 5 {
                        Text("+\(todoStore.filteredCompletedTodos.count - 5) more")
                            .scaledFont(size: 13, weight: .medium, relativeTo: .caption)
                            .foregroundStyle(DS.Colors.textTertiary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DS.Spacing.sm)
                    }
                }
            }
        }
    }

    // MARK: - Undo Toast

    private var undoToast: some View {
        HStack(spacing: DS.Spacing.md) {
            Text(todoStore.undoMessage ?? "Deleted")
                .scaledFont(size: 14, weight: .medium, relativeTo: .callout)
                .foregroundStyle(.white)

            Spacer()

            Button {
                todoStore.undoDelete()
            } label: {
                Text("Undo")
                    .scaledFont(size: 14, weight: .bold, relativeTo: .callout)
                    .foregroundStyle(DS.Colors.amber)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.vertical, DS.Spacing.md)
        .background(DS.Colors.night)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        .shadowLifted()
        .padding(.horizontal, DS.Spacing.xl)
        .padding(.bottom, 100)
    }

    // MARK: - Actions

    private func addTodo(title: String, priority: TodoPriority) {
        let newTodo = TodoItem(
            title: title,
            icon: suggestIcon(for: title),
            colorName: nextColor().rawValue,
            priority: priority
        )

        withAnimation(DS.Animation.spring) {
            todoStore.addTodo(newTodo)
        }
    }

    private func handleFloatingSubmit(_ draft: FloatingTaskInputDraft) {
        let newTodo = TodoItem(
            title: draft.title,
            icon: draft.icon,
            colorName: draft.color.rawValue,
            priority: .none,
            category: draft.category,
            dueDate: draft.dueDate,
            estimatedDuration: draft.duration
        )

        withAnimation(DS.Animation.spring) {
            todoStore.addTodo(newTodo)
        }
    }

    private func openFloatingInput() {
        withAnimation(DS.Animation.spring) {
            showFloatingInput = true
        }
        HapticManager.shared.selection()
    }

    private func closeFloatingInput() {
        withAnimation(DS.Animation.spring) {
            showFloatingInput = false
            keyboardHeight = 0
        }
    }
    
    // MARK: - Smart Icon Suggestion
    
    private func suggestIcon(for title: String) -> String {
        let lower = title.lowercased()
        
        // Shopping & Errands
        if lower.contains("shop") || lower.contains("buy") || lower.contains("grocery") || lower.contains("store") {
            return "🛒"
        }
        if lower.contains("cook") || lower.contains("meal") || lower.contains("dinner") || lower.contains("lunch") || lower.contains("breakfast") || lower.contains("food") {
            return "🍳"
        }
        
        // Work & Productivity
        if lower.contains("meeting") || lower.contains("call") || lower.contains("zoom") {
            return "📞"
        }
        if lower.contains("email") || lower.contains("mail") || lower.contains("send") {
            return "📧"
        }
        if lower.contains("work") || lower.contains("project") || lower.contains("task") {
            return "💼"
        }
        if lower.contains("code") || lower.contains("develop") || lower.contains("program") || lower.contains("app") {
            return "💻"
        }
        if lower.contains("write") || lower.contains("doc") || lower.contains("report") || lower.contains("note") {
            return "📝"
        }
        
        // Health & Fitness
        if lower.contains("gym") || lower.contains("workout") || lower.contains("exercise") || lower.contains("run") || lower.contains("fitness") {
            return "🏋️"
        }
        if lower.contains("doctor") || lower.contains("dentist") || lower.contains("appointment") || lower.contains("health") {
            return "🏥"
        }
        if lower.contains("medicine") || lower.contains("pill") || lower.contains("vitamin") {
            return "💊"
        }
        
        // Learning & Education
        if lower.contains("read") || lower.contains("book") || lower.contains("study") || lower.contains("learn") {
            return "📚"
        }
        if lower.contains("class") || lower.contains("course") || lower.contains("lecture") {
            return "🎓"
        }
        
        // Home & Personal
        if lower.contains("clean") || lower.contains("laundry") || lower.contains("wash") {
            return "🧹"
        }
        if lower.contains("fix") || lower.contains("repair") {
            return "🔧"
        }
        if lower.contains("pay") || lower.contains("bill") || lower.contains("bank") || lower.contains("money") {
            return "💳"
        }
        
        // Social & Events
        if lower.contains("party") || lower.contains("celebrate") || lower.contains("birthday") {
            return "🎉"
        }
        if lower.contains("gift") || lower.contains("present") {
            return "🎁"
        }
        if lower.contains("travel") || lower.contains("trip") || lower.contains("vacation") || lower.contains("flight") {
            return "✈️"
        }
        
        // Default
        return "📋"
    }
    
    // MARK: - Color Cycling for Visual Variety
    
    @State private var colorIndex = 0
    
    private func nextColor() -> TaskColor {
        let colors: [TaskColor] = [.sky, .sage, .rose, .amber, .lavender, .coral]
        let color = colors[colorIndex % colors.count]
        colorIndex += 1
        return color
    }

    private func moveTodo(_ todo: TodoItem, to priority: TodoPriority) {
        todoStore.updatePriority(for: todo, to: priority)
        HapticManager.shared.notification(.success)
    }
}

// MARK: - Supporting Views

private struct StatBadge: View {
    let icon: String
    let count: Int
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: DS.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(color)

            Text("\(count)")
                .scaledFont(size: 13, weight: .bold, design: .rounded, relativeTo: .caption)
                .foregroundStyle(color)
        }
        .padding(.horizontal, DS.Spacing.sm)
        .padding(.vertical, DS.Spacing.xs)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
        .accessibilityLabel("\(count) \(label)")
    }
}

private struct FilterChip: View {
    let filter: TodoFilter
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.xs) {
                Image(systemName: filter.icon)
                    .font(.system(size: 12, weight: .semibold))

                Text(filter.rawValue)
                    .scaledFont(size: 13, weight: .semibold, relativeTo: .callout)

                if count > 0 {
                    Text("\(count)")
                        .scaledFont(size: 11, weight: .bold, design: .rounded, relativeTo: .caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? .white.opacity(0.3) : filter.color.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            .foregroundStyle(isSelected ? .white : filter.color)
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
            .background(isSelected ? filter.color : filter.color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(filter.rawValue) filter, \(count) items")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct CategoryChip: View {
    let label: String
    let icon: String
    let tint: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.xs) {
                Text(icon)
                    .scaledFont(size: 12, relativeTo: .caption)

                Text(label)
                    .scaledFont(size: 13, weight: .semibold, relativeTo: .callout)
            }
            .foregroundStyle(isSelected ? .white : tint)
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
            .background(isSelected ? tint : tint.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(label) category")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct CompletedTodoCard: View {
    let todo: TodoItem
    let onTap: () -> Void
    let onUncomplete: () -> Void
    let onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    private let deleteThreshold: CGFloat = 100

    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete action background
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(DS.Animation.spring) { offset = 0 }
                    onDelete()
                }) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: max(offset, 0))
                }
                .background(DS.Colors.danger)
            }
            .frame(maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .opacity(offset > 0 ? 1 : 0)
            
            // Main content
            HStack(spacing: DS.Spacing.md) {
                // Checkmark
                Button(action: onUncomplete) {
                    ZStack {
                        Circle()
                            .fill(DS.Colors.success)
                            .frame(width: 24, height: 24)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)

                // Content
                Button(action: onTap) {
                    HStack(spacing: DS.Spacing.sm) {
                        Text(todo.icon)
                            .font(.system(size: 18))

                        Text(todo.title)
                            .scaledFont(size: 14, weight: .medium, relativeTo: .body)
                            .foregroundStyle(DS.Colors.textTertiary)
                            .strikethrough()
                            .lineLimit(1)

                        Spacer()

                        if let completedAt = todo.completedAt {
                            Text(completedAt.timeAgoShort)
                                .scaledFont(size: 11, weight: .medium, relativeTo: .caption2)
                                .foregroundStyle(DS.Colors.textTertiary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(DS.Spacing.md)
            .background(DS.Colors.surfacePrimary.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .offset(x: -offset)
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = -value.translation.width
                        }
                    }
                    .onEnded { value in
                        withAnimation(DS.Animation.spring) {
                            if offset > deleteThreshold {
                                offset = 0
                                onDelete()
                            } else {
                                offset = 0
                            }
                        }
                    }
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
    }
}

// MARK: - Date Extension

extension Date {
    var timeAgoShort: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
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

    return TodoView()
        .environment(store)
        .modelContainer(container)
}
