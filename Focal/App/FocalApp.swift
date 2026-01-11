import SwiftUI
import SwiftData

@main
struct FocalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [TaskItem.self, TodoItem.self])
    }
}
