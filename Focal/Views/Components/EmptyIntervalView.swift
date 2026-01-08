import SwiftUI

struct EmptyIntervalView: View {
    let gap: TimeInterval
    
    var body: some View {
        Color.clear
            .frame(height: 1)
            .accessibilityLabel("Free time interval")
    }
}

#Preview {
    VStack(spacing: DS.Spacing.lg) {
        EmptyIntervalView(gap: 2 * 3600)
        EmptyIntervalView(gap: 3.5 * 3600)
        EmptyIntervalView(gap: 30 * 60)
    }
    .padding()
    .background(DS.Colors.background)
}
