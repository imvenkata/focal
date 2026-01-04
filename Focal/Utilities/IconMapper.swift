import Foundation

struct IconMapping {
    let icon: String
    let label: String
    let suggestedColor: TaskColor
}

final class IconMapper {
    static let shared = IconMapper()

    private let mappings: [String: IconMapping] = [
        // Fitness
        "gym": IconMapping(icon: "🏋️", label: "Gym", suggestedColor: .sage),
        "workout": IconMapping(icon: "🏋️", label: "Workout", suggestedColor: .sage),
        "exercise": IconMapping(icon: "🏃", label: "Exercise", suggestedColor: .sage),
        "run": IconMapping(icon: "🏃", label: "Run", suggestedColor: .sage),
        "running": IconMapping(icon: "🏃", label: "Running", suggestedColor: .sage),
        "jog": IconMapping(icon: "🏃", label: "Jog", suggestedColor: .sage),
        "yoga": IconMapping(icon: "🧘", label: "Yoga", suggestedColor: .lavender),
        "meditation": IconMapping(icon: "🧘", label: "Meditation", suggestedColor: .lavender),
        "meditate": IconMapping(icon: "🧘", label: "Meditate", suggestedColor: .lavender),
        "swim": IconMapping(icon: "🏊", label: "Swim", suggestedColor: .sky),
        "swimming": IconMapping(icon: "🏊", label: "Swimming", suggestedColor: .sky),
        "bike": IconMapping(icon: "🚴", label: "Bike", suggestedColor: .sage),
        "cycling": IconMapping(icon: "🚴", label: "Cycling", suggestedColor: .sage),
        "walk": IconMapping(icon: "🚶", label: "Walk", suggestedColor: .sage),
        "stretch": IconMapping(icon: "🤸", label: "Stretch", suggestedColor: .lavender),

        // Work
        "meeting": IconMapping(icon: "👥", label: "Meeting", suggestedColor: .sky),
        "call": IconMapping(icon: "📞", label: "Call", suggestedColor: .sky),
        "phone": IconMapping(icon: "📞", label: "Phone", suggestedColor: .sky),
        "work": IconMapping(icon: "💼", label: "Work", suggestedColor: .sky),
        "email": IconMapping(icon: "📧", label: "Email", suggestedColor: .sky),
        "office": IconMapping(icon: "🏢", label: "Office", suggestedColor: .sky),
        "presentation": IconMapping(icon: "📊", label: "Presentation", suggestedColor: .sky),
        "project": IconMapping(icon: "📁", label: "Project", suggestedColor: .sky),
        "deadline": IconMapping(icon: "⏰", label: "Deadline", suggestedColor: .coral),
        "interview": IconMapping(icon: "🤝", label: "Interview", suggestedColor: .sky),

        // Food
        "breakfast": IconMapping(icon: "🍳", label: "Breakfast", suggestedColor: .amber),
        "lunch": IconMapping(icon: "🍽️", label: "Lunch", suggestedColor: .amber),
        "dinner": IconMapping(icon: "🍽️", label: "Dinner", suggestedColor: .amber),
        "coffee": IconMapping(icon: "☕", label: "Coffee", suggestedColor: .amber),
        "tea": IconMapping(icon: "🍵", label: "Tea", suggestedColor: .amber),
        "cook": IconMapping(icon: "👨‍🍳", label: "Cook", suggestedColor: .amber),
        "cooking": IconMapping(icon: "👨‍🍳", label: "Cooking", suggestedColor: .amber),
        "meal": IconMapping(icon: "🍽️", label: "Meal", suggestedColor: .amber),
        "snack": IconMapping(icon: "🍎", label: "Snack", suggestedColor: .amber),
        "eat": IconMapping(icon: "🍽️", label: "Eat", suggestedColor: .amber),

        // Study
        "study": IconMapping(icon: "📚", label: "Study", suggestedColor: .lavender),
        "read": IconMapping(icon: "📖", label: "Read", suggestedColor: .lavender),
        "reading": IconMapping(icon: "📖", label: "Reading", suggestedColor: .lavender),
        "learn": IconMapping(icon: "🎓", label: "Learn", suggestedColor: .lavender),
        "learning": IconMapping(icon: "🎓", label: "Learning", suggestedColor: .lavender),
        "homework": IconMapping(icon: "📝", label: "Homework", suggestedColor: .lavender),
        "class": IconMapping(icon: "🎓", label: "Class", suggestedColor: .lavender),
        "lecture": IconMapping(icon: "🎓", label: "Lecture", suggestedColor: .lavender),
        "exam": IconMapping(icon: "📝", label: "Exam", suggestedColor: .coral),
        "test": IconMapping(icon: "📝", label: "Test", suggestedColor: .coral),

        // Sleep & Morning
        "sleep": IconMapping(icon: "😴", label: "Sleep", suggestedColor: .night),
        "wake": IconMapping(icon: "☀️", label: "Wake", suggestedColor: .coral),
        "wakeup": IconMapping(icon: "☀️", label: "Wake Up", suggestedColor: .coral),
        "morning": IconMapping(icon: "🌅", label: "Morning", suggestedColor: .coral),
        "night": IconMapping(icon: "🌙", label: "Night", suggestedColor: .night),
        "bedtime": IconMapping(icon: "🌙", label: "Bedtime", suggestedColor: .night),
        "nap": IconMapping(icon: "💤", label: "Nap", suggestedColor: .lavender),
        "rest": IconMapping(icon: "🛋️", label: "Rest", suggestedColor: .lavender),

        // Chores
        "clean": IconMapping(icon: "🧹", label: "Clean", suggestedColor: .amber),
        "cleaning": IconMapping(icon: "🧹", label: "Cleaning", suggestedColor: .amber),
        "laundry": IconMapping(icon: "👕", label: "Laundry", suggestedColor: .amber),
        "dishes": IconMapping(icon: "🍽️", label: "Dishes", suggestedColor: .amber),
        "vacuum": IconMapping(icon: "🧹", label: "Vacuum", suggestedColor: .amber),
        "organize": IconMapping(icon: "📦", label: "Organize", suggestedColor: .amber),
        "tidy": IconMapping(icon: "🧹", label: "Tidy", suggestedColor: .amber),

        // Shopping
        "shopping": IconMapping(icon: "🛍️", label: "Shopping", suggestedColor: .rose),
        "shop": IconMapping(icon: "🛍️", label: "Shop", suggestedColor: .rose),
        "grocery": IconMapping(icon: "🛒", label: "Grocery", suggestedColor: .amber),
        "groceries": IconMapping(icon: "🛒", label: "Groceries", suggestedColor: .amber),
        "buy": IconMapping(icon: "🛍️", label: "Buy", suggestedColor: .rose),

        // Social
        "friends": IconMapping(icon: "👯", label: "Friends", suggestedColor: .rose),
        "party": IconMapping(icon: "🎉", label: "Party", suggestedColor: .rose),
        "date": IconMapping(icon: "❤️", label: "Date", suggestedColor: .rose),
        "hangout": IconMapping(icon: "👯", label: "Hangout", suggestedColor: .rose),
        "family": IconMapping(icon: "👨‍👩‍👧‍👦", label: "Family", suggestedColor: .rose),
        "birthday": IconMapping(icon: "🎂", label: "Birthday", suggestedColor: .rose),
        "celebrate": IconMapping(icon: "🎉", label: "Celebrate", suggestedColor: .rose),

        // Creative
        "write": IconMapping(icon: "✍️", label: "Write", suggestedColor: .lavender),
        "writing": IconMapping(icon: "✍️", label: "Writing", suggestedColor: .lavender),
        "draw": IconMapping(icon: "🎨", label: "Draw", suggestedColor: .lavender),
        "drawing": IconMapping(icon: "🎨", label: "Drawing", suggestedColor: .lavender),
        "paint": IconMapping(icon: "🎨", label: "Paint", suggestedColor: .lavender),
        "music": IconMapping(icon: "🎵", label: "Music", suggestedColor: .lavender),
        "practice": IconMapping(icon: "🎸", label: "Practice", suggestedColor: .lavender),
        "guitar": IconMapping(icon: "🎸", label: "Guitar", suggestedColor: .lavender),
        "piano": IconMapping(icon: "🎹", label: "Piano", suggestedColor: .lavender),
        "code": IconMapping(icon: "💻", label: "Code", suggestedColor: .sky),
        "coding": IconMapping(icon: "💻", label: "Coding", suggestedColor: .sky),
        "design": IconMapping(icon: "🎨", label: "Design", suggestedColor: .lavender),

        // Travel
        "travel": IconMapping(icon: "✈️", label: "Travel", suggestedColor: .sky),
        "flight": IconMapping(icon: "✈️", label: "Flight", suggestedColor: .sky),
        "drive": IconMapping(icon: "🚗", label: "Drive", suggestedColor: .sky),
        "commute": IconMapping(icon: "🚗", label: "Commute", suggestedColor: .slate),
        "train": IconMapping(icon: "🚆", label: "Train", suggestedColor: .sky),
        "bus": IconMapping(icon: "🚌", label: "Bus", suggestedColor: .sky),

        // Health
        "doctor": IconMapping(icon: "🏥", label: "Doctor", suggestedColor: .coral),
        "dentist": IconMapping(icon: "🦷", label: "Dentist", suggestedColor: .coral),
        "therapy": IconMapping(icon: "💭", label: "Therapy", suggestedColor: .lavender),
        "medicine": IconMapping(icon: "💊", label: "Medicine", suggestedColor: .coral),
        "appointment": IconMapping(icon: "📅", label: "Appointment", suggestedColor: .sky),

        // Entertainment
        "movie": IconMapping(icon: "🎬", label: "Movie", suggestedColor: .rose),
        "tv": IconMapping(icon: "📺", label: "TV", suggestedColor: .slate),
        "game": IconMapping(icon: "🎮", label: "Game", suggestedColor: .rose),
        "gaming": IconMapping(icon: "🎮", label: "Gaming", suggestedColor: .rose),
        "podcast": IconMapping(icon: "🎧", label: "Podcast", suggestedColor: .lavender),

        // Self-care
        "shower": IconMapping(icon: "🚿", label: "Shower", suggestedColor: .sky),
        "skincare": IconMapping(icon: "🧴", label: "Skincare", suggestedColor: .rose),
        "relax": IconMapping(icon: "🧘", label: "Relax", suggestedColor: .lavender),
        "journal": IconMapping(icon: "📓", label: "Journal", suggestedColor: .lavender),
        "journaling": IconMapping(icon: "📓", label: "Journaling", suggestedColor: .lavender),
    ]

    private init() {}

    func findMatch(for title: String) -> IconMapping? {
        let lower = title.lowercased().trimmingCharacters(in: .whitespaces)

        // 1. Exact match
        if let exact = mappings[lower] {
            return exact
        }

        // 2. Contains keyword
        for (keyword, mapping) in mappings {
            if lower.contains(keyword) {
                return mapping
            }
        }

        // 3. Word-by-word
        let words = lower.split(separator: " ").map(String.init)
        for word in words {
            if let match = mappings[word] {
                return match
            }
        }

        return nil
    }

    func suggestIcon(for title: String) -> String {
        findMatch(for: title)?.icon ?? "📝"
    }

    func suggestColor(for title: String) -> TaskColor {
        findMatch(for: title)?.suggestedColor ?? .sage
    }
}
