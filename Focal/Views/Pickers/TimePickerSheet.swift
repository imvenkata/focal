import SwiftUI

struct TimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTime: Date
    @Binding var duration: TimeInterval

    private let timeSlots: [Date] = {
        let calendar = Calendar.current
        let today = Date()
        var slots: [Date] = []
        for hour in 0..<24 {
            for minute in stride(from: 0, to: 60, by: 15) {
                if let time = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: today) {
                    slots.append(time)
                }
            }
        }
        return slots
    }()

    var body: some View {
        NavigationStack {
            VStack(spacing: DS.Spacing.xl) {
                // Time picker wheel
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(timeSlots, id: \.self) { time in
                                TimeSlotRow(
                                    time: time,
                                    endTime: time.addingTimeInterval(duration),
                                    isSelected: isSameTime(time, selectedTime)
                                )
                                .id(time)
                                .onTapGesture {
                                    HapticManager.shared.timeSnapped()
                                    selectedTime = time
                                }
                            }
                        }
                    }
                    .frame(height: 200)
                    .mask(
                        LinearGradient(
                            colors: [.clear, .black, .black, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .onAppear {
                        // Scroll to selected time
                        if let nearestSlot = findNearestSlot(for: selectedTime) {
                            proxy.scrollTo(nearestSlot, anchor: .center)
                        }
                    }
                }

                Divider()

                // Duration section
                VStack(alignment: .leading, spacing: DS.Spacing.md) {
                    Text("DURATION")
                        .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                        .foregroundStyle(DS.Colors.textSecondary)

                    DurationPickerRow(selectedDuration: $duration)
                }
                .padding(.horizontal, DS.Spacing.xl)

                Spacer()
            }
            .padding(.top, DS.Spacing.lg)
            .background(DS.Colors.background)
            .navigationTitle("Time")
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

    private func isSameTime(_ time1: Date, _ time2: Date) -> Bool {
        let calendar = Calendar.current
        let c1 = calendar.dateComponents([.hour, .minute], from: time1)
        let c2 = calendar.dateComponents([.hour, .minute], from: time2)
        return c1.hour == c2.hour && c1.minute == c2.minute
    }

    private func findNearestSlot(for time: Date) -> Date? {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)
        let roundedMinute = (minute / 15) * 15

        return timeSlots.first { slot in
            let slotHour = calendar.component(.hour, from: slot)
            let slotMinute = calendar.component(.minute, from: slot)
            return slotHour == hour && slotMinute == roundedMinute
        }
    }
}

// MARK: - Time Slot Row
struct TimeSlotRow: View {
    let time: Date
    let endTime: Date
    let isSelected: Bool

    var body: some View {
        HStack {
            Text("\(time.formattedTime) – \(endTime.formattedTime)")
                .scaledFont(size: 16, weight: isSelected ? .semibold : .regular, design: .monospaced, relativeTo: .body)
                .foregroundStyle(isSelected ? DS.Colors.textPrimary : DS.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(isSelected ? DS.Colors.sky.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
        .padding(.horizontal, DS.Spacing.xl)
    }
}

#Preview {
    TimePickerSheet(
        selectedTime: .constant(Date()),
        duration: .constant(3600)
    )
}
