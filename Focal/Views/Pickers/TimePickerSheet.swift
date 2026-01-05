import SwiftUI

struct TimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTime: Date
    @Binding var duration: TimeInterval

    @State private var selectedHour: Int
    @State private var selectedMinute: Int
    @State private var selectedDuration: TimeInterval

    private let hours = Array(0...23)
    private let minutes = Array(stride(from: 0, to: 60, by: 5))
    private let durations: [(label: String, value: TimeInterval)] = [
        ("15 min", 15 * 60),
        ("30 min", 30 * 60),
        ("45 min", 45 * 60),
        ("1 hour", 60 * 60),
        ("1.5 hours", 90 * 60),
        ("2 hours", 120 * 60),
        ("3 hours", 180 * 60),
        ("4 hours", 240 * 60)
    ]

    init(selectedTime: Binding<Date>, duration: Binding<TimeInterval>) {
        self._selectedTime = selectedTime
        self._duration = duration

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: selectedTime.wrappedValue)
        self._selectedHour = State(initialValue: components.hour ?? 9)
        self._selectedMinute = State(initialValue: (components.minute ?? 0 / 5) * 5)
        self._selectedDuration = State(initialValue: duration.wrappedValue)
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
                            .fill(DS.Colors.stone100)
                            .frame(width: 32, height: 32)

                        Circle()
                            .stroke(DS.Colors.stone200, lineWidth: 1)
                            .frame(width: 32, height: 32)

                        Image(systemName: "checkmark")
                            .scaledFont(size: 11, weight: .semibold, relativeTo: .caption)
                            .foregroundStyle(DS.Colors.emerald500)
                    }
                    .shadow(color: Color.black.opacity(0.06), radius: 4, y: 2)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Done")
            }
            .padding(.horizontal, DS.Spacing.xl)
            .padding(.top, DS.Spacing.md)
            .padding(.bottom, DS.Spacing.xs)

            ScrollView {
                VStack(spacing: DS.Spacing.xl) {
                    // Premium time wheels
                    VStack(spacing: DS.Spacing.md) {
                        Text("TIME")
                            .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                            .foregroundStyle(DS.Colors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

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
                                .foregroundStyle(DS.Colors.stone300)
                                .offset(y: -8)

                            // Minute wheel
                            PremiumWheelPicker(
                                selection: $selectedMinute,
                                items: minutes,
                                label: "Minute",
                                formatter: { String(format: "%02d", $0) }
                            )
                        }
                    }
                    .padding(.horizontal, DS.Spacing.xl)

                    // Duration selector
                    VStack(spacing: DS.Spacing.md) {
                        Text("DURATION")
                            .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                            .foregroundStyle(DS.Colors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: DS.Spacing.sm) {
                            ForEach(durations, id: \.value) { duration in
                                DurationChip(
                                    label: duration.label,
                                    isSelected: selectedDuration == duration.value
                                ) {
                                    HapticManager.shared.selection()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedDuration = duration.value
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, DS.Spacing.xl)
                    .padding(.bottom, DS.Spacing.xxl)
                }
                .padding(.top, DS.Spacing.sm)
            }
        }
        .background(DS.Colors.background)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func applyChanges() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: selectedTime)
        components.hour = selectedHour
        components.minute = selectedMinute
        components.second = 0

        if let newTime = calendar.date(from: components) {
            selectedTime = newTime
        }
        duration = selectedDuration
    }
}

// MARK: - Time Preview Card
struct TimePreviewCard: View {
    let hour: Int
    let minute: Int
    let duration: TimeInterval

    private var endTime: String {
        let calendar = Calendar.current
        let startDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
        let endDate = startDate.addingTimeInterval(duration)
        return endDate.formattedTime
    }

    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            // Large time display
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "%02d:%02d", hour, minute))
                    .scaledFont(size: 48, weight: .bold, design: .rounded, relativeTo: .largeTitle)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DS.Colors.sky, DS.Colors.sky.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text(hour < 12 ? "AM" : "PM")
                    .scaledFont(size: 18, weight: .semibold, relativeTo: .title3)
                    .foregroundStyle(DS.Colors.stone400)
                    .offset(y: -4)
            }

            // End time preview
            HStack(spacing: DS.Spacing.xs) {
                Text("Ends at")
                    .scaledFont(size: 14, weight: .medium, relativeTo: .callout)
                    .foregroundStyle(DS.Colors.textSecondary)

                Text(endTime)
                    .scaledFont(size: 14, weight: .semibold, design: .monospaced, relativeTo: .callout)
                    .foregroundStyle(DS.Colors.textPrimary)

                Text("·")
                    .scaledFont(size: 14, relativeTo: .callout)
                    .foregroundStyle(DS.Colors.stone300)

                Text(duration.formattedDuration)
                    .scaledFont(size: 14, weight: .medium, relativeTo: .callout)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
        }
        .padding(.vertical, DS.Spacing.xl)
        .padding(.horizontal, DS.Spacing.lg)
        .background(
            LinearGradient(
                colors: [
                    DS.Colors.sky.opacity(0.08),
                    DS.Colors.sky.opacity(0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.xl)
                .stroke(
                    LinearGradient(
                        colors: [DS.Colors.sky.opacity(0.2), DS.Colors.sky.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xl))
        .shadow(color: DS.Colors.sky.opacity(0.1), radius: 12, y: 4)
    }
}

// MARK: - Premium Wheel Picker
struct PremiumWheelPicker: View {
    @Binding var selection: Int
    let items: [Int]
    let label: String
    let formatter: (Int) -> String

    var body: some View {
        VStack(spacing: DS.Spacing.xs) {
            Text(label.uppercased())
                .scaledFont(size: 10, weight: .semibold, relativeTo: .caption2)
                .foregroundStyle(DS.Colors.textSecondary)

            Picker(label, selection: $selection) {
                ForEach(items, id: \.self) { item in
                    Text(formatter(item))
                        .scaledFont(size: 24, weight: .semibold, design: .rounded, relativeTo: .title)
                        .tag(item)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.lg)
                    .fill(DS.Colors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.lg)
                    .stroke(DS.Colors.stone200.opacity(0.5), lineWidth: 1)
            )
            .onChange(of: selection) { _, _ in
                HapticManager.shared.selection()
            }
        }
    }
}

// MARK: - Duration Chip
struct DurationChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .scaledFont(size: 14, weight: isSelected ? .semibold : .medium, relativeTo: .callout)
                .foregroundStyle(isSelected ? .white : DS.Colors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DS.Spacing.md)
                .background(
                    Group {
                        if isSelected {
                            LinearGradient(
                                colors: [DS.Colors.sky, DS.Colors.sky.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        } else {
                            LinearGradient(
                                colors: [DS.Colors.cardBackground, DS.Colors.cardBackground],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.md)
                        .stroke(
                            isSelected ? Color.clear : DS.Colors.stone200,
                            lineWidth: 1
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                .shadow(
                    color: isSelected ? DS.Colors.sky.opacity(0.3) : Color.clear,
                    radius: isSelected ? 8 : 0,
                    y: isSelected ? 4 : 0
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TimePickerSheet(
        selectedTime: .constant(Date()),
        duration: .constant(3600)
    )
}
