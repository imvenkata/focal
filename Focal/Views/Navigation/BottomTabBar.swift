import SwiftUI

struct BottomTabBar: View {
    @Binding var selectedTab: Tab
    let onAddTapped: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Left tabs
            ForEach([Tab.inbox, Tab.planner], id: \.self) { tab in
                TabButton(tab: tab, isSelected: selectedTab == tab) {
                    HapticManager.shared.selection()
                    selectedTab = tab
                }
            }

            // FAB spacer
            Spacer()
                .frame(width: DS.Sizes.fabSize + DS.Spacing.xl)

            // Right tabs
            ForEach([Tab.insights, Tab.settings], id: \.self) { tab in
                TabButton(tab: tab, isSelected: selectedTab == tab) {
                    HapticManager.shared.selection()
                    selectedTab = tab
                }
            }
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.top, DS.Spacing.md)
        .padding(.bottom, 34)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            // FAB
            FABButton(action: onAddTapped)
                .offset(y: -DS.Sizes.fabSize / 2)
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let tab: Tab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: DS.Spacing.xs) {
                Image(systemName: tab.icon)
                    .scaledFont(size: 20, weight: isSelected ? .semibold : .regular, relativeTo: .body)
                    .foregroundStyle(isSelected ? DS.Colors.sky : DS.Colors.textSecondary)

                Text(tab.label)
                    .scaledFont(size: 10, weight: .medium, relativeTo: .caption2)
                    .foregroundStyle(isSelected ? DS.Colors.sky : DS.Colors.textSecondary)
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
        BottomTabBar(selectedTab: .constant(.planner)) {
            print("Add tapped")
        }
    }
    .background(DS.Colors.background)
}
