import SwiftUI

struct IconPickerView: View {
    @Binding var selectedIcon: String
    let onSelect: () -> Void
    
    private let icons = [
        "🏋️", "🏃", "🧘", "🏊", "🚴", "⚽️", "🏀", "🎾",
        "💼", "💻", "📱", "📧", "📞", "👥", "🏢", "✈️",
        "🍳", "☕️", "🍽️", "🛒", "🍕", "🍔", "🥗", "🍜",
        "📚", "📖", "🎓", "✍️", "🎵", "🎨", "🎬", "📷",
        "😴", "☀️", "🌙", "🌅", "⏰", "🔔", "⏳", "📅",
        "🧹", "👕", "🛍️", "🛋️", "🏠", "🚗", "🚇", "🚲",
        "👯", "🎉", "🎊", "🎂", "🎁", "💐", "🌹", "🌸",
        "📝", "📋", "📌", "🔖", "💡", "🎯", "🔥", "⭐️",
        "❤️", "💚", "💙", "💛", "🧡", "💜", "🖤", "🤍"
    ]
    
    var body: some View {
        VStack(spacing: DS.Spacing.lg) {
            // Header
            HStack {
                Text("Choose Icon")
                    .scaledFont(size: 20, weight: .semibold, relativeTo: .title3)
                    .foregroundStyle(DS.Colors.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, DS.Spacing.xl)
            .padding(.top, DS.Spacing.xl)
            
            // Icon grid
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DS.Spacing.sm), count: 8), spacing: DS.Spacing.sm) {
                    ForEach(icons, id: \.self) { icon in
                        Button {
                            HapticManager.shared.iconSelected()
                            selectedIcon = icon
                            onSelect()
                        } label: {
                            Text(icon)
                                .scaledFont(size: 32, relativeTo: .title2)
                                .frame(width: 56, height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: DS.Radius.md)
                                        .fill(selectedIcon == icon ? DS.Colors.sky.opacity(0.2) : DS.Colors.cardBackground)
                                )
                                .overlay {
                                    if selectedIcon == icon {
                                        RoundedRectangle(cornerRadius: DS.Radius.md)
                                            .strokeBorder(DS.Colors.sky, lineWidth: 2)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Icon: \(icon)")
                        .accessibilityAddTraits(selectedIcon == icon ? .isSelected : [])
                    }
                }
                .padding(.horizontal, DS.Spacing.xl)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    IconPickerView(
        selectedIcon: .constant("🏋️"),
        onSelect: {}
    )
}
