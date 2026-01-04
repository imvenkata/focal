import SwiftUI

struct ProgressBar: View {
    let progress: Double
    let completed: Int
    let total: Int
    var color: Color = DS.Colors.sky

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Energy icon
            Text("🔥")
                .scaledFont(size: 14, relativeTo: .callout)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: DS.Radius.xs)
                        .fill(DS.Colors.divider)
                        .frame(height: 6)

                    // Progress
                    RoundedRectangle(cornerRadius: DS.Radius.xs)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 6)
                        .animation(DS.Animation.spring, value: progress)
                }
            }
            .frame(height: 6)

            // Count
            Text("\(completed)/\(total)")
                .scaledFont(size: 12, weight: .medium, design: .monospaced, relativeTo: .caption)
                .foregroundStyle(DS.Colors.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(completed) of \(total) tasks completed")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

#Preview {
    VStack(spacing: DS.Spacing.xl) {
        ProgressBar(progress: 0.6, completed: 12, total: 20)
        ProgressBar(progress: 0.25, completed: 5, total: 20, color: DS.Colors.sage)
        ProgressBar(progress: 1.0, completed: 20, total: 20, color: DS.Colors.coral)
    }
    .padding()
    .background(DS.Colors.background)
}
