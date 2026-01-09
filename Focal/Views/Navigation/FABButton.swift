import SwiftUI

struct FABButton: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            HapticManager.shared.impact(.medium)
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                DS.Colors.stone700,
                                DS.Colors.stone900
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: DS.Sizes.fabSize, height: DS.Sizes.fabSize)
                    .shadow(color: DS.Colors.stone900.opacity(0.3), radius: 16, x: 0, y: 8)
                
                Image(systemName: "plus")
                    .scaledFont(size: 28, weight: .semibold, relativeTo: .title)
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(FABButtonStyle())
        .accessibilityLabel("Add new task")
        .accessibilityHint("Opens task creation sheet")
    }
}

// MARK: - Compact FAB (Day View)
struct CompactFABButton: View {
    let action: () -> Void
    var size: CGFloat = DS.Sizes.minTouchTarget

    var body: some View {
        Button {
            HapticManager.shared.selection()
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Circle()
                            .stroke(DS.Colors.borderSubtle, lineWidth: 1)
                    )

                Image(systemName: "plus")
                    .scaledFont(size: 18, weight: .semibold, relativeTo: .headline)
                    .foregroundStyle(DS.Colors.primary)
            }
            .frame(width: size, height: size)
            .shadow(color: Color.black.opacity(0.18), radius: 10, y: 4)
        }
        .buttonStyle(PressableStyle(scaleAmount: 0.97))
        .accessibilityLabel("Add new task")
        .accessibilityHint("Opens task creation sheet")
    }
}

// MARK: - FAB Button Style
struct FABButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(DS.Animation.quick, value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1)
        
        FABButton {
            print("FAB tapped")
        }
    }
    .frame(width: 200, height: 200)
}
