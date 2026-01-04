import SwiftUI

struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TaskStore.self) private var taskStore

    var presetHour: Int?

    @State private var title = ""
    @State private var selectedIcon = "📝"
    @State private var selectedColor: TaskColor = .sage
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var selectedDuration: TimeInterval = 3600
    @State private var isRoutine = false
    @State private var selectedRepeatDays: Set<Int> = []
    @State private var reminder: ReminderOption = .none
    @State private var energyLevel = 2
    @State private var notes = ""

    @State private var showDatePicker = false
    @State private var showTimePicker = false

    @FocusState private var isTitleFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Spacing.xl) {
                    // Live preview card
                    TaskPreviewCard(
                        title: title.isEmpty ? "Task name" : title,
                        icon: selectedIcon,
                        color: selectedColor,
                        time: selectedTime,
                        duration: selectedDuration
                    )
                    .padding(.horizontal, DS.Spacing.xl)

                    // Title input
                    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                        Text("TASK NAME")
                            .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                            .foregroundStyle(DS.Colors.textSecondary)

                        HStack(spacing: DS.Spacing.md) {
                            // Icon picker button
                            Button {
                                // Show icon picker
                            } label: {
                                Text(selectedIcon)
                                    .scaledFont(size: 24, relativeTo: .title2)
                                    .frame(width: 44, height: 44)
                                    .background(selectedColor.lightColor)
                                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                            }

                            TextField("What do you need to do?", text: $title)
                                .scaledFont(size: 16, relativeTo: .body)
                                .focused($isTitleFocused)
                                .onChange(of: title) { _, newValue in
                                    updateIconAndColor(for: newValue)
                                }
                        }
                        .padding(DS.Spacing.md)
                        .background(DS.Colors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                    }
                    .padding(.horizontal, DS.Spacing.xl)

                    // Color picker
                    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                        Text("COLOR")
                            .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                            .foregroundStyle(DS.Colors.textSecondary)

                        ColorPickerRow(selectedColor: $selectedColor)
                    }
                    .padding(.horizontal, DS.Spacing.xl)

                    // When section
                    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                        Text("WHEN")
                            .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                            .foregroundStyle(DS.Colors.textSecondary)

                        VStack(spacing: 0) {
                            // Date
                            SettingRow(
                                icon: "📅",
                                title: "Date",
                                value: selectedDate.formattedDate
                            ) {
                                showDatePicker = true
                            }

                            Divider()
                                .padding(.leading, 52)

                            // Time
                            SettingRow(
                                icon: "⏰",
                                title: "Start Time",
                                value: selectedTime.formattedTime
                            ) {
                                showTimePicker = true
                            }
                        }
                        .background(DS.Colors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                    }
                    .padding(.horizontal, DS.Spacing.xl)

                    // Duration
                    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                        Text("DURATION")
                            .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                            .foregroundStyle(DS.Colors.textSecondary)

                        DurationPickerRow(selectedDuration: $selectedDuration)
                    }
                    .padding(.horizontal, DS.Spacing.xl)

                    // Repeat
                    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                        HStack {
                            Text("REPEAT")
                                .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                                .foregroundStyle(DS.Colors.textSecondary)

                            Spacer()

                            Toggle("", isOn: $isRoutine)
                                .labelsHidden()
                                .tint(DS.Colors.sky)
                        }

                        if isRoutine {
                            RepeatDaysPicker(selectedDays: $selectedRepeatDays)
                        }
                    }
                    .padding(.horizontal, DS.Spacing.xl)

                    // Reminder
                    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                        Text("REMINDER")
                            .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                            .foregroundStyle(DS.Colors.textSecondary)

                        ReminderPickerRow(selectedReminder: $reminder)
                    }
                    .padding(.horizontal, DS.Spacing.xl)

                    // Notes
                    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                        Text("NOTES")
                            .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                            .foregroundStyle(DS.Colors.textSecondary)

                        TextEditor(text: $notes)
                            .frame(minHeight: 80)
                            .padding(DS.Spacing.md)
                            .background(DS.Colors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                            .overlay {
                                if notes.isEmpty {
                                    Text("Add notes...")
                                        .foregroundStyle(DS.Colors.textSecondary)
                                        .padding(DS.Spacing.lg)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                        .allowsHitTesting(false)
                                }
                            }
                    }
                    .padding(.horizontal, DS.Spacing.xl)

                    // Create button
                    Button {
                        createTask()
                    } label: {
                        Text("Create Task")
                            .scaledFont(size: 16, weight: .semibold, relativeTo: .body)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(title.isEmpty ? DS.Colors.slate : DS.Colors.sky)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                    }
                    .disabled(title.isEmpty)
                    .padding(.horizontal, DS.Spacing.xl)
                    .padding(.bottom, DS.Spacing.xxl)
                }
                .padding(.top, DS.Spacing.lg)
            }
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
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(selectedDate: $selectedDate)
        }
        .sheet(isPresented: $showTimePicker) {
            TimePickerSheet(selectedTime: $selectedTime, duration: $selectedDuration)
        }
        .onAppear {
            if let hour = presetHour {
                selectedTime = Date().withTime(hour: hour)
            }
            isTitleFocused = true
        }
    }

    private func updateIconAndColor(for title: String) {
        if let mapping = IconMapper.shared.findMatch(for: title) {
            withAnimation(DS.Animation.quick) {
                selectedIcon = mapping.icon
                selectedColor = mapping.suggestedColor
            }
            HapticManager.shared.iconSelected()
        }
    }

    private func createTask() {
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
            isRoutine: isRoutine,
            repeatDays: Array(selectedRepeatDays),
            reminderOption: reminder == .none ? nil : reminder.rawValue,
            energyLevel: energyLevel,
            notes: notes.isEmpty ? nil : notes
        )

        taskStore.addTask(task)
        HapticManager.shared.notification(.success)
        dismiss()
    }
}

// MARK: - Task Preview Card
struct TaskPreviewCard: View {
    let title: String
    let icon: String
    let color: TaskColor
    let time: Date
    let duration: TimeInterval

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Icon pill
            ZStack {
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .fill(color.color)
                    .frame(width: 48, height: 48)

                Text(icon)
                    .scaledFont(size: 24, relativeTo: .title2)
            }

            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(title)
                    .scaledFont(size: 16, weight: .semibold, relativeTo: .body)
                    .foregroundStyle(DS.Colors.textPrimary)

                HStack(spacing: DS.Spacing.xs) {
                    Text("✨")
                        .scaledFont(size: 12, relativeTo: .caption)

                    Text("\(time.formattedTime) · \(duration.formattedDuration)")
                        .scaledFont(size: 12, relativeTo: .caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                }
            }

            Spacer()
        }
        .padding(DS.Spacing.lg)
        .background(color.lightColor)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
    }
}

// MARK: - Color Picker Row
struct ColorPickerRow: View {
    @Binding var selectedColor: TaskColor

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.sm) {
                ForEach(TaskColor.allCases) { color in
                    Button {
                        HapticManager.shared.colorSelected()
                        selectedColor = color
                    } label: {
                        ZStack {
                            Circle()
                                .fill(color.color)
                                .frame(width: 32, height: 32)

                            if selectedColor == color {
                                Circle()
                                    .stroke(.white, lineWidth: 2)
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .frame(width: DS.Sizes.minTouchTarget, height: DS.Sizes.minTouchTarget)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(color.displayName)
                    .accessibilityAddTraits(selectedColor == color ? .isSelected : [])
                }
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
        }
        .background(DS.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
    }
}

// MARK: - Duration Picker Row
struct DurationPickerRow: View {
    @Binding var selectedDuration: TimeInterval

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            ForEach(DurationPreset.allCases) { preset in
                Button {
                    HapticManager.shared.selection()
                    selectedDuration = preset.duration
                } label: {
                    Text(preset.label)
                        .scaledFont(size: 14, weight: selectedDuration == preset.duration ? .semibold : .regular, relativeTo: .callout)
                        .foregroundStyle(selectedDuration == preset.duration ? .white : DS.Colors.textPrimary)
                        .padding(.horizontal, DS.Spacing.md)
                        .padding(.vertical, DS.Spacing.sm)
                        .background(selectedDuration == preset.duration ? DS.Colors.sky : DS.Colors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Setting Row
struct SettingRow: View {
    let icon: String
    let title: String
    let value: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(icon)
                    .scaledFont(size: 18, relativeTo: .headline)
                    .frame(width: 32)

                Text(title)
                    .scaledFont(size: 16, relativeTo: .body)
                    .foregroundStyle(DS.Colors.textPrimary)

                Spacer()

                Text(value)
                    .scaledFont(size: 16, relativeTo: .body)
                    .foregroundStyle(DS.Colors.textSecondary)

                Image(systemName: "chevron.right")
                    .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
            .padding(DS.Spacing.lg)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Repeat Days Picker
struct RepeatDaysPicker: View {
    @Binding var selectedDays: Set<Int>

    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            // Day buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.sm) {
                    ForEach(Weekday.allCases) { day in
                        DayButton(
                            day: day,
                            isSelected: selectedDays.contains(day.rawValue)
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
            }

            // Preset buttons
            HStack(spacing: DS.Spacing.sm) {
                PresetButton(title: "Weekdays", isSelected: isWeekdays) {
                    selectedDays = Set([1, 2, 3, 4, 5])
                }

                PresetButton(title: "Weekends", isSelected: isWeekends) {
                    selectedDays = Set([0, 6])
                }

                PresetButton(title: "Every day", isSelected: isEveryDay) {
                    selectedDays = Set(0...6)
                }
            }
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
    }

    private var isWeekdays: Bool {
        selectedDays == Set([1, 2, 3, 4, 5])
    }

    private var isWeekends: Bool {
        selectedDays == Set([0, 6])
    }

    private var isEveryDay: Bool {
        selectedDays == Set(0...6)
    }
}

// MARK: - Day Button
struct DayButton: View {
    let day: Weekday
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(day.shortName)
                .scaledFont(size: 14, weight: .medium, relativeTo: .callout)
                .foregroundStyle(isSelected ? .white : DS.Colors.textPrimary)
                .frame(width: 36, height: 36)
                .background(isSelected ? DS.Colors.sky : DS.Colors.background)
                .clipShape(Circle())
                .frame(width: DS.Sizes.minTouchTarget, height: DS.Sizes.minTouchTarget)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preset Button
struct PresetButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .scaledFont(size: 12, weight: .medium, relativeTo: .caption)
                .foregroundStyle(isSelected ? .white : DS.Colors.textSecondary)
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.sm)
                .background(isSelected ? DS.Colors.sky : DS.Colors.background)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Reminder Picker Row
struct ReminderPickerRow: View {
    @Binding var selectedReminder: ReminderOption

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            ForEach(ReminderOption.allCases) { option in
                Button {
                    HapticManager.shared.selection()
                    selectedReminder = option
                } label: {
                    Text(option.rawValue)
                        .scaledFont(size: 12, weight: selectedReminder == option ? .semibold : .regular, relativeTo: .caption)
                        .foregroundStyle(selectedReminder == option ? .white : DS.Colors.textPrimary)
                        .padding(.horizontal, DS.Spacing.md)
                        .padding(.vertical, DS.Spacing.sm)
                        .background(selectedReminder == option ? DS.Colors.sky : DS.Colors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    AddTaskSheet()
        .environment(TaskStore())
}
