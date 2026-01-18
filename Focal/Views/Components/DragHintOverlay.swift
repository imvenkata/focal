import SwiftUI

/// First-use hint overlay for drag-to-reorder gestures
struct DragToReorderHint: View {
    @AppStorage("hasSeenDragToReorderHint") private var hasSeenHint = false
    @State private var dragOffset: CGFloat = 0
    var onDismiss: (() -> Void)?

    var body: some View {
        if !hasSeenHint {
            VStack(spacing: DS.Spacing.md) {
                // Animated drag indicator
                VStack(spacing: DS.Spacing.xs) {
                    dragItem(offset: -dragOffset * 0.5)
                    dragItem(offset: dragOffset, isActive: true)
                    dragItem(offset: 0)
                }

                Text("Drag tasks to reorder them")
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
                startDragAnimation()
            }
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Drag tasks to reorder them")
            .accessibilityHint("Tap Got it to dismiss this hint")
        }
    }

    @ViewBuilder
    private func dragItem(offset: CGFloat = 0, isActive: Bool = false) -> some View {
        HStack(spacing: DS.Spacing.sm) {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(DS.Colors.textTertiary)

            RoundedRectangle(cornerRadius: DS.Radius.xs)
                .fill(isActive ? DS.Colors.primary.opacity(0.2) : DS.Colors.surfaceSecondary)
                .frame(width: 60, height: 8)
        }
        .padding(.horizontal, DS.Spacing.sm)
        .padding(.vertical, DS.Spacing.xs)
        .background(isActive ? DS.Colors.primary.opacity(0.08) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
        .offset(y: offset)
        .scaleEffect(isActive ? 1.05 : 1.0)
        .shadow(color: isActive ? DS.Colors.primary.opacity(0.2) : .clear, radius: 4, y: 2)
    }

    private func startDragAnimation() {
        withAnimation(
            .easeInOut(duration: 0.8)
            .repeatForever(autoreverses: true)
        ) {
            dragOffset = 15
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

/// First-use hint for dragging tasks between days (week view)
struct DragBetweenDaysHint: View {
    @AppStorage("hasSeenDragBetweenDaysHint") private var hasSeenHint = false
    @State private var dragProgress: CGFloat = 0
    var onDismiss: (() -> Void)?

    var body: some View {
        if !hasSeenHint {
            VStack(spacing: DS.Spacing.md) {
                // Animated drag between columns
                HStack(spacing: DS.Spacing.lg) {
                    dayColumn(label: "Mon", hasTask: dragProgress < 0.5)
                    dayColumn(label: "Tue", hasTask: dragProgress >= 0.5)
                }
                .overlay {
                    // Floating task being dragged
                    if dragProgress > 0.1 && dragProgress < 0.9 {
                        Circle()
                            .fill(DS.Colors.primary)
                            .frame(width: 12, height: 12)
                            .offset(x: (dragProgress - 0.5) * 60)
                            .shadow(color: DS.Colors.primary.opacity(0.3), radius: 4, y: 2)
                    }
                }

                Text("Drag tasks between days to reschedule")
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
                startDragAnimation()
            }
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
        }
    }

    @ViewBuilder
    private func dayColumn(label: String, hasTask: Bool) -> some View {
        VStack(spacing: DS.Spacing.xs) {
            Text(label)
                .scaledFont(size: 10, weight: .semibold, relativeTo: .caption2)
                .foregroundStyle(DS.Colors.textTertiary)

            RoundedRectangle(cornerRadius: DS.Radius.xs)
                .fill(DS.Colors.surfaceSecondary)
                .frame(width: 40, height: 60)
                .overlay {
                    if hasTask {
                        Circle()
                            .fill(DS.Colors.primary)
                            .frame(width: 12, height: 12)
                    }
                }
        }
    }

    private func startDragAnimation() {
        withAnimation(
            .easeInOut(duration: 1.5)
            .repeatForever(autoreverses: true)
        ) {
            dragProgress = 1.0
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

#Preview("Drag to Reorder") {
    DragToReorderHint()
        .padding()
        .background(DS.Colors.background)
}

#Preview("Drag Between Days") {
    DragBetweenDaysHint()
        .padding()
        .background(DS.Colors.background)
}
