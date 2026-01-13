import SwiftUI

struct BottomTabBar: View {
    @Binding var selectedTab: AppTab
    let onAddTapped: () -> Void
    var showsFAB: Bool = true

    var body: some View {
        HStack(spacing: 0) {
            // Planner tab
            TabButton(tab: .planner, isSelected: selectedTab == .planner) {
                HapticManager.shared.selection()
                selectedTab = .planner
            }

            // FAB spacer (centered)
            Spacer()
                .frame(width: DS.Sizes.fabSize + DS.Spacing.xl)

            // Todos tab
            TabButton(tab: .todos, isSelected: selectedTab == .todos) {
                HapticManager.shared.selection()
                selectedTab = .todos
            }
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.top, DS.Spacing.md)
        .padding(.bottom, 34)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(DS.Colors.borderSubtle)
                .frame(height: 1)
        }
        .overlay(alignment: .top) {
            // FAB
            if showsFAB {
                FABButton(action: onAddTapped)
                    .offset(y: -DS.Sizes.fabSize / 2)
            }
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
        BottomTabBar(selectedTab: .constant(.planner), onAddTapped: {
            print("Add tapped")
        })
    }
    .background(DS.Colors.bgPrimary)
}
