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

            // Add button
            Button(action: onAdd) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(DS.Colors.primary)
                    .frame(width: 44, height: 44)
                    .background(DS.Colors.primary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            }
            .buttonStyle(.plain)
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
            .accessibilityLabel("Quick Add")
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
