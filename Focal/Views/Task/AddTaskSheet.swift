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
    @State private var recurrence: RecurrenceOption = .none
    @State private var selectedRecurrenceDays: Set<Int> = []
    @State private var reminder: ReminderOption = .none
    @State private var energyLevel = 2
    @State private var notes = ""

    @State private var showWhenPicker = false
    @State private var showIconPicker = false
    @State private var showEnergyPicker = false
    @State private var showFullColorPicker = false

    @FocusState private var isTitleFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Premium close button
                HStack {
                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(DS.Colors.surfaceSecondary)
                                .frame(width: 32, height: 32)

                            Circle()
                                .stroke(DS.Colors.borderSubtle, lineWidth: 1)
                                .frame(width: 32, height: 32)

                            Image(systemName: "xmark")
                                .scaledFont(size: 11, weight: .semibold, relativeTo: .caption)
                                .foregroundStyle(DS.Colors.textSecondary)
                        }
                        .shadowResting()
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close")
                }
                .padding(.horizontal, DS.Spacing.xl)
                .padding(.top, DS.Spacing.md)
                .padding(.bottom, DS.Spacing.xs)

                ScrollView {
                    VStack(spacing: DS.Spacing.lg) {
                        // Editable preview card with circular color picker
                        EditableTaskPreviewCardWithColors(
                            title: $title,
                            icon: selectedIcon,
                            selectedColor: $selectedColor,
                            time: selectedTime,
                            duration: selectedDuration,
                            isTitleFocused: $isTitleFocused,
                            onIconPickerTap: { showIconPicker = true },
                            onColorMoreTap: { showFullColorPicker = true },
                            onTitleChange: { newValue in
                                updateIconAndColor(for: newValue)
                            }
                        )
                        .padding(.horizontal, DS.Spacing.xl)

                        // When section
                        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                            Text("WHEN")
                                .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                                .foregroundStyle(DS.Colors.textSecondary)

                            Button {
                                showWhenPicker = true
                            } label: {
                                HStack(spacing: DS.Spacing.sm) {
                                    Text("📅")
                                        .scaledFont(size: 16, relativeTo: .body)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("When?")
                                            .scaledFont(size: 11, weight: .medium, relativeTo: .caption2)
                                            .foregroundStyle(DS.Colors.textSecondary)

                                        Text(whenSummary)
                                            .scaledFont(size: 14, weight: .medium, relativeTo: .callout)
                                            .foregroundStyle(DS.Colors.textPrimary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                                        .foregroundStyle(DS.Colors.textSecondary)
                                }
                                .padding(DS.Spacing.md)
                                .background(DS.Colors.surfacePrimary)
                                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                            }
                            .buttonStyle(.plain)
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

                        // Energy
                        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                            Text("ENERGY")
                                .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                                .foregroundStyle(DS.Colors.textSecondary)

                            SettingRow(
                                icon: selectedEnergyIcon,
                                title: "Energy",
                                value: selectedEnergyLabel
                            ) {
                                showEnergyPicker = true
                            }
                            .accessibilityLabel("Energy level")
                            .accessibilityValue(selectedEnergyLabel)
                            .accessibilityHint("Opens energy picker")
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
                                .background(DS.Colors.surfacePrimary)
                                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                                .overlay {
                                    if notes.isEmpty {
                                        Text("Add notes...")
                                            .foregroundStyle(DS.Colors.textTertiary)
                                            .padding(DS.Spacing.lg)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                            .allowsHitTesting(false)
                                    }
                                }
                        }
                        .padding(.horizontal, DS.Spacing.xl)
                        .padding(.bottom, DS.Spacing.md)
                    }
                    .padding(.top, DS.Spacing.lg)
                }

                // Create button - Pinned to bottom, always visible
                VStack(spacing: 0) {
                    Divider()

                    Button {
                        createTask()
                    } label: {
                        Text("Create Task")
                            .scaledFont(size: 16, weight: .semibold, relativeTo: .body)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(title.isEmpty ? DS.Colors.borderStrong : DS.Colors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                    }
                    .disabled(title.isEmpty)
                    .padding(.horizontal, DS.Spacing.xl)
                    .padding(.vertical, DS.Spacing.lg)
                    .background(DS.Colors.bgPrimary)
                }
            }
            .background(DS.Colors.bgPrimary)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showIconPicker) {
            IconPickerView(selectedIcon: $selectedIcon) {
                showIconPicker = false
            }
        }
        .sheet(isPresented: $showWhenPicker) {
            WhenPickerSheet(
                selectedDate: $selectedDate,
                selectedTime: $selectedTime,
                selectedDuration: $selectedDuration,
                recurrence: $recurrence,
                selectedRecurrenceDays: $selectedRecurrenceDays
            )
        }
        .sheet(isPresented: $showEnergyPicker) {
            EnergyPickerSheet(selectedLevel: $energyLevel)
        }
        .sheet(isPresented: $showFullColorPicker) {
            FullColorPickerSheet(selectedColor: $selectedColor)
        }
        .onAppear {
            if let hour = presetHour {
                selectedTime = Date().withTime(hour: hour)
            }
            isTitleFocused = true
        }
    }

    private var selectedEnergy: EnergyLevel {
        EnergyLevel(rawValue: energyLevel) ?? .moderate
    }

    private var selectedEnergyLabel: String {
        selectedEnergy.label
    }

    private var selectedEnergyIcon: String {
        selectedEnergy.icon
    }

    private var whenSummary: String {
        let dateText = selectedDate.formattedDate // "Today" | "Tomorrow" | "Mon, 5 Jan"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let timeText = timeFormatter.string(from: selectedTime)

        let hours = Int(selectedDuration) / 3600
        let minutes = Int(selectedDuration) % 3600 / 60
        var durationText = ""
        if hours > 0 && minutes > 0 {
            durationText = "\(hours)h \(minutes)m"
        } else if hours > 0 {
            durationText = "\(hours)h"
        } else {
            durationText = "\(minutes)m"
        }

        let recurrenceText = recurrence == .none ? "" : " · \(recurrence.rawValue)"
        return "\(dateText), \(timeText) · \(durationText)\(recurrenceText)"
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
            recurrenceOption: recurrence == .none ? nil : recurrence.rawValue,
            repeatDays: recurrence == .custom ? Array(selectedRecurrenceDays) : [],
            reminderOption: reminder == .none ? nil : reminder.rawValue,
            energyLevel: energyLevel,
            notes: notes.isEmpty ? nil : notes
        )

        taskStore.addTask(task)

        // Schedule notification if reminder is set
        if reminder != .none {
            Task {
                await TaskNotificationService.shared.scheduleReminder(for: task)
            }
        }

        HapticManager.shared.notification(.success)
        dismiss()
    }
}

// MARK: - Editable Task Preview Card With Colors
struct EditableTaskPreviewCardWithColors: View {
    @Binding var title: String
    let icon: String
    @Binding var selectedColor: TaskColor
    let time: Date
    let duration: TimeInterval
    var isTitleFocused: FocusState<Bool>.Binding
    let onIconPickerTap: () -> Void
    let onColorMoreTap: () -> Void
    let onTitleChange: (String) -> Void

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Icon picker button
            Button {
                onIconPickerTap()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: DS.Radius.md)
                        .fill(selectedColor.color)

                    RoundedRectangle(cornerRadius: DS.Radius.md)
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

                    RoundedRectangle(cornerRadius: DS.Radius.md)
                        .stroke(selectedColor.color.saturated(by: 1.2), lineWidth: 1.5)

                    Text(icon)
                        .scaledFont(size: 20, relativeTo: .title3)
                }
                .frame(width: 40, height: 40)
                .shadowColored(selectedColor.color)
            }
            .accessibilityLabel("Choose icon")
            .accessibilityValue(icon)
            .accessibilityHint("Opens icon picker")

            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                // Editable title
                TextField("Task name", text: $title)
                    .scaledFont(size: 16, weight: .semibold, relativeTo: .body)
                    .foregroundStyle(DS.Colors.textPrimary)
                    .focused(isTitleFocused)
                    .onChange(of: title) { _, newValue in
                        onTitleChange(newValue)
                    }

                HStack(spacing: DS.Spacing.xs) {
                    Text("✨")
                        .scaledFont(size: 12, relativeTo: .caption)

                    Text("\(time.formattedTime) · \(duration.formattedDuration)")
                        .scaledFont(size: 12, relativeTo: .caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                }
            }

            Spacer()

            // Circular color picker
            CircularColorPicker(
                selectedColor: $selectedColor,
                onMoreTap: onColorMoreTap
            )
        }
        .padding(DS.Spacing.lg)
        .background(selectedColor.lightColor)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
    }
}

// MARK: - Circular Color Picker
struct CircularColorPicker: View {
    @Binding var selectedColor: TaskColor
    let onMoreTap: () -> Void

    private let displayedColors: [TaskColor] = [.sage, .sky, .coral, .amber, .lavender, .rose]
    private let circleRadius: CGFloat = 35

    var body: some View {
        ZStack {
            // Color circles arranged in a circle
            ForEach(Array(displayedColors.enumerated()), id: \.element) { index, color in
                let angle = Angle(degrees: Double(index) * 60.0)
                let x = cos(angle.radians) * circleRadius
                let y = sin(angle.radians) * circleRadius

                Button {
                    HapticManager.shared.colorSelected()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedColor = color
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(color.color)
                            .frame(width: 24, height: 24)

                        if selectedColor == color {
                            Circle()
                                .stroke(.white, lineWidth: 2)
                                .frame(width: 20, height: 20)
                        }
                    }
                    .shadowResting()
                }
                .buttonStyle(.plain)
                .offset(x: x, y: y)
            }

            // More button in center
            Button {
                HapticManager.shared.selection()
                onMoreTap()
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    DS.Colors.surfaceSecondary,
                                    DS.Colors.surfacePrimary
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 32, height: 32)

                    Circle()
                        .stroke(DS.Colors.borderSubtle, lineWidth: 1)
                        .frame(width: 32, height: 32)

                    Image(systemName: "plus")
                        .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                }
                .shadowResting()
            }
            .buttonStyle(.plain)
        }
        .frame(width: 90, height: 90)
    }
}

// MARK: - Editable Task Preview Card
struct EditableTaskPreviewCard: View {
    @Binding var title: String
    let icon: String
    let color: TaskColor
    let time: Date
    let duration: TimeInterval
    var isTitleFocused: FocusState<Bool>.Binding
    let onIconPickerTap: () -> Void
    let onTitleChange: (String) -> Void

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Icon picker button
            Button {
                onIconPickerTap()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: DS.Radius.md)
                        .fill(color.color)

                    RoundedRectangle(cornerRadius: DS.Radius.md)
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

                    RoundedRectangle(cornerRadius: DS.Radius.md)
                        .stroke(color.color.saturated(by: 1.2), lineWidth: 1.5)

                    Text(icon)
                        .scaledFont(size: 20, relativeTo: .title3)
                }
                .frame(width: 40, height: 40)
                .shadowColored(color.color)
            }
            .accessibilityLabel("Choose icon")
            .accessibilityValue(icon)
            .accessibilityHint("Opens icon picker")

            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                // Editable title
                TextField("Task name", text: $title)
                    .scaledFont(size: 16, weight: .semibold, relativeTo: .body)
                    .foregroundStyle(DS.Colors.textPrimary)
                    .focused(isTitleFocused)
                    .onChange(of: title) { _, newValue in
                        onTitleChange(newValue)
                    }

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

                RoundedRectangle(cornerRadius: DS.Radius.md)
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

                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .stroke(color.color.saturated(by: 1.2), lineWidth: 1.5)

                Text(icon)
                    .scaledFont(size: 20, relativeTo: .title3)
            }
            .frame(width: 40, height: 40)
            .shadowColored(color.color)

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

// MARK: - Compact Color Picker
struct CompactColorPicker: View {
    @Binding var selectedColor: TaskColor
    let onMoreTap: () -> Void

    private let displayedColors: [TaskColor] = [.sage, .sky, .coral, .amber, .lavender, .rose]

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            // First 3 colors
            ForEach(displayedColors.prefix(3)) { color in
                ColorButton(color: color, isSelected: selectedColor == color) {
                    HapticManager.shared.colorSelected()
                    selectedColor = color
                }
            }

            // More button in the middle
            Button {
                onMoreTap()
            } label: {
                ZStack {
                    Circle()
                        .fill(DS.Colors.surfaceSecondary)
                        .frame(width: 32, height: 32)

                    Image(systemName: "plus.circle.fill")
                        .scaledFont(size: 16, weight: .semibold, relativeTo: .body)
                        .foregroundStyle(DS.Colors.textSecondary)
                }
                .frame(width: DS.Sizes.minTouchTarget, height: DS.Sizes.minTouchTarget)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("More colors")
            .accessibilityHint("Opens full color picker")

            // Last 3 colors
            ForEach(displayedColors.suffix(3)) { color in
                ColorButton(color: color, isSelected: selectedColor == color) {
                    HapticManager.shared.colorSelected()
                    selectedColor = color
                }
            }
        }
    }
}

// MARK: - Color Button
struct ColorButton: View {
    let color: TaskColor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.color)
                    .frame(width: 32, height: 32)

                if isSelected {
                    Circle()
                        .stroke(.white, lineWidth: 2.5)
                        .frame(width: 24, height: 24)

                    Circle()
                        .stroke(color.color.opacity(0.3), lineWidth: 4)
                        .frame(width: 38, height: 38)
                }
            }
            .frame(width: DS.Sizes.minTouchTarget, height: DS.Sizes.minTouchTarget)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(color.displayName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Full Color Picker Sheet
struct FullColorPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedColor: TaskColor

    var body: some View {
        NavigationStack {
            VStack(spacing: DS.Spacing.xl) {
                // Color grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DS.Spacing.lg) {
                    ForEach(TaskColor.allCases) { color in
                        Button {
                            HapticManager.shared.colorSelected()
                            selectedColor = color
                            dismiss()
                        } label: {
                            VStack(spacing: DS.Spacing.sm) {
                                ZStack {
                                    Circle()
                                        .fill(color.color)
                                        .frame(width: 60, height: 60)

                                    if selectedColor == color {
                                        Circle()
                                            .stroke(.white, lineWidth: 3)
                                            .frame(width: 48, height: 48)
                                    }
                                }
                                .shadowColored(color.color)

                                Text(color.displayName)
                                    .scaledFont(size: 12, weight: .medium, relativeTo: .caption)
                                    .foregroundStyle(DS.Colors.textSecondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(DS.Spacing.xl)

                Spacer()
            }
            .background(DS.Colors.bgPrimary)
            .navigationTitle("Choose Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
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
        .background(DS.Colors.surfacePrimary)
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
                        .background(selectedDuration == preset.duration ? DS.Colors.primary : DS.Colors.surfacePrimary)
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

// MARK: - Repeat Days Picker (AddTaskSheet)
private struct AddTaskRepeatDaysPicker: View {
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
                AddTaskPresetButton(title: "Weekdays", isSelected: isWeekdays) {
                    selectedDays = Set([1, 2, 3, 4, 5])
                }

                AddTaskPresetButton(title: "Weekends", isSelected: isWeekends) {
                    selectedDays = Set([0, 6])
                }

                AddTaskPresetButton(title: "Every day", isSelected: isEveryDay) {
                    selectedDays = Set(0...6)
                }
            }
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.surfacePrimary)
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
                .background(isSelected ? DS.Colors.primary : DS.Colors.surfacePrimary)
                .clipShape(Circle())
                .frame(width: DS.Sizes.minTouchTarget, height: DS.Sizes.minTouchTarget)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preset Button (AddTaskSheet)
private struct AddTaskPresetButton: View {
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
                .background(isSelected ? DS.Colors.primary : DS.Colors.surfacePrimary)
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
                        .background(selectedReminder == option ? DS.Colors.primary : DS.Colors.surfacePrimary)
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
