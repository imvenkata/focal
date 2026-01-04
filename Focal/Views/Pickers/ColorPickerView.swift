import SwiftUI

struct ColorPickerView: View {
    @Binding var selectedColor: TaskColor
    let onSelect: () -> Void
    
    var body: some View {
        VStack(spacing: DS.Spacing.lg) {
            // Header
            HStack {
                Text("Choose Color")
                    .scaledFont(size: 20, weight: .semibold, relativeTo: .title3)
                    .foregroundStyle(DS.Colors.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, DS.Spacing.xl)
            .padding(.top, DS.Spacing.xl)
            
            // Color grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DS.Spacing.md), count: 4), spacing: DS.Spacing.md) {
                ForEach(TaskColor.allCases, id: \.self) { color in
                    Button {
                        HapticManager.shared.colorSelected()
                        selectedColor = color
                        onSelect()
                    } label: {
                        VStack(spacing: DS.Spacing.sm) {
                            // Color circle
                            Circle()
                                .fill(color.color)
                                .frame(width: 56, height: 56)
                                .overlay {
                                    if selectedColor == color {
                                        Circle()
                                            .strokeBorder(.white, lineWidth: 3)
                                        Circle()
                                            .strokeBorder(color.color, lineWidth: 6)
                                        
                                        Image(systemName: "checkmark")
                                            .scaledFont(size: 20, weight: .bold, relativeTo: .title3)
                                            .foregroundStyle(.white)
                                    }
                                }
                                .shadow(color: color.color.opacity(0.3), radius: 8, y: 4)
                            
                            // Color name
                            Text(color.rawValue.capitalized)
                                .scaledFont(size: 12, weight: .medium, relativeTo: .caption)
                                .foregroundStyle(DS.Colors.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: DS.Radius.lg)
                                .fill(selectedColor == color ? color.lightColor : DS.Colors.cardBackground)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(color.rawValue) color")
                    .accessibilityAddTraits(selectedColor == color ? .isSelected : [])
                }
            }
            .padding(.horizontal, DS.Spacing.xl)
            .padding(.bottom, DS.Spacing.xl)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    ColorPickerView(
        selectedColor: .constant(.sage),
        onSelect: {}
    )
}
