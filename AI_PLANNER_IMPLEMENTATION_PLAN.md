# AI-Assisted Planner Implementation Plan

## Executive Summary

This document outlines a phased implementation plan for adding AI-assisted planning features to Focal, designed to compete with Tiimo (iPhone App of the Year 2025) and Structured. The plan leverages the existing architecture (SwiftData, @Observable stores, service layer pattern) while introducing new AI capabilities through a combination of on-device intelligence and optional cloud APIs.

### Competitive Positioning

**Target**: Privacy-first AI planner with energy-optimized scheduling.

| Differentiator | vs Tiimo | vs Structured |
|----------------|----------|---------------|
| **On-device AI** | Tiimo uses cloud AI | Structured uses cloud AI |
| **Energy-aware scheduling** | Has mood check-ins, not predictive | Basic energy tracking |
| **Weekly review wizard** | No structured reflection | No review feature |
| **Predictive insights** | Basic patterns | No analytics |

---

## Architecture Overview

### Proposed AI Service Layer

```
┌─────────────────────────────────────────────────────────────────┐
│                         Views (SwiftUI)                         │
│  ┌─────────────┬─────────────┬─────────────┬─────────────────┐ │
│  │ BrainDump   │ FocusTimer  │ Widgets     │ Live Activities │ │
│  │ View        │ View        │ Extension   │ Extension       │ │
│  └─────────────┴─────────────┴─────────────┴─────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│                    TaskStore / TodoStore                        │
├─────────────────────────────────────────────────────────────────┤
│                      AICoordinator                              │
│  ┌─────────┬─────────┬─────────┬─────────┬─────────┬─────────┐ │
│  │Voice    │ NLP     │Schedule │BrainDump│ Focus   │Calendar │ │
│  │Input    │ Parser  │Optimizer│Organizer│ Session │ Sync    │ │
│  ├─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤ │
│  │Insights │Suggest  │AutoRe-  │Pattern  │ Widget  │ Live    │ │
│  │Engine   │Service  │schedule │Tracker  │ Manager │ Activity│ │
│  └─────────┴─────────┴─────────┴─────────┴─────────┴─────────┘ │
├─────────────────────────────────────────────────────────────────┤
│              UserPatternStore (Learning Data)                   │
├─────────────────────────────────────────────────────────────────┤
│          SwiftData (Persistence) + EventKit (Calendar)         │
└─────────────────────────────────────────────────────────────────┘
```

### Key Design Principles

1. **Privacy First**: On-device processing for sensitive data; cloud API optional
2. **Graceful Degradation**: App works fully without AI; AI enhances experience
3. **Progressive Disclosure**: Simple by default, power features discoverable
4. **Non-Intrusive**: AI suggestions are gentle nudges, not interruptions
5. **Transparent**: User always understands why AI made a suggestion

---

## Phase 1: Foundation & Quick Wins (Weeks 1-3)

### 1.1 Smart Suggestions Enhancement

**Goal**: Upgrade existing `IconMapper` to smarter suggestion system

**Files to Create/Modify**:
- `Focal/Services/AI/SuggestionService.swift` (new)
- `Focal/Models/TaskSuggestion.swift` (new)
- `Focal/Utilities/IconMapper.swift` (enhance)

**Features**:
```swift
struct TaskSuggestion {
    let icon: String?
    let color: TaskColor?
    let estimatedDuration: TimeInterval?
    let suggestedEnergyLevel: Int?
    let confidence: Float // 0.0-1.0
}

@Observable
class SuggestionService {
    func suggest(for title: String) -> TaskSuggestion
    func suggestDuration(for title: String, basedOn history: [TaskItem]) -> TimeInterval?
    func suggestTimeSlot(for task: TaskItem, on date: Date) -> DateInterval?
}
```

**Implementation**:
- Expand keyword dictionary (200+ entries)
- Add duration estimation from historical average
- Energy level suggestions based on task category
- Color suggestions based on task type clustering

**UI Changes**:
- Show suggestion chips when creating tasks
- "AI suggests: 45 min, High energy" badge
- One-tap to accept suggestion

---

### 1.2 User Pattern Tracking

**Goal**: Build foundation for learning user behavior

**Files to Create**:
- `Focal/Models/UserPattern.swift`
- `Focal/Services/PatternTracker.swift`
- `Focal/ViewModels/UserPatternStore.swift`

**Data Model**:
```swift
@Model
class UserPattern {
    var id: UUID
    var patternType: PatternType // .productivity, .energy, .completion, .timing
    var dayOfWeek: Int? // 0-6
    var hourOfDay: Int? // 0-23
    var metric: String // e.g., "completion_rate", "avg_duration_accuracy"
    var value: Double
    var sampleSize: Int
    var updatedAt: Date
}

enum PatternType: String, Codable {
    case productivity    // Tasks completed per hour/day
    case energy         // Energy level at different times
    case completion     // Completion rates by task type
    case timing         // Preferred times for task types
    case duration       // Actual vs estimated duration
}
```

**Tracked Metrics**:
- Completion rate by hour of day
- Completion rate by day of week
- Average task duration by category
- Duration estimation accuracy
- Energy level patterns
- Most productive time windows

---

### 1.3 Natural Language Task Input (Basic)

**Goal**: Parse simple natural language into structured tasks

**Files to Create**:
- `Focal/Services/AI/NLPParser.swift`
- `Focal/Services/AI/DateTimeExtractor.swift`

**Parsing Capabilities**:
```swift
// Input: "Gym tomorrow 7am for 1 hour"
// Output:
ParsedTask(
    title: "Gym",
    startTime: /* tomorrow 7am */,
    duration: 3600, // 1 hour
    icon: "🏋️",
    color: .sage,
    energyLevel: 4
)

// Input: "Call mom this weekend"
// Output:
ParsedTask(
    title: "Call mom",
    startTime: /* Saturday or Sunday */,
    duration: 1800, // default 30 min
    icon: "📞",
    color: .rose,
    isFlexible: true
)
```

**Implementation Approach**:
- Use Apple's `NaturalLanguage` framework for tokenization
- Custom date/time parser for relative dates ("tomorrow", "next week", "this weekend")
- Duration parser ("1 hour", "30 min", "2h", "1.5 hours")
- Fall back to existing IconMapper for suggestions

**UI Integration**:
- New "Quick Add" field with NLP parsing
- Show parsed interpretation before creating
- Easy edit if parsing is wrong

---

### 1.4 Voice Input (Speech-to-Text)

**Goal**: Enable hands-free task creation via voice

**Files to Create**:
- `Focal/Services/AI/VoiceInputService.swift`
- `Focal/Views/Components/VoiceInputButton.swift`
- `Focal/Views/Components/VoiceInputSheet.swift`

**Implementation Options**:

| Option | Pros | Cons | Recommendation |
|--------|------|------|----------------|
| **Apple Speech Framework** | Free, on-device, private, offline capable | Less accurate for complex phrases | Primary choice |
| **Whisper (on-device)** | Very accurate, open source | Large model size (~40MB), battery | Optional download |
| **Cloud API (Whisper/Deepgram)** | Most accurate, handles accents well | Requires network, privacy concerns, cost | Premium option |

**Recommended Approach**: Apple Speech Framework as default, with optional Whisper for power users.

**VoiceInputService Implementation**:
```swift
import Speech
import AVFoundation

@Observable
class VoiceInputService: NSObject {
    // State
    var isListening: Bool = false
    var isAuthorized: Bool = false
    var transcribedText: String = ""
    var error: VoiceInputError?

    // Audio
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer: SFSpeechRecognizer?

    // Settings
    var language: Locale = .current
    var enablePunctuation: Bool = true
    var autoStopAfterSilence: TimeInterval = 2.0

    override init() {
        self.speechRecognizer = SFSpeechRecognizer(locale: language)
        super.init()
    }

    /// Request microphone and speech recognition permissions
    func requestAuthorization() async -> Bool {
        // Request Speech Recognition
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }

        // Request Microphone
        let micStatus = await AVAudioApplication.requestRecordPermission()

        isAuthorized = (speechStatus == .authorized) && micStatus
        return isAuthorized
    }

    /// Start listening and transcribing
    func startListening() throws {
        guard isAuthorized else { throw VoiceInputError.notAuthorized }
        guard let speechRecognizer, speechRecognizer.isAvailable else {
            throw VoiceInputError.recognizerUnavailable
        }

        // Cancel any existing task
        stopListening()

        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else { throw VoiceInputError.requestFailed }

        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.addsPunctuation = enablePunctuation

        // Configure audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        // Start recognition
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self else { return }

            if let result {
                self.transcribedText = result.bestTranscription.formattedString

                // Auto-stop after final result
                if result.isFinal {
                    self.stopListening()
                }
            }

            if let error {
                self.error = .recognitionFailed(error.localizedDescription)
                self.stopListening()
            }
        }

        // Start audio engine
        audioEngine.prepare()
        try audioEngine.start()

        isListening = true
        HapticManager.shared.impact(.medium)
    }

    /// Stop listening and finalize
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        recognitionRequest = nil
        recognitionTask = nil
        isListening = false

        HapticManager.shared.impact(.light)
    }

    /// Reset for new input
    func reset() {
        stopListening()
        transcribedText = ""
        error = nil
    }
}

enum VoiceInputError: Error, LocalizedError {
    case notAuthorized
    case recognizerUnavailable
    case requestFailed
    case recognitionFailed(String)
    case audioSessionFailed

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Microphone or speech recognition not authorized"
        case .recognizerUnavailable:
            return "Speech recognizer not available for this language"
        case .requestFailed:
            return "Failed to create recognition request"
        case .recognitionFailed(let message):
            return "Recognition failed: \(message)"
        case .audioSessionFailed:
            return "Failed to configure audio session"
        }
    }
}
```

**VoiceInputButton Component**:
```swift
struct VoiceInputButton: View {
    @State private var voiceService = VoiceInputService()
    @State private var showSheet = false
    let onTranscribed: (String) -> Void

    var body: some View {
        Button {
            showSheet = true
        } label: {
            Image(systemName: "mic.fill")
                .font(.system(size: 20))
                .foregroundStyle(DS.Colors.primary)
                .frame(width: DS.Sizes.iconButton, height: DS.Sizes.iconButton)
                .background(DS.Colors.surfaceSecondary)
                .clipShape(Circle())
        }
        .accessibilityLabel("Voice input")
        .accessibilityHint("Tap to add task by voice")
        .sheet(isPresented: $showSheet) {
            VoiceInputSheet(
                voiceService: voiceService,
                onComplete: { text in
                    onTranscribed(text)
                    showSheet = false
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}
```

**VoiceInputSheet UI**:
```swift
struct VoiceInputSheet: View {
    @Bindable var voiceService: VoiceInputService
    let onComplete: (String) -> Void

    @State private var parsedTask: ParsedTask?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: DS.Spacing.xl) {
            // Header
            Text("Speak your task")
                .font(.title2.weight(.semibold))
                .foregroundStyle(DS.Colors.textPrimary)

            // Waveform animation
            VoiceWaveformView(isActive: voiceService.isListening)
                .frame(height: 60)

            // Transcribed text
            Text(voiceService.transcribedText.isEmpty ? "Listening..." : voiceService.transcribedText)
                .font(.body)
                .foregroundStyle(voiceService.transcribedText.isEmpty ? DS.Colors.textMuted : DS.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding()
                .background(DS.Colors.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))

            // Parsed preview (if available)
            if let parsed = parsedTask {
                ParsedTaskPreview(task: parsed)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Spacer()

            // Action buttons
            HStack(spacing: DS.Spacing.lg) {
                // Cancel
                Button("Cancel") {
                    voiceService.reset()
                    dismiss()
                }
                .buttonStyle(.bordered)

                // Mic toggle / Done
                if voiceService.isListening {
                    Button {
                        voiceService.stopListening()
                    } label: {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(DS.Colors.danger)
                    }
                } else if !voiceService.transcribedText.isEmpty {
                    Button("Add Task") {
                        onComplete(voiceService.transcribedText)
                        voiceService.reset()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button {
                        try? voiceService.startListening()
                    } label: {
                        Image(systemName: "mic.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(DS.Colors.primary)
                    }
                }

                // Retry
                if !voiceService.transcribedText.isEmpty && !voiceService.isListening {
                    Button {
                        voiceService.reset()
                        try? voiceService.startListening()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .onAppear {
            Task {
                await voiceService.requestAuthorization()
                try? voiceService.startListening()
            }
        }
        .onDisappear {
            voiceService.reset()
        }
        .onChange(of: voiceService.transcribedText) { _, newValue in
            // Parse in real-time
            if !newValue.isEmpty {
                parsedTask = NLPParser.shared.parse(newValue)
            }
        }
    }
}

// Animated waveform visualization
struct VoiceWaveformView: View {
    let isActive: Bool
    @State private var animationPhase: CGFloat = 0

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<7, id: \.self) { index in
                Capsule()
                    .fill(DS.Colors.primary.opacity(isActive ? 1 : 0.3))
                    .frame(width: 4, height: barHeight(for: index))
                    .animation(
                        isActive ? .easeInOut(duration: 0.3).repeatForever().delay(Double(index) * 0.05) : .default,
                        value: isActive
                    )
            }
        }
    }

    func barHeight(for index: Int) -> CGFloat {
        let baseHeight: CGFloat = 20
        let variance: CGFloat = isActive ? 40 : 0
        return baseHeight + variance * sin(CGFloat(index) * 0.5 + animationPhase)
    }
}
```

**Integration with Quick Add**:
```swift
// In TaskFormView or QuickAddView
struct QuickAddBar: View {
    @State private var inputText = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            // Text input
            TextField("Add a task...", text: $inputText)
                .textFieldStyle(.plain)
                .focused($isFocused)

            // Voice input button
            VoiceInputButton { transcribedText in
                inputText = transcribedText
                // Trigger NLP parsing
                processInput(transcribedText)
            }

            // Submit button
            if !inputText.isEmpty {
                Button {
                    processInput(inputText)
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(DS.Colors.primary)
                }
            }
        }
        .padding()
        .background(DS.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xl))
    }

    func processInput(_ text: String) {
        let parsed = NLPParser.shared.parse(text)
        // Create task from parsed result
    }
}
```

**Voice Commands (Future Enhancement)**:
```swift
enum VoiceCommand {
    case addTask(String)           // "Add gym tomorrow"
    case showDay(Date)             // "Show me tomorrow"
    case complete(String)          // "Complete gym"
    case reschedule(String, Date)  // "Move gym to Friday"
    case whatNext                  // "What's next?"
    case summary                   // "What's my day look like?"
}

extension NLPParser {
    func parseCommand(_ text: String) -> VoiceCommand? {
        let lowercased = text.lowercased()

        if lowercased.hasPrefix("add ") || lowercased.hasPrefix("create ") {
            return .addTask(String(text.dropFirst(4)))
        }
        if lowercased.hasPrefix("show ") || lowercased.hasPrefix("open ") {
            // Parse date from rest
            return .showDay(extractDate(from: text))
        }
        if lowercased.hasPrefix("complete ") || lowercased.hasPrefix("done ") {
            return .complete(String(text.dropFirst(9)))
        }
        if lowercased.contains("what's next") || lowercased.contains("next task") {
            return .whatNext
        }
        if lowercased.contains("my day") || lowercased.contains("today look") {
            return .summary
        }

        // Default: treat as task creation
        return .addTask(text)
    }
}
```

**Permissions & Info.plist**:
```xml
<!-- Add to Info.plist -->
<key>NSSpeechRecognitionUsageDescription</key>
<string>Focal uses speech recognition to let you add tasks by voice.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Focal needs microphone access to transcribe your voice into tasks.</string>
```

**Accessibility Considerations**:
- VoiceOver compatible announcements for state changes
- Visual feedback (waveform) for deaf/hard-of-hearing users
- Haptic feedback for start/stop recording
- Text fallback always available

**Error Handling UI**:
```swift
struct VoicePermissionDeniedView: View {
    var body: some View {
        VStack(spacing: DS.Spacing.lg) {
            Image(systemName: "mic.slash")
                .font(.system(size: 48))
                .foregroundStyle(DS.Colors.textMuted)

            Text("Microphone Access Required")
                .font(.headline)

            Text("Enable microphone access in Settings to use voice input.")
                .font(.subheadline)
                .foregroundStyle(DS.Colors.textSecondary)
                .multilineTextAlignment(.center)

            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
```

---

### 1.5 Brain Dump → AI Organize (Competitive Must-Have)

**Goal**: Let users dump all their thoughts, AI organizes into actionable tasks

**Why Critical**: This is Tiimo's killer feature - *"braindump everything and I will plan, prioritize, and sort your tasks for you."*

**Files to Create**:
- `Focal/Services/AI/BrainDumpOrganizer.swift`
- `Focal/Views/AI/BrainDumpView.swift`
- `Focal/Views/AI/BrainDumpResultView.swift`
- `Focal/Models/BrainDumpSession.swift`

**Data Model**:
```swift
struct BrainDumpSession {
    let id: UUID
    let rawInput: String
    let createdAt: Date
    let organizedOutput: OrganizedPlan
}

struct OrganizedPlan {
    let tasks: [ParsedTask]
    let categories: [TaskCategory: [ParsedTask]]
    let priorities: PriorityBreakdown
    let suggestedSchedule: [ScheduledTask]?
    let warnings: [PlanWarning] // "This looks like a lot for one day"
}

struct PriorityBreakdown {
    let mustDo: [ParsedTask]      // High priority
    let shouldDo: [ParsedTask]    // Medium priority
    let couldDo: [ParsedTask]     // Low priority
    let someday: [ParsedTask]     // No deadline
}
```

**BrainDumpOrganizer Service**:
```swift
@Observable
class BrainDumpOrganizer {
    /// Process raw brain dump text into organized tasks
    func organize(_ rawText: String) async -> OrganizedPlan {
        // 1. Split into potential tasks (by line, comma, "and", etc.)
        let fragments = splitIntoFragments(rawText)

        // 2. Parse each fragment with NLP
        let parsedTasks = fragments.compactMap { NLPParser.shared.parse($0) }

        // 3. Categorize tasks
        let categorized = categorize(parsedTasks)

        // 4. Prioritize based on deadlines, keywords ("urgent", "important")
        let prioritized = prioritize(parsedTasks)

        // 5. Optionally suggest schedule
        let schedule = suggestSchedule(for: parsedTasks)

        // 6. Generate warnings
        let warnings = analyzeLoad(parsedTasks)

        return OrganizedPlan(
            tasks: parsedTasks,
            categories: categorized,
            priorities: prioritized,
            suggestedSchedule: schedule,
            warnings: warnings
        )
    }

    private func splitIntoFragments(_ text: String) -> [String] {
        // Split by newlines, bullet points, numbers, commas
        let separators = CharacterSet.newlines
            .union(CharacterSet(charactersIn: "•●○◦-"))

        var fragments = text.components(separatedBy: separators)

        // Also split on "and" for compound sentences
        fragments = fragments.flatMap {
            $0.components(separatedBy: " and ")
        }

        // Clean up
        return fragments
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.count > 2 }
    }

    private func prioritize(_ tasks: [ParsedTask]) -> PriorityBreakdown {
        var mustDo: [ParsedTask] = []
        var shouldDo: [ParsedTask] = []
        var couldDo: [ParsedTask] = []
        var someday: [ParsedTask] = []

        for task in tasks {
            if task.hasDeadline && task.daysUntilDeadline <= 1 {
                mustDo.append(task)
            } else if task.hasDeadline && task.daysUntilDeadline <= 7 {
                shouldDo.append(task)
            } else if task.hasDeadline {
                couldDo.append(task)
            } else {
                someday.append(task)
            }

            // Override: urgent keywords
            if task.title.lowercased().contains(["urgent", "asap", "important", "critical"]) {
                mustDo.append(task)
            }
        }

        return PriorityBreakdown(
            mustDo: mustDo,
            shouldDo: shouldDo,
            couldDo: couldDo,
            someday: someday
        )
    }
}
```

**BrainDumpView UI**:
```swift
struct BrainDumpView: View {
    @State private var rawText = ""
    @State private var isProcessing = false
    @State private var result: OrganizedPlan?
    @State private var showResult = false

    @Environment(\.dismiss) private var dismiss

    private let organizer = BrainDumpOrganizer()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: DS.Spacing.sm) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 40))
                        .foregroundStyle(DS.Colors.aiAccent)

                    Text("Brain Dump")
                        .font(.title2.weight(.semibold))

                    Text("Dump everything on your mind.\nI'll organize it for you.")
                        .font(.subheadline)
                        .foregroundStyle(DS.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding()

                // Text input area
                TextEditor(text: $rawText)
                    .font(.body)
                    .padding()
                    .frame(maxHeight: .infinity)
                    .background(DS.Colors.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                    .padding(.horizontal)
                    .overlay(alignment: .topLeading) {
                        if rawText.isEmpty {
                            Text("Buy groceries, call mom, finish report by Friday, gym tomorrow morning, dentist appointment next week, plan birthday party, respond to emails...")
                                .font(.body)
                                .foregroundStyle(DS.Colors.textMuted)
                                .padding(.horizontal, DS.Spacing.xl)
                                .padding(.top, DS.Spacing.xl)
                                .allowsHitTesting(false)
                        }
                    }

                // Voice input option
                HStack {
                    VoiceInputButton { transcribed in
                        rawText += (rawText.isEmpty ? "" : "\n") + transcribed
                    }

                    Text("or speak your thoughts")
                        .font(.caption)
                        .foregroundStyle(DS.Colors.textMuted)
                }
                .padding()

                // Organize button
                Button {
                    Task {
                        await processInput()
                    }
                } label: {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "sparkles")
                        }
                        Text(isProcessing ? "Organizing..." : "Organize This")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: DS.Sizes.buttonHeight)
                    .background(rawText.isEmpty ? DS.Colors.textMuted : DS.Colors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                }
                .disabled(rawText.isEmpty || isProcessing)
                .padding()
            }
            .navigationTitle("Brain Dump")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showResult) {
                if let result {
                    BrainDumpResultView(plan: result) {
                        dismiss()
                    }
                }
            }
        }
    }

    private func processInput() async {
        isProcessing = true
        HapticManager.shared.impact(.medium)

        result = await organizer.organize(rawText)

        isProcessing = false
        showResult = true
        HapticManager.shared.notification(.success)
    }
}
```

**BrainDumpResultView**:
```swift
struct BrainDumpResultView: View {
    let plan: OrganizedPlan
    let onDone: () -> Void

    @State private var selectedTasks: Set<UUID> = []
    @State private var showScheduleOptions = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Spacing.xl) {
                    // Summary header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(plan.tasks.count) tasks found")
                                .font(.title3.weight(.semibold))
                            Text("Review and add to your plan")
                                .font(.subheadline)
                                .foregroundStyle(DS.Colors.textSecondary)
                        }
                        Spacer()

                        Button("Select All") {
                            selectedTasks = Set(plan.tasks.map { $0.id })
                        }
                        .font(.subheadline)
                    }
                    .padding(.horizontal)

                    // Warnings
                    ForEach(plan.warnings, id: \.message) { warning in
                        WarningBanner(warning: warning)
                    }

                    // Priority sections
                    if !plan.priorities.mustDo.isEmpty {
                        TaskSection(
                            title: "Must Do",
                            subtitle: "Urgent or due soon",
                            icon: "exclamationmark.circle.fill",
                            color: DS.Colors.danger,
                            tasks: plan.priorities.mustDo,
                            selectedTasks: $selectedTasks
                        )
                    }

                    if !plan.priorities.shouldDo.isEmpty {
                        TaskSection(
                            title: "Should Do",
                            subtitle: "Due this week",
                            icon: "arrow.up.circle.fill",
                            color: DS.Colors.warning,
                            tasks: plan.priorities.shouldDo,
                            selectedTasks: $selectedTasks
                        )
                    }

                    if !plan.priorities.couldDo.isEmpty {
                        TaskSection(
                            title: "Could Do",
                            subtitle: "Has deadline",
                            icon: "circle.fill",
                            color: DS.Colors.primary,
                            tasks: plan.priorities.couldDo,
                            selectedTasks: $selectedTasks
                        )
                    }

                    if !plan.priorities.someday.isEmpty {
                        TaskSection(
                            title: "Someday",
                            subtitle: "No deadline",
                            icon: "clock.fill",
                            color: DS.Colors.textMuted,
                            tasks: plan.priorities.someday,
                            selectedTasks: $selectedTasks
                        )
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Organized")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") { }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Add \(selectedTasks.count)") {
                        addSelectedTasks()
                    }
                    .disabled(selectedTasks.isEmpty)
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: DS.Spacing.sm) {
                    Button {
                        showScheduleOptions = true
                    } label: {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                            Text("Add & Schedule for Me")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: DS.Sizes.buttonHeight)
                        .background(DS.Colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                    }
                    .disabled(selectedTasks.isEmpty)

                    Button {
                        addSelectedTasks()
                    } label: {
                        Text("Add to To-Do List")
                            .font(.subheadline)
                            .foregroundStyle(DS.Colors.primary)
                    }
                    .disabled(selectedTasks.isEmpty)
                }
                .padding()
                .background(DS.Colors.cardBackground)
            }
        }
    }

    private func addSelectedTasks() {
        // Add selected tasks to TodoStore
        onDone()
    }
}

struct TaskSection: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let tasks: [ParsedTask]
    @Binding var selectedTasks: Set<UUID>

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                }
                Spacer()
                Text("\(tasks.count)")
                    .font(.subheadline)
                    .foregroundStyle(DS.Colors.textMuted)
            }

            ForEach(tasks) { task in
                BrainDumpTaskRow(
                    task: task,
                    isSelected: selectedTasks.contains(task.id),
                    onToggle: {
                        if selectedTasks.contains(task.id) {
                            selectedTasks.remove(task.id)
                        } else {
                            selectedTasks.insert(task.id)
                        }
                    }
                )
            }
        }
        .padding()
        .background(DS.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        .padding(.horizontal)
    }
}
```

**Entry Point Integration**:
```swift
// Add to main navigation or FAB menu
struct QuickActionsMenu: View {
    @State private var showBrainDump = false

    var body: some View {
        Menu {
            Button {
                showBrainDump = true
            } label: {
                Label("Brain Dump", systemImage: "brain.head.profile")
            }

            Button {
                // Quick add single task
            } label: {
                Label("Quick Add", systemImage: "plus")
            }
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: DS.Sizes.fab))
        }
        .sheet(isPresented: $showBrainDump) {
            BrainDumpView()
        }
    }
}
```

---

## Phase 2: Intelligent Scheduling (Weeks 5-8)

### 2.1 Auto-Schedule Engine

**Goal**: Automatically find optimal time slots for unscheduled tasks

**Files to Create**:
- `Focal/Services/AI/ScheduleOptimizer.swift`
- `Focal/Services/AI/TimeSlotFinder.swift`
- `Focal/Models/ScheduleConstraint.swift`

**Algorithm**:
```swift
class ScheduleOptimizer {
    /// Find best time slots for a task
    func findOptimalSlots(
        for task: TodoItem,
        on date: Date,
        existingTasks: [TaskItem],
        userPatterns: [UserPattern],
        constraints: [ScheduleConstraint]
    ) -> [SuggestedTimeSlot]

    /// Auto-schedule multiple tasks
    func autoSchedule(
        tasks: [TodoItem],
        dateRange: DateInterval,
        existingTasks: [TaskItem],
        userPatterns: [UserPattern]
    ) -> SchedulePlan
}

struct SuggestedTimeSlot {
    let startTime: Date
    let endTime: Date
    let score: Float // 0-1, higher is better
    let reasons: [String] // Why this slot is good
}
```

**Scheduling Factors** (weighted scoring):
| Factor | Weight | Description |
|--------|--------|-------------|
| Energy Match | 25% | Task energy vs user's typical energy at that time |
| Gap Fit | 20% | How well task fits in available gap |
| Deadline Proximity | 20% | Urgency based on due date |
| Similar Task History | 15% | When user typically does this type of task |
| Buffer Time | 10% | Avoid back-to-back high-energy tasks |
| Day Balance | 10% | Distribute workload across day |

**UI Components**:
- "Schedule for me" button on TodoItem
- Time slot suggestions with reasoning
- Drag unscheduled todos to "AI Schedule" drop zone
- Bulk auto-schedule for multiple todos

---

### 2.2 Energy-Aware Planning

**Goal**: Match tasks to user's energy patterns

**Files to Modify/Create**:
- `Focal/Services/AI/EnergyMatcher.swift` (new)
- `Focal/ViewModels/TaskStore.swift` (add energy analysis)

**Energy Curve Model**:
```swift
struct EnergyProfile {
    // User's typical energy by hour (0-23)
    var hourlyEnergy: [Int: Float] // hour -> 0.0-1.0

    // Day-of-week modifiers
    var dayModifiers: [Int: Float] // 0-6 -> multiplier

    func expectedEnergy(at date: Date) -> Float
    func peakHours(on date: Date) -> [Int]
    func lowHours(on date: Date) -> [Int]
}

class EnergyMatcher {
    func matchScore(task: TaskItem, time: Date, profile: EnergyProfile) -> Float
    func suggestBetterTime(for task: TaskItem, profile: EnergyProfile) -> Date?
    func warnMismatch(task: TaskItem, time: Date, profile: EnergyProfile) -> String?
}
```

**UI Integration**:
- Energy curve visualization in Insights tab
- Warning when scheduling high-energy task in low-energy time
- "Better time available" suggestion badge

---

### 2.3 Conflict Detection & Resolution

**Goal**: Identify and help resolve scheduling conflicts

**Files to Create**:
- `Focal/Services/AI/ConflictDetector.swift`
- `Focal/Models/ScheduleConflict.swift`

**Conflict Types**:
```swift
enum ConflictType {
    case overlap           // Tasks at same time
    case overload          // Too many tasks in period
    case deadlineMiss      // Task won't finish before deadline
    case energyMismatch    // High-energy task at low-energy time
    case noBreak           // Long stretch without breaks
    case unrealistic       // More hours scheduled than available
}

struct ScheduleConflict {
    let type: ConflictType
    let severity: Severity // .info, .warning, .critical
    let affectedTasks: [TaskItem]
    let message: String
    let suggestions: [ConflictResolution]
}

struct ConflictResolution {
    let description: String
    let action: () -> Void
}
```

---

### 2.4 Focus Timer / Pomodoro (Competitive Must-Have)

**Goal**: Built-in focus sessions with timer, like Tiimo and Structured

**Why Critical**: Both competitors have this. Tiimo: *"Pomodoro Timer for ADHD-friendly focus sessions."*

**Files to Create**:
- `Focal/Services/FocusSessionManager.swift`
- `Focal/Models/FocusSession.swift`
- `Focal/Views/Focus/FocusTimerView.swift`
- `Focal/Views/Focus/FocusCompletedView.swift`

**Data Model**:
```swift
@Model
class FocusSession {
    var id: UUID
    var task: TaskItem?
    var startedAt: Date
    var plannedDuration: TimeInterval // 25 min default
    var actualDuration: TimeInterval?
    var breakDuration: TimeInterval // 5 min default
    var completedPomodoros: Int
    var status: FocusStatus
    var notes: String?
}

enum FocusStatus: String, Codable {
    case active
    case paused
    case completed
    case abandoned
}

struct FocusPreferences: Codable {
    var defaultFocusDuration: TimeInterval = 25 * 60 // 25 min
    var defaultBreakDuration: TimeInterval = 5 * 60  // 5 min
    var longBreakDuration: TimeInterval = 15 * 60    // 15 min
    var longBreakAfter: Int = 4                      // pomodoros
    var autoStartBreak: Bool = true
    var autoStartNextPomodoro: Bool = false
    var playSound: Bool = true
    var enableHaptics: Bool = true
}
```

**FocusSessionManager**:
```swift
@Observable
class FocusSessionManager {
    var currentSession: FocusSession?
    var timeRemaining: TimeInterval = 0
    var isOnBreak: Bool = false
    var preferences = FocusPreferences()

    private var timer: Timer?

    var progress: Double {
        guard let session = currentSession else { return 0 }
        let total = isOnBreak ? preferences.defaultBreakDuration : session.plannedDuration
        return 1 - (timeRemaining / total)
    }

    func startFocus(for task: TaskItem? = nil, duration: TimeInterval? = nil) {
        let session = FocusSession(
            id: UUID(),
            task: task,
            startedAt: Date(),
            plannedDuration: duration ?? preferences.defaultFocusDuration,
            breakDuration: preferences.defaultBreakDuration,
            completedPomodoros: 0,
            status: .active
        )

        currentSession = session
        timeRemaining = session.plannedDuration
        isOnBreak = false

        startTimer()
        HapticManager.shared.notification(.success)

        // Start Live Activity
        LiveActivityManager.shared.startFocusActivity(session: session)
    }

    func pause() {
        timer?.invalidate()
        currentSession?.status = .paused
        HapticManager.shared.impact(.medium)
    }

    func resume() {
        startTimer()
        currentSession?.status = .active
    }

    func skip() {
        if isOnBreak {
            startNextPomodoro()
        } else {
            startBreak()
        }
    }

    func abandon() {
        timer?.invalidate()
        currentSession?.status = .abandoned
        currentSession?.actualDuration = (currentSession?.plannedDuration ?? 0) - timeRemaining
        LiveActivityManager.shared.endFocusActivity()
        currentSession = nil
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        timeRemaining -= 1

        if timeRemaining <= 0 {
            if isOnBreak {
                breakCompleted()
            } else {
                pomodoroCompleted()
            }
        }

        // Update Live Activity
        LiveActivityManager.shared.updateFocusActivity(timeRemaining: timeRemaining)
    }

    private func pomodoroCompleted() {
        timer?.invalidate()
        currentSession?.completedPomodoros += 1

        HapticManager.shared.notification(.success)
        // Play completion sound

        if preferences.autoStartBreak {
            startBreak()
        }
    }

    private func startBreak() {
        isOnBreak = true
        let isLongBreak = (currentSession?.completedPomodoros ?? 0) % preferences.longBreakAfter == 0
        timeRemaining = isLongBreak ? preferences.longBreakDuration : preferences.defaultBreakDuration
        startTimer()
    }

    private func breakCompleted() {
        timer?.invalidate()
        isOnBreak = false

        HapticManager.shared.notification(.success)

        if preferences.autoStartNextPomodoro {
            startNextPomodoro()
        }
    }

    private func startNextPomodoro() {
        isOnBreak = false
        timeRemaining = currentSession?.plannedDuration ?? preferences.defaultFocusDuration
        startTimer()
    }
}
```

**FocusTimerView**:
```swift
struct FocusTimerView: View {
    @Environment(FocusSessionManager.self) private var focusManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Background - dims everything else
            DS.Colors.background
                .ignoresSafeArea()

            VStack(spacing: DS.Spacing.xxxl) {
                // Current task (if any)
                if let task = focusManager.currentSession?.task {
                    HStack {
                        Text(task.icon)
                            .font(.title)
                        Text(task.title)
                            .font(.title3.weight(.medium))
                    }
                    .foregroundStyle(DS.Colors.textSecondary)
                }

                // Status label
                Text(focusManager.isOnBreak ? "Break Time" : "Focus Time")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(focusManager.isOnBreak ? DS.Colors.success : DS.Colors.primary)
                    .textCase(.uppercase)
                    .tracking(2)

                // Timer circle
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(DS.Colors.surfaceSecondary, lineWidth: 12)
                        .frame(width: 280, height: 280)

                    // Progress ring
                    Circle()
                        .trim(from: 0, to: focusManager.progress)
                        .stroke(
                            focusManager.isOnBreak ? DS.Colors.success : DS.Colors.primary,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 280, height: 280)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: focusManager.progress)

                    // Time display
                    VStack(spacing: DS.Spacing.xs) {
                        Text(formatTime(focusManager.timeRemaining))
                            .font(.system(size: 64, weight: .light, design: .rounded))
                            .monospacedDigit()

                        if let session = focusManager.currentSession {
                            Text("\(session.completedPomodoros) pomodoros")
                                .font(.caption)
                                .foregroundStyle(DS.Colors.textMuted)
                        }
                    }
                }

                // Controls
                HStack(spacing: DS.Spacing.xxl) {
                    // Abandon
                    Button {
                        focusManager.abandon()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(DS.Colors.textMuted)
                    }

                    // Play/Pause
                    Button {
                        if focusManager.currentSession?.status == .paused {
                            focusManager.resume()
                        } else {
                            focusManager.pause()
                        }
                    } label: {
                        Image(systemName: focusManager.currentSession?.status == .paused ? "play.circle.fill" : "pause.circle.fill")
                            .font(.system(size: 72))
                            .foregroundStyle(DS.Colors.primary)
                    }

                    // Skip
                    Button {
                        focusManager.skip()
                    } label: {
                        Image(systemName: "forward.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(DS.Colors.textMuted)
                    }
                }

                Spacer()
            }
            .padding(.top, DS.Spacing.xxxxl)
        }
        .persistentSystemOverlays(.hidden) // Hide status bar for immersion
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
```

**Starting Focus from Task**:
```swift
// Add to TaskCardView or context menu
Button {
    focusManager.startFocus(for: task)
    showFocusTimer = true
} label: {
    Label("Start Focus", systemImage: "timer")
}
```

---

### 2.5 Calendar Sync (Competitive Must-Have)

**Goal**: Import events from iOS Calendar to see real availability

**Why Critical**: Both Tiimo and Structured sync with Google/iCal/Outlook. Without this, auto-schedule can't see real conflicts.

**Files to Create**:
- `Focal/Services/CalendarSyncService.swift`
- `Focal/Models/ExternalEvent.swift`
- `Focal/Views/Settings/CalendarSettingsView.swift`

**Implementation**:
```swift
import EventKit

@Observable
class CalendarSyncService {
    private let eventStore = EKEventStore()
    var isAuthorized: Bool = false
    var enabledCalendars: Set<String> = [] // Calendar identifiers
    var syncedEvents: [ExternalEvent] = []

    /// Request calendar access
    func requestAccess() async -> Bool {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            isAuthorized = granted
            return granted
        } catch {
            return false
        }
    }

    /// Get available calendars
    func getCalendars() -> [EKCalendar] {
        eventStore.calendars(for: .event)
    }

    /// Fetch events for date range
    func fetchEvents(from startDate: Date, to endDate: Date) -> [ExternalEvent] {
        guard isAuthorized else { return [] }

        let calendars = eventStore.calendars(for: .event).filter {
            enabledCalendars.contains($0.calendarIdentifier)
        }

        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: calendars.isEmpty ? nil : calendars
        )

        let events = eventStore.events(matching: predicate)

        return events.map { event in
            ExternalEvent(
                id: event.eventIdentifier,
                title: event.title,
                startDate: event.startDate,
                endDate: event.endDate,
                isAllDay: event.isAllDay,
                calendarName: event.calendar.title,
                calendarColor: UIColor(cgColor: event.calendar.cgColor)
            )
        }
    }

    /// Get blocked time slots for scheduling
    func getBlockedSlots(on date: Date) -> [DateInterval] {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let events = fetchEvents(from: startOfDay, to: endOfDay)

        return events.compactMap { event in
            guard !event.isAllDay else { return nil }
            return DateInterval(start: event.startDate, end: event.endDate)
        }
    }
}

struct ExternalEvent: Identifiable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let calendarName: String
    let calendarColor: UIColor
}
```

**Integration with ScheduleOptimizer**:
```swift
extension ScheduleOptimizer {
    func findOptimalSlots(
        for task: TodoItem,
        on date: Date,
        existingTasks: [TaskItem],
        externalEvents: [ExternalEvent], // ← NEW
        userPatterns: [UserPattern],
        constraints: [ScheduleConstraint]
    ) -> [SuggestedTimeSlot] {
        // Combine internal tasks and external events as blocked time
        var blockedSlots: [DateInterval] = []

        // Add internal tasks
        for task in existingTasks {
            blockedSlots.append(DateInterval(start: task.startTime, duration: task.duration))
        }

        // Add external calendar events
        for event in externalEvents where !event.isAllDay {
            blockedSlots.append(DateInterval(start: event.startDate, end: event.endDate))
        }

        // Find gaps and score them
        // ...
    }
}
```

**Calendar Settings UI**:
```swift
struct CalendarSettingsView: View {
    @Environment(CalendarSyncService.self) private var calendarService
    @State private var calendars: [EKCalendar] = []

    var body: some View {
        List {
            Section {
                if calendarService.isAuthorized {
                    ForEach(calendars, id: \.calendarIdentifier) { calendar in
                        Toggle(isOn: binding(for: calendar)) {
                            HStack {
                                Circle()
                                    .fill(Color(UIColor(cgColor: calendar.cgColor)))
                                    .frame(width: 12, height: 12)
                                Text(calendar.title)
                            }
                        }
                    }
                } else {
                    Button("Enable Calendar Access") {
                        Task {
                            await calendarService.requestAccess()
                            loadCalendars()
                        }
                    }
                }
            } header: {
                Text("Sync Calendars")
            } footer: {
                Text("Events from selected calendars will be shown in your timeline and considered when auto-scheduling.")
            }
        }
        .navigationTitle("Calendar Sync")
        .onAppear { loadCalendars() }
    }

    private func loadCalendars() {
        calendars = calendarService.getCalendars()
    }

    private func binding(for calendar: EKCalendar) -> Binding<Bool> {
        Binding(
            get: { calendarService.enabledCalendars.contains(calendar.calendarIdentifier) },
            set: { enabled in
                if enabled {
                    calendarService.enabledCalendars.insert(calendar.calendarIdentifier)
                } else {
                    calendarService.enabledCalendars.remove(calendar.calendarIdentifier)
                }
            }
        )
    }
}
```

**Show External Events in Timeline**:
```swift
// In DailyTimelineView, show external events differently
struct ExternalEventPill: View {
    let event: ExternalEvent

    var body: some View {
        HStack(spacing: DS.Spacing.xs) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(event.calendarColor))
                .frame(width: 4)

            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.caption.weight(.medium))
                    .lineLimit(1)
                Text(event.calendarName)
                    .font(.caption2)
                    .foregroundStyle(DS.Colors.textMuted)
            }
        }
        .padding(.horizontal, DS.Spacing.sm)
        .padding(.vertical, DS.Spacing.xs)
        .background(DS.Colors.surfaceSecondary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
    }
}
```

---

### 2.6 Widgets (Competitive Must-Have)

**Goal**: Home screen widgets showing today's schedule and quick actions

**Why Critical**: Both competitors use widgets heavily for "ambient awareness."

**Files to Create**:
- `FocalWidget/FocalWidget.swift` (Widget Extension)
- `FocalWidget/TodayWidget.swift`
- `FocalWidget/NextTaskWidget.swift`
- `FocalWidget/ProgressWidget.swift`

**Widget Extension Setup**:
```swift
// FocalWidget/FocalWidget.swift
import WidgetKit
import SwiftUI

@main
struct FocalWidgets: WidgetBundle {
    var body: some Widget {
        TodayWidget()
        NextTaskWidget()
        ProgressWidget()
    }
}
```

**Today Widget** (Medium/Large):
```swift
struct TodayWidget: Widget {
    let kind: String = "TodayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayProvider()) { entry in
            TodayWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Today's Schedule")
        .description("See your upcoming tasks at a glance.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct TodayEntry: TimelineEntry {
    let date: Date
    let tasks: [WidgetTask]
    let completedCount: Int
    let totalCount: Int
}

struct WidgetTask: Identifiable {
    let id: UUID
    let title: String
    let icon: String
    let colorName: String
    let startTime: Date
    let isCompleted: Bool
}

struct TodayWidgetView: View {
    let entry: TodayEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text("Today")
                    .font(.headline)
                Spacer()
                Text("\(entry.completedCount)/\(entry.totalCount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Task list
            ForEach(entry.tasks.prefix(4)) { task in
                HStack(spacing: 8) {
                    Text(task.icon)
                        .font(.caption)

                    Text(task.title)
                        .font(.caption)
                        .lineLimit(1)
                        .strikethrough(task.isCompleted)

                    Spacer()

                    Text(task.startTime, style: .time)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .opacity(task.isCompleted ? 0.5 : 1)
            }

            if entry.tasks.count > 4 {
                Text("+\(entry.tasks.count - 4) more")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
```

**Next Task Widget** (Small):
```swift
struct NextTaskWidget: Widget {
    let kind: String = "NextTaskWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NextTaskProvider()) { entry in
            NextTaskWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Next Task")
        .description("See what's coming up next.")
        .supportedFamilies([.systemSmall])
    }
}

struct NextTaskEntry: TimelineEntry {
    let date: Date
    let task: WidgetTask?
    let timeUntil: String? // "in 15 min"
}

struct NextTaskWidgetView: View {
    let entry: NextTaskEntry

    var body: some View {
        if let task = entry.task {
            VStack(spacing: 8) {
                Text(task.icon)
                    .font(.largeTitle)

                Text(task.title)
                    .font(.caption.weight(.medium))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                if let timeUntil = entry.timeUntil {
                    Text(timeUntil)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            VStack {
                Image(systemName: "checkmark.circle")
                    .font(.largeTitle)
                    .foregroundStyle(.green)
                Text("All done!")
                    .font(.caption)
            }
        }
    }
}
```

**Progress Widget** (Small circular):
```swift
struct ProgressWidget: Widget {
    let kind: String = "ProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProgressProvider()) { entry in
            ProgressWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Daily Progress")
        .description("Track your completion progress.")
        .supportedFamilies([.accessoryCircular, .systemSmall])
    }
}

struct ProgressEntry: TimelineEntry {
    let date: Date
    let completed: Int
    let total: Int
    var progress: Double { total > 0 ? Double(completed) / Double(total) : 0 }
}

struct ProgressWidgetView: View {
    let entry: ProgressEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            Gauge(value: entry.progress) {
                Text("\(entry.completed)")
            }
            .gaugeStyle(.accessoryCircular)

        default:
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)

                Circle()
                    .trim(from: 0, to: entry.progress)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack {
                    Text("\(entry.completed)/\(entry.total)")
                        .font(.title3.weight(.semibold))
                    Text("tasks")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
    }
}
```

**Shared Data with App Group**:
```swift
// In both main app and widget extension
let sharedDefaults = UserDefaults(suiteName: "group.com.focal.app")

// Save widget data when tasks change
func updateWidgetData() {
    let tasks = taskStore.tasksForSelectedDate.map { task in
        WidgetTask(
            id: task.id,
            title: task.title,
            icon: task.icon,
            colorName: task.colorName,
            startTime: task.startTime,
            isCompleted: task.isCompleted
        )
    }

    let encoder = JSONEncoder()
    if let data = try? encoder.encode(tasks) {
        sharedDefaults?.set(data, forKey: "todayTasks")
    }

    WidgetCenter.shared.reloadAllTimelines()
}
```

---

## Phase 3: Task Intelligence (Weeks 7-9)

### 3.1 Smart Task Breakdown

**Goal**: AI-powered subtask generation for complex tasks

**Files to Create**:
- `Focal/Services/AI/TaskDecomposer.swift`
- `Focal/Views/AI/TaskBreakdownSheet.swift`

**Implementation Options**:

**Option A: Rule-Based Templates**
```swift
struct TaskTemplate {
    let keywords: [String]
    let subtasks: [SubtaskTemplate]
    let estimatedTotalDuration: TimeInterval
}

// Example templates
let templates = [
    TaskTemplate(
        keywords: ["birthday party", "party planning"],
        subtasks: [
            SubtaskTemplate(title: "Create guest list", duration: 900),
            SubtaskTemplate(title: "Send invitations", duration: 1200),
            SubtaskTemplate(title: "Order cake", duration: 600),
            SubtaskTemplate(title: "Plan decorations", duration: 1800),
            SubtaskTemplate(title: "Prepare food/drinks", duration: 3600)
        ],
        estimatedTotalDuration: 8100
    ),
    // ... 50+ templates for common tasks
]
```

**Option B: LLM-Powered (Cloud API)**
```swift
class LLMTaskDecomposer {
    func breakdown(task: String, context: TaskContext) async throws -> [GeneratedSubtask]
}

// Uses Claude/GPT API to generate contextual subtasks
// Requires network, user consent, API key
```

**Recommended**: Start with Option A (50+ templates), add Option B as premium feature

**UI Flow**:
1. User creates task "Plan vacation to Japan"
2. AI detects complex task, shows "Break this down?" prompt
3. Sheet shows suggested subtasks with durations
4. User can edit, add, remove, reorder
5. Accept creates task with all subtasks

---

### 3.2 Routine Builder

**Goal**: Help users create and optimize daily routines

**Files to Create**:
- `Focal/Models/Routine.swift`
- `Focal/Services/AI/RoutineOptimizer.swift`
- `Focal/Views/Routine/RoutineBuilderView.swift`

**Data Model**:
```swift
@Model
class Routine {
    var id: UUID
    var name: String // "Morning Routine", "Evening Wind-down"
    var type: RoutineType // .morning, .evening, .workout, .custom
    var tasks: [RoutineTask]
    var totalDuration: TimeInterval
    var preferredStartTime: Date?
    var activeDays: [Int] // 0-6 for days of week
    var isActive: Bool
}

struct RoutineTask: Codable {
    var title: String
    var icon: String
    var duration: TimeInterval
    var orderIndex: Int
    var isOptional: Bool
}
```

**AI Features**:
- Suggest routine templates based on user goals
- Optimize task order (shower after workout, not before)
- Adjust durations based on user's actual times
- Suggest additions based on common routines

**UI**:
- "Build a Routine" wizard
- Drag-and-drop routine editor
- One-tap to schedule routine for a day
- Routine completion tracking

---

### 3.3 Proactive Auto-Reschedule (Competitive Must-Have)

**Goal**: Automatically detect and offer to reschedule when plans change

**Why Critical**: Structured's killer feature - *"If you sleep in, Structured AI can automatically reschedule your tasks."*

**Files to Create**:
- `Focal/Services/AI/ProactiveRescheduleService.swift`
- `Focal/Services/AI/ScheduleMonitor.swift`
- `Focal/Views/AI/RescheduleSheet.swift`
- `Focal/Views/AI/RescheduleBanner.swift`

**Proactive Triggers** (automatic detection):
```swift
enum RescheduleTrigger {
    case sleptIn(missedTasks: [TaskItem])        // First task missed by 30+ min
    case taskOverran(task: TaskItem, by: TimeInterval)  // Task took longer than planned
    case dayRunningLate(behindBy: TimeInterval)  // Multiple tasks delayed
    case unexpectedFreeTime(duration: TimeInterval)  // Gap opened up
    case conflictDetected(tasks: [TaskItem])     // Overlapping tasks
    case endOfDay(incomplete: [TaskItem])        // Day ending with unfinished tasks
}
```

**ScheduleMonitor Service**:
```swift
@Observable
class ScheduleMonitor {
    private var monitorTimer: Timer?
    var pendingReschedule: RescheduleSuggestion?

    func startMonitoring() {
        // Check every 5 minutes
        monitorTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.checkScheduleHealth()
        }
    }

    private func checkScheduleHealth() {
        let now = Date()
        let todayTasks = taskStore.tasksForSelectedDate

        // Check: Slept in?
        if let firstTask = todayTasks.first(where: { !$0.isCompleted }),
           firstTask.startTime < now,
           now.timeIntervalSince(firstTask.startTime) > 30 * 60 {
            // First task is 30+ min overdue
            let missedTasks = todayTasks.filter {
                !$0.isCompleted && $0.startTime < now
            }
            triggerReschedule(.sleptIn(missedTasks: missedTasks))
            return
        }

        // Check: Running late?
        let incompletePastTasks = todayTasks.filter {
            !$0.isCompleted && $0.endTime < now
        }
        if incompletePastTasks.count >= 2 {
            let totalDelay = incompletePastTasks.reduce(0) {
                $0 + now.timeIntervalSince($1.endTime)
            }
            triggerReschedule(.dayRunningLate(behindBy: totalDelay))
        }
    }

    private func triggerReschedule(_ trigger: RescheduleTrigger) {
        let suggestion = ProactiveRescheduleService.shared.generateSuggestion(for: trigger)
        pendingReschedule = suggestion

        // Show non-intrusive banner
        NotificationCenter.default.post(
            name: .rescheduleNeeded,
            object: suggestion
        )
    }
}
```

**ProactiveRescheduleService**:
```swift
@Observable
class ProactiveRescheduleService {
    static let shared = ProactiveRescheduleService()

    func generateSuggestion(for trigger: RescheduleTrigger) -> RescheduleSuggestion {
        switch trigger {
        case .sleptIn(let missedTasks):
            return generateSleptInPlan(missedTasks: missedTasks)

        case .taskOverran(let task, let overrun):
            return generateCascadePlan(from: task, delay: overrun)

        case .dayRunningLate(let delay):
            return generateCatchUpPlan(behindBy: delay)

        case .unexpectedFreeTime(let duration):
            return suggestTasksForGap(duration: duration)

        case .endOfDay(let incomplete):
            return generateTomorrowPlan(for: incomplete)

        default:
            return RescheduleSuggestion.empty
        }
    }

    private func generateSleptInPlan(missedTasks: [TaskItem]) -> RescheduleSuggestion {
        // Strategy: Shift all remaining tasks, drop or move least important
        let now = Date()
        var adjustedTasks: [TaskAdjustment] = []

        // Find next available slot
        let nextSlot = findNextAvailableSlot(after: now)

        for (index, task) in missedTasks.enumerated() {
            let newStart = nextSlot.addingTimeInterval(TimeInterval(index) * task.duration)

            adjustedTasks.append(TaskAdjustment(
                task: task,
                action: .moveToTime(newStart),
                reason: "Shifted to fit your current schedule"
            ))
        }

        return RescheduleSuggestion(
            trigger: .sleptIn(missedTasks: missedTasks),
            title: "Running late?",
            message: "Looks like your morning got delayed. I can adjust your schedule.",
            adjustments: adjustedTasks,
            quickActions: [
                QuickAction(label: "Shift everything", action: .applyAll),
                QuickAction(label: "Skip morning tasks", action: .skipMissed),
                QuickAction(label: "I'll handle it", action: .dismiss)
            ]
        )
    }

    private func generateCatchUpPlan(behindBy delay: TimeInterval) -> RescheduleSuggestion {
        // Options: Compress remaining tasks, skip one, or extend day
        return RescheduleSuggestion(
            trigger: .dayRunningLate(behindBy: delay),
            title: "Day running behind",
            message: "You're about \(formatDuration(delay)) behind. Want me to help catch up?",
            adjustments: [],
            quickActions: [
                QuickAction(label: "Compress schedule", action: .compress),
                QuickAction(label: "Skip lowest priority", action: .skipLowest),
                QuickAction(label: "Extend my day", action: .extendDay)
            ]
        )
    }
}

struct RescheduleSuggestion {
    let trigger: RescheduleTrigger
    let title: String
    let message: String
    let adjustments: [TaskAdjustment]
    let quickActions: [QuickAction]
}

struct TaskAdjustment {
    let task: TaskItem
    let action: AdjustmentAction
    let reason: String
}

enum AdjustmentAction {
    case moveToTime(Date)
    case moveToTomorrow
    case shorten(by: TimeInterval)
    case skip
    case keep // No change
}
```

**Reschedule Banner UI** (non-intrusive):
```swift
struct RescheduleBanner: View {
    let suggestion: RescheduleSuggestion
    let onAction: (QuickAction) -> Void
    let onExpand: () -> Void

    var body: some View {
        VStack(spacing: DS.Spacing.sm) {
            HStack {
                Image(systemName: "clock.badge.exclamationmark")
                    .foregroundStyle(DS.Colors.warning)

                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestion.title)
                        .font(.subheadline.weight(.medium))
                    Text(suggestion.message)
                        .font(.caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                }

                Spacer()

                Button {
                    onExpand()
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(DS.Colors.textMuted)
                }
            }

            // Quick actions
            HStack(spacing: DS.Spacing.sm) {
                ForEach(suggestion.quickActions.prefix(2), id: \.label) { action in
                    Button {
                        onAction(action)
                    } label: {
                        Text(action.label)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, DS.Spacing.md)
                            .padding(.vertical, DS.Spacing.sm)
                            .background(DS.Colors.surfaceSecondary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .background(DS.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        .padding(.horizontal)
    }
}
```

**Full Reschedule Sheet** (for detailed adjustments):
```swift
struct RescheduleSheet: View {
    let suggestion: RescheduleSuggestion
    @State private var adjustments: [TaskAdjustment]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Spacing.xl) {
                    // Header
                    VStack(spacing: DS.Spacing.sm) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 44))
                            .foregroundStyle(DS.Colors.primary)

                        Text(suggestion.title)
                            .font(.title2.weight(.semibold))

                        Text(suggestion.message)
                            .font(.subheadline)
                            .foregroundStyle(DS.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()

                    // Visual timeline comparison
                    HStack(spacing: DS.Spacing.lg) {
                        // Before
                        VStack {
                            Text("Before")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(DS.Colors.textMuted)
                            MiniTimelineView(tasks: originalTasks)
                        }

                        Image(systemName: "arrow.right")
                            .foregroundStyle(DS.Colors.textMuted)

                        // After
                        VStack {
                            Text("After")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(DS.Colors.success)
                            MiniTimelineView(tasks: adjustedTasks)
                        }
                    }
                    .padding()

                    // Individual adjustments
                    ForEach(adjustments, id: \.task.id) { adjustment in
                        AdjustmentRow(adjustment: adjustment)
                    }
                }
            }
            .navigationTitle("Reschedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Apply") {
                        applyAdjustments()
                        dismiss()
                    }
                }
            }
        }
    }

    private func applyAdjustments() {
        for adjustment in adjustments {
            switch adjustment.action {
            case .moveToTime(let newTime):
                adjustment.task.startTime = newTime
            case .moveToTomorrow:
                // Move to tomorrow same time
                break
            case .skip:
                // Mark as skipped
                break
            default:
                break
            }
        }
        taskStore.save()
        HapticManager.shared.notification(.success)
    }
}
```

**Pattern Learning & Suggestions**:
```swift
extension ProactiveRescheduleService {
    /// Learn from user behavior
    func trackRescheduleDecision(_ suggestion: RescheduleSuggestion, action: QuickAction) {
        // Record for pattern learning
        let record = RescheduleRecord(
            trigger: suggestion.trigger,
            chosenAction: action,
            timestamp: Date()
        )

        // Store in UserDefaults or SwiftData
        rescheduleHistory.append(record)

        // Analyze patterns
        analyzePatterns()
    }

    private func analyzePatterns() {
        // Example: If user often skips morning gym
        let gymSkips = rescheduleHistory.filter {
            $0.trigger.affectedTasks.contains(where: { $0.title.lowercased().contains("gym") })
            && $0.chosenAction == .skip
        }

        if gymSkips.count >= 3 {
            // Suggest changing default gym time
            queueInsight(
                "You often skip morning gym. Want to move it to evenings?",
                action: .suggestTimeChange(for: "Gym", to: "6:00 PM")
            )
        }
    }
}
```

**Integration Points**:
```swift
// In ContentView or main app coordinator
struct ContentView: View {
    @State private var scheduleMonitor = ScheduleMonitor()
    @State private var showRescheduleBanner = false
    @State private var pendingSuggestion: RescheduleSuggestion?

    var body: some View {
        ZStack(alignment: .top) {
            // Main content
            TabView { ... }

            // Reschedule banner overlay
            if showRescheduleBanner, let suggestion = pendingSuggestion {
                RescheduleBanner(
                    suggestion: suggestion,
                    onAction: handleQuickAction,
                    onExpand: { showRescheduleSheet = true }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(100)
            }
        }
        .onAppear {
            scheduleMonitor.startMonitoring()
        }
        .onReceive(NotificationCenter.default.publisher(for: .rescheduleNeeded)) { notification in
            if let suggestion = notification.object as? RescheduleSuggestion {
                pendingSuggestion = suggestion
                withAnimation(.spring()) {
                    showRescheduleBanner = true
                }
            }
        }
    }
}
```

---

## Phase 4: Planning Assistants (Weeks 10-12)

### 4.1 Daily Planning Coach

**Goal**: Morning briefing and planning assistance

**Files to Create**:
- `Focal/Services/AI/DailyCoach.swift`
- `Focal/Views/AI/DailyBriefingView.swift`
- `Focal/Models/DailyPlan.swift`

**Morning Briefing Content**:
```swift
struct DailyBriefing {
    let date: Date
    let greeting: String // "Good morning! Here's your Tuesday"
    let taskSummary: TaskSummary
    let warnings: [PlanWarning]
    let suggestions: [PlanningSuggestion]
    let motivationalNote: String?
}

struct TaskSummary {
    let totalTasks: Int
    let totalDuration: TimeInterval
    let highPriorityCount: Int
    let scheduledTime: String // "9am - 5pm with 1h break"
    let energyProfile: String // "Moderate day"
}

struct PlanWarning {
    let type: WarningType // .overloaded, .noBreaks, .conflicting
    let message: String
    let suggestion: String?
}
```

**UI Flow**:
1. Morning notification: "Ready to plan your day?"
2. Open app → Daily Briefing sheet
3. Shows today's overview with AI insights
4. Quick actions: Add task, reschedule, set priorities
5. "Start my day" dismisses and begins first task

---

### 4.2 Weekly Review & Planning

**Goal**: End-of-week reflection and next-week planning

**Files to Create**:
- `Focal/Services/AI/WeeklyReview.swift`
- `Focal/Views/AI/WeeklyReviewView.swift`

**Review Components**:
```swift
struct WeeklyReview {
    let weekOf: Date

    // Accomplishments
    let completedTasks: Int
    let completedSubtasks: Int
    let totalTimeWorked: TimeInterval
    let completionRate: Float

    // Patterns
    let mostProductiveDay: String
    let mostProductiveTime: String
    let energyPattern: String

    // Insights
    let wins: [String] // "Completed all high-priority tasks"
    let improvements: [String] // "3 tasks rescheduled multiple times"
    let suggestions: [String] // "Consider blocking 2pm for focused work"

    // Carryover
    let incompleteTasks: [TaskItem]
    let overdueItems: [TodoItem]
}
```

**Planning Wizard**:
1. Review last week's accomplishments
2. Address incomplete/overdue items
3. Set 1-3 priorities for coming week
4. AI suggests time blocks for priorities
5. Preview week schedule, adjust as needed

---

### 4.3 Focus Time Protection

**Goal**: Identify and protect best focus time windows

**Files to Create**:
- `Focal/Services/AI/FocusTimeManager.swift`
- `Focal/Models/FocusBlock.swift`

**Features**:
```swift
@Model
class FocusBlock {
    var id: UUID
    var dayOfWeek: Int
    var startHour: Int
    var endHour: Int
    var label: String // "Deep Work", "Creative Time"
    var isProtected: Bool
}

class FocusTimeManager {
    /// Identify user's natural focus times from history
    func detectFocusTimes(from patterns: [UserPattern]) -> [FocusBlock]

    /// Warn when scheduling meetings during focus time
    func checkConflict(task: TaskItem, focusBlocks: [FocusBlock]) -> FocusConflict?

    /// Suggest best time for deep work tasks
    func suggestFocusTime(for task: TaskItem, blocks: [FocusBlock]) -> Date?
}
```

---

## Phase 5: Advanced Intelligence (Weeks 13-16)

### 5.1 Predictive Insights

**Goal**: Surface actionable insights from user data

**Files to Create**:
- `Focal/Services/AI/InsightsEngine.swift`
- `Focal/Views/Insights/InsightsView.swift`
- `Focal/Models/Insight.swift`

**Insight Types**:
```swift
enum InsightType {
    case productivity      // "You complete 80% more tasks before noon"
    case timing           // "Tuesdays are your most productive day"
    case estimation       // "You typically underestimate tasks by 20%"
    case pattern          // "You've meditated 7 days in a row!"
    case warning          // "You've rescheduled 'Exercise' 3 times"
    case recommendation   // "Consider batching email checks"
}

struct Insight {
    let type: InsightType
    let title: String
    let description: String
    let dataPoints: [DataPoint] // For visualization
    let actionable: Bool
    let action: InsightAction?
    let generatedAt: Date
}
```

**Insights Dashboard** (new tab):
- Weekly productivity chart
- Completion rate trends
- Energy pattern visualization
- Top insights cards
- Streaks and achievements

---

### 5.2 LLM Integration (Optional/Premium)

**Goal**: Cloud-based AI for advanced features

**Files to Create**:
- `Focal/Services/AI/LLMService.swift`
- `Focal/Services/AI/LLMPromptBuilder.swift`

**Features Requiring LLM**:
- Complex natural language parsing
- Contextual task breakdown
- Personalized planning advice
- Conversational planning assistant

**Implementation**:
```swift
class LLMService {
    private let apiKey: String
    private let endpoint: URL

    func parse(naturalLanguage: String) async throws -> ParsedTask
    func breakdown(task: String, context: String) async throws -> [Subtask]
    func planDay(tasks: [TodoItem], preferences: UserPreferences) async throws -> DayPlan
    func chat(message: String, context: PlanningContext) async throws -> String
}
```

**Privacy Considerations**:
- Explicit user opt-in required
- Clear data usage disclosure
- Option to use local-only features
- No PII sent to API (titles only, anonymized)

---

### 5.3 Habit Tracking & Streaks

**Goal**: Track habits and encourage consistency

**Files to Create**:
- `Focal/Models/Habit.swift`
- `Focal/Services/HabitTracker.swift`
- `Focal/Views/Habits/HabitView.swift`

**Data Model**:
```swift
@Model
class Habit {
    var id: UUID
    var title: String
    var icon: String
    var color: String
    var frequency: HabitFrequency // .daily, .weekdays, .weekly, .custom
    var targetDays: [Int]?
    var currentStreak: Int
    var longestStreak: Int
    var completions: [HabitCompletion]
    var remindAt: Date?
    var linkedTaskTitle: String? // Auto-track from tasks
}

struct HabitCompletion: Codable {
    var date: Date
    var completed: Bool
}
```

**AI Features**:
- Auto-detect habits from recurring tasks
- Optimal habit stacking suggestions
- Streak recovery (miss one day, don't lose streak)
- Best time suggestions based on completion history

---

## Technical Implementation Details

### API Design

**AICoordinator** (Central service):
```swift
@Observable
class AICoordinator {
    let suggestionService: SuggestionService
    let scheduleOptimizer: ScheduleOptimizer
    let nlpParser: NLPParser
    let insightsEngine: InsightsEngine
    let patternTracker: PatternTracker

    // Feature flags
    var isAutoScheduleEnabled: Bool
    var isNLPEnabled: Bool
    var isLLMEnabled: Bool

    // Convenience methods
    func processQuickAdd(_ text: String) async -> ParsedTask
    func suggestTimeSlot(for todo: TodoItem) -> SuggestedTimeSlot?
    func getDailyBriefing() -> DailyBriefing
    func getWeeklyReview() -> WeeklyReview
}
```

### Settings & Preferences

```swift
struct AIPreferences: Codable {
    var enableSmartSuggestions: Bool = true
    var enableAutoSchedule: Bool = true
    var enableDailyBriefing: Bool = true
    var briefingTime: Date = /* 8am */
    var enableWeeklyReview: Bool = true
    var reviewDay: Int = 0 // Sunday
    var enableLLM: Bool = false
    var preferredEnergyMatching: Bool = true
    var showInsights: Bool = true
}
```

### Error Handling

```swift
enum AIError: Error {
    case insufficientData       // Not enough history for prediction
    case parsingFailed          // NLP couldn't understand input
    case noSlotsAvailable       // No time slots found
    case networkError           // LLM API failed
    case userCancelled          // User dismissed AI suggestion
}
```

---

## UI/UX Guidelines

### AI Interaction Patterns

1. **Suggestion Chips**: Small, tappable suggestions below input fields
2. **Smart Banners**: Non-modal alerts for AI insights
3. **Bottom Sheets**: For multi-option AI decisions (reschedule, breakdown)
4. **Inline Hints**: Subtle text hints ("AI: 45 min typical")
5. **Full-Screen Wizards**: For complex flows (weekly planning)

### Visual Language

- Use `DS.Colors.aiAccent` (new) for AI-powered elements - suggest: soft gradient
- Subtle sparkle/wand icon (✨) for AI features
- "AI" badge on AI-generated content
- Smooth animations for AI suggestions appearing

### Copy Guidelines

- Friendly, not robotic: "I noticed..." not "Analysis indicates..."
- Humble: "You might want to..." not "You should..."
- Transparent: Always explain why ("Based on your history...")
- Encouraging: Celebrate wins, gentle with misses

---

## Testing Strategy

### Unit Tests
- `NLPParserTests`: Date/time parsing accuracy
- `ScheduleOptimizerTests`: Slot finding algorithms
- `PatternTrackerTests`: Pattern detection accuracy
- `SuggestionServiceTests`: Suggestion quality

### Integration Tests
- End-to-end quick add flow
- Auto-schedule with real task data
- Daily briefing generation

### User Testing
- A/B test AI suggestions on/off
- Measure task completion rates
- Track suggestion acceptance rate
- Gather qualitative feedback

---

## Milestones & Deliverables

### Phase 1 Completion (Week 4) - Foundation + Quick Wins

**Core Features:**
- [ ] Enhanced SuggestionService with duration/energy suggestions
- [ ] UserPattern model and PatternTracker service
- [ ] Basic NLP parser for quick add
- [ ] Voice input with Apple Speech Framework
- [ ] VoiceInputSheet with waveform visualization
- [ ] Real-time voice-to-NLP parsing pipeline
- [ ] UI integration for suggestion chips and voice button

**Competitive Must-Have:**
- [ ] Brain Dump feature with AI organize
- [ ] BrainDumpView with voice input integration
- [ ] Priority-based task organization (Must/Should/Could/Someday)

### Phase 2 Completion (Week 8) - Intelligent Scheduling

**Core Features:**
- [ ] ScheduleOptimizer with multi-factor scoring
- [ ] Energy-aware planning with profile
- [ ] Conflict detection and resolution UI
- [ ] "Schedule for me" feature working

**Competitive Must-Haves:**
- [ ] Focus Timer / Pomodoro with full-screen UI
- [ ] Calendar Sync via EventKit
- [ ] External events in timeline view
- [ ] Home Screen Widgets (Today, Next Task, Progress)
- [ ] Widget Extension with App Group data sharing

### Phase 3 Completion (Week 12) - Task Intelligence

**Core Features:**
- [ ] Task breakdown with 50+ templates
- [ ] Routine builder wizard
- [ ] Pattern-based suggestions

**Competitive Must-Haves:**
- [ ] Proactive Auto-Reschedule with ScheduleMonitor
- [ ] "Slept in?" detection and cascade adjustment
- [ ] Reschedule banner with quick actions
- [ ] Live Activities for Focus Timer
- [ ] Dynamic Island support

### Phase 4 Completion (Week 16) - Planning Assistants

**Core Features:**
- [ ] Daily briefing flow with morning prompt
- [ ] Weekly review and planning wizard
- [ ] Focus time detection and protection
- [ ] Insights tab with productivity charts

**Differentiators:**
- [ ] Energy curve visualization
- [ ] Completion rate trends
- [ ] Pattern-based recommendations

### Phase 5 Completion (Week 20) - Polish & Advanced

- [ ] Full insights dashboard with actionable insights
- [ ] Optional LLM integration (task breakdown, planning advice)
- [ ] Habit tracking with streak recovery
- [ ] Apple Watch companion (basic)
- [ ] Performance optimization and polish

---

## Competitive Feature Checklist

| Feature | Tiimo | Structured | Focal | Status |
|---------|:-----:|:----------:|:-----:|:------:|
| Natural Language Input | ✅ | ✅ | ✅ | Phase 1 |
| Voice Input | ✅ | ✅ | ✅ | Phase 1 |
| Brain Dump → Organize | ✅ | ❌ | ✅ | Phase 1 |
| Visual Timeline | ✅ | ✅ | ✅ | Exists |
| Auto-Schedule | ✅ | ✅ | ✅ | Phase 2 |
| Focus Timer | ✅ | ✅ | ✅ | Phase 2 |
| Calendar Sync | ✅ | ✅ | ✅ | Phase 2 |
| Widgets | ✅ | ✅ | ✅ | Phase 2 |
| Live Activities | ✅ | ✅ | ✅ | Phase 3 |
| Auto-Reschedule | ❌ | ✅ | ✅ | Phase 3 |
| Energy Tracking | ✅ | ✅ | ✅ | Exists |
| Insights/Analytics | ✅ | ❌ | ✅ | Phase 4 |
| Weekly Review | ❌ | ❌ | ✅ | Phase 4 (Differentiator) |
| On-Device AI | ❌ | ❌ | ✅ | All (Differentiator) |

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| AI suggestions annoying users | Default off, user enables; easy dismiss |
| Poor NLP accuracy | Show preview before creating; easy edit |
| Privacy concerns | On-device first; explicit LLM opt-in |
| Performance impact | Background processing; lazy loading |
| Scope creep | Strict phase gates; MVP per phase |
| Voice recognition inaccuracy | Show transcription in real-time; easy edit before submit |
| Microphone permission denied | Clear permission rationale; graceful fallback to text |
| Background noise issues | Visual feedback when listening; manual stop option |
| Accent/language support | Use device locale; support multiple languages via Speech framework |
| Widget data sync issues | App Group for shared data; WidgetCenter reload on changes |
| Calendar permission denied | Clear rationale; app works without; graceful degradation |
| Live Activity not supported | Check availability; fall back to notifications |

---

## Future Considerations (Post v1.0)

- **Location Awareness**: Suggest tasks based on location (home/work/gym)
- **Siri Shortcuts**: "Hey Siri, add to Focal..."
- **Apple Watch App**: Full companion with complications
- **Apple Watch**: Quick AI suggestions on wrist
- **Collaborative Planning**: AI for shared schedules

---

## Appendix A: NLP Parsing Examples

| Input | Parsed Output |
|-------|---------------|
| "Gym tomorrow 7am" | title: "Gym", date: tomorrow, time: 7:00 AM |
| "Call mom in 2 hours" | title: "Call mom", date: today, time: +2h |
| "Dentist next Tuesday 2:30pm 1h" | title: "Dentist", date: next Tue, time: 2:30 PM, duration: 1h |
| "Weekly review every Sunday" | title: "Weekly review", recurrence: weekly, day: Sunday |
| "Finish report by Friday" | title: "Finish report", deadline: Friday |
| "30 min meditation" | title: "meditation", duration: 30 min |
| "Quick call 15m" | title: "Quick call", duration: 15 min |

## Appendix B: Task Breakdown Templates

### Work Tasks
- **Presentation**: Outline (15m) → Research (1h) → Create slides (1h) → Review (30m) → Practice (30m)
- **Report**: Gather data (30m) → Outline (15m) → Write draft (1h) → Review (30m) → Finalize (15m)
- **Meeting prep**: Review agenda (10m) → Prepare notes (20m) → Gather materials (10m)

### Personal Tasks
- **Grocery shopping**: Check inventory (10m) → Make list (10m) → Shop (45m) → Put away (15m)
- **Workout**: Warm up (5m) → Main workout (30m) → Cool down (5m) → Shower (15m)
- **Meal prep**: Plan meals (15m) → Shop (45m) → Prep ingredients (30m) → Cook (1h) → Store (15m)

### Life Admin
- **Doctor appointment**: Schedule (10m) → Prepare questions (15m) → Attend (30m) → Follow up (15m)
- **Home cleaning**: Declutter (30m) → Dust (20m) → Vacuum (20m) → Mop (15m) → Bathrooms (20m)
- **Travel planning**: Research (1h) → Book flights (30m) → Book hotel (30m) → Plan activities (1h) → Pack list (15m)

---

## Appendix C: Design System Additions

```swift
extension DS.Colors {
    /// AI-powered feature accent color
    static let aiAccent = LinearGradient(
        colors: [.purple.opacity(0.6), .blue.opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// AI suggestion background
    static let aiSuggestionBg = Color.purple.opacity(0.1)
}

extension DS.Icons {
    static let aiSparkle = "sparkles"
    static let aiWand = "wand.and.stars"
    static let aiSuggest = "lightbulb.fill"
    static let aiSchedule = "calendar.badge.clock"
    static let voiceMic = "mic.fill"
    static let voiceListening = "waveform"
    static let voiceStop = "stop.circle.fill"
}
```

---

## Appendix D: Voice Input Examples

### Task Creation via Voice

| Spoken Input | Transcription | Parsed Task |
|--------------|---------------|-------------|
| "Add gym tomorrow at 7 AM" | "Add gym tomorrow at 7 AM" | title: "Gym", date: tomorrow, time: 7:00 AM, icon: 🏋️ |
| "Meeting with Sarah on Friday 2pm for one hour" | "Meeting with Sarah on Friday 2pm for one hour" | title: "Meeting with Sarah", date: Friday, time: 2:00 PM, duration: 1h, icon: 👥 |
| "Remind me to call the dentist" | "Remind me to call the dentist" | title: "Call the dentist", icon: 📞, reminder: true |
| "Pick up groceries after work" | "Pick up groceries after work" | title: "Pick up groceries", time: 5:00 PM (inferred), icon: 🛒 |
| "Thirty minutes of meditation every morning" | "30 minutes of meditation every morning" | title: "Meditation", duration: 30m, recurrence: daily, time: 8:00 AM, icon: 🧘 |

### Voice Commands

| Spoken Command | Action |
|----------------|--------|
| "What's next?" | Shows next upcoming task |
| "Show me tomorrow" | Navigates to tomorrow's schedule |
| "Complete gym" | Marks "Gym" task as completed |
| "Move lunch to 1pm" | Reschedules lunch task to 1:00 PM |
| "How's my day looking?" | Reads daily summary aloud (future TTS feature) |
| "Cancel my 3pm meeting" | Deletes or marks cancelled |

### Handling Ambiguity

| Spoken Input | Clarification Prompt |
|--------------|---------------------|
| "Meeting tomorrow" | "What time? (tap to set or speak)" |
| "Call John" | "When should I schedule this?" → Shows time picker |
| "Workout" | "Add to today or schedule for later?" → Quick options |
| "Something at 3" | "What would you like to do at 3 PM?" |

### Multi-Language Support

| Language | Example | Notes |
|----------|---------|-------|
| English (US) | "Gym at seven AM" | Default |
| English (UK) | "Gym at half seven" | 7:30 AM interpretation |
| Spanish | "Gimnasio mañana a las siete" | Requires device language |
| German | "Fitnessstudio morgen um sieben" | Requires device language |
| Japanese | "明日7時にジム" | Requires device language |

*Note: Language support depends on iOS Speech Framework availability for each locale.*

---

## Appendix E: Voice Input Flow Diagrams

### Basic Voice Input Flow
```
┌─────────────────┐
│ User taps mic   │
└────────┬────────┘
         ▼
┌─────────────────┐     ┌─────────────────┐
│ Check perms     │────▶│ Request perms   │
│ (authorized?)   │ No  │ (first time)    │
└────────┬────────┘     └────────┬────────┘
         │ Yes                   │
         ▼                       ▼
┌─────────────────┐     ┌─────────────────┐
│ Start listening │◀────│ User grants     │
│ (show waveform) │     │ permission      │
└────────┬────────┘     └─────────────────┘
         │
         ▼
┌─────────────────┐
│ Real-time       │
│ transcription   │◀──── Audio chunks
│ + NLP parsing   │
└────────┬────────┘
         │
         ▼ (user stops or silence detected)
┌─────────────────┐
│ Show parsed     │
│ task preview    │
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌───────┐ ┌───────┐
│ Edit  │ │ Add   │
│ task  │ │ task  │
└───────┘ └───────┘
```

### Voice Error Recovery
```
┌─────────────────┐
│ Recognition     │
│ fails/unclear   │
└────────┬────────┘
         ▼
┌─────────────────┐
│ Show error:     │
│ "Didn't catch   │
│ that. Try again │
│ or type instead"│
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌───────┐ ┌───────┐
│ Retry │ │ Type  │
│ voice │ │ input │
└───────┘ └───────┘
```

---

*Document Version: 1.1*
*Created: January 2026*
*Last Updated: January 2026*
