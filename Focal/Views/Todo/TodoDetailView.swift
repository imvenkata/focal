import SwiftUI
import SwiftData

struct TodoDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TodoStore.self) private var todoStore

    let todo: TodoItem

    @State private var title: String
    @State private var notes: String
    @State private var showIconPicker = false
    @State private var showColorPicker = false
    @State private var showPriorityPicker = false
    @State private var showDeleteConfirmation = false
    @State private var showEnergyPicker = false
    @State private var showReminderPicker = false
    @State private var newSubtaskTitle = ""

    // Inline expandable sections (reduces sheet cascade)
    @State private var expandedSection: ScheduleSection?

    enum ScheduleSection: Equatable {
        case date, time, reminder, repeatOption
    }

    @FocusState private var isSubtaskFieldFocused: Bool
    @FocusState private var isNotesFocused: Bool

    init(todo: TodoItem) {
        self.todo = todo
        _title = State(initialValue: todo.title)
        _notes = State(initialValue: todo.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Premium Header
                    TodoDetailHeader(
                        todo: todo,
                        title: $title,
                        showIconPicker: $showIconPicker,
                        showColorPicker: $showColorPicker,
                        showDeleteConfirmation: $showDeleteConfirmation,
                        onClose: { dismiss() }
                    )

                    // Content
                    VStack(spacing: 0) {
                        VStack(spacing: DS.Spacing.xl) {
                            // Schedule Section
                            scheduleSection

                            // Priority & Energy Row
                            priorityEnergyRow

                            // Subtasks Section
                            subtasksSection

                            // Notes Section
                            notesSection
                        }
                        .padding(.top, DS.Spacing.xl)
                        .padding(.horizontal, DS.Spacing.xl)

                        // Delete Button
                        Rectangle()
                            .fill(DS.Colors.borderSubtle)
                            .frame(height: DS.Spacing.xs / 4)
                            .padding(.top, DS.Spacing.xl)

                        TodoDetailDeleteButton {
                            showDeleteConfirmation = true
                        }
                        .padding(.horizontal, DS.Spacing.xl)
                        .padding(.top, DS.Spacing.lg)
                    }
                    .padding(.bottom, DS.Spacing.xxl)
                    .background(DS.Colors.surfacePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xxxl, style: .continuous))
                    .shadow(color: DS.Colors.overlay.opacity(0.12), radius: 24, x: 0, y: -DS.Spacing.xs)
                    .padding(.top, -DS.Spacing.lg)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .background(DS.Colors.bgPrimary)
            .toolbar(.hidden, for: .navigationBar)
            .onDisappear {
                // Ensure all changes are persisted
                todoStore.save()
            }
        }
        .sheet(isPresented: $showIconPicker) {
            IconPickerView(
                selectedIcon: Binding(
                    get: { todo.icon },
                    set: { newIcon in
                        todo.icon = newIcon
                        todo.updatedAt = Date()
                    }
                ),
                onSelect: { showIconPicker = false }
            )
        }
        .sheet(isPresented: $showColorPicker) {
            ColorPickerView(
                selectedColor: Binding(
                    get: { todo.color },
                    set: { newColor in
                        todo.colorName = newColor.rawValue
                        todo.updatedAt = Date()
                    }
                ),
                onSelect: { showColorPicker = false }
            )
        }
        .sheet(isPresented: $showEnergyPicker) {
            EnergyPickerSheet(
                selectedLevel: Binding(
                    get: { todo.energyLevel },
                    set: { todo.setEnergyLevel($0) }
                )
            )
        }
        .confirmationDialog("Reminder", isPresented: $showReminderPicker) {
            ForEach(TodoReminderOption.allCases) { option in
                Button(option.displayName) {
                    todo.setReminder(option)
                    HapticManager.shared.selection()
                    // Schedule notification
                    Task {
                        await TodoNotificationService.shared.scheduleReminder(for: todo)
                    }
                }
            }
        } message: {
            Text("When should we remind you?")
        }
        .confirmationDialog("Priority", isPresented: $showPriorityPicker) {
            ForEach(TodoPriority.allCases) { priority in
                Button {
                    todo.setPriority(priority)
                    HapticManager.shared.selection()
                } label: {
                    Label(priority.displayName, systemImage: priority.icon ?? "circle")
                }
            }
        } message: {
            Text("Set priority level")
        }
        .confirmationDialog("Delete Todo", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                // Remove notification before deleting todo
                Task {
                    await TodoNotificationService.shared.removeReminder(for: todo)
                }
                todoStore.deleteTodo(todo)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this todo?")
        }
    }

    // MARK: - Schedule Section

    private var scheduleSection: some View {
        VStack(spacing: 0) {
            // Due Date - Inline expandable
            VStack(spacing: 0) {
                TodoDetailExpandableRow(
                    systemName: "calendar",
                    title: todo.dueDateFormatted ?? "Add due date",
                    trailingText: todo.isDueToday ? "Today" : nil,
                    trailingTint: todo.isOverdue ? DS.Colors.danger : todo.color.color,
                    accentColor: todo.color.color,
                    isEmpty: todo.dueDate == nil,
                    isExpanded: expandedSection == .date,
                    accessibilityLabel: "Due date"
                ) {
                    withAnimation(DS.Animation.spring) {
                        expandedSection = expandedSection == .date ? nil : .date
                    }
                    HapticManager.shared.selection()
                }

                if expandedSection == .date {
                    VStack(spacing: DS.Spacing.md) {
                        // Quick date options
                        HStack(spacing: DS.Spacing.sm) {
                            InlineQuickDateButton(title: "Today", accentColor: todo.color.color) {
                                todo.setDueDate(Date())
                            }
                            InlineQuickDateButton(title: "Tomorrow", accentColor: todo.color.color) {
                                todo.setDueDate(Calendar.current.date(byAdding: .day, value: 1, to: Date()))
                            }
                            InlineQuickDateButton(title: "Next Week", accentColor: todo.color.color) {
                                todo.setDueDate(Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()))
                            }
                        }

                        DatePicker(
                            "Select Date",
                            selection: Binding(
                                get: { todo.dueDate ?? Date() },
                                set: { todo.setDueDate($0) }
                            ),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .tint(todo.color.color)

                        if todo.dueDate != nil {
                            Button {
                                todo.setDueDate(nil)
                                todo.setDueTime(nil)
                                HapticManager.shared.selection()
                            } label: {
                                Text("Remove Due Date")
                                    .scaledFont(size: 14, weight: .medium, relativeTo: .callout)
                                    .foregroundStyle(DS.Colors.danger)
                            }
                        }
                    }
                    .padding(DS.Spacing.lg)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }

            RowDivider()

            // Due Time - Inline expandable (only show if has due date)
            if todo.dueDate != nil {
                VStack(spacing: 0) {
                    TodoDetailExpandableRow(
                        systemName: "clock",
                        title: todo.dueTimeFormatted ?? "Add time",
                        trailingText: nil,
                        trailingTint: todo.color.color,
                        accentColor: todo.color.color,
                        isEmpty: !todo.hasDueTime,
                        isExpanded: expandedSection == .time,
                        accessibilityLabel: "Due time"
                    ) {
                        withAnimation(DS.Animation.spring) {
                            expandedSection = expandedSection == .time ? nil : .time
                        }
                        HapticManager.shared.selection()
                    }

                    if expandedSection == .time {
                        VStack(spacing: DS.Spacing.md) {
                            // Quick time options
                            HStack(spacing: DS.Spacing.sm) {
                                InlineQuickTimeButton(title: "9 AM", hour: 9, accentColor: todo.color.color) {
                                    setTime(hour: 9, minute: 0)
                                }
                                InlineQuickTimeButton(title: "12 PM", hour: 12, accentColor: todo.color.color) {
                                    setTime(hour: 12, minute: 0)
                                }
                                InlineQuickTimeButton(title: "5 PM", hour: 17, accentColor: todo.color.color) {
                                    setTime(hour: 17, minute: 0)
                                }
                            }

                            DatePicker(
                                "Select Time",
                                selection: Binding(
                                    get: { todo.dueTime ?? Date() },
                                    set: { todo.setDueTime($0) }
                                ),
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(maxHeight: 120)

                            if todo.hasDueTime {
                                Button {
                                    todo.setDueTime(nil)
                                    HapticManager.shared.selection()
                                } label: {
                                    Text("Remove Time")
                                        .scaledFont(size: 14, weight: .medium, relativeTo: .callout)
                                        .foregroundStyle(DS.Colors.danger)
                                }
                            }
                        }
                        .padding(DS.Spacing.lg)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }

                RowDivider()
            }

            // Reminder (uses confirmation dialog - quick to interact with)
            TodoDetailInfoRow(
                systemName: todo.reminderOption != nil ? "bell.badge.fill" : "bell",
                title: "Reminder",
                trailingText: todo.reminderFormatted,
                trailingTint: DS.Colors.textSecondary,
                accentColor: todo.color.color,
                isEmpty: todo.reminderOption == nil,
                accessibilityLabel: "Reminder",
                accessibilityHint: "Opens reminder options"
            ) {
                showReminderPicker = true
            }

            RowDivider()

            // Repeat - Inline expandable
            VStack(spacing: 0) {
                TodoDetailExpandableRow(
                    systemName: "arrow.clockwise",
                    title: "Repeat",
                    trailingText: todo.recurrenceFormatted.isEmpty ? "None" : todo.recurrenceFormatted,
                    trailingTint: DS.Colors.textSecondary,
                    accentColor: todo.color.color,
                    isEmpty: todo.recurrenceOption == nil,
                    isExpanded: expandedSection == .repeatOption,
                    accessibilityLabel: "Repeat"
                ) {
                    withAnimation(DS.Animation.spring) {
                        expandedSection = expandedSection == .repeatOption ? nil : .repeatOption
                    }
                    HapticManager.shared.selection()
                }

                if expandedSection == .repeatOption {
                    VStack(alignment: .leading, spacing: DS.Spacing.md) {
                        // Recurrence options
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DS.Spacing.sm) {
                                ForEach(TodoRecurrenceOption.allCases) { option in
                                    InlineRecurrenceButton(
                                        title: option.rawValue,
                                        isSelected: (TodoRecurrenceOption(rawValue: todo.recurrenceOption ?? "None") ?? .none) == option,
                                        accentColor: todo.color.color
                                    ) {
                                        todo.setRecurrence(option, days: todo.repeatDays)
                                        HapticManager.shared.selection()
                                    }
                                }
                            }
                        }

                        // Custom days picker
                        if (TodoRecurrenceOption(rawValue: todo.recurrenceOption ?? "None") ?? .none) == .custom {
                            InlineRepeatDaysPicker(
                                selectedDays: Binding(
                                    get: { Set(todo.repeatDays) },
                                    set: { todo.setRecurrence(.custom, days: Array($0)) }
                                ),
                                accentColor: todo.color.color
                            )
                        }
                    }
                    .padding(DS.Spacing.lg)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .background(DS.Colors.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xxl, style: .continuous))
    }

    private func setTime(hour: Int, minute: Int) {
        let calendar = Calendar.current
        let baseDate = todo.dueTime ?? Date()
        var components = calendar.dateComponents([.year, .month, .day], from: baseDate)
        components.hour = hour
        components.minute = minute
        if let newTime = calendar.date(from: components) {
            todo.setDueTime(newTime)
            HapticManager.shared.selection()
        }
    }

    // MARK: - Priority & Energy Row

    private var priorityEnergyRow: some View {
        HStack(spacing: DS.Spacing.md) {
            // Priority Button
            Button {
                showPriorityPicker = true
                HapticManager.shared.selection()
            } label: {
                HStack(spacing: DS.Spacing.sm) {
                    if let icon = todo.priorityEnum.icon {
                        Text(icon)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(todo.priorityEnum.iconColor)
                    }

                    Text(todo.priorityEnum.displayName)
                        .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                        .foregroundStyle(todo.priorityEnum.badgeTextColor)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(todo.priorityEnum.badgeTextColor.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DS.Spacing.md)
                .background(todo.priorityEnum.badgeBackground)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xxl, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Priority: \(todo.priorityEnum.displayName)")

            // Energy Button
            Button {
                showEnergyPicker = true
                HapticManager.shared.selection()
            } label: {
                HStack(spacing: DS.Spacing.sm) {
                    Text(todo.energyIcon)
                        .scaledFont(size: 16, relativeTo: .callout)

                    Text("Energy")
                        .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                        .foregroundStyle(todo.color.color)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DS.Spacing.md)
                .background(todo.color.color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xxl, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Energy: \(todo.energyLabel)")
        }
    }

    // MARK: - Subtasks Section

    private var subtasksSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack {
                Text("Subtasks")
                    .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .textCase(.uppercase)

                Spacer()

                if !todo.subtasks.isEmpty {
                    Text("\(todo.completedSubtasksCount)/\(todo.totalSubtasks)")
                        .scaledFont(size: 12, weight: .medium, design: .monospaced, relativeTo: .caption)
                        .foregroundStyle(todo.color.color)
                }
            }

            VStack(spacing: 0) {
                ForEach(todo.subtasks.sorted(by: { $0.orderIndex < $1.orderIndex })) { subtask in
                    TodoDetailSubtaskRow(
                        subtask: subtask,
                        accentColor: todo.color.color,
                        onToggle: {
                            subtask.toggle()
                            todo.updatedAt = Date()
                            HapticManager.shared.selection()
                        },
                        onDelete: {
                            todo.removeSubtask(subtask)
                            HapticManager.shared.deleted()
                        }
                    )

                    if subtask.id != todo.subtasks.last?.id {
                        RowDivider()
                    }
                }

                if !todo.subtasks.isEmpty {
                    RowDivider()
                }

                // Add subtask row
                HStack(spacing: DS.Spacing.md) {
                    RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                        .stroke(
                            DS.Colors.borderStrong,
                            style: StrokeStyle(
                                lineWidth: DS.Spacing.xs / 2,
                                dash: [DS.Spacing.sm, DS.Spacing.sm]
                            )
                        )
                        .frame(width: DS.Spacing.xxl, height: DS.Spacing.xxl)

                    TextField("Add subtask", text: $newSubtaskTitle)
                        .scaledFont(size: 15, weight: .medium, relativeTo: .subheadline)
                        .foregroundStyle(DS.Colors.textPrimary)
                        .focused($isSubtaskFieldFocused)
                        .submitLabel(.done)
                        .onSubmit { addSubtask() }
                        .accessibilityLabel("New subtask")

                    Spacer()

                    if !newSubtaskTitle.isEmpty {
                        Button {
                            addSubtask()
                        } label: {
                            Image(systemName: "plus")
                                .scaledFont(size: 14, weight: .bold, relativeTo: .callout)
                                .foregroundStyle(.white)
                                .frame(width: DS.Spacing.xxxl, height: DS.Spacing.xxxl)
                                .background(todo.color.color)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Add subtask")
                    }
                }
                .padding(DS.Spacing.lg)
            }
            .background(DS.Colors.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xxl, style: .continuous))
        }
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Notes")
                .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                .foregroundStyle(DS.Colors.textSecondary)
                .textCase(.uppercase)

            TextEditor(text: $notes)
                .frame(minHeight: 110)
                .padding(DS.Spacing.md)
                .background(DS.Colors.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xxl, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.xxl, style: .continuous)
                        .stroke(
                            isNotesFocused ? todo.color.color : .clear,
                            lineWidth: DS.Spacing.xs / 2
                        )
                )
                .focused($isNotesFocused)
                .onChange(of: notes) { _, newValue in
                    todo.notes = newValue.isEmpty ? nil : newValue
                    todo.updatedAt = Date()
                }
                .overlay {
                    if notes.isEmpty {
                        Text("Add notes, links, details...")
                            .scaledFont(size: 14, relativeTo: .callout)
                            .foregroundStyle(DS.Colors.textTertiary)
                            .padding(.horizontal, DS.Spacing.md)
                            .padding(.vertical, DS.Spacing.md)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .allowsHitTesting(false)
                    }
                }
                .accessibilityLabel("Notes")
        }
    }

    // MARK: - Actions

    private func addSubtask() {
        let trimmed = newSubtaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        todo.addSubtask(trimmed)
        newSubtaskTitle = ""
        HapticManager.shared.notification(.success)
    }
}

// MARK: - Todo Detail Header

private struct TodoDetailHeader: View {
    let todo: TodoItem
    @Binding var title: String
    @Binding var showIconPicker: Bool
    @Binding var showColorPicker: Bool
    @Binding var showDeleteConfirmation: Bool
    let onClose: () -> Void

    @FocusState private var isTitleFocused: Bool

    private var pillHeight: CGFloat {
        DS.Sizes.taskPillLarge + DS.Spacing.xxxl
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xl) {
            // Top Bar
            HStack {
                Button {
                    HapticManager.shared.buttonTapped()
                    onClose()
                } label: {
                    HeaderActionButton(systemName: "xmark", backgroundColor: todo.color.color)
                }
                .accessibilityLabel("Close")

                Spacer()

                // Status Badge
                if let badge = todo.statusBadge {
                    Text(badge.text)
                        .scaledFont(size: 11, weight: .bold, relativeTo: .caption2)
                        .foregroundStyle(.white)
                        .padding(.horizontal, DS.Spacing.md)
                        .padding(.vertical, DS.Spacing.xs)
                        .background(badge.color)
                        .clipShape(Capsule())
                }

                Menu {
                    Button {
                        showIconPicker = true
                    } label: {
                        Label("Change Icon", systemImage: "face.smiling")
                    }

                    Button {
                        showColorPicker = true
                    } label: {
                        Label("Change Color", systemImage: "paintpalette")
                    }

                    Divider()

                    Button {
                        todo.archive()
                    } label: {
                        Label("Archive", systemImage: "archivebox")
                    }

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    HeaderActionButton(systemName: "ellipsis", backgroundColor: todo.color.color)
                }
                .accessibilityLabel("More options")
            }

            // Todo Info
            HStack(alignment: .top, spacing: DS.Spacing.lg) {
                // Icon Pill
                TodoDetailPill(todo: todo, height: pillHeight)
                    .overlay(alignment: .bottomLeading) {
                        Button {
                            withAnimation(DS.Animation.quick) {
                                showIconPicker.toggle()
                            }
                        } label: {
                            Text("✏️")
                                .scaledFont(size: 14, relativeTo: .callout)
                                .frame(width: DS.Sizes.taskPillSmall, height: DS.Sizes.taskPillSmall)
                                .background(DS.Colors.surfacePrimary)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(todo.color.color, lineWidth: DS.Spacing.xs / 2)
                                )
                                .shadowResting()
                        }
                        .buttonStyle(.plain)
                        .offset(x: -DS.Spacing.sm, y: DS.Spacing.sm)
                        .accessibilityLabel("Change icon")
                    }

                // Title and Due
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    // Due date badge
                    if let dueText = todo.dueDateFormatted {
                        HStack(spacing: DS.Spacing.xs) {
                            Image(systemName: todo.isOverdue ? "exclamationmark.circle.fill" : "calendar")
                                .font(.system(size: 11, weight: .semibold))

                            Text(dueText)
                                .scaledFont(size: 12, weight: .medium, relativeTo: .caption)

                            if let timeText = todo.dueTimeFormatted {
                                Text("at \(timeText)")
                                    .scaledFont(size: 12, weight: .medium, relativeTo: .caption)
                            }
                        }
                        .foregroundStyle(todo.isOverdue ? DS.Colors.danger : todo.color.color.opacity(0.8))
                    }

                    TextField("Todo name", text: $title)
                        .scaledFont(size: 24, weight: .bold, relativeTo: .title2)
                        .foregroundStyle(todo.color.color)
                        .focused($isTitleFocused)
                        .onChange(of: title) { _, newValue in
                            todo.title = newValue
                            todo.updatedAt = Date()
                        }
                        .overlay(alignment: .bottomLeading) {
                            Rectangle()
                                .fill(isTitleFocused ? todo.color.color : .clear)
                                .frame(height: DS.Spacing.xs / 2)
                        }
                        .accessibilityLabel("Todo title")
                }
                .frame(maxWidth: 200)
                .padding(.top, DS.Spacing.xs)

                Spacer()

                // Completion Button
                Button {
                    todo.toggleCompletion()
                    HapticManager.shared.notification(todo.isCompleted ? .success : .warning)
                } label: {
                    ZStack {
                        Circle()
                            .stroke(
                                todo.isCompleted ? DS.Colors.success : todo.color.color,
                                lineWidth: DS.Spacing.xs / 2
                            )
                            .frame(width: DS.Spacing.xxxl, height: DS.Spacing.xxxl)

                        if todo.isCompleted {
                            Circle()
                                .fill(DS.Colors.success)
                                .frame(width: DS.Spacing.xxxl, height: DS.Spacing.xxxl)

                            Image(systemName: "checkmark")
                                .scaledFont(size: 14, weight: .bold, relativeTo: .callout)
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(width: DS.Sizes.minTouchTarget, height: DS.Sizes.minTouchTarget)
                }
                .buttonStyle(.plain)
                .padding(.top, DS.Spacing.md)
                .accessibilityLabel(todo.isCompleted ? "Mark incomplete" : "Mark complete")
            }
        }
        .padding(.horizontal, DS.Spacing.xl)
        .padding(.top, DS.Spacing.xxxl)
        .padding(.bottom, DS.Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(todo.color.lightColor)
    }
}

// MARK: - Supporting Views

private struct HeaderActionButton: View {
    let systemName: String
    let backgroundColor: Color

    var body: some View {
        Image(systemName: systemName)
            .scaledFont(size: 16, weight: .semibold, relativeTo: .callout)
            .foregroundStyle(.white)
            .frame(width: DS.Sizes.iconButtonSize, height: DS.Sizes.iconButtonSize)
            .background(backgroundColor)
            .clipShape(Circle())
    }
}

private struct TodoDetailPill: View {
    let todo: TodoItem
    let height: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DS.Radius.xxl, style: .continuous)
                .fill(todo.color.color)
                .frame(width: DS.Sizes.taskPillLarge, height: height)

            RoundedRectangle(cornerRadius: DS.Radius.xxl, style: .continuous)
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
                .frame(width: DS.Sizes.taskPillLarge, height: height)

            RoundedRectangle(cornerRadius: DS.Radius.xxl, style: .continuous)
                .stroke(todo.color.color.saturated(by: 1.2), lineWidth: 1.5)
                .frame(width: DS.Sizes.taskPillLarge, height: height)

            Text(todo.icon)
                .scaledFont(size: DS.Sizes.taskPillLarge * 0.5, relativeTo: .title2)
        }
        .shadowColored(todo.color.color)
        .opacity(todo.isCompleted ? 0.65 : 1)
    }
}

private struct TodoDetailInfoRow: View {
    let systemName: String
    let title: String
    let trailingText: String?
    let trailingTint: Color
    let accentColor: Color
    let isEmpty: Bool
    let accessibilityLabel: String
    let accessibilityHint: String
    let action: () -> Void

    private var iconSize: CGFloat {
        DS.Sizes.iconButtonSize - DS.Spacing.xs
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                        .fill(accentColor.opacity(0.15))
                        .frame(width: iconSize, height: iconSize)

                    Image(systemName: systemName)
                        .scaledFont(size: 16, weight: .semibold, relativeTo: .callout)
                        .foregroundStyle(accentColor)
                }

                Text(title)
                    .scaledFont(size: 16, weight: .medium, relativeTo: .body)
                    .foregroundStyle(isEmpty ? DS.Colors.textTertiary : DS.Colors.textPrimary)

                Spacer()

                if let trailingText, !trailingText.isEmpty {
                    Text(trailingText)
                        .scaledFont(size: 12, weight: .medium, relativeTo: .caption)
                        .foregroundStyle(trailingTint)
                }

                Image(systemName: "chevron.right")
                    .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                    .foregroundStyle(DS.Colors.textTertiary)
            }
            .padding(DS.Spacing.lg)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
    }
}

private struct RowDivider: View {
    var body: some View {
        Rectangle()
            .fill(DS.Colors.borderSubtle)
            .frame(height: DS.Spacing.xs / 4)
            .padding(.horizontal, DS.Spacing.lg)
    }
}

private struct TodoDetailSubtaskRow: View {
    let subtask: TodoSubtask
    let accentColor: Color
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                        .stroke(
                            subtask.isCompleted ? DS.Colors.success : DS.Colors.borderStrong,
                            lineWidth: DS.Spacing.xs / 2
                        )
                        .frame(width: DS.Spacing.xxl, height: DS.Spacing.xxl)

                    if subtask.isCompleted {
                        RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                            .fill(DS.Colors.success)
                            .frame(width: DS.Spacing.xxl, height: DS.Spacing.xxl)

                        Image(systemName: "checkmark")
                            .scaledFont(size: 12, weight: .bold, relativeTo: .caption)
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(subtask.isCompleted ? "Mark incomplete" : "Mark complete")

            Text(subtask.title)
                .scaledFont(size: 15, weight: .medium, relativeTo: .subheadline)
                .foregroundStyle(subtask.isCompleted ? DS.Colors.textTertiary : DS.Colors.textPrimary)
                .strikethrough(subtask.isCompleted, color: DS.Colors.textTertiary)

            Spacer()
        }
        .padding(.vertical, DS.Spacing.sm)
        .padding(.horizontal, DS.Spacing.lg)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            .tint(DS.Colors.danger)
        }
    }
}

private struct TodoDetailDeleteButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.sm) {
                Image(systemName: "trash")
                    .scaledFont(size: 16, weight: .semibold, relativeTo: .callout)
                    .foregroundStyle(DS.Colors.danger)

                Text("Delete Todo")
                    .scaledFont(size: 16, weight: .semibold, relativeTo: .body)
                    .foregroundStyle(DS.Colors.danger)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Spacing.lg)
            .background(DS.Colors.dangerLight)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xxl, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Delete todo")
    }
}

// MARK: - Inline Expandable Row

private struct TodoDetailExpandableRow: View {
    let systemName: String
    let title: String
    let trailingText: String?
    let trailingTint: Color
    let accentColor: Color
    let isEmpty: Bool
    let isExpanded: Bool
    let accessibilityLabel: String
    let action: () -> Void

    private var iconSize: CGFloat {
        DS.Sizes.iconButtonSize - DS.Spacing.xs
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                        .fill(accentColor.opacity(0.15))
                        .frame(width: iconSize, height: iconSize)

                    Image(systemName: systemName)
                        .scaledFont(size: 16, weight: .semibold, relativeTo: .callout)
                        .foregroundStyle(accentColor)
                }

                Text(title)
                    .scaledFont(size: 16, weight: .medium, relativeTo: .body)
                    .foregroundStyle(isEmpty ? DS.Colors.textTertiary : DS.Colors.textPrimary)

                Spacer()

                if let trailingText, !trailingText.isEmpty {
                    Text(trailingText)
                        .scaledFont(size: 12, weight: .medium, relativeTo: .caption)
                        .foregroundStyle(trailingTint)
                }

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                    .foregroundStyle(DS.Colors.textTertiary)
            }
            .padding(DS.Spacing.lg)
            .background(isExpanded ? accentColor.opacity(0.05) : Color.clear)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(isExpanded ? "Tap to collapse" : "Tap to expand")
    }
}

// MARK: - Inline Quick Buttons

private struct InlineQuickDateButton: View {
    let title: String
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button {
            action()
            HapticManager.shared.selection()
        } label: {
            Text(title)
                .scaledFont(size: 13, weight: .medium, relativeTo: .callout)
                .foregroundStyle(accentColor)
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.sm)
                .background(accentColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        }
        .buttonStyle(.plain)
    }
}

private struct InlineQuickTimeButton: View {
    let title: String
    let hour: Int
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button {
            action()
            HapticManager.shared.selection()
        } label: {
            Text(title)
                .scaledFont(size: 13, weight: .medium, relativeTo: .callout)
                .foregroundStyle(accentColor)
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.sm)
                .background(accentColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        }
        .buttonStyle(.plain)
    }
}

private struct InlineRecurrenceButton: View {
    let title: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .scaledFont(size: 13, weight: isSelected ? .semibold : .medium, relativeTo: .callout)
                .foregroundStyle(isSelected ? .white : DS.Colors.textSecondary)
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.sm)
                .background(isSelected ? accentColor : DS.Colors.surfaceTertiary)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct InlineRepeatDaysPicker: View {
    @Binding var selectedDays: Set<Int>
    let accentColor: Color

    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            HStack(spacing: DS.Spacing.sm) {
                ForEach(Weekday.allCases) { day in
                    InlineDayButton(
                        label: day.shortName,
                        isSelected: selectedDays.contains(day.rawValue),
                        accentColor: accentColor
                    ) {
                        HapticManager.shared.selection()
                        if selectedDays.contains(day.rawValue) {
                            selectedDays.remove(day.rawValue)
                        } else {
                            selectedDays.insert(day.rawValue)
                        }
                    }
                }
            }

            // Preset buttons
            HStack(spacing: DS.Spacing.sm) {
                InlinePresetButton(title: "Weekdays", isSelected: selectedDays.sorted() == [1, 2, 3, 4, 5], accentColor: accentColor) {
                    selectedDays = Set([1, 2, 3, 4, 5])
                    HapticManager.shared.selection()
                }

                InlinePresetButton(title: "Weekends", isSelected: selectedDays.sorted() == [0, 6], accentColor: accentColor) {
                    selectedDays = Set([0, 6])
                    HapticManager.shared.selection()
                }

                InlinePresetButton(title: "Every day", isSelected: selectedDays.count == 7, accentColor: accentColor) {
                    selectedDays = Set(0...6)
                    HapticManager.shared.selection()
                }
            }
        }
    }
}

private struct InlineDayButton: View {
    let label: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                .foregroundStyle(isSelected ? .white : DS.Colors.textSecondary)
                .frame(width: 36, height: 36)
                .background(isSelected ? accentColor : DS.Colors.surfaceTertiary)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

private struct InlinePresetButton: View {
    let title: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .scaledFont(size: 12, weight: isSelected ? .semibold : .medium, relativeTo: .caption)
                .foregroundStyle(isSelected ? accentColor : DS.Colors.textSecondary)
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.sm)
                .background(isSelected ? accentColor.opacity(0.1) : DS.Colors.surfaceTertiary)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Date Picker Sheet (Legacy - kept for backwards compatibility)

struct TodoDatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    let hasDueDate: Bool
    let onClear: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: DS.Spacing.xl) {
                // Quick options
                HStack(spacing: DS.Spacing.md) {
                    QuickDateButton(title: "Today", date: Date()) {
                        selectedDate = Date()
                        HapticManager.shared.selection()
                    }

                    QuickDateButton(title: "Tomorrow", date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()) {
                        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
                        HapticManager.shared.selection()
                    }

                    QuickDateButton(title: "Next Week", date: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()) {
                        selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()
                        HapticManager.shared.selection()
                    }
                }
                .padding(.horizontal, DS.Spacing.xl)

                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(DS.Colors.primary)
                .padding(.horizontal, DS.Spacing.md)

                Spacer()

                if hasDueDate {
                    Button {
                        onClear()
                    } label: {
                        Text("Remove Due Date")
                            .scaledFont(size: 16, weight: .medium, relativeTo: .body)
                            .foregroundStyle(DS.Colors.danger)
                    }
                    .padding(.bottom, DS.Spacing.xl)
                }
            }
            .padding(.top, DS.Spacing.lg)
            .background(DS.Colors.bgPrimary)
            .navigationTitle("Due Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(DS.Colors.primary)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

private struct QuickDateButton: View {
    let title: String
    let date: Date
    let action: () -> Void

    private var isSelected: Bool {
        Calendar.current.isDate(date, inSameDayAs: Date())
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .scaledFont(size: 13, weight: .medium, relativeTo: .callout)
                .foregroundStyle(DS.Colors.textPrimary)
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.sm)
                .background(DS.Colors.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Time Picker Sheet

struct TodoTimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTime: Date
    let hasTime: Bool
    let onClear: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: DS.Spacing.xl) {
                DatePicker(
                    "Select Time",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding(.horizontal, DS.Spacing.xl)

                // Quick time options
                HStack(spacing: DS.Spacing.md) {
                    QuickTimeButton(title: "9:00 AM", hour: 9, minute: 0) { h, m in
                        setTime(hour: h, minute: m)
                    }
                    QuickTimeButton(title: "12:00 PM", hour: 12, minute: 0) { h, m in
                        setTime(hour: h, minute: m)
                    }
                    QuickTimeButton(title: "5:00 PM", hour: 17, minute: 0) { h, m in
                        setTime(hour: h, minute: m)
                    }
                }
                .padding(.horizontal, DS.Spacing.xl)

                Spacer()

                if hasTime {
                    Button {
                        onClear()
                    } label: {
                        Text("Remove Time")
                            .scaledFont(size: 16, weight: .medium, relativeTo: .body)
                            .foregroundStyle(DS.Colors.danger)
                    }
                    .padding(.bottom, DS.Spacing.xl)
                }
            }
            .padding(.top, DS.Spacing.lg)
            .background(DS.Colors.bgPrimary)
            .navigationTitle("Due Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(DS.Colors.primary)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private func setTime(hour: Int, minute: Int) {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: selectedTime)
        components.hour = hour
        components.minute = minute
        if let newTime = calendar.date(from: components) {
            selectedTime = newTime
            HapticManager.shared.selection()
        }
    }
}

private struct QuickTimeButton: View {
    let title: String
    let hour: Int
    let minute: Int
    let action: (Int, Int) -> Void

    var body: some View {
        Button {
            action(hour, minute)
        } label: {
            Text(title)
                .scaledFont(size: 13, weight: .medium, relativeTo: .callout)
                .foregroundStyle(DS.Colors.textPrimary)
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.sm)
                .background(DS.Colors.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Repeat Picker Sheet

struct TodoRepeatPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var recurrence: TodoRecurrenceOption
    @Binding var selectedDays: Set<Int>
    let accentColor: Color

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                    Text("REPEAT")
                        .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                        .foregroundStyle(DS.Colors.textSecondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DS.Spacing.sm) {
                            ForEach(TodoRecurrenceOption.allCases) { option in
                                RecurrenceButton(
                                    title: option.rawValue,
                                    isSelected: recurrence == option,
                                    accentColor: accentColor
                                ) {
                                    HapticManager.shared.selection()
                                    recurrence = option
                                }
                            }
                        }
                    }

                    if recurrence == .custom {
                        TodoRepeatDaysPicker(selectedDays: $selectedDays, accentColor: accentColor)
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, DS.Spacing.xl)
                .padding(.top, DS.Spacing.lg)
                .padding(.bottom, DS.Spacing.xxxl)
            }
            .background(DS.Colors.bgPrimary)
            .navigationTitle("Repeat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        HapticManager.shared.selection()
                        dismiss()
                    }
                    .foregroundStyle(DS.Colors.textPrimary)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

private struct RecurrenceButton: View {
    let title: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .scaledFont(size: 13, weight: isSelected ? .semibold : .medium, relativeTo: .callout)
                .foregroundStyle(isSelected ? .white : DS.Colors.textSecondary)
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.sm)
                .background(isSelected ? accentColor : DS.Colors.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct TodoRepeatDaysPicker: View {
    @Binding var selectedDays: Set<Int>
    let accentColor: Color

    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            HStack(spacing: DS.Spacing.sm) {
                ForEach(Weekday.allCases) { day in
                    TodoDayButton(
                        label: day.shortName,
                        isSelected: selectedDays.contains(day.rawValue),
                        accentColor: accentColor
                    ) {
                        HapticManager.shared.selection()
                        if selectedDays.contains(day.rawValue) {
                            selectedDays.remove(day.rawValue)
                        } else {
                            selectedDays.insert(day.rawValue)
                        }
                    }
                }
            }

            // Preset buttons
            HStack(spacing: DS.Spacing.sm) {
                TodoPresetButton(title: "Weekdays", isSelected: selectedDays.sorted() == [1, 2, 3, 4, 5]) {
                    selectedDays = Set([1, 2, 3, 4, 5])
                    HapticManager.shared.selection()
                }

                TodoPresetButton(title: "Weekends", isSelected: selectedDays.sorted() == [0, 6]) {
                    selectedDays = Set([0, 6])
                    HapticManager.shared.selection()
                }

                TodoPresetButton(title: "Every day", isSelected: selectedDays.count == 7) {
                    selectedDays = Set(0...6)
                    HapticManager.shared.selection()
                }
            }
        }
        .padding(.top, DS.Spacing.md)
    }
}

private struct TodoDayButton: View {
    let label: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                .foregroundStyle(isSelected ? .white : DS.Colors.textSecondary)
                .frame(width: 40, height: 40)
                .background(isSelected ? accentColor : DS.Colors.surfaceSecondary)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

private struct TodoPresetButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .scaledFont(size: 12, weight: isSelected ? .semibold : .medium, relativeTo: .caption)
                .foregroundStyle(isSelected ? DS.Colors.primary : DS.Colors.textSecondary)
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.sm)
                .background(isSelected ? DS.Colors.primary.opacity(0.1) : DS.Colors.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let todo = TodoItem(
        title: "Weekly shopping",
        icon: "🛒",
        colorName: "sage",
        priority: .high
    )
    todo.addSubtask("Milk")
    todo.addSubtask("Bread")
    todo.addSubtask("Eggs")

    return TodoDetailView(todo: todo)
        .environment(TodoStore())
}
