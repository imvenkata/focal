import Foundation
import SwiftUI

struct FloatingTaskInputDraft {
    let title: String
    let icon: String
    let color: TaskColor
    let category: TodoCategory
    let priority: TodoPriority
    let duration: TimeInterval?
    let dueDate: Date?
}

private struct ParsedDateResult {
    let date: Date
    let label: String
    let range: Range<String.Index>
}

struct FloatingTaskInputCard: View {
    let initialPriority: TodoPriority
    let onSubmit: (FloatingTaskInputDraft) -> Void
    let onClose: () -> Void

    @State private var title = ""
    @State private var selectedCategory: TodoCategory = .todo
    @State private var selectedDuration: TimeInterval?
    @State private var showDurationPicker = false
    @State private var isExpanded = false
    @State private var selectedIcon = "✨"
    @State private var selectedColor: TaskColor = .sage

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

            if let parsedDateResult {
                parsedDateBadge(label: parsedDateResult.label)
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
        .glassEffect(in: RoundedRectangle(cornerRadius: DS.Radius.xxl))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.xxl, style: .continuous)
                .stroke(DS.Colors.borderSubtle, lineWidth: DS.Sizes.hairline)
        )
        .onAppear {
            updateSuggestions(for: title)
            DispatchQueue.main.async {
                isTitleFocused = true
            }
        }
        .onChange(of: title) { _, newValue in
            updateSuggestions(for: newValue)
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

            // Auto-selected icon display (non-interactive)
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
            .accessibilityLabel("Task icon: \(selectedIcon)")

            // Voice recorder button
            Button {
                HapticManager.shared.impact(.light)
                // TODO: Implement voice input
            } label: {
                Image(systemName: "mic.fill")
                    .scaledFont(size: 16, weight: .semibold, relativeTo: .callout)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .frame(width: DS.Sizes.iconButtonSize, height: DS.Sizes.iconButtonSize)
                    .background(DS.Colors.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Voice input")
            .accessibilityHint("Record task with your voice")
        }
    }

    private var chipsRow: some View {
        HStack(spacing: DS.Spacing.sm) {
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
            .accessibilityLabel("Create todo")
            .accessibilityHint("Creates the todo")
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

    private var parsedDateResult: ParsedDateResult? {
        parseDateResult(from: title)
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
        if let mapping = IconMapper.shared.findMatch(for: value) {
            selectedIcon = mapping.icon
            selectedColor = mapping.suggestedColor
        } else {
            selectedIcon = "✨"
            selectedColor = .sage
        }
    }

    private func parseDateResult(from text: String) -> ParsedDateResult? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let keywordMatches: [(String, String, Date)] = [
            ("next week", "Next Week", (calendar.date(byAdding: .weekOfYear, value: 1, to: today) ?? today).startOfWeek),
            ("today", "Today", today),
            ("tomorrow", "Tomorrow", calendar.date(byAdding: .day, value: 1, to: today) ?? today)
        ]

        for (keyword, label, date) in keywordMatches {
            if let range = text.range(of: keyword, options: [.caseInsensitive, .diacriticInsensitive]) {
                return ParsedDateResult(date: date, label: label, range: range)
            }
        }

        let weekdayMatches: [(String, Int)] = [
            ("monday", 2),
            ("tuesday", 3),
            ("wednesday", 4),
            ("thursday", 5),
            ("friday", 6),
            ("saturday", 7),
            ("sunday", 1)
        ]

        for (keyword, weekday) in weekdayMatches {
            if let range = text.range(of: keyword, options: [.caseInsensitive, .diacriticInsensitive]) {
                let nextDate = nextWeekday(weekday, from: today)
                return ParsedDateResult(date: nextDate, label: keyword.capitalized, range: range)
            }
        }

        let pattern = #"(\d{1,2})(st|nd|rd|th)?\s+(?:of\s+)?(jan|feb|mar|apr|may|jun|jul|aug|sep|sept|oct|nov|dec)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: range),
              let dayRange = Range(match.range(at: 1), in: text),
              let monthRange = Range(match.range(at: 3), in: text),
              let fullRange = Range(match.range(at: 0), in: text) else {
            return nil
        }

        let dayString = String(text[dayRange])
        let monthKey = String(text[monthRange]).lowercased()
        let monthMap: [String: Int] = [
            "jan": 1,
            "feb": 2,
            "mar": 3,
            "apr": 4,
            "may": 5,
            "jun": 6,
            "jul": 7,
            "aug": 8,
            "sep": 9,
            "sept": 9,
            "oct": 10,
            "nov": 11,
            "dec": 12
        ]

        guard let day = Int(dayString),
              let month = monthMap[monthKey] else {
            return nil
        }

        var components = calendar.dateComponents([.year], from: today)
        components.month = month
        components.day = day
        let currentYearDate = calendar.date(from: components) ?? today
        let date = currentYearDate < today ? calendar.date(byAdding: .year, value: 1, to: currentYearDate) ?? currentYearDate : currentYearDate

        let labelFormatter = DateFormatter()
        labelFormatter.dateFormat = "d MMM"
        let label = labelFormatter.string(from: date)
        return ParsedDateResult(date: date, label: label, range: fullRange)
    }

    private func nextWeekday(_ weekday: Int, from base: Date) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.weekday = weekday
        let seed = calendar.startOfDay(for: base).addingTimeInterval(-1)
        let next = calendar.nextDate(
            after: seed,
            matching: components,
            matchingPolicy: .nextTimePreservingSmallerComponents
        ) ?? base
        return calendar.startOfDay(for: next)
    }

    private func cleanedTitle(from text: String, removing range: Range<String.Index>) -> String {
        var adjustedRange = range
        let prefixCandidates = [" on ", " by ", " at "]
        for prefix in prefixCandidates {
            if text[..<range.lowerBound].lowercased().hasSuffix(prefix) {
                let prefixStart = text.index(range.lowerBound, offsetBy: -prefix.count)
                adjustedRange = prefixStart..<range.upperBound
                break
            }
        }

        var result = text
        result.removeSubrange(adjustedRange)

        result = result.replacingOccurrences(of: #"\\s{2,}"#, with: " ", options: .regularExpression)
        result = result.replacingOccurrences(of: #"(?i)\\b(on|by|at)\\b$"#, with: "", options: .regularExpression)

        let trimSet = CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: "-,"))
        return result.trimmingCharacters(in: trimSet)
    }

    private func submit() {
        guard isTitleValid else { return }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let parsedResult = parseDateResult(from: trimmedTitle)
        let strippedTitle = parsedResult.map { cleanedTitle(from: trimmedTitle, removing: $0.range) } ?? trimmedTitle
        let finalTitle = strippedTitle.isEmpty ? trimmedTitle : strippedTitle
        let draft = FloatingTaskInputDraft(
            title: finalTitle,
            icon: selectedIcon,
            color: selectedColor,
            category: selectedCategory,
            priority: initialPriority,
            duration: selectedDuration,
            dueDate: parsedResult?.date
        )

        onSubmit(draft)
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
    FloatingTaskInputCard(initialPriority: .none, onSubmit: { _ in }, onClose: {})
        .padding(DS.Spacing.lg)
        .background(DS.Colors.background)
}
