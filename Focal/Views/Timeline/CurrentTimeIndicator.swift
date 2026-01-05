import SwiftUI

struct CurrentTimeIndicator: View {
    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: 0) {
            // Pulsing dot with premium glow
            ZStack {
                // Outer glow
                Circle()
                    .fill(DS.Colors.coral.opacity(0.4))
                    .frame(width: 16, height: 16)
                    .blur(radius: 4)
                    .scaleEffect(isPulsing ? 1.3 : 1)

                // Core dot
                Circle()
                    .fill(DS.Colors.coral)
                    .frame(width: 10, height: 10)
                    .shadow(color: DS.Colors.coral.opacity(0.6), radius: 6, x: 0, y: 0)
                    .scaleEffect(isPulsing ? 1.15 : 1)
            }
            .animation(
                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                value: isPulsing
            )

            // Line with subtle glow
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [DS.Colors.coral, DS.Colors.coral.opacity(0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2.5)
                .shadow(color: DS.Colors.coral.opacity(0.5), radius: 4, x: 0, y: 0)
        }
        .onAppear {
            isPulsing = true
        }
        .accessibilityLabel("Current time")
    }
}

// MARK: - Time Label
struct TimeLabel: View {
    let hour: Int

    var body: some View {
        Text(String(format: "%02d:00", hour))
            .scaledFont(size: 10, weight: .medium, design: .monospaced, relativeTo: .caption2)
            .foregroundStyle(DS.Colors.stone400)
            .frame(width: DS.Sizes.timeLabelWidth, alignment: .trailing)
    }
}

#Preview {
    VStack(spacing: DS.Spacing.xl) {
        CurrentTimeIndicator()
            .frame(height: 20)

        HStack {
            TimeLabel(hour: 9)
            Rectangle()
                .fill(DS.Colors.divider)
                .frame(height: 1)
        }
    }
    .padding()
    .background(DS.Colors.background)
}
