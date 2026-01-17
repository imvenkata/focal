import SwiftUI

/// A horizontal selector for the user's current energy level in Calm Mode.
/// Uses large touch targets and gentle visual feedback.
struct EnergySelector: View {
    @Binding var selection: UserEnergy
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("How's your energy?")
                .scaledFont(size: 15, weight: .medium, relativeTo: .subheadline)
                .foregroundStyle(DS.Colors.textSecondary)

            HStack(spacing: DS.Spacing.md) {
                ForEach(UserEnergy.allCases) { energy in
                    EnergyButton(
                        energy: energy,
                        isSelected: selection == energy
                    ) {
                        withAnimation(reduceMotion ? DS.Animation.reduced : DS.Animation.spring) {
                            selection = energy
                        }
                        HapticManager.shared.selection()
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Energy level selector")
    }
}

// MARK: - Energy Button

private struct EnergyButton: View {
    let energy: UserEnergy
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.sm) {
                Text(energy.emoji)
                    .font(.system(size: 20))

                Text(energy.rawValue)
                    .scaledFont(size: 14, weight: isSelected ? .semibold : .medium, relativeTo: .callout)
            }
            .foregroundStyle(isSelected ? .white : DS.Colors.textPrimary)
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.vertical, DS.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                    .fill(isSelected ? energy.color : DS.Colors.surfaceSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                    .stroke(isSelected ? energy.color : DS.Colors.borderSubtle, lineWidth: isSelected ? 0 : 1)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadowResting()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(energy.rawValue) energy")
        .accessibilityHint(energy.description)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    @Previewable @State var energy: UserEnergy = .medium

    VStack(spacing: DS.Spacing.xxl) {
        EnergySelector(selection: $energy)

        Text("Selected: \(energy.rawValue)")
            .foregroundStyle(DS.Colors.textSecondary)
    }
    .padding()
    .background(DS.Colors.background)
}
