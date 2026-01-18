import SwiftUI

struct AIQuickAddBar: View {
    @Environment(AICoordinator.self) private var ai
    @Environment(TaskStore.self) private var taskStore
    @Environment(TodoStore.self) private var todoStore

    @State private var inputText: String = ""
    @State private var isProcessing: Bool = false
    @State private var parsedTask: ParsedTask?
    @State private var showParsedPreview: Bool = false
    @State private var error: String?

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Error banner
            if let error {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(error)
                    Spacer()
                    Button {
                        self.error = nil
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                .font(.caption)
                .foregroundStyle(DS.Colors.error)
                .padding(DS.Spacing.sm)
                .background(DS.Colors.error.opacity(0.1))
            }

            // Parsed preview
            if showParsedPreview, let parsed = parsedTask {
                ParsedTaskPreview(
                    task: parsed,
                    onAddToSchedule: { addToSchedule(parsed) },
                    onAddToTodo: { addToTodo(parsed) },
                    onEdit: { showParsedPreview = false },
                    onDismiss: {
                        showParsedPreview = false
                        parsedTask = nil
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Input bar
            HStack(spacing: DS.Spacing.sm) {
                // AI indicator
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                // Text field
                TextField("Add task with AI... \"Gym tomorrow 7am\"", text: $inputText)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .submitLabel(.done)
                    .onSubmit { Task { await processInput() } }

                // Submit button
                if !inputText.isEmpty {
                    Button {
                        Task { await processInput() }
                    } label: {
                        Group {
                            if isProcessing {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 28))
                            }
                        }
                        .foregroundStyle(DS.Colors.primary)
                    }
                    .disabled(isProcessing)
                }
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
            .background(DS.Colors.cardBackground)
        }
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xl))
        .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
    }

    private func processInput() async {
        guard !inputText.isEmpty else { return }
        guard ai.isConfigured else {
            error = "AI not configured. Go to Settings to set up."
            return
        }

        isProcessing = true
        error = nil
        HapticManager.shared.impact(.medium)

        do {
            let parsed = try await ai.parseTask(inputText)
            self.parsedTask = parsed

            withAnimation(DS.Animation.spring) {
                showParsedPreview = true
            }

            HapticManager.shared.notification(.success)

        } catch let llmError as LLMError {
            error = llmError.localizedDescription
            HapticManager.shared.notification(.error)
        } catch {
            self.error = error.localizedDescription
            HapticManager.shared.notification(.error)
        }

        isProcessing = false
    }

    private func addToSchedule(_ parsed: ParsedTask) {
        let task = parsed.toTaskItem()
        taskStore.addTask(task)

        // Reset state
        inputText = ""
        parsedTask = nil
        showParsedPreview = false
        isFocused = false

        HapticManager.shared.notification(.success)
    }

    private func addToTodo(_ parsed: ParsedTask) {
        let todo = parsed.toTodoItem()
        todoStore.addTodo(todo)

        // Reset state
        inputText = ""
        parsedTask = nil
        showParsedPreview = false
        isFocused = false

        HapticManager.shared.notification(.success)
    }
}

// MARK: - Parsed Task Preview

struct ParsedTaskPreview: View {
    let task: ParsedTask
    let onAddToSchedule: () -> Void
    let onAddToTodo: () -> Void
    let onEdit: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            // Header with dismiss
            HStack {
                Text("AI parsed your task")
                    .font(.caption)
                    .foregroundStyle(DS.Colors.textMuted)

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(DS.Colors.textMuted)
                }
            }

            // Task preview card
            HStack(spacing: DS.Spacing.md) {
                Text(task.icon ?? "📌")
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.subheadline.weight(.medium))

                    HStack(spacing: DS.Spacing.sm) {
                        if let date = task.date {
                            Label(date, systemImage: "calendar")
                        }
                        if let time = task.time {
                            Label(time, systemImage: "clock")
                        }
                        if let duration = task.durationMinutes {
                            Label("\(duration)m", systemImage: "timer")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(DS.Colors.textSecondary)
                }

                Spacer()

                // Confidence indicator
                ConfidenceIndicator(confidence: task.confidence)
            }
            .padding()
            .background(DS.Colors.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))

            // Action buttons
            HStack(spacing: DS.Spacing.sm) {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                        .font(.caption.weight(.medium))
                }
                .buttonStyle(.bordered)

                Spacer()

                if task.date != nil && task.time != nil {
                    Button(action: onAddToSchedule) {
                        Label("Add to Schedule", systemImage: "calendar.badge.plus")
                            .font(.caption.weight(.medium))
                    }
                    .buttonStyle(.borderedProminent)
                }

                if task.time == nil {
                    Button(action: onAddToTodo) {
                        Label("Add to Todos", systemImage: "checklist")
                            .font(.caption.weight(.medium))
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button(action: onAddToTodo) {
                        Label("Add to Todos", systemImage: "checklist")
                            .font(.caption.weight(.medium))
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .background(DS.Colors.cardBackground)
    }
}

// MARK: - Confidence Indicator

struct ConfidenceIndicator: View {
    let confidence: Double

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(i < filledDots ? DS.Colors.success : DS.Colors.textMuted.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
    }

    private var filledDots: Int {
        if confidence >= 0.9 { return 3 }
        if confidence >= 0.7 { return 2 }
        return 1
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Spacer()
        AIQuickAddBar()
            .padding()
    }
    .environment(AICoordinator())
    .environment(TaskStore())
    .environment(TodoStore())
}
