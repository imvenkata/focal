import SwiftUI

struct BottomTabBar: View {
    @Binding var selectedTab: Tab
    let onAddTapped: () -> Void
    var showsFAB: Bool = true

    var body: some View {
        HStack(spacing: 0) {
            // Left tabs
            ForEach([Tab.inbox, Tab.planner, Tab.todos], id: \.self) { tab in
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
    let tab: Tab
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
