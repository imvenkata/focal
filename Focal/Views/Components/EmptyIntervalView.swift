import SwiftUI

struct EmptyIntervalView: View {
    let gap: TimeInterval
    
    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            Text("💤")
                .scaledFont(size: 14, relativeTo: .callout)
            
            Text(gapMessage)
                .scaledFont(size: 14, relativeTo: .callout)
                .foregroundStyle(DS.Colors.textSecondary)
                .italic()
        }
        .padding(.vertical, DS.Spacing.md)
        .accessibilityLabel("Free time interval: \(gapMessage)")
    }
    
    private var gapMessage: String {
        let hours = Int(gap) / 3600
        let minutes = Int(gap) % 3600 / 60
        
        if hours > 0 {
            return "A well-spent interval of \(hours)h \(minutes)m."
        } else {
            return "A well-spent interval."
        }
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
