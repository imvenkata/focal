import SwiftUI

/// A reusable glass-style toggle component inspired by iOS Menu design.
/// Features frosted material background, sliding indicator, and smooth animations.
struct GlassToggle<Option: Hashable>: View {
    let options: [Option]
    @Binding var selection: Option
    let label: (Option) -> String
    let icon: ((Option) -> String)?
    
    init(
        options: [Option],
        selection: Binding<Option>,
        label: @escaping (Option) -> String,
        icon: ((Option) -> String)? = nil
    ) {
        self.options = options
        self._selection = selection
        self.label = label
        self.icon = icon
    }
    
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selection = option
                    }
                    HapticManager.shared.selection()
                } label: {
                    HStack(spacing: DS.Spacing.xs) {
                        if let icon = icon {
                            Image(systemName: icon(option))
                                .font(.system(size: 14, weight: .semibold))
                        }
                        Text(label(option))
                            .scaledFont(size: 13, weight: .semibold, relativeTo: .subheadline)
                    }
                    .foregroundStyle(selection == option ? DS.Colors.textPrimary : DS.Colors.textTertiary)
                    .padding(.horizontal, DS.Spacing.lg)
                    .padding(.vertical, DS.Spacing.sm + 2)
                    .frame(maxWidth: .infinity)
                    .background {
                        if selection == option {
                            RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                                        .fill(DS.Colors.surfacePrimary.opacity(0.85))
                                )
                                .shadow(color: DS.Colors.overlay.opacity(0.12), radius: 4, y: 2)
                                .matchedGeometryEffect(id: "indicator", in: animation)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                        .stroke(DS.Colors.borderSubtle.opacity(0.5), lineWidth: 0.5)
                )
        )
        .shadow(color: DS.Colors.overlay.opacity(0.08), radius: 8, y: 4)
    }
}

// MARK: - Convenience initializers

extension GlassToggle where Option == String {
    init(options: [String], selection: Binding<String>) {
        self.init(options: options, selection: selection, label: { $0 }, icon: nil)
    }
}

#Preview {
    @Previewable @State var selected = "Week"
    
    VStack(spacing: 32) {
        GlassToggle(
            options: ["Week", "Day"],
            selection: $selected
        )
        .frame(width: 200)
        
        GlassToggle(
            options: ["Todo", "Planner"],
            selection: .constant("Todo"),
            label: { $0 },
            icon: { $0 == "Todo" ? "checkmark.circle" : "calendar" }
        )
        .frame(width: 240)
    }
    .padding()
    .background(DS.Colors.bgPrimary)
}
