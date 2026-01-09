import SwiftUI

struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date

    var body: some View {
        NavigationStack {
            VStack(spacing: DS.Spacing.xl) {
                // Today button
                HStack {
                    Spacer()
                    Button("Today") {
                        HapticManager.shared.selection()
                        selectedDate = Date()
                    }
                    .scaledFont(size: 14, weight: .medium, relativeTo: .callout)
                    .foregroundStyle(DS.Colors.primary)
                }
                .padding(.horizontal, DS.Spacing.xl)

                // Calendar
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(DS.Colors.primary)
                .padding(.horizontal, DS.Spacing.md)

                Spacer()
            }
            .padding(.top, DS.Spacing.lg)
            .background(DS.Colors.bgPrimary)
            .navigationTitle("Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .scaledFont(size: 14, weight: .semibold, relativeTo: .callout)
                            .foregroundStyle(DS.Colors.textSecondary)
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    DatePickerSheet(selectedDate: .constant(Date()))
}
