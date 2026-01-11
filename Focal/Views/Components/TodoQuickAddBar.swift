import SwiftUI

struct TodoQuickAddBar: View {
    @Binding var text: String
    let onAdd: () -> Void
    @FocusState.Binding var isFocused: Bool

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Plus icon
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(DS.Colors.sky)

            // Text field
            TextField("Add a new todo...", text: $text)
                .scaledFont(size: 16, relativeTo: .body)
                .foregroundStyle(DS.Colors.textPrimary)
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit {
                    onAdd()
                }

            // Add button (only visible when text exists)
            if !text.isEmpty {
                Button(action: onAdd) {
                    Text("Add")
                        .scaledFont(size: 14, weight: .semibold, relativeTo: .subheadline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, DS.Spacing.lg)
                        .padding(.vertical, DS.Spacing.sm)
                        .background(DS.Colors.sky)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(DS.Spacing.lg)
        .background(DS.Colors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.lg)
                .stroke(isFocused ? DS.Colors.sky : DS.Colors.borderSubtle, lineWidth: 1.5)
        )
        .shadowResting()
        .animation(DS.Animation.spring, value: isFocused)
        .animation(DS.Animation.spring, value: text.isEmpty)
    }
}
