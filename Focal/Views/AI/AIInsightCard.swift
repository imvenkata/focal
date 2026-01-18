import SwiftUI

struct AIInsightCard: View {
    let insight: AIInsight
    let onDismiss: () -> Void

    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            // Header
            HStack(alignment: .top, spacing: DS.Spacing.sm) {
                Image(systemName: insight.icon)
                    .font(.title3)
                    .foregroundStyle(typeColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(insight.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(DS.Colors.textPrimary)

                    Text(insight.description)
                        .font(.caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                        .lineLimit(isExpanded ? nil : 2)
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(DS.Colors.textMuted)
                        .padding(6)
                        .background(DS.Colors.surfaceSecondary)
                        .clipShape(Circle())
                }
            }

            // Action (expandable)
            if let action = insight.action, !action.isEmpty {
                Button {
                    withAnimation(DS.Animation.spring) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(isExpanded ? "Hide suggestion" : "See suggestion")
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    }
                    .font(.caption)
                    .foregroundStyle(DS.Colors.primary)
                }

                if isExpanded {
                    HStack(alignment: .top, spacing: DS.Spacing.sm) {
                        Image(systemName: priorityIcon)
                            .font(.caption)
                            .foregroundStyle(priorityColor)
                            .frame(width: 16)

                        Text(action)
                            .font(.caption)
                            .foregroundStyle(DS.Colors.textSecondary)
                    }
                    .padding(DS.Spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(DS.Colors.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg)
                .fill(typeColor.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.lg)
                        .stroke(typeColor.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private var typeColor: Color {
        switch insight.type {
        case "celebration", "success", "productivity":
            return DS.Colors.success
        case "tip", "suggestion", "timing":
            return DS.Colors.info
        case "pattern", "streak", "estimation":
            return DS.Colors.primary
        case "warning", "caution":
            return DS.Colors.warning
        default:
            return DS.Colors.primary
        }
    }

    private var priorityIcon: String {
        switch insight.priority {
        case "high":
            return "exclamationmark.circle.fill"
        case "medium":
            return "arrow.right.circle.fill"
        default:
            return "circle.fill"
        }
    }

    private var priorityColor: Color {
        switch insight.priority {
        case "high":
            return DS.Colors.error
        case "medium":
            return DS.Colors.warning
        default:
            return DS.Colors.textMuted
        }
    }
}

// MARK: - Recommendation Row

// RecommendationRow struct removed as per instructions

// MARK: - AI Insights Container View

struct AIInsightsView: View {
    @Environment(AICoordinator.self) private var ai
    @Environment(TaskStore.self) private var taskStore

    @State private var insights: AIInsights?
    @State private var isLoading: Bool = false
    @State private var dismissedInsights: Set<String> = []

    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            if isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading insights...")
                        .font(.caption)
                        .foregroundStyle(DS.Colors.textMuted)
                }
                .padding()
            } else if let insights {
                ForEach(visibleInsights) { insight in
                    AIInsightCard(insight: insight) {
                        withAnimation(DS.Animation.spring) {
                            _ = dismissedInsights.insert(insight.id.uuidString)
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                        removal: .opacity.combined(with: .move(edge: .trailing))
                    ))
                }
            }
        }
        .task {
            await loadInsights()
        }
    }

    private var visibleInsights: [AIInsight] {
        insights?.insights.filter { !dismissedInsights.contains($0.id.uuidString) } ?? []
    }

    private func loadInsights() async {
        guard ai.isConfigured else { return }

        isLoading = true

        // Use available task data
        let tasksToday = taskStore.tasksForSelectedDate
        let completedToday = tasksToday.filter { $0.isCompleted }.count
        let scheduledToday = tasksToday.count
        let completionRate = scheduledToday > 0 ? Double(completedToday) / Double(scheduledToday) : 0.0

        insights = try? await ai.generateInsights(
            completionRate: completionRate,
            tasksCompleted: completedToday,
            tasksScheduled: scheduledToday,
            averageDuration: 45 * 60, // TODO: Calculate real average
            topCategories: ["Work", "Personal", "Health"]
        )

        isLoading = false
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: DS.Spacing.lg) {
        AIInsightCard(
            insight: AIInsight(
                type: "productivity",
                title: "Great week! 🎉",
                description: "You completed 85% of your scheduled tasks this week, your best performance in a month.",
                action: "Try scheduling one more task tomorrow",
                priority: "medium"
            ),
            onDismiss: { print("Dismissed") }
        )

        AIInsightCard(
            insight: AIInsight(
                type: "timing",
                title: "Morning productivity",
                description: "You complete tasks 40% faster before noon. Consider scheduling important work earlier.",
                action: nil,
                priority: "low"
            ),
            onDismiss: { print("Dismissed") }
        )

        AIInsightCard(
            insight: AIInsight(
                type: "warning",
                title: "Overloaded schedule",
                description: "You have 8 hours of tasks scheduled with only 6 hours available today.",
                action: "Move 2 tasks to tomorrow",
                priority: "high"
            ),
            onDismiss: { print("Dismissed") }
        )
    }
    .padding()
    .background(DS.Colors.background)
}
