import SwiftUI

struct BottomTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: DS.Spacing.xl) {
            // Todos tab (first)
            TabButton(tab: .todos, isSelected: selectedTab == .todos) {
                HapticManager.shared.selection()
                selectedTab = .todos
            }
            .frame(maxWidth: 80)

            // Planner tab (second)
            TabButton(tab: .planner, isSelected: selectedTab == .planner) {
                HapticManager.shared.selection()
                selectedTab = .planner
            }
            .frame(maxWidth: 80)

            // Blank space on right
            Spacer()
        }
        .padding(.horizontal, DS.Spacing.xl)
        .padding(.top, DS.Spacing.md)
        .padding(.bottom, 34)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(DS.Colors.borderSubtle)
                .frame(height: 1)
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: DS.Spacing.xs) {
                Image(systemName: tab.icon)
                    .scaledFont(size: 20, weight: isSelected ? .semibold : .regular, relativeTo: .body)
                    .foregroundStyle(isSelected ? DS.Colors.textPrimary : DS.Colors.textTertiary)

                Text(tab.label)
                    .scaledFont(size: 10, weight: .medium, relativeTo: .caption2)
                    .foregroundStyle(isSelected ? DS.Colors.textPrimary : DS.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: DS.Sizes.minTouchTarget)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    VStack {
        Spacer()
        BottomTabBar(selectedTab: .constant(.todos))
    }
    .background(DS.Colors.bgPrimary)
}
