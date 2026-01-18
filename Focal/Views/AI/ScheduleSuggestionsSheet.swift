import SwiftUI

struct ScheduleSuggestionsSheet: View {
    @Environment(AICoordinator.self) private var ai
    @Environment(TaskStore.self) private var taskStore
    @Environment(\.dismiss) private var dismiss

    let taskTitle: String
    let duration: TimeInterval
    let energyLevel: Int
    let onSelect: (Date) -> Void

    @State private var suggestions: ScheduleSuggestions?
    @State private var isLoading: Bool = true
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    loadingView
                } else if let error {
                    errorView(error)
                } else if let suggestions {
                    suggestionsView(suggestions)
                }
            }
            .navigationTitle("AI Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .task {
            await loadSuggestions()
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: DS.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Finding best times...")
                .font(.subheadline)
                .foregroundStyle(DS.Colors.textSecondary)

            VStack(spacing: DS.Spacing.xs) {
                Text(taskTitle)
                    .font(.caption.weight(.medium))
                Text("\(Int(duration / 60)) min • Energy: \(energyLevel)/4")
                    .font(.caption)
                    .foregroundStyle(DS.Colors.textMuted)
            }
        }
    }

    // MARK: - Error View

    private func errorView(_ message: String) -> some View {
        VStack(spacing: DS.Spacing.lg) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(DS.Colors.error)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(DS.Colors.textSecondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task { await loadSuggestions() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // MARK: - Suggestions View

    private func suggestionsView(_ suggestions: ScheduleSuggestions) -> some View {
        ScrollView {
            VStack(spacing: DS.Spacing.xl) {
                // Best recommendation
                VStack(spacing: DS.Spacing.sm) {
                    Label("AI Recommendation", systemImage: "sparkles")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(DS.Colors.primary)

                    Text(suggestions.bestRecommendation)
                        .font(.subheadline)
                        .foregroundStyle(DS.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(DS.Colors.primary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))

                // Time slots
                VStack(spacing: DS.Spacing.md) {
                    ForEach(suggestions.suggestions) { slot in
                        TimeSlotCard(slot: slot) {
                            selectSlot(slot)
                        }
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Actions

    private func loadSuggestions() async {
        isLoading = true
        error = nil

        do {
            suggestions = try await ai.suggestTimeSlots(
                for: taskTitle,
                duration: Int(duration / 60),
                energyLevel: energyLevel,
                existingTasks: taskStore.tasksForSelectedDate
            )
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

    private func selectSlot(_ slot: TimeSlotSuggestion) {
        // Parse time and create date
        let components = slot.startTime.split(separator: ":").compactMap { Int($0) }
        guard components.count >= 2 else { return }

        let selectedDate = taskStore.selectedDate
        if let date = Calendar.current.date(bySettingHour: components[0], minute: components[1], second: 0, of: selectedDate) {
            onSelect(date)
            HapticManager.shared.notification(.success)
            dismiss()
        }
    }
}

// MARK: - Time Slot Card

struct TimeSlotCard: View {
    let slot: TimeSlotSuggestion
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: DS.Spacing.md) {
                // Time range
                VStack(alignment: .leading) {
                    Text(slot.startTime)
                        .font(.title3.weight(.semibold))
                    Text("to \(slot.endTime)")
                        .font(.caption)
                        .foregroundStyle(DS.Colors.textMuted)
                }

                Spacer()

                // Score indicator
                ScoreIndicator(score: slot.score)

                // Reason
                VStack(alignment: .trailing, spacing: 2) {
                    Text(slot.reason)
                        .font(.caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(2)
                }
                .frame(maxWidth: 150)

                Image(systemName: "chevron.right")
                    .foregroundStyle(DS.Colors.textMuted)
            }
            .padding()
            .background(DS.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Score Indicator

struct ScoreIndicator: View {
    let score: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(DS.Colors.textMuted.opacity(0.2), lineWidth: 4)

            Circle()
                .trim(from: 0, to: score)
                .stroke(scoreColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(Int(score * 100))")
                .font(.caption2.weight(.bold))
        }
        .frame(width: 36, height: 36)
    }

    private var scoreColor: Color {
        if score >= 0.8 { return DS.Colors.success }
        if score >= 0.6 { return DS.Colors.warning }
        return DS.Colors.error
    }
}

// MARK: - Preview

#Preview {
    ScheduleSuggestionsSheet(
        taskTitle: "Deep work session",
        duration: 90 * 60,
        energyLevel: 3
    ) { date in
        print("Selected: \(date)")
    }
    .environment(AICoordinator())
    .environment(TaskStore())
}
