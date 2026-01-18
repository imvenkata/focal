import SwiftUI

struct BrainDumpView: View {
    @Environment(AICoordinator.self) private var ai
    @Environment(TodoStore.self) private var todoStore
    @Environment(\.dismiss) private var dismiss

    @State private var rawText: String = ""
    @State private var isProcessing: Bool = false
    @State private var result: OrganizedBrainDump?
    @State private var error: String?
    @State private var showResults: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if showResults, let result {
                    BrainDumpResultView(
                        result: result,
                        onAddSelected: addSelectedTasks,
                        onBack: { showResults = false }
                    )
                } else {
                    inputView
                }
            }
            .navigationTitle("Brain Dump")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var inputView: some View {
        VStack(spacing: DS.Spacing.xl) {
            // Header
            VStack(spacing: DS.Spacing.sm) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Dump everything on your mind")
                    .font(.headline)

                Text("Type freely. AI will organize it into tasks.")
                    .font(.subheadline)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
            .padding(.top, DS.Spacing.xl)

            // Text input
            ZStack(alignment: .topLeading) {
                TextEditor(text: $rawText)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .padding(DS.Spacing.md)

                if rawText.isEmpty {
                    Text("Ask anything...")
                        .font(.body)
                        .foregroundStyle(DS.Colors.textMuted)
                        .padding(DS.Spacing.md)
                        .padding(.top, 8)
                        .allowsHitTesting(false)
                }
            }
            .frame(height: 200)
            .background(DS.Colors.surfaceSecondary)
            .glassEffect(in: RoundedRectangle(cornerRadius: DS.Radius.lg))
            .padding(.horizontal)

            // Error message
            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(DS.Colors.error)
                    .padding(.horizontal)
            }

            // Action button
            Button {
                Task { await processBrainDump() }
            } label: {
                HStack(spacing: DS.Spacing.sm) {
                    if isProcessing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "sparkles")
                    }
                    Text(isProcessing ? "Organizing..." : "Organize with AI")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: DS.Sizes.buttonHeight)
                .background(rawText.isEmpty || isProcessing ? DS.Colors.textMuted : DS.Colors.primary)
                .glassEffect(in: RoundedRectangle(cornerRadius: DS.Radius.lg))
            }
            .disabled(rawText.isEmpty || isProcessing)
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    private func processBrainDump() async {
        guard ai.isConfigured else {
            error = "AI not configured. Go to Settings to set up."
            return
        }

        isProcessing = true
        error = nil
        HapticManager.shared.impact(.medium)

        do {
            result = try await ai.organizeBrainDump(rawText)

            withAnimation(DS.Animation.spring) {
                showResults = true
            }

            HapticManager.shared.notification(.success)

        } catch let llmError as LLMError {
            error = llmError.localizedDescription
            HapticManager.shared.notification(.error)
        } catch {
            self.error = error.localizedDescription
            HapticManager.shared.notification(.error)
        }

        isProcessing = false
    }

    private func addSelectedTasks(_ tasks: [BrainDumpTask]) {
        for task in tasks {
            let todo = task.toTodoItem()
            todoStore.addTodo(todo)
        }

        HapticManager.shared.notification(.success)
        dismiss()
    }
}

// MARK: - Brain Dump Result View

struct BrainDumpResultView: View {
    let result: OrganizedBrainDump
    let onAddSelected: ([BrainDumpTask]) -> Void
    let onBack: () -> Void

    @State private var tasks: [BrainDumpTask]
    @State private var selectedIds: Set<UUID> = []

    init(result: OrganizedBrainDump, onAddSelected: @escaping ([BrainDumpTask]) -> Void, onBack: @escaping () -> Void) {
        self.result = result
        self.onAddSelected = onAddSelected
        self.onBack = onBack
        self._tasks = State(initialValue: result.tasks)
        self._selectedIds = State(initialValue: Set(result.tasks.map { $0.id }))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Summary header
            VStack(spacing: DS.Spacing.sm) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(result.tasks.count) tasks found")
                            .font(.title3.weight(.semibold))

                        Text(result.summary)
                            .font(.caption)
                            .foregroundStyle(DS.Colors.textSecondary)
                    }

                    Spacer()

                    Button(selectedIds.count == tasks.count ? "Deselect All" : "Select All") {
                        if selectedIds.count == tasks.count {
                            selectedIds.removeAll()
                        } else {
                            selectedIds = Set(tasks.map { $0.id })
                        }
                    }
                    .font(.caption)
                }

                // Warnings
                if let warnings = result.warnings, !warnings.isEmpty {
                    ForEach(warnings, id: \.self) { warning in
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(DS.Colors.warning)
                            Text(warning)
                                .font(.caption)
                        }
                        .padding(DS.Spacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(DS.Colors.warning.opacity(0.1))
                        .glassEffect(in: RoundedRectangle(cornerRadius: DS.Radius.sm))
                    }
                }
            }
            .padding()

            Divider()

            // Task list by priority
            ScrollView {
                LazyVStack(spacing: DS.Spacing.md) {
                    ForEach(["high", "medium", "low", "none"], id: \.self) { priority in
                        let priorityTasks = tasks.filter { $0.priority == priority }

                        if !priorityTasks.isEmpty {
                            PrioritySection(
                                priority: priority,
                                tasks: priorityTasks,
                                selectedIds: $selectedIds
                            )
                        }
                    }
                }
                .padding()
            }

            // Bottom action bar
            VStack(spacing: DS.Spacing.sm) {
                Button {
                    let selected = tasks.filter { selectedIds.contains($0.id) }
                    onAddSelected(selected)
                } label: {
                    Text("Add \(selectedIds.count) Tasks")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: DS.Sizes.buttonHeight)
                        .background(selectedIds.isEmpty ? DS.Colors.textMuted : DS.Colors.primary)
                        .glassEffect(in: RoundedRectangle(cornerRadius: DS.Radius.lg))
                }
                .disabled(selectedIds.isEmpty)

                Button("Back to Edit", action: onBack)
                    .font(.subheadline)
                    .foregroundStyle(DS.Colors.primary)
            }
            .padding()
            .background(DS.Colors.cardBackground)
        }
    }
}

// MARK: - Priority Section

struct PrioritySection: View {
    let priority: String
    let tasks: [BrainDumpTask]
    @Binding var selectedIds: Set<UUID>

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack {
                Image(systemName: priorityIcon)
                    .foregroundStyle(priorityColor)
                Text(priority.capitalized + " Priority")
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text("\(tasks.count)")
                    .font(.caption)
                    .foregroundStyle(DS.Colors.textMuted)
            }

            ForEach(tasks) { task in
                BrainDumpTaskRow(
                    task: task,
                    isSelected: selectedIds.contains(task.id),
                    onToggle: {
                        if selectedIds.contains(task.id) {
                            selectedIds.remove(task.id)
                        } else {
                            selectedIds.insert(task.id)
                        }
                    }
                )
            }
        }
    }

    private var priorityIcon: String {
        switch priority {
        case "high": return "exclamationmark.circle.fill"
        case "medium": return "arrow.up.circle.fill"
        case "low": return "arrow.down.circle.fill"
        default: return "minus.circle.fill"
        }
    }

    private var priorityColor: Color {
        switch priority {
        case "high": return DS.Colors.error
        case "medium": return DS.Colors.warning
        case "low": return DS.Colors.info
        default: return DS.Colors.textMuted
        }
    }
}

// MARK: - Brain Dump Task Row

struct BrainDumpTaskRow: View {
    let task: BrainDumpTask
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: DS.Spacing.md) {
                // Checkbox
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? DS.Colors.primary : DS.Colors.textMuted)

                // Icon
                Text(task.icon)

                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.subheadline)
                        .foregroundStyle(DS.Colors.textPrimary)

                    HStack(spacing: DS.Spacing.sm) {
                        if let date = task.date {
                            Text(date)
                        }
                        if let duration = task.durationMinutes {
                            Text("\(duration)m")
                        }
                        Text(task.category)
                    }
                    .font(.caption)
                    .foregroundStyle(DS.Colors.textMuted)
                }

                Spacer()
            }
            .padding(DS.Spacing.md)
            .background(isSelected ? DS.Colors.primary.opacity(0.05) : DS.Colors.surfaceSecondary)
            .glassEffect(in: RoundedRectangle(cornerRadius: DS.Radius.md))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    BrainDumpView()
        .environment(AICoordinator())
        .environment(TodoStore())
}
