import SwiftUI

struct AIOnboardingView: View {
    @Environment(AICoordinator.self) private var ai
    @Environment(\.dismiss) private var dismiss

    @State private var selectedProvider: LLMProvider = .gemini
    @State private var apiKey: String = ""
    @State private var isValidating: Bool = false
    @State private var validationError: String?
    @State private var isValidated: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Spacing.xxl) {
                    // Header
                    VStack(spacing: DS.Spacing.md) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 56))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text("Enable AI Features")
                            .font(.title.weight(.bold))

                        Text("Connect an AI provider to unlock intelligent task parsing, smart scheduling, and personalized insights.")
                            .font(.subheadline)
                            .foregroundStyle(DS.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, DS.Spacing.xl)

                    // Provider Selection
                    VStack(alignment: .leading, spacing: DS.Spacing.md) {
                        Text("Choose Provider")
                            .font(.headline)

                        ForEach(LLMProvider.allCases, id: \.self) { provider in
                            ProviderCard(
                                provider: provider,
                                isSelected: selectedProvider == provider,
                                onSelect: {
                                    selectedProvider = provider
                                    apiKey = ""
                                    validationError = nil
                                    isValidated = false
                                }
                            )
                        }
                    }
                    .padding(.horizontal)

                    // API Key Input
                    if selectedProvider.requiresAPIKey {
                        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                            Text("API Key")
                                .font(.headline)

                            SecureField(selectedProvider.apiKeyPlaceholder, text: $apiKey)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(DS.Colors.surfaceSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))

                            Text(selectedProvider.setupInstructions)
                                .font(.caption)
                                .foregroundStyle(DS.Colors.textMuted)

                            if let error = validationError {
                                Label(error, systemImage: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                    .foregroundStyle(DS.Colors.error)
                            }

                            if isValidated {
                                Label("API key validated successfully", systemImage: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(DS.Colors.success)
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer(minLength: DS.Spacing.xxl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: DS.Spacing.md) {
                    Button {
                        Task { await validateAndSave() }
                    } label: {
                        HStack {
                            if isValidating {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(isValidated ? "Enable AI" : "Validate & Enable")
                            }
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: DS.Sizes.buttonHeight)
                        .background(canSubmit ? DS.Colors.primary : DS.Colors.textMuted)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                    }
                    .disabled(!canSubmit || isValidating)
                }
                .padding()
                .background(DS.Colors.cardBackground)
            }
        }
    }

    private var canSubmit: Bool {
        if selectedProvider == .apple {
            return selectedProvider.isAvailable
        }
        return !apiKey.isEmpty
    }

    private func validateAndSave() async {
        isValidating = true
        validationError = nil

        do {
            // Test the API key with a simple request
            ai.configure(provider: selectedProvider, apiKey: apiKey)

            let _ = try await ai.parseTask("test task tomorrow")

            isValidated = true
            HapticManager.shared.notification(.success)

            // Dismiss after short delay
            try? await Task.sleep(for: .seconds(0.5))
            dismiss()

        } catch let error as LLMError {
            validationError = error.localizedDescription
            HapticManager.shared.notification(.error)
        } catch {
            validationError = error.localizedDescription
            HapticManager.shared.notification(.error)
        }

        isValidating = false
    }
}

// MARK: - Provider Card

struct ProviderCard: View {
    let provider: LLMProvider
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: DS.Spacing.md) {
                Image(systemName: providerIcon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? DS.Colors.primary : DS.Colors.textSecondary)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(provider.rawValue)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(DS.Colors.textPrimary)

                    Text(provider.modelName)
                        .font(.caption)
                        .foregroundStyle(DS.Colors.textMuted)
                }

                Spacer()

                if !provider.isAvailable {
                    Text("Unavailable")
                        .font(.caption)
                        .foregroundStyle(DS.Colors.textMuted)
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(DS.Colors.primary)
                }
            }
            .padding()
            .background(isSelected ? DS.Colors.primary.opacity(0.1) : DS.Colors.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .stroke(isSelected ? DS.Colors.primary : .clear, lineWidth: 2)
            )
        }
        .disabled(!provider.isAvailable)
        .opacity(provider.isAvailable ? 1 : 0.5)
    }

    private var providerIcon: String {
        switch provider {
        case .gemini: return "g.circle.fill"
        case .openAI: return "brain.head.profile"
        case .anthropic: return "sparkles.rectangle.stack"
        case .apple: return "apple.logo"
        }
    }
}

// MARK: - Preview

#Preview {
    AIOnboardingView()
        .environment(AICoordinator())
}
