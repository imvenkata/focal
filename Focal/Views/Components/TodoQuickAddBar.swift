import SwiftUI

struct TodoQuickAddBar: View {
    @Binding var text: String
    let onAdd: () -> Void
    @FocusState.Binding var isFocused: Bool

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Text field
            TextField("Add it to your list", text: $text)
                .scaledFont(size: 15, relativeTo: .body)
                .foregroundStyle(DS.Colors.textPrimary)
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit {
                    onAdd()
                }

            // AI sparkle button
            Button(action: {
                // AI magic action - placeholder for now
                onAdd()
            }) {
                Text("✨")
                    .font(.system(size: 18))
                    .frame(width: 44, height: 44)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(hex: "#E8E4FF"),
                                Color(hex: "#F0E8FF")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, DS.Spacing.lg)
        .padding(.trailing, DS.Spacing.xs)
        .padding(.vertical, DS.Spacing.xs)
        .background(DS.Colors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.lg)
                .stroke(
                    style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                )
                .foregroundStyle(DS.Colors.divider)
        )
        .animation(DS.Animation.spring, value: isFocused)
        .animation(DS.Animation.spring, value: text.isEmpty)
    }
}
