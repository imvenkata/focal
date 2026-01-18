import SwiftUI

struct AISettingsView: View {
    @Environment(AICoordinator.self) private var ai
    @Binding var showOnboarding: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Spacing.xl) {
                    // Header
                    VStack(spacing: DS.Spacing.sm) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text("AI Settings")
                            .font(.title.weight(.bold))

                        Text("Configure AI features for smarter task management")
                            .font(.subheadline)
                            .foregroundStyle(DS.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, DS.Spacing.xl)

                    // Status Card
                    statusCard
                        .padding(.horizontal)

                    // Features Section
                    featuresSection
                        .padding(.horizontal)

                    Spacer(minLength: DS.Spacing.xxl)
                }
            }
            .background(DS.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var statusCard: some View {
        VStack(spacing: DS.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text("AI Status")
                        .font(.headline)

                    HStack(spacing: DS.Spacing.xs) {
                        Circle()
                            .fill(ai.isConfigured ? DS.Colors.success : DS.Colors.warning)
                            .frame(width: 8, height: 8)

                        Text(ai.isConfigured ? "Connected" : "Not configured")
                            .font(.subheadline)
                            .foregroundStyle(DS.Colors.textSecondary)
                    }
                }

                Spacer()

                if ai.isConfigured {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(ai.currentProvider.rawValue)
                            .font(.caption.weight(.medium))
                        Text(ai.currentProvider.modelName)
                            .font(.caption2)
                            .foregroundStyle(DS.Colors.textMuted)
                    }
                }
            }

            Button {
                showOnboarding = true
            } label: {
                Text(ai.isConfigured ? "Change Provider" : "Set Up AI")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(ai.isConfigured ? DS.Colors.primary : .white)
                    .frame(maxWidth: .infinity)
                    .frame(height: DS.Sizes.buttonHeight - 8)
                    .background(ai.isConfigured ? DS.Colors.primary.opacity(0.1) : DS.Colors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            }
        }
        .padding()
        .background(DS.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("AI Features")
                .font(.headline)
                .padding(.horizontal, DS.Spacing.xs)

            VStack(spacing: DS.Spacing.sm) {
                FeatureRow(
                    icon: "text.bubble.fill",
                    title: "Natural Language Input",
                    description: "Add tasks by typing naturally, like \"Gym tomorrow at 7am\"",
                    isEnabled: ai.isConfigured
                )

                FeatureRow(
                    icon: "brain.head.profile",
                    title: "Brain Dump",
                    description: "Dump all your thoughts and let AI organize them into tasks",
                    isEnabled: ai.isConfigured
                )

                FeatureRow(
                    icon: "calendar.badge.clock",
                    title: "Smart Scheduling",
                    description: "AI suggests optimal times based on your patterns",
                    isEnabled: false,
                    comingSoon: true
                )

                FeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Insights & Analytics",
                    description: "Get personalized insights about your productivity",
                    isEnabled: false,
                    comingSoon: true
                )
            }
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let isEnabled: Bool
    var comingSoon: Bool = false

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(isEnabled ? DS.Colors.primary : DS.Colors.textMuted)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: DS.Spacing.xs) {
                    Text(title)
                        .font(.subheadline.weight(.medium))

                    if comingSoon {
                        Text("Coming Soon")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(DS.Colors.info)
                            .clipShape(Capsule())
                    }
                }

                Text(description)
                    .font(.caption)
                    .foregroundStyle(DS.Colors.textSecondary)
            }

            Spacer()

            if isEnabled {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(DS.Colors.success)
            }
        }
        .padding()
        .background(DS.Colors.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .opacity(comingSoon ? 0.7 : 1)
    }
}

// MARK: - Preview

#Preview {
    AISettingsView(showOnboarding: .constant(false))
        .environment(AICoordinator())
}
