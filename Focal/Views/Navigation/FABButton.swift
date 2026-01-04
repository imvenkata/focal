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
