import Foundation
import SwiftUI

struct FloatingTaskInputDraft {
    let title: String
    let icon: String
    let color: TaskColor
    let category: FloatingTaskCategory
    let duration: TimeInterval?
    let parsedDateLabel: String?
}

enum FloatingTaskCategory: String, CaseIterable, Identifiable {
    case todo
    case routine
    case event

    var id: String { rawValue }

    var label: String {
        switch self {
        case .todo: return "To-do"
        case .routine: return "Routine"
        case .event: return "Event"
        }
    }

    var icon: String {
        switch self {
        case .todo: return "📋"
        case .routine: return "🔁"
        case .event: return "📅"
        }
    }

    var tint: Color {
        switch self {
        case .todo: return DS.Colors.slate
        case .routine: return DS.Colors.sage
        case .event: return DS.Colors.sky
        }
    }
}

struct FloatingTaskInputCard: View {
    let onSubmit: (FloatingTaskInputDraft) -> Void
    let onClose: () -> Void

    @State private var title = ""
    @State private var selectedCategory: FloatingTaskCategory = .todo
    @State private var selectedDuration: TimeInterval?
    @State private var showDurationPicker = false
    @State private var isExpanded = false
    @State private var selectedIcon = "✨"
    @State private var selectedColor: TaskColor = .sage
    @State private var isIconPinned = false
    @State private var showIconPicker = false

    @FocusState private var isTitleFocused: Bool

    private let durationOptions: [DurationOption] = [
        DurationOption(minutes: 15),
        DurationOption(minutes: 30),
        DurationOption(minutes: 60),
        DurationOption(minutes: 90),
        DurationOption(minutes: 120)
    ]

    var body: some View {
        VStack(spacing: DS.Spacing.sm) {
            handleButton

            inputRow

            if let parsedDateLabel {
                parsedDateBadge(label: parsedDateLabel)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            if isExpanded && !suggestedBreakdown.isEmpty {
                breakdownPreview
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            chipsRow

            if showDurationPicker {
                durationPicker
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.top, DS.Spacing.sm)
        .padding(.bottom, DS.Spacing.lg)
        .background(DS.Colors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xxl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.xxl, style: .continuous)
                .stroke(DS.Colors.borderSubtle, lineWidth: DS.Sizes.hairline)
        )
        .shadowLifted()
        .onAppear {
            updateSuggestions(for: title)
            DispatchQueue.main.async {
                isTitleFocused = true
            }
        }
        .onChange(of: title) { newValue in
            updateSuggestions(for: newValue)
        }
        .sheet(isPresented: $showIconPicker) {
            IconPickerView(selectedIcon: $selectedIcon) {
                isIconPinned = true
                showIconPicker = false
            }
        }
    }

    private var handleButton: some View {
        Button {
            withAnimation(DS.Animation.spring) {
                isExpanded.toggle()
            }
            HapticManager.shared.selection()
        } label: {
            Capsule()
                .fill(DS.Colors.divider)
                .frame(width: DS.Sizes.sheetHandle, height: DS.Spacing.xs)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isExpanded ? "Collapse quick add" : "Expand quick add")
        .accessibilityHint("Shows or hides suggested steps")
    }

    private var inputRow: some View {
        HStack(spacing: DS.Spacing.md) {
            TextField("What needs to be done?", text: $title)
                .scaledFont(size: 20, weight: .semibold, relativeTo: .title3)
                .foregroundStyle(DS.Colors.textPrimary)
                .focused($isTitleFocused)
                .submitLabel(.done)
                .textInputAutocapitalization(.sentences)
                .onSubmit { submit() }
                .accessibilityLabel("Task title")
                .accessibilityHint("Enter what you need to do")

            Button {
                showIconPicker = true
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                        .fill(selectedColor.lightColor)

                    RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                        .stroke(selectedColor.color, lineWidth: DS.Sizes.hairline * 1.5)

                    Text(selectedIcon)
                        .scaledFont(size: 22, relativeTo: .title2)
                }
                .frame(
                    width: DS.Sizes.iconButtonSize + DS.Spacing.sm,
                    height: DS.Sizes.iconButtonSize + DS.Spacing.sm
                )
                .shadowColored(selectedColor.color)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Choose icon")
            .accessibilityHint("Opens the icon picker")
        }
    }

    private var chipsRow: some View {
        HStack(spacing: DS.Spacing.sm) {
            Menu {
                ForEach(FloatingTaskCategory.allCases) { category in
                    Button {
                        selectedCategory = category
                        HapticManager.shared.impact(.light)
                    } label: {
                        HStack(spacing: DS.Spacing.sm) {
                            Text(category.icon)
                            Text(category.label)
                        }
                    }
                }
            } label: {
                chipView(
                    label: selectedCategory.label,
                    icon: selectedCategory.icon,
                    isActive: true
                )
            }
            .accessibilityLabel("Category")
            .accessibilityHint("Double tap to change category")

            Button {
                withAnimation(DS.Animation.spring) {
                    showDurationPicker.toggle()
                }
                HapticManager.shared.selection()
            } label: {
                chipView(
                    label: durationLabel,
                    icon: "⏱️",
                    isActive: showDurationPicker
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Duration")
            .accessibilityHint("Double tap to choose duration")

            Button {
                HapticManager.shared.selection()
            } label: {
                chipView(label: "More", icon: "•••", isActive: false)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("More options")
            .accessibilityHint("Opens extra options")

            Spacer(minLength: DS.Spacing.sm)

            Button {
                HapticManager.shared.impact(.light)
            } label: {
                Image(systemName: "mic.fill")
                    .scaledFont(size: 14, weight: .semibold, relativeTo: .caption)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .frame(width: DS.Sizes.iconButtonSize, height: DS.Sizes.iconButtonSize)
                    .background(DS.Colors.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Voice input")
            .accessibilityHint("Starts voice input")

            Button {
                submit()
            } label: {
                Image(systemName: "arrow.up")
                    .scaledFont(size: 16, weight: .bold, relativeTo: .callout)
                    .foregroundStyle(.white)
                    .frame(width: DS.Sizes.minTouchTarget, height: DS.Sizes.minTouchTarget)
                    .background(isTitleValid ? DS.Colors.textPrimary : DS.Colors.dividerStrong)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            }
            .buttonStyle(.plain)
            .disabled(!isTitleValid)
            .accessibilityLabel("Add task")
            .accessibilityHint("Creates the task")
        }
    }

    private var durationPicker: some View {
        HStack(spacing: DS.Spacing.sm) {
            ForEach(durationOptions) { option in
                Button {
                    selectedDuration = option.interval
                    withAnimation(DS.Animation.spring) {
                        showDurationPicker = false
                    }
                    HapticManager.shared.impact(.light)
                } label: {
                    Text(option.label)
                        .scaledFont(size: 13, weight: .semibold, relativeTo: .caption)
                        .foregroundStyle(selectedDuration == option.interval ? DS.Colors.textInverse : DS.Colors.textPrimary)
                        .padding(.horizontal, DS.Spacing.md)
                        .padding(.vertical, DS.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                                .fill(selectedDuration == option.interval ? DS.Colors.textPrimary : DS.Colors.surfaceSecondary)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Duration \(option.label)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var breakdownPreview: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack(spacing: DS.Spacing.xs) {
                Text("✨")
                    .scaledFont(size: 12, relativeTo: .caption)

                Text("Suggested steps")
                    .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                    .foregroundStyle(DS.Colors.textSecondary)
            }

            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                ForEach(suggestedBreakdown, id: \.self) { step in
                    HStack(spacing: DS.Spacing.sm) {
                        Circle()
                            .fill(DS.Colors.lavender)
                            .frame(width: DS.Spacing.xs * 1.5, height: DS.Spacing.xs * 1.5)

                        Text(step)
                            .scaledFont(size: 13, relativeTo: .callout)
                            .foregroundStyle(DS.Colors.textPrimary)
                    }
                }
            }
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous))
    }

    private func parsedDateBadge(label: String) -> some View {
        HStack(spacing: DS.Spacing.xs) {
            Image(systemName: "calendar")
                .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                .foregroundStyle(DS.Colors.success)

            Text(label)
                .scaledFont(size: 12, weight: .semibold, relativeTo: .caption)
                .foregroundStyle(DS.Colors.success)

            Image(systemName: "checkmark")
                .scaledFont(size: 10, weight: .bold, relativeTo: .caption2)
                .foregroundStyle(DS.Colors.success)
        }
        .padding(.horizontal, DS.Spacing.sm)
        .padding(.vertical, DS.Spacing.xs)
        .background(DS.Colors.successLight.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous))
    }

    private func chipView(label: String, icon: String, isActive: Bool) -> some View {
        HStack(spacing: DS.Spacing.xs) {
            Text(icon)
                .scaledFont(size: 13, relativeTo: .caption)

            Text(label)
                .scaledFont(size: 13, weight: .medium, relativeTo: .caption)
                .foregroundStyle(DS.Colors.textPrimary)
        }
        .padding(.horizontal, DS.Spacing.sm)
        .padding(.vertical, DS.Spacing.xs)
        .background(isActive ? DS.Colors.surfaceSecondary : DS.Colors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                .stroke(DS.Colors.borderSubtle, lineWidth: DS.Sizes.hairline)
        )
    }

    private var durationLabel: String {
        guard let selectedDuration else { return "Duration" }
        return selectedDuration.formattedDuration
    }

    private var isTitleValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var parsedDateLabel: String? {
        parseDateLabel(from: title)
    }

    private var suggestedBreakdown: [String] {
        let lower = title.lowercased()
        if lower.contains("shop") || lower.contains("grocery") {
            return ["Make list", "Check pantry", "Go to store"]
        }
        if lower.contains("appointment") || lower.contains("doctor") {
            return ["Confirm time", "Gather documents", "Set reminder"]
        }
        if lower.contains("party") || lower.contains("birthday") {
            return ["Guest list", "Send invites", "Order food"]
        }
        return []
    }

    private func updateSuggestions(for value: String) {
        guard !isIconPinned else { return }
        if let mapping = IconMapper.shared.findMatch(for: value) {
            selectedIcon = mapping.icon
            selectedColor = mapping.suggestedColor
        } else {
            selectedIcon = "✨"
            selectedColor = .sage
        }
    }

    private func parseDateLabel(from text: String) -> String? {
        let lower = text.lowercased()
        let keywordLabels: [(String, String)] = [
            ("next week", "Next Week"),
            ("today", "Today"),
            ("tomorrow", "Tomorrow"),
            ("monday", "Monday"),
            ("tuesday", "Tuesday"),
            ("wednesday", "Wednesday"),
            ("thursday", "Thursday"),
            ("friday", "Friday"),
            ("saturday", "Saturday"),
            ("sunday", "Sunday")
        ]

        for (keyword, label) in keywordLabels where lower.contains(keyword) {
            return label
        }

        let pattern = #"(\d{1,2})(st|nd|rd|th)?\s+(jan|feb|mar|apr|may|jun|jul|aug|sep|sept|oct|nov|dec)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        let range = NSRange(lower.startIndex..., in: lower)
        guard let match = regex.firstMatch(in: lower, options: [], range: range),
              let dayRange = Range(match.range(at: 1), in: lower),
              let monthRange = Range(match.range(at: 3), in: lower) else {
            return nil
        }

        let day = String(lower[dayRange])
        let monthKey = String(lower[monthRange])
        let monthMap: [String: String] = [
            "jan": "Jan",
            "feb": "Feb",
            "mar": "Mar",
            "apr": "Apr",
            "may": "May",
            "jun": "Jun",
            "jul": "Jul",
            "aug": "Aug",
            "sep": "Sep",
            "sept": "Sep",
            "oct": "Oct",
            "nov": "Nov",
            "dec": "Dec"
        ]
        return "\(day) \(monthMap[monthKey, default: monthKey.capitalized])"
    }

    private func submit() {
        guard isTitleValid else { return }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let draft = FloatingTaskInputDraft(
            title: trimmedTitle,
            icon: selectedIcon,
            color: selectedColor,
            category: selectedCategory,
            duration: selectedDuration,
            parsedDateLabel: parsedDateLabel
        )

        onSubmit(draft)
        HapticManager.shared.notification(.success)
        onClose()
    }
}

private struct DurationOption: Identifiable {
    let minutes: Int

    var id: Int { minutes }

    var interval: TimeInterval {
        TimeInterval(minutes * 60)
    }

    var label: String {
        if minutes < 60 { return "\(minutes)m" }
        let hours = minutes / 60
        let remainder = minutes % 60
        if remainder == 0 {
            return "\(hours)h"
        }
        return "\(hours)h \(remainder)m"
    }
}

#Preview {
    FloatingTaskInputCard(onSubmit: { _ in }, onClose: {})
        .padding(DS.Spacing.lg)
        .background(DS.Colors.background)
}
