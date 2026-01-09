import SwiftUI

struct TimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTime: Date
    @Binding var duration: TimeInterval

    @State private var selectedHour: Int
    @State private var selectedMinute: Int
    @State private var selectedDurationMinutes: Int

    private let hours = Array(0...23)
    private let minutes = Array(stride(from: 0, to: 60, by: 5))

    init(selectedTime: Binding<Date>, duration: Binding<TimeInterval>) {
        self._selectedTime = selectedTime
        self._duration = duration

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: selectedTime.wrappedValue)
        self._selectedHour = State(initialValue: components.hour ?? 9)
        self._selectedMinute = State(initialValue: (components.minute ?? 0 / 5) * 5)

        // Find nearest duration or default to 1 hour
        let durationMinutes = Int(duration.wrappedValue / 60)
        let nearestDuration = Self.durations.min(by: { abs($0.minutes - durationMinutes) < abs($1.minutes - durationMinutes) })?.minutes ?? 60
        self._selectedDurationMinutes = State(initialValue: nearestDuration)
    }

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
                    // Premium time & duration wheels
                    VStack(spacing: DS.Spacing.md) {
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

                            // Duration wheel
                            PremiumDurationPicker(
                                selectedMinutes: $selectedDurationMinutes,
                                durations: Self.durations
                            )
                        }
                    }
                    .padding(.horizontal, DS.Spacing.lg)
                    .padding(.bottom, DS.Spacing.xxl)
                }
                .padding(.top, DS.Spacing.lg)
            }
        }
        .background(DS.Colors.bgPrimary)
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
        duration = TimeInterval(selectedDurationMinutes * 60)
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
                            colors: [DS.Colors.primary, DS.Colors.primary.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text(hour < 12 ? "AM" : "PM")
                    .scaledFont(size: 18, weight: .semibold, relativeTo: .title3)
                    .foregroundStyle(DS.Colors.textTertiary)
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
                .foregroundStyle(DS.Colors.textTertiary)

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
                    DS.Colors.primary.opacity(0.08),
                    DS.Colors.primary.opacity(0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.xl)
                .stroke(
                    LinearGradient(
                        colors: [DS.Colors.primary.opacity(0.2), DS.Colors.primary.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xl))
        .shadow(color: DS.Colors.primary.opacity(0.1), radius: 12, y: 4)
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
                .foregroundStyle(DS.Colors.primary.opacity(0.8))

            ZStack {
                // Premium gradient background
                RoundedRectangle(cornerRadius: DS.Radius.xl)
                    .fill(
                        LinearGradient(
                            colors: [
                                DS.Colors.surfacePrimary,
                                DS.Colors.surfaceSecondary
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Picker
                Picker(label, selection: $selection) {
                    ForEach(items, id: \.self) { item in
                        Text(formatter(item))
                            .scaledFont(size: 32, weight: .bold, design: .rounded, relativeTo: .largeTitle)
                            .foregroundStyle(
                                item == selection ?
                                LinearGradient(
                                    colors: [DS.Colors.primary, DS.Colors.primary.opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ) :
                                LinearGradient(
                                    colors: [DS.Colors.textTertiary, DS.Colors.textTertiary],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .tag(item)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 140)

                // Center highlight overlay
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: DS.Radius.md)
                        .fill(DS.Colors.primary.opacity(0.06))
                        .frame(height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: DS.Radius.md)
                                .stroke(
                                    LinearGradient(
                                        colors: [DS.Colors.primary.opacity(0.3), DS.Colors.primary.opacity(0.1)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                    Spacer()
                }
                .allowsHitTesting(false)
            }
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xl))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.xl)
                    .stroke(
                        LinearGradient(
                            colors: [DS.Colors.borderSubtle.opacity(0.6), DS.Colors.surfaceSecondary.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, y: 2)
            .onChange(of: selection) { _, _ in
                HapticManager.shared.selection()
            }
        }
    }
}

// MARK: - Premium Duration Picker
struct PremiumDurationPicker: View {
    @Binding var selectedMinutes: Int
    let durations: [(label: String, minutes: Int)]

    var body: some View {
        VStack(spacing: DS.Spacing.xs) {
            Text("DURATION")
                .scaledFont(size: 10, weight: .semibold, relativeTo: .caption2)
                .foregroundStyle(DS.Colors.accent.opacity(0.9))

            ZStack {
                // Premium gradient background
                RoundedRectangle(cornerRadius: DS.Radius.xl)
                    .fill(
                        LinearGradient(
                            colors: [
                                DS.Colors.accent.opacity(0.06),
                                DS.Colors.accent.opacity(0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Picker
                Picker("Duration", selection: $selectedMinutes) {
                    ForEach(durations, id: \.minutes) { duration in
                        Text(duration.label)
                            .scaledFont(size: 24, weight: .bold, design: .rounded, relativeTo: .title)
                            .foregroundStyle(
                                duration.minutes == selectedMinutes ?
                                LinearGradient(
                                    colors: [DS.Colors.accent, DS.Colors.accent.opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ) :
                                LinearGradient(
                                    colors: [DS.Colors.textTertiary, DS.Colors.textTertiary],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .tag(duration.minutes)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 140)

                // Center highlight overlay
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: DS.Radius.md)
                        .fill(DS.Colors.accent.opacity(0.08))
                        .frame(height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: DS.Radius.md)
                                .stroke(
                                    LinearGradient(
                                        colors: [DS.Colors.accent.opacity(0.4), DS.Colors.accent.opacity(0.2)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                    Spacer()
                }
                .allowsHitTesting(false)
            }
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xl))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.xl)
                    .stroke(
                        LinearGradient(
                            colors: [DS.Colors.accent.opacity(0.3), DS.Colors.accent.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: DS.Colors.accent.opacity(0.08), radius: 8, y: 2)
            .onChange(of: selectedMinutes) { _, _ in
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
                                colors: [DS.Colors.primary, DS.Colors.primary.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        } else {
                            LinearGradient(
                                colors: [DS.Colors.surfacePrimary, DS.Colors.surfacePrimary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.md)
                        .stroke(
                            isSelected ? Color.clear : DS.Colors.borderSubtle,
                            lineWidth: 1
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                .shadow(
                    color: isSelected ? DS.Colors.primary.opacity(0.3) : Color.clear,
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
