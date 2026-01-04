import SwiftUI

struct EnergyPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLevel: Int

    var body: some View {
        NavigationStack {
            VStack(spacing: DS.Spacing.xxl) {
                // Energy level selector
                HStack(spacing: DS.Spacing.md) {
                    ForEach(EnergyLevel.allCases) { level in
                        EnergyLevelButton(
                            level: level,
                            isSelected: selectedLevel == level.rawValue
                        ) {
                            HapticManager.shared.selection()
                            selectedLevel = level.rawValue
                        }
                    }
                }
                .padding(.horizontal, DS.Spacing.xl)

                // Selected level info
                if let level = EnergyLevel(rawValue: selectedLevel) {
                    VStack(spacing: DS.Spacing.md) {
                        Text("\(level.icon) \(level.label)")
                            .scaledFont(size: 18, weight: .semibold, relativeTo: .headline)
                            .foregroundStyle(DS.Colors.textPrimary)

                        Text(level.description)
                            .scaledFont(size: 14, relativeTo: .callout)
                            .foregroundStyle(DS.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(DS.Spacing.xl)
                    .frame(maxWidth: .infinity)
                    .background(DS.Colors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                    .padding(.horizontal, DS.Spacing.xl)
                }

                // Info text
                Text("The energy monitor helps you get a better overview of what you can handle in a day.")
                    .scaledFont(size: 14, relativeTo: .callout)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DS.Spacing.xxl)

                Spacer()
            }
            .padding(.top, DS.Spacing.xxl)
            .background(DS.Colors.background)
            .navigationTitle("Energy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: DS.Spacing.sm) {
                        Text("Energy")
                            .scaledFont(size: 17, weight: .semibold, relativeTo: .headline)

                        if let level = EnergyLevel(rawValue: selectedLevel) {
                            Text(level.icon)
                        }
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                            .foregroundStyle(DS.Colors.textSecondary)
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Energy Level Button
struct EnergyLevelButton: View {
    let level: EnergyLevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(level.icon)
                .scaledFont(size: 24, relativeTo: .title2)
                .frame(width: 52, height: 52)
                .background(isSelected ? energyColor.opacity(0.2) : DS.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                .overlay {
                    if isSelected {
                        RoundedRectangle(cornerRadius: DS.Radius.md)
                            .stroke(energyColor, lineWidth: 2)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(level.label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var energyColor: Color {
        switch level {
        case .restful: return DS.Colors.sage
        case .light: return DS.Colors.sky
        case .moderate: return DS.Colors.amber
        case .high: return DS.Colors.coral
        case .intense: return DS.Colors.coral
        }
    }
}

#Preview {
    EnergyPickerSheet(selectedLevel: .constant(2))
}
