import SwiftUI

struct WhenPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedDate: Date
    @Binding var selectedTime: Date
    @Binding var selectedDuration: TimeInterval
    @Binding var recurrence: RecurrenceOption
    @Binding var selectedRecurrenceDays: Set<Int>

    @State private var selectedHour: Int
    @State private var selectedMinute: Int
    @State private var selectedDurationMinutes: Int

    private let hours = Array(0...23)
    private let minutes = Array(stride(from: 0, to: 60, by: 5))

    private static let durations: [(label: String, minutes: Int)] = [
        ("15m", 15),
        ("30m", 30),
        ("45m", 45),
        ("1h", 60),
        ("1.5h", 90),
        ("2h", 120),
        ("2.5h", 150),
        ("3h", 180),
        ("4h", 240),
        ("5h", 300),
        ("6h", 360)
    ]

    init(
        selectedDate: Binding<Date>,
        selectedTime: Binding<Date>,
        selectedDuration: Binding<TimeInterval>,
        recurrence: Binding<RecurrenceOption>,
        selectedRecurrenceDays: Binding<Set<Int>>
    ) {
        self._selectedDate = selectedDate
        self._selectedTime = selectedTime
        self._selectedDuration = selectedDuration
        self._recurrence = recurrence
        self._selectedRecurrenceDays = selectedRecurrenceDays

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: selectedTime.wrappedValue)
        self._selectedHour = State(initialValue: components.hour ?? 9)
        self._selectedMinute = State(initialValue: (components.minute ?? 0 / 5) * 5)

        // Find nearest duration or default to 1 hour
        let durationMinutes = Int(selectedDuration.wrappedValue / 60)
        let nearestDuration = Self.durations.min(by: { abs($0.minutes - durationMinutes) < abs($1.minutes - durationMinutes) })?.minutes ?? 60
        self._selectedDurationMinutes = State(initialValue: nearestDuration)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Premium close button
            HStack {
                Spacer()

                Button {
                    applyChanges()
                    dismiss()
                } label: {
                    ZStack {
                        Circle()
                            .fill(DS.Colors.surfaceSecondary)
                            .frame(width: 32, height: 32)

                        Circle()
                            .stroke(DS.Colors.borderSubtle, lineWidth: 1)
                            .frame(width: 32, height: 32)

                        Image(systemName: "checkmark")
                            .scaledFont(size: 11, weight: .semibold, relativeTo: .caption)
                            .foregroundStyle(DS.Colors.accent)
                    }
                    .shadowResting()
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Done")
            }
            .padding(.horizontal, DS.Spacing.xl)
            .padding(.top, DS.Spacing.md)
            .padding(.bottom, DS.Spacing.xs)

            ScrollView {
                VStack(spacing: DS.Spacing.xxl) {
                    // Section 1: Date
                    dateSection

                    // Section 2: Time
                    timeSection

                    // Section 3: Recurrence
                    recurrenceSection

                    // Section 4: Duration
                    durationSection
                }
                .padding(.top, DS.Spacing.lg)
                .padding(.bottom, DS.Spacing.xxxl)
            }
        }
        .background(DS.Colors.bgPrimary)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Date Section
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack {
                Text("DATE")
                    .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                    .foregroundStyle(DS.Colors.textSecondary)

                Spacer()

                Button("Today") {
                    HapticManager.shared.selection()
                    selectedDate = Date()
                }
                .scaledFont(size: 14, weight: .medium, relativeTo: .callout)
                .foregroundStyle(DS.Colors.primary)
            }
            .padding(.horizontal, DS.Spacing.xl)

            DatePicker(
                "Select Date",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(DS.Colors.primary)
            .padding(.horizontal, DS.Spacing.md)
        }
    }

    // MARK: - Time Section
    private var timeSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("TIME")
                .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                .foregroundStyle(DS.Colors.textSecondary)
                .padding(.horizontal, DS.Spacing.xl)

            HStack(spacing: DS.Spacing.md) {
                // Hour wheel
                PremiumWheelPicker(
                    selection: $selectedHour,
                    items: hours,
                    label: "Hour",
                    formatter: { String(format: "%02d", $0) }
                )

                Text(":")
                    .scaledFont(size: 32, weight: .bold, design: .rounded, relativeTo: .largeTitle)
                    .foregroundStyle(DS.Colors.textTertiary)
                    .offset(y: -8)

                // Minute wheel
                PremiumWheelPicker(
                    selection: $selectedMinute,
                    items: minutes,
                    label: "Min",
                    formatter: { String(format: "%02d", $0) }
                )
            }
            .padding(.horizontal, DS.Spacing.lg)
        }
    }

    // MARK: - Recurrence Section
    private var recurrenceSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("RECURRENCE")
                .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                .foregroundStyle(DS.Colors.textSecondary)
                .padding(.horizontal, DS.Spacing.xl)

            // Scrollable pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.sm) {
                    ForEach(RecurrenceOption.allCases) { option in
                        RecurrencePill(
                            option: option,
                            isSelected: recurrence == option
                        ) {
                            HapticManager.shared.selection()
                            recurrence = option
                        }
                    }
                }
                .padding(.horizontal, DS.Spacing.xl)
            }

            // Custom day picker (conditionally shown)
            if recurrence == .custom {
                RepeatDaysPicker(selectedDays: $selectedRecurrenceDays, accentColor: DS.Colors.primary)
                    .padding(.horizontal, DS.Spacing.xl)
                    .padding(.top, DS.Spacing.sm)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(DS.Animation.quick, value: recurrence)
    }

    // MARK: - Duration Section
    private var durationSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("DURATION")
                .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                .foregroundStyle(DS.Colors.textSecondary)
                .padding(.horizontal, DS.Spacing.xl)

            PremiumDurationPicker(
                selectedMinutes: $selectedDurationMinutes,
                durations: Self.durations
            )
            .padding(.horizontal, DS.Spacing.lg)
        }
    }

    // MARK: - Apply Changes
    private func applyChanges() {
        // Update time
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: selectedTime)
        components.hour = selectedHour
        components.minute = selectedMinute
        components.second = 0

        if let newTime = calendar.date(from: components) {
            selectedTime = newTime
        }

        // Update duration
        selectedDuration = TimeInterval(selectedDurationMinutes * 60)
    }
}

// MARK: - Recurrence Pill
struct RecurrencePill: View {
    let option: RecurrenceOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(option.rawValue)
                .scaledFont(size: 14, weight: isSelected ? .semibold : .regular, relativeTo: .callout)
                .foregroundStyle(isSelected ? .white : DS.Colors.textPrimary)
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.sm)
                .background(isSelected ? DS.Colors.primary : DS.Colors.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    WhenPickerSheet(
        selectedDate: .constant(Date()),
        selectedTime: .constant(Date()),
        selectedDuration: .constant(3600),
        recurrence: .constant(.none),
        selectedRecurrenceDays: .constant([])
    )
}
