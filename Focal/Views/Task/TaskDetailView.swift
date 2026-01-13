import SwiftUI

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TaskStore.self) private var taskStore

    let task: TaskItem

    @State private var title: String
    @State private var notes: String
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    @State private var showEnergyPicker = false
    @State private var showReminderPicker = false
    @State private var showColorPicker = false
    @State private var showDeleteConfirmation = false
    @State private var showRepeatPicker = false
    @State private var newSubtaskTitle = ""

    @FocusState private var isSubtaskFieldFocused: Bool
    @FocusState private var isNotesFocused: Bool

    init(task: TaskItem) {
        self.task = task
        _title = State(initialValue: task.title)
        _notes = State(initialValue: task.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    TaskDetailHeader(
                        task: task,
                        title: $title,
                        timeRange: timeRangeLabel,
                        showColorPicker: $showColorPicker,
                        showDeleteConfirmation: $showDeleteConfirmation,
                        onClose: {
                            dismiss()
                        }
                    )

                    VStack(spacing: 0) {
                        VStack(spacing: DS.Spacing.xl) {
                            VStack(spacing: 0) {
                                TaskDetailInfoRow(
                                    systemName: "calendar",
                                    title: detailDateLabel,
                                    trailingText: dateStatusLabel,
                                    trailingTint: dateStatusLabel == nil ? DS.Colors.textSecondary : task.color.color,
                                    accentColor: task.color.color,
                                    accessibilityLabel: "Date, \(detailDateLabel)",
                                    accessibilityHint: "Opens date picker",
                                    action: {
                                        showDatePicker = true
                                    }
                                )

                                RowDivider()

                                TaskDetailInfoRow(
                                    systemName: "clock",
                                    title: timeRangeLabel,
                                    trailingText: task.durationFormatted,
                                    trailingTint: DS.Colors.textSecondary,
                                    accentColor: task.color.color,
                                    accessibilityLabel: "Time, \(timeRangeLabel), \(task.durationFormatted)",
                                    accessibilityHint: "Opens time picker",
                                    action: {
                                        showTimePicker = true
                                    }
                                )

                                RowDivider()

                                TaskDetailInfoRow(
                                    systemName: "bell",
                                    title: alertsTitle,
                                    trailingText: alertsDetail,
                                    trailingTint: DS.Colors.textSecondary,
                                    accentColor: task.color.color,
                                    accessibilityLabel: "Alerts, \(alertsTitle)",
                                    accessibilityHint: "Opens alert options",
                                    action: {
                                        showReminderPicker = true
                                    }
                                )
                            }
                            .background(DS.Colors.surfaceSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xxl, style: .continuous))

                            HStack(spacing: DS.Spacing.md) {
                                Button {
                                    showRepeatPicker = true
                                    HapticManager.shared.selection()
                                } label: {
                                    HStack(spacing: DS.Spacing.sm) {
                                        Image(systemName: "arrow.clockwise")
                                            .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                                            .foregroundStyle(DS.Colors.textSecondary)

                                        Text("Repeat")
                                            .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                                            .foregroundStyle(DS.Colors.textPrimary)

                                        Spacer()

                                        Text(task.recurrenceFormatted.isEmpty ? "None" : task.recurrenceFormatted)
                                            .scaledFont(size: 12, weight: .medium, relativeTo: .caption)
                                            .foregroundStyle(DS.Colors.textSecondary)

                                        Image(systemName: "chevron.right")
                                            .scaledFont(size: 12, weight: .semibold, relativeTo: .caption2)
                                            .foregroundStyle(DS.Colors.textTertiary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, DS.Spacing.md)
                                    .padding(.horizontal, DS.Spacing.lg)
                                    .background(DS.Colors.surfaceSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xxl, style: .continuous))
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Repeat options")
                                .accessibilityValue(task.recurrenceFormatted.isEmpty ? "None" : task.recurrenceFormatted)

                                Button {
                                    showEnergyPicker = true
                                    HapticManager.shared.selection()
                                } label: {
                                    HStack(spacing: DS.Spacing.sm) {
                                        Text(task.energyIcon)
                                            .scaledFont(size: 16, relativeTo: .callout)

                                        Text("Energy")
                                            .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                                            .foregroundStyle(task.color.color)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, DS.Spacing.md)
                                    .background(task.color.color.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xxl, style: .continuous))
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Energy level")
                                .accessibilityHint("Opens energy picker")
                            }

                            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                                Text("Subtasks")
                                    .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                                    .foregroundStyle(DS.Colors.textSecondary)
                                    .textCase(.uppercase)

                                VStack(spacing: 0) {
                                    ForEach(task.subtasks) { subtask in
                                        TaskDetailSubtaskRow(
                                            subtask: subtask,
                                            onToggle: {
                                                subtask.isCompleted.toggle()
                                                task.updatedAt = Date()
                                                HapticManager.shared.selection()
                                            },
                                            onDelete: {
                                                task.removeSubtask(subtask)
                                                HapticManager.shared.deleted()
                                            }
                                        )

                                        if subtask.id != task.subtasks.last?.id {
                                            RowDivider()
                                        }
                                    }

                                    if !task.subtasks.isEmpty {
                                        RowDivider()
                                    }

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

                                        TextField("Add Subtask", text: $newSubtaskTitle)
                                            .scaledFont(size: 15, weight: .medium, relativeTo: .subheadline)
                                            .foregroundStyle(DS.Colors.textPrimary)
                                            .focused($isSubtaskFieldFocused)
                                            .submitLabel(.done)
                                            .onSubmit {
                                                addSubtask()
                                            }
                                            .accessibilityLabel("New subtask")
                                            .accessibilityHint("Enter a subtask title")

                                        Spacer()

                                        if !newSubtaskTitle.isEmpty {
                                            Button {
                                                addSubtask()
                                            } label: {
                                                Image(systemName: "plus")
                                                    .scaledFont(size: 14, weight: .bold, relativeTo: .callout)
                                                    .foregroundStyle(.white)
                                                    .frame(width: DS.Spacing.xxxl, height: DS.Spacing.xxxl)
                                                    .background(task.color.color)
                                                    .clipShape(Circle())
                                            }
                                            .buttonStyle(.plain)
                                            .accessibilityLabel("Add subtask")
                                            .accessibilityHint("Adds the new subtask")
                                        }
                                    }
                                    .padding(DS.Spacing.lg)
                                }
                                .background(DS.Colors.surfaceSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xxl, style: .continuous))
                            }

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
                                                isNotesFocused ? task.color.color : .clear,
                                                lineWidth: DS.Spacing.xs / 2
                                            )
                                    )
                                    .focused($isNotesFocused)
                                    .onChange(of: notes) { _, newValue in
                                        task.notes = newValue.isEmpty ? nil : newValue
                                        task.updatedAt = Date()
                                    }
                                    .overlay {
                                        if notes.isEmpty {
                                            Text("Add notes, meeting links...")
                                                .scaledFont(size: 14, relativeTo: .callout)
                                                .foregroundStyle(DS.Colors.textTertiary)
                                                .padding(.horizontal, DS.Spacing.md)
                                                .padding(.vertical, DS.Spacing.md)
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                                .allowsHitTesting(false)
                                        }
                                    }
                                    .accessibilityLabel("Notes")
                                    .accessibilityHint("Add additional details")
                            }
                        }
                        .padding(.top, DS.Spacing.xl)
                        .padding(.horizontal, DS.Spacing.xl)

                        Rectangle()
                            .fill(DS.Colors.borderSubtle)
                            .frame(height: DS.Spacing.xs / 4)
                            .padding(.top, DS.Spacing.xl)

                        TaskDetailDeleteButton {
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
            .background(DS.Colors.bgPrimary)
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(selectedDate: .init(
                get: { task.startTime },
                set: { newDate in
                    let calendar = Calendar.current
                    let timeComponents = calendar.dateComponents([.hour, .minute], from: task.startTime)
                    task.startTime = calendar.date(
                        bySettingHour: timeComponents.hour ?? 9,
                        minute: timeComponents.minute ?? 0,
                        second: 0,
                        of: newDate
                    ) ?? newDate
                    task.updatedAt = Date()
                }
            ))
        }
        .sheet(isPresented: $showTimePicker) {
            TimePickerSheet(
                selectedTime: .init(
                    get: { task.startTime },
                    set: { newTime in
                        let calendar = Calendar.current
                        let dateComponents = calendar.dateComponents([.year, .month, .day], from: task.startTime)
                        let timeComponents = calendar.dateComponents([.hour, .minute], from: newTime)
                        var combined = DateComponents()
                        combined.year = dateComponents.year
                        combined.month = dateComponents.month
                        combined.day = dateComponents.day
                        combined.hour = timeComponents.hour
                        combined.minute = timeComponents.minute
                        task.startTime = calendar.date(from: combined) ?? task.startTime
                        task.updatedAt = Date()
                    }
                ),
                duration: .init(
                    get: { task.duration },
                    set: { newDuration in
                        task.duration = newDuration
                        task.updatedAt = Date()
                    }
                )
            )
        }
        .sheet(isPresented: $showEnergyPicker) {
            EnergyPickerSheet(
                selectedLevel: .init(
                    get: { task.energyLevel },
                    set: { newLevel in
                        task.energyLevel = newLevel
                        task.updatedAt = Date()
                    }
                )
            )
        }
        .sheet(isPresented: $showRepeatPicker) {
            RepeatPickerSheet(
                recurrence: .init(
                    get: { RecurrenceOption(rawValue: task.recurrenceOption ?? "None") ?? .none },
                    set: { newValue in
                        task.recurrenceOption = newValue == .none ? nil : newValue.rawValue
                        task.updatedAt = Date()
                    }
                ),
                selectedDays: .init(
                    get: { Set(task.repeatDays) },
                    set: { newDays in
                        task.repeatDays = Array(newDays)
                        task.updatedAt = Date()
                    }
                ),
                accentColor: task.color.color
            )
        }
        .confirmationDialog("Alerts", isPresented: $showReminderPicker) {
            ForEach(ReminderOption.allCases) { option in
                Button(option.rawValue) {
                    task.reminderOption = option == .none ? nil : option.rawValue
                    task.updatedAt = Date()
                    HapticManager.shared.selection()
                    // Schedule notification
                    Task {
                        await TaskNotificationService.shared.scheduleReminder(for: task)
                    }
                }
            }
        } message: {
            Text("Choose when to be notified.")
        }
        .confirmationDialog("Delete Task", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                // Remove notification before deleting task
                TaskNotificationService.shared.removeReminder(forTaskId: task.id)
                taskStore.deleteTask(task)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this task?")
        }
    }

    private static let detailDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy"
        return formatter
    }()

    private static let detailTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private var detailDateLabel: String {
        TaskDetailView.detailDateFormatter.string(from: task.startTime)
    }

    private var timeRangeLabel: String {
        let formatter = TaskDetailView.detailTimeFormatter
        return "\(formatter.string(from: task.startTime)) – \(formatter.string(from: task.endTime))"
    }

    private var dateStatusLabel: String? {
        task.startTime.isToday ? "Today" : nil
    }

    private var alertsTitle: String {
        let count = task.reminderOption == nil ? 0 : 1
        if count == 0 {
            return "Alerts"
        }
        return count == 1 ? "1 Alert" : "\(count) Alerts"
    }

    private var alertsDetail: String {
        task.reminderOption ?? "None"
    }

    private func addSubtask() {
        let trimmed = newSubtaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        task.addSubtask(trimmed)
        newSubtaskTitle = ""
        HapticManager.shared.selection()
    }
}

private struct TaskDetailHeader: View {
    let task: TaskItem
    @Binding var title: String
    let timeRange: String
    @Binding var showColorPicker: Bool
    @Binding var showDeleteConfirmation: Bool
    let onClose: () -> Void

    @FocusState private var isTitleFocused: Bool

    private var pillHeight: CGFloat {
        DS.Sizes.taskPillLarge + DS.Spacing.xxxl
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xl) {
            HStack {
                Button {
                    HapticManager.shared.buttonTapped()
                    onClose()
                } label: {
                    HeaderActionButton(systemName: "xmark", backgroundColor: task.color.color)
                }
                .accessibilityLabel("Close")
                .accessibilityHint("Closes task details")

                Spacer()

                Menu {
                    Button {
                        // Coming soon
                    } label: {
                        Label("Duplicate", systemImage: "doc.on.doc")
                    }
                    .disabled(true)

                    Button {
                        // Coming soon
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .disabled(true)

                    Button {
                        // Coming soon
                    } label: {
                        Label("Pin to Top", systemImage: "pin")
                    }
                    .disabled(true)

                    Button {
                        // Coming soon
                    } label: {
                        Label("Move to...", systemImage: "folder")
                    }
                    .disabled(true)

                    Button {
                        // Coming soon
                    } label: {
                        Label("Skip Once", systemImage: "pause.circle")
                    }
                    .disabled(true)

                    Button {
                        // Coming soon
                    } label: {
                        Label("Copy Link", systemImage: "link")
                    }
                    .disabled(true)

                    Divider()

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    HeaderActionButton(systemName: "ellipsis", backgroundColor: task.color.color)
                }
                .accessibilityLabel("More options")
                .accessibilityHint("Shows more actions")
            }

            HStack(alignment: .top, spacing: DS.Spacing.lg) {
                TaskDetailPill(task: task, height: pillHeight)
                    .overlay(alignment: .bottomLeading) {
                        Button {
                            withAnimation(DS.Animation.quick) {
                                showColorPicker.toggle()
                            }
                        } label: {
                            Text("🎨")
                                .scaledFont(size: 16, relativeTo: .callout)
                                .frame(width: DS.Sizes.taskPillSmall, height: DS.Sizes.taskPillSmall)
                                .background(DS.Colors.surfacePrimary)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(task.color.color, lineWidth: DS.Spacing.xs / 2)
                                )
                                .shadowResting()
                        }
                        .buttonStyle(.plain)
                        .offset(x: -DS.Spacing.sm, y: DS.Spacing.sm)
                        .accessibilityLabel("Choose color")
                        .accessibilityHint("Shows color options")
                    }
                    .overlay(alignment: .topLeading) {
                        if showColorPicker {
                            TaskDetailColorPicker(selectedColor: task.color) { color in
                                task.colorName = color.rawValue
                                task.updatedAt = Date()
                                HapticManager.shared.colorSelected()
                                withAnimation(DS.Animation.quick) {
                                    showColorPicker = false
                                }
                            }
                            .offset(x: 0, y: pillHeight + DS.Spacing.md)
                            .transition(.scale.combined(with: .opacity))
                            .zIndex(1)
                        }
                    }
                    .animation(DS.Animation.quick, value: showColorPicker)

                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text("\(timeRange) (\(task.durationFormatted))")
                        .scaledFont(size: 14, weight: .medium, design: .monospaced, relativeTo: .callout)
                        .foregroundStyle(task.color.color.opacity(0.7))

                    TextField("Task name", text: $title)
                        .scaledFont(size: 24, weight: .bold, relativeTo: .title2)
                        .foregroundStyle(task.color.color)
                        .focused($isTitleFocused)
                        .onChange(of: title) { _, newValue in
                            task.title = newValue
                            task.updatedAt = Date()
                        }
                        .overlay(alignment: .bottomLeading) {
                            Rectangle()
                                .fill(isTitleFocused ? task.color.color : .clear)
                                .frame(height: DS.Spacing.xs / 2)
                        }
                        .accessibilityLabel("Task title")
                        .accessibilityHint("Edit the task title")
                }
                .padding(.top, DS.Spacing.xs)

                Spacer()

                Button {
                    task.toggleCompletion()
                    HapticManager.shared.notification(task.isCompleted ? .success : .warning)
                } label: {
                    ZStack {
                        Circle()
                            .stroke(
                                task.isCompleted ? DS.Colors.success : task.color.color,
                                lineWidth: DS.Spacing.xs / 2
                            )
                            .frame(width: DS.Spacing.xxxl, height: DS.Spacing.xxxl)

                        if task.isCompleted {
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
                .accessibilityLabel(task.isCompleted ? "Mark task incomplete" : "Mark task complete")
                .accessibilityHint("Toggles task completion")
            }
        }
        .padding(.horizontal, DS.Spacing.xl)
        .padding(.top, DS.Spacing.xxxl)
        .padding(.bottom, DS.Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(task.color.lightColor)
        .overlay(alignment: .leading) {
            VerticalDashedLine()
                .stroke(
                    style: StrokeStyle(
                        lineWidth: DS.Spacing.xs / 2,
                        dash: [DS.Spacing.sm, DS.Spacing.sm]
                    )
                )
                .foregroundStyle(task.color.color.opacity(0.3))
                .frame(width: DS.Spacing.xs)
                .frame(maxHeight: .infinity)
                .padding(.leading, DS.Spacing.xxxl)
                .padding(.vertical, DS.Spacing.sm)
        }
    }
}

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

private struct TaskDetailPill: View {
    let task: TaskItem
    let height: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DS.Radius.xxl, style: .continuous)
                .fill(task.color.color)
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
                .stroke(task.color.color.saturated(by: 1.2), lineWidth: 1.5)
                .frame(width: DS.Sizes.taskPillLarge, height: height)

            Text(task.icon)
                .scaledFont(size: DS.Sizes.taskPillLarge * 0.5, relativeTo: .title2)
        }
        .shadowColored(task.color.color)
        .opacity(task.isCompleted ? 0.65 : 1)
    }
}

private struct TaskDetailColorPicker: View {
    let selectedColor: TaskColor
    let onSelect: (TaskColor) -> Void

    private let columns = Array(
        repeating: GridItem(.flexible(minimum: DS.Spacing.xxxl), spacing: DS.Spacing.sm),
        count: 4
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: DS.Spacing.sm) {
            ForEach(TaskColor.allCases) { color in
                Button {
                    onSelect(color)
                } label: {
                    Circle()
                        .fill(color.color)
                        .frame(width: DS.Spacing.xxxl, height: DS.Spacing.xxxl)
                        .overlay {
                            if selectedColor == color {
                                Circle()
                                    .stroke(DS.Colors.surfacePrimary, lineWidth: DS.Spacing.xs / 2)
                            }
                        }
                        .scaleEffect(selectedColor == color ? 1.1 : 1)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(color.displayName)
                .accessibilityHint("Selects \(color.displayName)")
            }
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xl, style: .continuous))
        .shadowLifted()
    }
}

private struct TaskDetailInfoRow: View {
    let systemName: String
    let title: String
    let trailingText: String?
    let trailingTint: Color
    let accentColor: Color
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
                    .foregroundStyle(DS.Colors.textPrimary)

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

private struct TaskDetailSubtaskRow: View {
    let subtask: Subtask
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
            .accessibilityLabel(subtask.isCompleted ? "Mark subtask incomplete" : "Mark subtask complete")
            .accessibilityHint(subtask.title)

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

private struct TaskDetailDeleteButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.sm) {
                Image(systemName: "trash")
                    .scaledFont(size: 16, weight: .semibold, relativeTo: .callout)
                    .foregroundStyle(DS.Colors.danger)

                Text("Delete Task")
                    .scaledFont(size: 16, weight: .semibold, relativeTo: .body)
                    .foregroundStyle(DS.Colors.danger)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Spacing.lg)
            .background(DS.Colors.dangerLight)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xxl, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Delete task")
        .accessibilityHint("Deletes this task")
    }
}

private struct VerticalDashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

#Preview {
    let task = TaskItem(
        title: "Gym Workout",
        icon: "🏋️",
        colorName: "sage",
        startTime: Date(),
        duration: 3600,
        energyLevel: 4
    )
    task.addSubtask("Warm up - 10 min")
    task.addSubtask("Strength training")

    return TaskDetailView(task: task)
        .environment(TaskStore())
}
