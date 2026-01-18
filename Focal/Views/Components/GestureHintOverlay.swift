import SwiftUI

/// First-use hint overlay for swipe gestures
struct SwipeGestureHint: View {
    @AppStorage("hasSeenSwipeHint") private var hasSeenHint = false
    @State private var animationPhase: CGFloat = 0
    @State private var isAnimating = false

    let direction: SwipeDirection
    let message: String
    var onDismiss: (() -> Void)?

    enum SwipeDirection {
        case left
        case right
    }

    var body: some View {
        if !hasSeenHint {
            VStack(spacing: DS.Spacing.md) {
                // Animated hand indicator
                HStack(spacing: DS.Spacing.sm) {
                    if direction == .right {
                        Image(systemName: "hand.point.right.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(DS.Colors.textSecondary)
                            .offset(x: animationPhase)
                    }

                    Image(systemName: "rectangle.fill")
                        .font(.system(size: 40, weight: .light))
                        .foregroundStyle(DS.Colors.surfaceSecondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: DS.Radius.sm)
                                .stroke(DS.Colors.divider, lineWidth: 1)
                        )

                    if direction == .left {
                        Image(systemName: "hand.point.left.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(DS.Colors.textSecondary)
                            .offset(x: -animationPhase)
                    }
                }

                Text(message)
                    .scaledFont(size: 13, weight: .medium, relativeTo: .caption)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)

                Button {
                    dismissHint()
                } label: {
                    Text("Got it")
                        .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                        .foregroundStyle(DS.Colors.primary)
                        .padding(.horizontal, DS.Spacing.lg)
                        .padding(.vertical, DS.Spacing.sm)
                        .background(DS.Colors.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                }
                .buttonStyle(.plain)
            }
            .padding(DS.Spacing.xl)
            .background(DS.Colors.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xl))
            .shadowElevated()
            .onAppear {
                startAnimation()
            }
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(message)
            .accessibilityHint("Tap Got it to dismiss this hint")
        }
    }

    private func startAnimation() {
        guard !isAnimating else { return }
        isAnimating = true

        withAnimation(
            .easeInOut(duration: 0.8)
            .repeatForever(autoreverses: true)
        ) {
            animationPhase = 20
        }
    }

    private func dismissHint() {
        HapticManager.shared.selection()
        withAnimation(DS.Animation.spring) {
            hasSeenHint = true
        }
        onDismiss?()
    }
}

/// First-use hint for tap-to-create on timeline
struct TapToCreateHint: View {
    @AppStorage("hasSeenTapToCreateHint") private var hasSeenHint = false
    @State private var pulseScale: CGFloat = 1.0
    var onDismiss: (() -> Void)?

    var body: some View {
        if !hasSeenHint {
            VStack(spacing: DS.Spacing.md) {
                // Animated tap indicator
                ZStack {
                    Circle()
                        .fill(DS.Colors.primary.opacity(0.15))
                        .frame(width: 60, height: 60)
                        .scaleEffect(pulseScale)
                        .opacity(2 - pulseScale)

                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(DS.Colors.primary)
                }

                Text("Tap empty time slots to quickly add tasks")
                    .scaledFont(size: 13, weight: .medium, relativeTo: .caption)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)

                Button {
                    dismissHint()
                } label: {
                    Text("Got it")
                        .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                        .foregroundStyle(DS.Colors.primary)
                        .padding(.horizontal, DS.Spacing.lg)
                        .padding(.vertical, DS.Spacing.sm)
                        .background(DS.Colors.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                }
                .buttonStyle(.plain)
            }
            .padding(DS.Spacing.xl)
            .background(DS.Colors.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xl))
            .shadowElevated()
            .onAppear {
                startPulseAnimation()
            }
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Tap empty time slots to quickly add tasks")
            .accessibilityHint("Tap Got it to dismiss this hint")
        }
    }

    private func startPulseAnimation() {
        withAnimation(
            .easeOut(duration: 1.2)
            .repeatForever(autoreverses: false)
        ) {
            pulseScale = 1.8
        }
    }

    private func dismissHint() {
        HapticManager.shared.selection()
        withAnimation(DS.Animation.spring) {
            hasSeenHint = true
        }
        onDismiss?()
    }
}

/// Hint overlay for context menu (long-press)
struct ContextMenuHint: View {
    @AppStorage("hasSeenContextMenuHint") private var hasSeenHint = false
    @State private var isPressed = false
    var onDismiss: (() -> Void)?

    var body: some View {
        if !hasSeenHint {
            VStack(spacing: DS.Spacing.md) {
                // Animated long-press indicator
                ZStack {
                    RoundedRectangle(cornerRadius: DS.Radius.md)
                        .fill(DS.Colors.surfaceSecondary)
                        .frame(width: 80, height: 50)
                        .scaleEffect(isPressed ? 0.95 : 1.0)

                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(DS.Colors.textSecondary)
                        .offset(y: isPressed ? 2 : 0)
                }

                Text("Long-press tasks for quick actions")
                    .scaledFont(size: 13, weight: .medium, relativeTo: .caption)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)

                Button {
                    dismissHint()
                } label: {
                    Text("Got it")
                        .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                        .foregroundStyle(DS.Colors.primary)
                        .padding(.horizontal, DS.Spacing.lg)
                        .padding(.vertical, DS.Spacing.sm)
                        .background(DS.Colors.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                }
                .buttonStyle(.plain)
            }
            .padding(DS.Spacing.xl)
            .background(DS.Colors.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xl))
            .shadowElevated()
            .onAppear {
                startPressAnimation()
            }
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
        }
    }

    private func startPressAnimation() {
        withAnimation(
            .easeInOut(duration: 0.5)
            .repeatForever(autoreverses: true)
            .delay(0.3)
        ) {
            isPressed = true
        }
    }

    private func dismissHint() {
        HapticManager.shared.selection()
        withAnimation(DS.Animation.spring) {
            hasSeenHint = true
        }
        onDismiss?()
    }
}

#Preview("Swipe Hint - Left") {
    SwipeGestureHint(
        direction: .left,
        message: "Swipe left to delete"
    )
    .padding()
    .background(DS.Colors.background)
}

#Preview("Swipe Hint - Right") {
    SwipeGestureHint(
        direction: .right,
        message: "Swipe right to complete"
    )
    .padding()
    .background(DS.Colors.background)
}

#Preview("Tap to Create") {
    TapToCreateHint()
        .padding()
        .background(DS.Colors.background)
}

#Preview("Context Menu") {
    ContextMenuHint()
        .padding()
        .background(DS.Colors.background)
}
