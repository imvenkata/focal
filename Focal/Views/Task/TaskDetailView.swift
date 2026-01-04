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
    @State private var showDeleteConfirmation = false
    @State private var newSubtaskTitle = ""

    @FocusState private var isSubtaskFieldFocused: Bool

    init(task: TaskItem) {
        self.task = task
        _title = State(initialValue: task.title)
        _notes = State(initialValue: task.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Colored header
                    TaskDetailHeader(task: task)

                    VStack(spacing: DS.Spacing.xl) {
                        // Title editing
                        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                            TextField("Task name", text: $title)
                                .scaledFont(size: 22, weight: .semibold, relativeTo: .title2)
                                .foregroundStyle(DS.Colors.textPrimary)
                                .onChange(of: title) { _, newValue in
                                    task.title = newValue
                                    task.updatedAt = Date()
                                }
                        }
                        .padding(.horizontal, DS.Spacing.xl)

                        // Info cards
                        VStack(spacing: 0) {
                            // Date
                            DetailRow(
                                icon: "📅",
                                title: task.startTime.formattedDate,
                                subtitle: "Date"
                            ) {
                                showDatePicker = true
                            }

                            Divider()
                                .padding(.leading, 52)

                            // Time
                            DetailRow(
                                icon: "⏰",
                                title: task.timeRangeFormatted,
                                subtitle: task.durationFormatted
                            ) {
                                showTimePicker = true
                            }

                            Divider()
                                .padding(.leading, 52)

                            // Energy
                            DetailRow(
                                icon: task.energyIcon,
                                title: task.energyLabel,
                                subtitle: "Energy Level"
                            ) {
                                showEnergyPicker = true
                            }
                        }
                        .background(DS.Colors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                        .padding(.horizontal, DS.Spacing.xl)

                        // Subtasks
                        VStack(alignment: .leading, spacing: DS.Spacing.md) {
                            Text("SUBTASKS")
                                .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                                .foregroundStyle(DS.Colors.textSecondary)
                                .padding(.horizontal, DS.Spacing.xl)

                            VStack(spacing: 0) {
                                ForEach(task.subtasks) { subtask in
                                    SubtaskRow(
                                        subtask: subtask,
                                        onToggle: {
                                            subtask.isCompleted.toggle()
                                            HapticManager.shared.selection()
                                        },
                                        onDelete: {
                                            task.removeSubtask(subtask)
                                            HapticManager.shared.deleted()
                                        }
                                    )

                                    if subtask.id != task.subtasks.last?.id {
                                        Divider()
                                            .padding(.leading, 52)
                                    }
                                }

                                // Add subtask field
                                HStack(spacing: DS.Spacing.md) {
                                    Image(systemName: "plus.circle")
                                        .scaledFont(size: 20, relativeTo: .title3)
                                        .foregroundStyle(DS.Colors.sky)
                                        .frame(width: 32)

                                    TextField("Add subtask", text: $newSubtaskTitle)
                                        .scaledFont(size: 16, relativeTo: .body)
                                        .focused($isSubtaskFieldFocused)
                                        .onSubmit {
                                            addSubtask()
                                        }
                                }
                                .padding(DS.Spacing.lg)
                            }
                            .background(DS.Colors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                            .padding(.horizontal, DS.Spacing.xl)
                        }

                        // Notes
                        VStack(alignment: .leading, spacing: DS.Spacing.md) {
                            Text("NOTES")
                                .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                                .foregroundStyle(DS.Colors.textSecondary)
                                .padding(.horizontal, DS.Spacing.xl)

                            TextEditor(text: $notes)
                                .frame(minHeight: 100)
                                .padding(DS.Spacing.md)
                                .background(DS.Colors.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                                .padding(.horizontal, DS.Spacing.xl)
                                .onChange(of: notes) { _, newValue in
                                    task.notes = newValue.isEmpty ? nil : newValue
                                    task.updatedAt = Date()
                                }
                                .overlay {
                                    if notes.isEmpty {
                                        Text("Add notes, meeting links...")
                                            .foregroundStyle(DS.Colors.textSecondary)
                                            .padding(.horizontal, DS.Spacing.xl + DS.Spacing.lg)
                                            .padding(.vertical, DS.Spacing.lg)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                            .allowsHitTesting(false)
                                    }
                                }
                        }

                        // Delete button
                        Button {
                            showDeleteConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Task")
                            }
                            .scaledFont(size: 16, weight: .medium, relativeTo: .body)
                            .foregroundStyle(DS.Colors.coral)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(DS.Colors.coralLight)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                        }
                        .padding(.horizontal, DS.Spacing.xl)
                        .padding(.bottom, DS.Spacing.xxl)
                    }
                    .padding(.top, DS.Spacing.xl)
                }
            }
            .background(DS.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                            .foregroundStyle(DS.Colors.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            // Duplicate
                        } label: {
                            Label("Duplicate", systemImage: "plus.square.on.square")
                        }

                        Button {
                            // Share
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }

                        Button {
                            // Pin
                        } label: {
                            Label("Pin", systemImage: "pin")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                            .foregroundStyle(DS.Colors.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
            }
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
        .confirmationDialog("Delete Task", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                taskStore.deleteTask(task)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this task?")
        }
    }

    private func addSubtask() {
        guard !newSubtaskTitle.isEmpty else { return }
        task.addSubtask(newSubtaskTitle)
        newSubtaskTitle = ""
        HapticManager.shared.selection()
    }
}

// MARK: - Task Detail Header
struct TaskDetailHeader: View {
    let task: TaskItem

    var body: some View {
        VStack(spacing: DS.Spacing.lg) {
            // Thin solid line
            Rectangle()
                .fill(DS.Colors.divider)
                .frame(width: 1, height: 40)
                .padding(.top, DS.Spacing.md)

            // Task pill
            HStack(spacing: DS.Spacing.lg) {
                TaskPinView(task: task, size: DS.Sizes.taskPillLarge)

                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(task.timeRangeFormatted)
                        .scaledFont(size: 14, weight: .medium, design: .monospaced, relativeTo: .callout)
                        .foregroundStyle(DS.Colors.textSecondary)

                    Text("(\(task.durationFormatted))")
                        .scaledFont(size: 12, relativeTo: .caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                }

                Spacer()

                // Completion checkbox
                Button {
                    task.toggleCompletion()
                    HapticManager.shared.taskCompleted()
                } label: {
                    ZStack {
                        Circle()
                            .stroke(task.isCompleted ? task.color.color : DS.Colors.divider, lineWidth: 2)
                            .frame(width: 32, height: 32)

                        if task.isCompleted {
                            Circle()
                                .fill(task.color.color)
                                .frame(width: 32, height: 32)

                            Image(systemName: "checkmark")
                                .scaledFont(size: 16, weight: .bold, relativeTo: .callout)
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(width: DS.Sizes.minTouchTarget, height: DS.Sizes.minTouchTarget)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, DS.Spacing.xl)

            // Color picker
            ColorPickerRow(selectedColor: .init(
                get: { task.color },
                set: { newColor in
                    task.colorName = newColor.rawValue
                    task.updatedAt = Date()
                }
            ))
            .padding(.horizontal, DS.Spacing.xl)
        }
        .padding(.bottom, DS.Spacing.lg)
        .background(task.color.lightColor)
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(icon)
                    .scaledFont(size: 18, relativeTo: .headline)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .scaledFont(size: 16, weight: .medium, relativeTo: .body)
                        .foregroundStyle(DS.Colors.textPrimary)

                    Text(subtitle)
                        .scaledFont(size: 12, relativeTo: .caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
            .padding(DS.Spacing.lg)
        }
        .buttonStyle(.plain)
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
