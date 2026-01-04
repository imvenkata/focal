import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) ?? self
    }

    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }

    var dayOfWeek: Int {
        Calendar.current.component(.weekday, from: self) - 1
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    var isWeekend: Bool {
        Calendar.current.isDateInWeekend(self)
    }

    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }

    func isSameWeek(as date: Date) -> Bool {
        Calendar.current.isDate(self, equalTo: date, toGranularity: .weekOfYear)
    }

    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    func adding(hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: self) ?? self
    }

    func adding(minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: minutes, to: self) ?? self
    }

    var dayNumber: Int {
        Calendar.current.component(.day, from: self)
    }

    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self)
    }

    var yearNumber: Int {
        Calendar.current.component(.year, from: self)
    }

    var shortWeekdayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: self)
    }

    var hour: Int {
        Calendar.current.component(.hour, from: self)
    }

    var minute: Int {
        Calendar.current.component(.minute, from: self)
    }

    func withTime(hour: Int, minute: Int = 0) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: self) ?? self
    }

    static var weekDates: [Date] {
        let today = Date()
        let startOfWeek = today.startOfWeek
        return (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        if isToday {
            return "Today"
        } else if isTomorrow {
            return "Tomorrow"
        } else if isYesterday {
            return "Yesterday"
        } else {
            formatter.dateFormat = "E, d MMM"
            return formatter.string(from: self)
        }
    }

    var formattedFullDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: self)
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}

// MARK: - TimeInterval Extensions
extension TimeInterval {
    var hours: Int {
        Int(self) / 3600
    }

    var minutes: Int {
        Int(self) % 3600 / 60
    }

    var formattedDuration: String {
        let h = hours
        let m = minutes
        if h > 0 && m > 0 {
            return "\(h)h \(m)m"
        } else if h > 0 {
            return "\(h)h"
        } else {
            return "\(m)m"
        }
    }
}
