import SwiftUI

struct RescheduleBanner: View {
    let suggestion: RescheduleSuggestion
    let onAccept: () -> Void
    let onDismiss: () -> Void

    @State private var showFullDetails: Bool = false

    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            // Header
            HStack {
                Image(systemName: "clock.badge.exclamationmark")
                    .foregroundStyle(DS.Colors.warning)

                Text("Schedule Disruption")
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(DS.Colors.textMuted)
                }
            }

            // Strategy
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(suggestion.strategy)
                    .font(.subheadline)
                    .foregroundStyle(DS.Colors.textPrimary)

                Text(suggestion.summary)
                    .font(.caption)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .lineLimit(showFullDetails ? nil : 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Trade-offs (expandable)
            if let tradeOffs = suggestion.tradeOffs, !tradeOffs.isEmpty {
                Button {
                    withAnimation(DS.Animation.spring) {
                        showFullDetails.toggle()
                    }
                } label: {
                    HStack {
                        Text(showFullDetails ? "Hide details" : "Show trade-offs")
                            .font(.caption)
                        Image(systemName: showFullDetails ? "chevron.up" : "chevron.down")
                            .font(.caption2)
                    }
                    .foregroundStyle(DS.Colors.primary)
                }

                if showFullDetails {
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        ForEach(tradeOffs, id: \.self) { tradeOff in
                            HStack(alignment: .top, spacing: DS.Spacing.sm) {
                                Image(systemName: "exclamationmark.circle")
                                    .font(.caption)
                                    .foregroundStyle(DS.Colors.warning)
                                Text(tradeOff)
                                    .font(.caption)
                                    .foregroundStyle(DS.Colors.textSecondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                }
            }

            // Adjustments preview
            if !suggestion.adjustments.isEmpty {
                HStack(spacing: DS.Spacing.sm) {
                    ForEach(suggestion.adjustments.prefix(3)) { adjustment in
                        AdjustmentChip(adjustment: adjustment)
                    }
                    if suggestion.adjustments.count > 3 {
                        Text("+\(suggestion.adjustments.count - 3)")
                            .font(.caption2)
                            .foregroundStyle(DS.Colors.textMuted)
                    }
                }
            }

            // Action buttons
            HStack(spacing: DS.Spacing.md) {
                Button("Dismiss") {
                    onDismiss()
                }
                .font(.subheadline)
                .foregroundStyle(DS.Colors.textSecondary)

                Spacer()

                Button {
                    onAccept()
                } label: {
                    Label("Apply Changes", systemImage: "checkmark")
                        .font(.subheadline.weight(.medium))
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg)
                .fill(DS.Colors.cardBackground)
                .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
        )
        .padding(.horizontal)
    }
}

// MARK: - Adjustment Chip

struct AdjustmentChip: View {
    let adjustment: TaskAdjustment

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: actionIcon)
                .font(.caption2)
            Text(adjustment.taskTitle)
                .font(.caption2)
                .lineLimit(1)
        }
        .padding(.horizontal, DS.Spacing.sm)
        .padding(.vertical, 4)
        .background(actionColor.opacity(0.15))
        .foregroundStyle(actionColor)
        .clipShape(Capsule())
    }

    private var actionIcon: String {
        switch adjustment.action.lowercased() {
        case "postpone", "defer", "delay":
            return "arrow.right.circle"
        case "shorten", "reduce":
            return "minus.circle"
        case "cancel", "skip", "remove":
            return "xmark.circle"
        case "prioritize", "move up":
            return "arrow.up.circle"
        default:
            return "arrow.triangle.2.circlepath"
        }
    }

    private var actionColor: Color {
        switch adjustment.action.lowercased() {
        case "cancel", "skip", "remove":
            return DS.Colors.error
        case "postpone", "defer", "delay":
            return DS.Colors.warning
        case "prioritize", "move up":
            return DS.Colors.success
        default:
            return DS.Colors.info
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        RescheduleBanner(
            suggestion: RescheduleSuggestion(
                strategy: "Prioritize the meeting",
                adjustments: [
                    TaskAdjustment(
                        taskTitle: "Deep work",
                        action: "postpone",
                        newTime: "15:00",
                        newDurationMinutes: nil,
                        reason: "Meeting takes priority"
                    ),
                    TaskAdjustment(
                        taskTitle: "Email review",
                        action: "shorten",
                        newTime: nil,
                        newDurationMinutes: 15,
                        reason: "Reduce to fit schedule"
                    )
                ],
                summary: "Your 2pm meeting will push deep work to 3pm. Consider shortening email review.",
                tradeOffs: ["Less time for deep work", "May need to finish emails tomorrow"]
            ),
            onAccept: { print("Accepted") },
            onDismiss: { print("Dismissed") }
        )
        Spacer()
    }
    .background(DS.Colors.background)
}
