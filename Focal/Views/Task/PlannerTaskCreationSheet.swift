import SwiftUI

struct PlannerTaskCreationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TaskStore.self) private var taskStore

    var presetHour: Int?

    @State private var title = ""
    @State private var selectedIcon = "@"
    @State private var selectedColor: TaskColor = .coral
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var selectedDuration: TimeInterval = 15 * 60
    @State private var recurrence: RecurrenceOption = .none
    @State private var selectedRecurrenceDays: Set<Int> = []
    @State private var reminder: ReminderOption = .none
    @State private var notes = ""
    @State private var subtasks: [PlannerSubtask] = []
    @State private var newSubtaskTitle = ""
    @State private var isCompleted = false

    @State private var showDatePicker = false
    @State private var showTimePicker = false
    @State private var showRepeatPicker = false
    @State private var showReminderPicker = false

    @FocusState private var isTitleFocused: Bool
    @FocusState private var isSubtaskFocused: Bool

    var body: some View {
        ZStack {
            DS.Colors.bgPrimary
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: DS.Spacing.xxl) {
                    PlannerTaskHeaderCard(
                        title: $title,
                        icon: selectedIcon,
                        timeRange: timeRangeLabel,
                        durationLabel: durationLabel,
                        accentColor: accentColor,
                        accentDark: accentDark,
                        isCompleted: $isCompleted,
                        isTitleFocused: $isTitleFocused,
                        onClose: {
                            HapticManager.shared.buttonTapped()
                            dismiss()
                        },
                        onToggleComplete: {
                            HapticManager.shared.selection()
                            isCompleted.toggle()
                        }
                    )
                    .padding(.horizontal, DS.Spacing.xl)

                    PlannerSection(title: "SCHEDULE") {
                        VStack(spacing: 0) {
                            PlannerActionRow(
                                icon: "calendar",
                                title: "Date",
                                value: fullDateLabel,
                                accentColor: accentColor
                            ) {
                                HapticManager.shared.selection()
                                showDatePicker = true
                            }

                            PlannerDivider()

                            PlannerActionRow(
                                icon: "clock",
                                title: "Time",
                                value: timeRangeLabel,
                                accentColor: accentColor
                            ) {
                                HapticManager.shared.selection()
                                showTimePicker = true
                            }

                            PlannerDivider()

                            PlannerActionRow(
                                icon: "repeat",
                                title: "Repeat",
                                value: repeatSummary,
                                accentColor: accentColor
                            ) {
                                HapticManager.shared.selection()
                                showRepeatPicker = true
                            }

                            PlannerDivider()

                            PlannerActionRow(
                                icon: "bell",
                                title: "Reminder",
                                value: reminder == .none ? "None" : reminder.rawValue,
                                accentColor: accentColor
                            ) {
                                HapticManager.shared.selection()
                                showReminderPicker = true
                            }
                        }
                        .background(DS.Colors.surfacePrimary)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                                .stroke(DS.Colors.borderSubtle.opacity(0.6), lineWidth: DS.Sizes.hairline)
                        )
                        .shadow(color: DS.Colors.glassShadow.opacity(0.12), radius: DS.Spacing.lg, y: DS.Spacing.sm)
                    }

                    PlannerSection(title: "SUBTASKS") {
                        PlannerSubtasksCard(
                            subtasks: subtasks,
                            newSubtaskTitle: $newSubtaskTitle,
                            isSubtaskFocused: $isSubtaskFocused,
                            accentColor: accentColor,
                            onAdd: addSubtask,
                            onDelete: removeSubtask
                        )
                    }

                    PlannerSection(title: "NOTES") {
                        PlannerNotesEditor(notes: $notes)
                    }

                    PlannerContinueButton(
                        isEnabled: isTitleValid,
                        accentColor: accentColor,
                        accentDark: accentDark,
                        action: createTask
                    )
                    .padding(.horizontal, DS.Spacing.xl)
                    .padding(.bottom, DS.Spacing.xxxl)
                }
                .padding(.top, DS.Spacing.lg)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(DS.Radius.xxl)
        .sheet(isPresented: $showDatePicker) {
            PlannerDatePickerSheet(selectedDate: $selectedDate, accentColor: accentColor)
        }
        .sheet(isPresented: $showTimePicker) {
            PlannerTimePickerSheet(
                selectedTime: $selectedTime,
                selectedDuration: $selectedDuration,
                accentColor: accentColor
            )
        }
        .sheet(isPresented: $showRepeatPicker) {
            RepeatPickerSheet(
                recurrence: $recurrence,
                selectedDays: $selectedRecurrenceDays,
                accentColor: accentColor
            )
        }
        .confirmationDialog("Reminder", isPresented: $showReminderPicker) {
            ForEach(ReminderOption.allCases) { option in
                Button(option.rawValue) {
                    reminder = option
                    HapticManager.shared.selection()
                }
            }
        } message: {
            Text("Choose when to be notified.")
        }
        .onAppear {
            syncInitialTime()
            isTitleFocused = true
        }
        .onChange(of: title) { _, newValue in
            updateIconAndColor(for: newValue)
        }
    }

    private var accentColor: Color {
        selectedColor.color
    }

    private var accentDark: Color {
        selectedColor == .coral ? DS.Colors.coralDark : selectedColor.color.saturated(by: 1.2)
    }

    private var isTitleValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var timeRangeLabel: String {
        let endTime = selectedTime.addingTimeInterval(selectedDuration)
        return "\(selectedTime.formattedTime) - \(endTime.formattedTime)"
    }

    private var durationLabel: String {
        selectedDuration.formattedDuration
    }

    private var fullDateLabel: String {
        Self.fullDateFormatter.string(from: selectedDate)
    }

    private var repeatSummary: String {
        guard recurrence != .none else { return "None" }

        if recurrence == .custom {
            if selectedRecurrenceDays.isEmpty { return "Custom" }

            if selectedRecurrenceDays == Set([1, 2, 3, 4, 5]) { return "Weekdays" }
            if selectedRecurrenceDays == Set([0, 6]) { return "Weekends" }
            if selectedRecurrenceDays.count == 7 { return "Every day" }

            let days = selectedRecurrenceDays.sorted().compactMap { Weekday(rawValue: $0)?.shortName }
            return days.joined(separator: " ")
        }

        return recurrence.rawValue
    }

    private func syncInitialTime() {
        let calendar = Calendar.current
        let now = Date()
        let baseMinutes: Int

        if let presetHour {
            baseMinutes = presetHour * 60
        } else {
            baseMinutes = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
        }

        let snappedMinutes = snapToQuarterHour(baseMinutes)
        selectedTime = now.withTime(hour: snappedMinutes / 60, minute: snappedMinutes % 60)
    }

    private func snapToQuarterHour(_ minutes: Int) -> Int {
        let remainder = minutes % 15
        if remainder == 0 { return minutes }
        let rounded = minutes + (15 - remainder)
        return min(rounded, 23 * 60 + 45)
    }

    private func updateIconAndColor(for title: String) {
        guard let mapping = IconMapper.shared.findMatch(for: title) else { return }
        withAnimation(DS.Animation.quick) {
            selectedIcon = mapping.icon
            selectedColor = mapping.suggestedColor
        }
        HapticManager.shared.iconSelected()
    }

    private func addSubtask() {
        let trimmed = newSubtaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        subtasks.append(PlannerSubtask(title: trimmed))
        newSubtaskTitle = ""
        HapticManager.shared.selection()
    }

    private func removeSubtask(_ subtask: PlannerSubtask) {
        subtasks.removeAll { $0.id == subtask.id }
        HapticManager.shared.deleted()
    }

    private func createTask() {
        guard isTitleValid else { return }

        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
        let startTime = calendar.date(
            bySettingHour: timeComponents.hour ?? 9,
            minute: timeComponents.minute ?? 0,
            second: 0,
            of: selectedDate
        ) ?? selectedDate

        let task = TaskItem(
            title: title,
            icon: selectedIcon,
            colorName: selectedColor.rawValue,
            startTime: startTime,
            duration: selectedDuration,
            recurrenceOption: recurrence == .none ? nil : recurrence.rawValue,
            repeatDays: recurrence == .custom ? Array(selectedRecurrenceDays) : [],
            reminderOption: reminder == .none ? nil : reminder.rawValue,
            notes: notes.isEmpty ? nil : notes
        )

        taskStore.addTask(task)
        subtasks.forEach { task.addSubtask($0.title) }

        // Schedule notification if reminder is set
        if reminder != .none {
            Task {
                await TaskNotificationService.shared.scheduleReminder(for: task)
            }
        }

        HapticManager.shared.notification(.success)
        dismiss()
    }

    private static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy"
        return formatter
    }()
}

private struct PlannerSubtask: Identifiable {
    let id = UUID()
    let title: String
}

private struct PlannerTaskHeaderCard: View {
    @Binding var title: String
    let icon: String
    let timeRange: String
    let durationLabel: String
    let accentColor: Color
    let accentDark: Color
    @Binding var isCompleted: Bool
    var isTitleFocused: FocusState<Bool>.Binding
    let onClose: () -> Void
    let onToggleComplete: () -> Void

    var body: some View {
        let closeButtonSize = DS.Sizes.iconButtonSize - DS.Spacing.sm
        let iconSize = DS.Spacing.xxxl * 2
        let completionSize = DS.Spacing.xl + DS.Spacing.sm

        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: DS.Radius.xxl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [accentColor, accentDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: accentColor.opacity(0.3), radius: DS.Spacing.xxl, y: DS.Spacing.sm)

            Button(action: onClose) {
                ZStack {
                    Circle()
                        .fill(DS.Colors.glassHighlight)
                        .frame(width: closeButtonSize, height: closeButtonSize)

                    Image(systemName: "xmark")
                        .scaledFont(size: 14, weight: .semibold, relativeTo: .caption)
                        .foregroundStyle(DS.Colors.glassTextPrimary)
                }
            }
            .buttonStyle(.plain)
            .padding(.top, DS.Spacing.md)
            .padding(.leading, DS.Spacing.md)
            .accessibilityLabel("Close")
            .accessibilityHint("Dismisses task creation")

            HStack(spacing: DS.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(DS.Colors.glassTextPrimary)

                    Circle()
                        .stroke(DS.Colors.glassTextPrimary.opacity(0.3), lineWidth: DS.Sizes.hairline * 3)

                    Text(icon)
                        .scaledFont(size: 28, weight: .semibold, relativeTo: .title2)
                        .foregroundStyle(accentColor)
                }
                .frame(width: iconSize, height: iconSize)
                .shadow(color: DS.Colors.glassShadow, radius: DS.Spacing.md, y: DS.Spacing.sm)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text("\(timeRange) (\(durationLabel))")
                        .scaledFont(size: 14, weight: .medium, relativeTo: .caption)
                        .foregroundStyle(DS.Colors.glassTextSecondary)

                    TextField("Task name", text: $title)
                        .scaledFont(size: 20, weight: .semibold, relativeTo: .title3)
                        .foregroundStyle(DS.Colors.glassTextPrimary)
                        .focused(isTitleFocused)
                        .submitLabel(.done)
                        .accessibilityLabel("Task title")
                        .accessibilityHint("Enter a task name")

                    HStack(spacing: DS.Spacing.xs) {
                        Image(systemName: "hand.thumbsup.fill")
                            .scaledFont(size: 12, weight: .semibold, relativeTo: .caption2)
                            .foregroundStyle(DS.Colors.glassTextSecondary)

                        Text("1")
                            .scaledFont(size: 14, weight: .medium, relativeTo: .caption)
                            .foregroundStyle(DS.Colors.glassTextSecondary)
                    }
                }

                Spacer()

                Button(action: onToggleComplete) {
                    ZStack {
                        Circle()
                            .stroke(DS.Colors.glassTextPrimary.opacity(0.5), lineWidth: DS.Sizes.hairline * 2)
                            .frame(width: completionSize, height: completionSize)

                        if isCompleted {
                    Circle()
                        .fill(DS.Colors.success)
                        .frame(width: completionSize, height: completionSize)

                            Image(systemName: "checkmark")
                                .scaledFont(size: 11, weight: .bold, relativeTo: .caption2)
                                .foregroundStyle(DS.Colors.glassTextPrimary)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Completion")
                .accessibilityHint("Marks the task as completed")
                .accessibilityValue(isCompleted ? "Completed" : "Not completed")
            }
            .padding(.top, DS.Spacing.xxxl + DS.Spacing.lg)
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.bottom, DS.Spacing.lg)
        }
    }
}

private struct PlannerSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text(title)
                .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                .foregroundStyle(DS.Colors.textSecondary)

            content
        }
        .padding(.horizontal, DS.Spacing.xl)
    }
}

private struct PlannerDivider: View {
    var inset: CGFloat = DS.Spacing.xxxl + DS.Spacing.md

    var body: some View {
        Rectangle()
            .fill(DS.Colors.divider)
            .frame(height: DS.Sizes.hairline)
            .padding(.leading, inset)
    }
}

private struct PlannerActionRow: View {
    let icon: String
    let title: String
    let value: String
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: DS.Radius.sm)
                        .fill(DS.Colors.surfaceSecondary)
                        .frame(width: DS.Spacing.xxxl, height: DS.Spacing.xxxl)

                    Image(systemName: icon)
                        .scaledFont(size: 14, weight: .semibold, relativeTo: .caption)
                        .foregroundStyle(accentColor)
                }

                Text(title)
                    .scaledFont(size: 16, weight: .medium, relativeTo: .body)
                    .foregroundStyle(DS.Colors.textPrimary)

                Spacer()

                Text(value)
                    .scaledFont(size: 14, weight: .medium, relativeTo: .caption)
                    .foregroundStyle(DS.Colors.textSecondary)

                Image(systemName: "chevron.right")
                    .scaledFont(size: 12, weight: .semibold, relativeTo: .caption2)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
            .padding(DS.Spacing.lg)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityValue(value)
        .accessibilityHint("Opens \(title.lowercased()) picker")
    }
}

private struct PlannerSubtasksCard: View {
    let subtasks: [PlannerSubtask]
    @Binding var newSubtaskTitle: String
    var isSubtaskFocused: FocusState<Bool>.Binding
    let accentColor: Color
    let onAdd: () -> Void
    let onDelete: (PlannerSubtask) -> Void

    var body: some View {
        VStack(spacing: DS.Spacing.sm) {
            if subtasks.isEmpty {
                Text("No subtasks yet")
                    .scaledFont(size: 14, weight: .medium, relativeTo: .caption)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 0) {
                    ForEach(subtasks) { subtask in
                        PlannerSubtaskRow(title: subtask.title, onDelete: {
                            onDelete(subtask)
                        })

                        if subtask.id != subtasks.last?.id {
                            PlannerDivider(inset: 0)
                        }
                    }
                }
            }

            HStack(spacing: DS.Spacing.sm) {
                TextField("Add subtask", text: $newSubtaskTitle)
                    .scaledFont(size: 15, weight: .medium, relativeTo: .subheadline)
                    .foregroundStyle(DS.Colors.textPrimary)
                    .focused(isSubtaskFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        onAdd()
                    }

                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                        .foregroundStyle(DS.Colors.glassTextPrimary)
                        .frame(width: DS.Spacing.xxxl, height: DS.Spacing.xxxl)
                        .background(accentColor)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled(newSubtaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityLabel("Add subtask")
                .accessibilityHint("Adds this subtask")
            }
            .padding(.top, subtasks.isEmpty ? 0 : DS.Spacing.sm)
        }
        .padding(DS.Spacing.lg)
        .background(DS.Colors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .stroke(DS.Colors.borderSubtle.opacity(0.6), lineWidth: DS.Sizes.hairline)
        )
        .shadow(color: DS.Colors.glassShadow.opacity(0.1), radius: DS.Spacing.lg, y: DS.Spacing.sm)
    }
}

private struct PlannerSubtaskRow: View {
    let title: String
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            Circle()
                .stroke(DS.Colors.borderSubtle, lineWidth: DS.Sizes.hairline * 2)
                .frame(width: 22, height: 22)

            Text(title)
                .scaledFont(size: 15, weight: .medium, relativeTo: .subheadline)
                .foregroundStyle(DS.Colors.textPrimary)

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .scaledFont(size: 18, relativeTo: .headline)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Delete subtask")
        }
        .padding(.vertical, DS.Spacing.sm)
    }
}

private struct PlannerNotesEditor: View {
    @Binding var notes: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $notes)
                .scrollContentBackground(.hidden)
                .scaledFont(size: 15, relativeTo: .body)
                .foregroundStyle(DS.Colors.textPrimary)
                .padding(DS.Spacing.md)
                .frame(minHeight: 100)

            if notes.isEmpty {
                Text("Add notes...")
                    .scaledFont(size: 14, weight: .medium, relativeTo: .caption)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .padding(DS.Spacing.lg)
            }
        }
        .background(DS.Colors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .stroke(DS.Colors.borderSubtle.opacity(0.6), lineWidth: DS.Sizes.hairline)
        )
        .shadow(color: DS.Colors.glassShadow.opacity(0.1), radius: DS.Spacing.lg, y: DS.Spacing.sm)
    }
}

private struct PlannerDatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    let accentColor: Color

    var body: some View {
        NavigationStack {
            VStack(spacing: DS.Spacing.xl) {
                HStack {
                    Spacer()

                    Button("Today") {
                        HapticManager.shared.selection()
                        selectedDate = Date()
                    }
                    .scaledFont(size: 14, weight: .medium, relativeTo: .callout)
                    .foregroundStyle(accentColor)
                }
                .padding(.horizontal, DS.Spacing.xl)

                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(accentColor)
                    .padding(.horizontal, DS.Spacing.md)

                Spacer()
            }
            .padding(.top, DS.Spacing.lg)
            .background(DS.Colors.bgPrimary)
            .navigationTitle("Date")
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

private struct PlannerTimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTime: Date
    @Binding var selectedDuration: TimeInterval
    let accentColor: Color

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    private let dialHeight: CGFloat = 120
    private let dialScale: CGFloat = 0.8

    private var endTimeBinding: Binding<Date> {
        Binding(
            get: { selectedTime.addingTimeInterval(selectedDuration) },
            set: { newEndTime in
                let minimumDuration = DurationPreset.fifteenMin.duration
                let updatedDuration = max(newEndTime.timeIntervalSince(selectedTime), minimumDuration)
                selectedDuration = updatedDuration
            }
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DS.Spacing.md) {
                    GeometryReader { proxy in
                        let dialSpacing = DS.Spacing.sm
                        let dialWidth = (proxy.size.width - dialSpacing) / 2

                        HStack(alignment: .top, spacing: dialSpacing) {
                            timeDial(
                                title: "Start",
                                selection: $selectedTime,
                                width: dialWidth,
                                accessibilityLabel: "Start time",
                                accessibilityHint: "Select a start time"
                            )

                            timeDial(
                                title: "End",
                                selection: endTimeBinding,
                                width: dialWidth,
                                accessibilityLabel: "End time",
                                accessibilityHint: "Select an end time"
                            )
                        }
                        .frame(width: proxy.size.width, height: dialHeight + DS.Spacing.lg, alignment: .top)
                    }
                    .frame(height: dialHeight + DS.Spacing.lg)
                    .padding(.horizontal, DS.Spacing.md)

                    Text("Duration \(selectedDuration.formattedDuration)")
                        .scaledFont(size: 14, weight: .medium, relativeTo: .callout)
                        .foregroundStyle(DS.Colors.textSecondary)

                    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                        Text("Duration")
                            .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                            .foregroundStyle(DS.Colors.textSecondary)

                        LazyVGrid(columns: columns, spacing: DS.Spacing.sm) {
                            ForEach(DurationPreset.allCases) { preset in
                                let isSelected = selectedDuration == preset.duration
                                Button {
                                    selectedDuration = preset.duration
                                    HapticManager.shared.selection()
                                } label: {
                                    Text(preset.label)
                                        .scaledFont(size: 14, weight: isSelected ? .semibold : .medium, relativeTo: .callout)
                                        .foregroundStyle(isSelected ? DS.Colors.glassTextPrimary : DS.Colors.textSecondary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, DS.Spacing.sm)
                                .background(isSelected ? accentColor : DS.Colors.surfaceSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous))
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Duration \(preset.label)")
                                .accessibilityAddTraits(isSelected ? .isSelected : [])
                            }
                        }
                    }
                    .padding(DS.Spacing.lg)
                    .background(DS.Colors.surfacePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                            .stroke(DS.Colors.borderSubtle.opacity(0.6), lineWidth: DS.Sizes.hairline)
                    )
                }
                .padding(.top, DS.Spacing.md)
                .padding(.bottom, DS.Spacing.xxl)
            }
                .background(DS.Colors.bgPrimary)
            .navigationTitle("Time & Duration")
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

    private func timeDial(
        title: String,
        selection: Binding<Date>,
        width: CGFloat,
        accessibilityLabel: String,
        accessibilityHint: String
    ) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Text(title)
                .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                .foregroundStyle(DS.Colors.textSecondary)

            ZStack {
                RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [DS.Colors.surfacePrimary, DS.Colors.surfaceSecondary],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                DatePicker(title, selection: selection, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .tint(accentColor)
                    .frame(height: dialHeight)
                    .scaleEffect(dialScale)
                    .frame(width: width, height: dialHeight)
                    .clipped()
                    .accessibilityLabel(accessibilityLabel)
                    .accessibilityHint(accessibilityHint)

                RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [accentColor.opacity(0.18), accentColor.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: DS.Sizes.hairline
                    )
                    .padding(DS.Spacing.sm)
                    .allowsHitTesting(false)
            }
            .frame(width: width, height: dialHeight)
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                    .stroke(DS.Colors.borderSubtle.opacity(0.7), lineWidth: DS.Sizes.hairline)
            )
            .shadow(color: DS.Colors.glassShadow.opacity(0.08), radius: DS.Spacing.sm, y: DS.Spacing.xs)
        }
    }
}

struct RepeatPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var recurrence: RecurrenceOption
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
                            ForEach(RecurrenceOption.allCases) { option in
                                RecurrencePillButton(
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
                        RepeatDaysPicker(selectedDays: $selectedDays, accentColor: accentColor)
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

struct RecurrencePillButton: View {
    let title: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .scaledFont(size: 13, weight: isSelected ? .semibold : .medium, relativeTo: .callout)
                .foregroundStyle(isSelected ? DS.Colors.glassTextPrimary : DS.Colors.textSecondary)
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.sm)
                .background(isSelected ? accentColor : DS.Colors.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct RepeatDaysPicker: View {
    @Binding var selectedDays: Set<Int>
    let accentColor: Color

    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            HStack(spacing: DS.Spacing.sm) {
                ForEach(Weekday.allCases) { day in
                    DaySelectionButton(
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

            HStack(spacing: DS.Spacing.sm) {
                PresetButton(title: "Weekdays", isSelected: selectedDays == Set([1, 2, 3, 4, 5]), accentColor: accentColor) {
                    selectedDays = Set([1, 2, 3, 4, 5])
                    HapticManager.shared.selection()
                }

                PresetButton(title: "Weekends", isSelected: selectedDays == Set([0, 6]), accentColor: accentColor) {
                    selectedDays = Set([0, 6])
                    HapticManager.shared.selection()
                }

                PresetButton(title: "Every day", isSelected: selectedDays.count == 7, accentColor: accentColor) {
                    selectedDays = Set(0...6)
                    HapticManager.shared.selection()
                }
            }
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.lg)
                .stroke(DS.Colors.borderSubtle.opacity(0.6), lineWidth: DS.Sizes.hairline)
        )
    }
}

struct DaySelectionButton: View {
    let label: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .scaledFont(size: 13, weight: .medium, relativeTo: .callout)
                .foregroundStyle(isSelected ? DS.Colors.glassTextPrimary : DS.Colors.textSecondary)
                .frame(width: 32, height: 32)
                .background(isSelected ? accentColor : DS.Colors.surfaceSecondary)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

struct PresetButton: View {
    let title: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .scaledFont(size: 12, weight: .medium, relativeTo: .caption)
                .foregroundStyle(isSelected ? DS.Colors.glassTextPrimary : DS.Colors.textSecondary)
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.xs)
                .background(isSelected ? accentColor : DS.Colors.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
        }
        .buttonStyle(.plain)
    }
}

private struct PlannerContinueButton: View {
    let isEnabled: Bool
    let accentColor: Color
    let accentDark: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Continue")
                .scaledFont(size: 18, weight: .semibold, relativeTo: .body)
                .foregroundStyle(DS.Colors.glassTextPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DS.Spacing.lg)
                .background(
                    LinearGradient(
                        colors: [accentColor, accentDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous))
                .shadow(color: accentColor.opacity(0.4), radius: DS.Spacing.lg, y: DS.Spacing.sm)
                .opacity(isEnabled ? 1 : 0.6)
        }
        .buttonStyle(PlannerPressableButtonStyle())
        .disabled(!isEnabled)
        .accessibilityLabel("Continue")
        .accessibilityHint("Creates the task")
    }
}

private struct PlannerPressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(DS.Animation.quick, value: configuration.isPressed)
    }
}

#Preview {
    PlannerTaskCreationSheet()
        .environment(TaskStore())
}
