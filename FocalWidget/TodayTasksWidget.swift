import WidgetKit
import SwiftUI

// MARK: - Widget Configuration

struct TodayTasksWidget: Widget {
    let kind: String = "TodayTasksWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayTasksProvider()) { entry in
            TodayTasksWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Today's Tasks")
        .description("View and complete your tasks for today.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Timeline Provider

struct TodayTasksProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayTasksEntry {
        TodayTasksEntry(
            date: Date(),
            tasks: TodayTasksEntry.sampleTasks,
            completedCount: 1,
            totalCount: 3
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayTasksEntry) -> Void) {
        let entry = TodayTasksEntry(
            date: Date(),
            tasks: loadTasks(),
            completedCount: loadCompletedCount(),
            totalCount: loadTotalCount()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayTasksEntry>) -> Void) {
        let tasks = loadTasks()
        let entry = TodayTasksEntry(
            date: Date(),
            tasks: tasks,
            completedCount: loadCompletedCount(),
            totalCount: loadTotalCount()
        )

        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    // MARK: - Data Loading (App Group shared data)

    private func loadTasks() -> [WidgetTask] {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.focal.app") else {
            return TodayTasksEntry.sampleTasks
        }

        guard let data = sharedDefaults.data(forKey: "widgetTasks"),
              let tasks = try? JSONDecoder().decode([WidgetTask].self, from: data) else {
            return TodayTasksEntry.sampleTasks
        }

        return tasks
    }

    private func loadCompletedCount() -> Int {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.focal.app") else {
            return 0
        }
        return sharedDefaults.integer(forKey: "widgetCompletedCount")
    }

    private func loadTotalCount() -> Int {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.focal.app") else {
            return 0
        }
        return sharedDefaults.integer(forKey: "widgetTotalCount")
    }
}

// MARK: - Timeline Entry

struct TodayTasksEntry: TimelineEntry {
    let date: Date
    let tasks: [WidgetTask]
    let completedCount: Int
    let totalCount: Int

    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    static let sampleTasks: [WidgetTask] = [
        WidgetTask(id: UUID(), title: "Morning workout", icon: "figure.run", colorHex: "#4CAF50", startTime: Date(), isCompleted: true),
        WidgetTask(id: UUID(), title: "Team standup", icon: "person.3", colorHex: "#2196F3", startTime: Date().addingTimeInterval(3600), isCompleted: false),
        WidgetTask(id: UUID(), title: "Review PRs", icon: "doc.text", colorHex: "#9C27B0", startTime: Date().addingTimeInterval(7200), isCompleted: false)
    ]
}

// MARK: - Widget Task Model

struct WidgetTask: Codable, Identifiable {
    let id: UUID
    let title: String
    let icon: String
    let colorHex: String
    let startTime: Date
    let isCompleted: Bool

    var color: Color {
        Color(hex: colorHex) ?? .blue
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }
}

// MARK: - Widget Views

struct TodayTasksWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: TodayTasksEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: TodayTasksEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text("Today")
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                Text("\(entry.completedCount)/\(entry.totalCount)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }

            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 6)

                Circle()
                    .trim(from: 0, to: entry.progress)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(Int(entry.progress * 100))%")
                        .font(.system(size: 20, weight: .bold, design: .rounded))

                    Text("done")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Next task
            if let nextTask = entry.tasks.first(where: { !$0.isCompleted }) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(nextTask.color)
                        .frame(width: 8, height: 8)

                    Text(nextTask.title)
                        .font(.caption)
                        .lineLimit(1)
                }
            }
        }
        .padding()
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: TodayTasksEntry

    var body: some View {
        HStack(spacing: 16) {
            // Progress section
            VStack(alignment: .leading, spacing: 8) {
                Text("Today")
                    .font(.headline)
                    .fontWeight(.bold)

                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)

                    Circle()
                        .trim(from: 0, to: entry.progress)
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("\(entry.completedCount)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))

                        Text("of \(entry.totalCount)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 80, height: 80)
            }
            .frame(width: 100)

            // Tasks list
            VStack(alignment: .leading, spacing: 6) {
                ForEach(entry.tasks.prefix(4)) { task in
                    WidgetTaskRow(task: task, compact: true)
                }

                if entry.tasks.count > 4 {
                    Text("+\(entry.tasks.count - 4) more")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    let entry: TodayTasksEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today's Tasks")
                        .font(.headline)
                        .fontWeight(.bold)

                    Text(entry.date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Progress badge
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)

                    Text("\(entry.completedCount)/\(entry.totalCount)")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.green)
                        .frame(width: geo.size.width * entry.progress, height: 8)
                }
            }
            .frame(height: 8)

            // Tasks list
            VStack(spacing: 8) {
                ForEach(entry.tasks.prefix(6)) { task in
                    WidgetTaskRow(task: task, compact: false)
                }

                if entry.tasks.count > 6 {
                    HStack {
                        Spacer()
                        Text("+\(entry.tasks.count - 6) more tasks")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }

            Spacer(minLength: 0)

            // Open app hint
            HStack {
                Spacer()
                Label("Open Focal", systemImage: "arrow.up.right.square")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}

// MARK: - Widget Task Row

struct WidgetTaskRow: View {
    let task: WidgetTask
    let compact: Bool

    var body: some View {
        HStack(spacing: 10) {
            // Checkbox
            ZStack {
                Circle()
                    .stroke(task.isCompleted ? Color.green : task.color, lineWidth: 2)
                    .frame(width: compact ? 18 : 22, height: compact ? 18 : 22)

                if task.isCompleted {
                    Circle()
                        .fill(Color.green)
                        .frame(width: compact ? 18 : 22, height: compact ? 18 : 22)

                    Image(systemName: "checkmark")
                        .font(.system(size: compact ? 10 : 12, weight: .bold))
                        .foregroundStyle(.white)
                }
            }

            // Task info
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(compact ? .caption : .subheadline)
                    .fontWeight(.medium)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                    .lineLimit(1)

                if !compact {
                    Text(task.formattedTime)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Color indicator
            if !compact {
                RoundedRectangle(cornerRadius: 2)
                    .fill(task.color)
                    .frame(width: 4, height: 24)
            }
        }
        .padding(.vertical, compact ? 2 : 4)
    }
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    TodayTasksWidget()
} timeline: {
    TodayTasksEntry(date: Date(), tasks: TodayTasksEntry.sampleTasks, completedCount: 1, totalCount: 3)
}

#Preview(as: .systemMedium) {
    TodayTasksWidget()
} timeline: {
    TodayTasksEntry(date: Date(), tasks: TodayTasksEntry.sampleTasks, completedCount: 1, totalCount: 3)
}

#Preview(as: .systemLarge) {
    TodayTasksWidget()
} timeline: {
    TodayTasksEntry(date: Date(), tasks: TodayTasksEntry.sampleTasks, completedCount: 1, totalCount: 3)
}
