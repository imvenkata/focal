import SwiftUI

struct BottomTabBar: View {
    @Binding var selectedTab: AppTab
    @Namespace private var tabAnimation

    var body: some View {
        HStack(spacing: DS.Spacing.xl) {
            // Glass-style tab toggle
            glassTabToggle
            
            Spacer()
        }
        .padding(.horizontal, DS.Spacing.xl)
        .padding(.top, DS.Spacing.md)
        .padding(.bottom, 34)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(DS.Colors.borderSubtle.opacity(0.3))
                .frame(height: 0.5)
        }
    }
    
    private var glassTabToggle: some View {
        HStack(spacing: 0) {
            ForEach([AppTab.todos, AppTab.planner], id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedTab = tab
                    }
                    HapticManager.shared.selection()
                } label: {
                    HStack(spacing: DS.Spacing.sm) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16, weight: selectedTab == tab ? .semibold : .regular))
                        Text(tab.label)
                            .scaledFont(size: 14, weight: .semibold, relativeTo: .subheadline)
                    }
                    .foregroundStyle(selectedTab == tab ? DS.Colors.textPrimary : DS.Colors.textTertiary)
                    .padding(.horizontal, DS.Spacing.lg)
                    .padding(.vertical, DS.Spacing.md)
                    .background {
                        if selectedTab == tab {
                            RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                                        .fill(DS.Colors.surfacePrimary.opacity(0.9))
                                )
                                .shadow(color: DS.Colors.overlay.opacity(0.1), radius: 3, y: 1)
                                .matchedGeometryEffect(id: "tab_indicator", in: tabAnimation)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.label)
                .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                        .stroke(DS.Colors.borderSubtle.opacity(0.4), lineWidth: 0.5)
                )
        )
        .shadow(color: DS.Colors.overlay.opacity(0.06), radius: 6, y: 2)
    }
}

// MARK: - Tab Button (kept for backwards compatibility if needed elsewhere)
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

