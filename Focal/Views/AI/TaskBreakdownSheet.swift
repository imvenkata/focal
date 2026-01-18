import SwiftUI

struct TaskBreakdownSheet: View {
    @Environment(AICoordinator.self) private var ai
    @Environment(\.dismiss) private var dismiss

    let taskTitle: String
    let onAccept: ([Subtask]) -> Void

    @State private var breakdown: TaskBreakdown?
    @State private var isLoading: Bool = true
    @State private var error: String?
    @State private var editedSubtasks: [GeneratedSubtask] = []

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    loadingView
                } else if let error {
                    errorView(error)
                } else if breakdown != nil {
                    resultView
                }
            }
            .navigationTitle("Break Down Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .task {
            await loadBreakdown()
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: DS.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)

            Text("AI is breaking down your task...")
                .font(.subheadline)
                .foregroundStyle(DS.Colors.textSecondary)

            Text("\"" + taskTitle + "\"")
                .font(.caption)
                .foregroundStyle(DS.Colors.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    // MARK: - Error View

    private func errorView(_ message: String) -> some View {
        VStack(spacing: DS.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(DS.Colors.error)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(DS.Colors.textSecondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task { await loadBreakdown() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // MARK: - Result View

    private var resultView: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: DS.Spacing.xl) {
                    // Original task
                    VStack(spacing: DS.Spacing.sm) {
                        Text("Breaking down:")
                            .font(.caption)
                            .foregroundStyle(DS.Colors.textMuted)

                        Text(taskTitle)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                    }
                    .padding()

                    // Total time estimate
                    if let breakdown {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(DS.Colors.primary)
                            Text("Total: \(breakdown.totalDurationMinutes) minutes")
                                .font(.subheadline.weight(.medium))
                        }
                        .padding(DS.Spacing.md)
                        .background(DS.Colors.primary.opacity(0.1))
                        .glassEffect(in: RoundedRectangle(cornerRadius: DS.Radius.md))
                    }

                    // Subtasks
                    VStack(spacing: DS.Spacing.sm) {
                        ForEach(Array(editedSubtasks.enumerated()), id: \.element.id) { index, subtask in
                            BreakdownSubtaskRow(
                                subtask: subtask,
                                index: index + 1
                            )
                        }
                    }
                    .padding(.horizontal)

                    // Notes
                    if let notes = breakdown?.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                            Label("AI Notes", systemImage: "lightbulb.fill")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(DS.Colors.textMuted)

                            Text(notes)
                                .font(.caption)
                                .foregroundStyle(DS.Colors.textSecondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(DS.Colors.surfaceSecondary)
                        .glassEffect(in: RoundedRectangle(cornerRadius: DS.Radius.md))
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }

            // Accept button
            VStack {
                Button {
                    acceptBreakdown()
                } label: {
                    Text("Add \(editedSubtasks.count) Subtasks")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: DS.Sizes.buttonHeight)
                        .background(DS.Colors.primary)
                        .glassEffect(in: RoundedRectangle(cornerRadius: DS.Radius.lg))
                }
            }
            .padding()
            .background(DS.Colors.cardBackground)
        }
    }

    // MARK: - Actions

    private func loadBreakdown() async {
        isLoading = true
        error = nil

        do {
            breakdown = try await ai.breakdownTask(taskTitle)
            editedSubtasks = breakdown?.subtasks ?? []
            HapticManager.shared.notification(.success)
        } catch let llmError as LLMError {
            error = llmError.localizedDescription
            HapticManager.shared.notification(.error)
        } catch {
            self.error = error.localizedDescription
            HapticManager.shared.notification(.error)
        }

        isLoading = false
    }

    private func acceptBreakdown() {
        let subtasks = editedSubtasks.map { generated in
            Subtask(title: generated.title)
        }
        onAccept(subtasks)
        HapticManager.shared.notification(.success)
        dismiss()
    }
}

// MARK: - Subtask Row

struct BreakdownSubtaskRow: View {
    let subtask: GeneratedSubtask
    let index: Int

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            Text("\(index)")
                .font(.caption.weight(.medium))
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(DS.Colors.primary)
                .glassEffect(in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(subtask.title)
                    .font(.subheadline)

                Text("\(subtask.durationMinutes) min")
                    .font(.caption)
                    .foregroundStyle(DS.Colors.textMuted)
            }

            Spacer()

            if subtask.isOptional == true {
                Text("Optional")
                    .font(.caption2)
                    .foregroundStyle(DS.Colors.textMuted)
                    .padding(.horizontal, DS.Spacing.sm)
                    .padding(.vertical, 2)
                    .background(DS.Colors.surfaceSecondary)
                    .glassEffect(in: Capsule())
            }
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.cardBackground)
        .glassEffect(in: RoundedRectangle(cornerRadius: DS.Radius.md))
    }
}

// MARK: - Preview

#Preview {
    TaskBreakdownSheet(taskTitle: "Plan birthday party") { subtasks in
        print("Added \(subtasks.count) subtasks")
    }
    .environment(AICoordinator())
}
