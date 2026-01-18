import Foundation

enum PromptTemplates {

    // MARK: - Date Helper

    private static var todayISO: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.string(from: Date())
    }

    // MARK: - System Prompts

    static var taskParsingSystem: String {
        """
        You are a task parsing assistant for a productivity app.
        Extract structured task information from natural language.
        Always respond with valid JSON only, no explanations.
        Use ISO 8601 format for dates (YYYY-MM-DD).
        Use 24-hour format for times (HH:mm).
        Today's date is \(todayISO).
        """
    }

    static var brainDumpSystem: String {
        """
        You are a productivity assistant that helps organize scattered thoughts into actionable tasks.
        Parse the user's brain dump and create structured, prioritized tasks.
        Always respond with valid JSON only.
        Today's date is \(todayISO).
        """
    }

    static let scheduleSystem = """
    You are a scheduling assistant that finds optimal time slots for tasks.
    Consider energy levels, existing commitments, and task requirements.
    Always respond with valid JSON only.
    """

    static let insightSystem = """
    You are an analytics assistant that identifies patterns and provides actionable insights.
    Be encouraging but honest. Focus on specific, actionable recommendations.
    Always respond with valid JSON only.
    """

    // MARK: - Task Parsing

    static func parseTask(input: String) -> String {
        """
        Parse this natural language input into a structured task:

        "\(input)"

        Return JSON in this exact format:
        {
            "title": "clean task title without date/time",
            "date": "YYYY-MM-DD or null if not specified",
            "time": "HH:mm or null if not specified",
            "duration_minutes": estimated minutes or null,
            "energy_level": 0-4 (0=restful, 4=intense) or null,
            "icon": "single emoji that represents this task",
            "color": "coral|sage|sky|lavender|amber|rose|slate" or null,
            "is_recurring": true/false,
            "recurrence": "daily|weekly|weekdays|weekends" or null,
            "confidence": 0.0-1.0 how confident you are in the parsing
        }
        """
    }

    // MARK: - Brain Dump

    static func organizeBrainDump(input: String, existingCategories: [String] = []) -> String {
        """
        The user has done a brain dump of everything on their mind:

        "\(input)"

        Organize this into actionable tasks. For each item:
        1. Create a clear, actionable task title
        2. Identify any dates, times, or deadlines mentioned
        3. Assign priority based on urgency and importance
        4. Group related items together
        5. Suggest an icon and color

        Return JSON:
        {
            "tasks": [
                {
                    "title": "actionable task title",
                    "original_text": "the original fragment this came from",
                    "date": "YYYY-MM-DD or null",
                    "time": "HH:mm or null",
                    "duration_minutes": estimated or null,
                    "priority": "high|medium|low|none",
                    "energy_level": 0-4,
                    "icon": "emoji",
                    "color": "coral|sage|sky|lavender|amber|rose|slate",
                    "category": "work|personal|health|errands|social|other"
                }
            ],
            "summary": "brief summary of what was captured",
            "warnings": ["any concerns about overload, conflicts, etc"]
        }
        """
    }

    // MARK: - Task Breakdown

    static func breakdownTask(task: String, context: String? = nil) -> String {
        let contextLine = context.map { "Additional context: \($0)" } ?? ""
        return """
        Break down this task into actionable subtasks:

        Task: "\(task)"
        \(contextLine)

        Create 3-7 specific, actionable subtasks. Each should be:
        - Concrete and specific (not vague)
        - Completable in one session
        - Properly sequenced

        Return JSON:
        {
            "subtasks": [
                {
                    "title": "specific subtask",
                    "duration_minutes": estimated time,
                    "order": 1-based order,
                    "is_optional": true/false
                }
            ],
            "total_duration_minutes": sum of all subtasks,
            "notes": "any helpful tips or considerations"
        }
        """
    }

    // MARK: - Schedule Optimization

    static func suggestTimeSlots(
        task: String,
        duration: Int,
        energyLevel: Int,
        existingTasks: [String],
        userPatterns: String
    ) -> String {
        """
        Find the best time slots for this task:

        Task: "\(task)"
        Duration: \(duration) minutes
        Energy required: \(energyLevel)/4

        Already scheduled today:
        \(existingTasks.joined(separator: "\n"))

        User patterns:
        \(userPatterns)

        Suggest 3 optimal time slots. Consider:
        - Energy matching (high energy tasks at peak energy times)
        - Avoiding conflicts with existing tasks
        - Buffer time between tasks
        - User's historical preferences

        Return JSON:
        {
            "suggestions": [
                {
                    "start_time": "HH:mm",
                    "end_time": "HH:mm",
                    "score": 0.0-1.0,
                    "reason": "why this is a good slot"
                }
            ],
            "best_recommendation": "which slot is best and why"
        }
        """
    }

    // MARK: - Rescheduling

    static func suggestReschedule(
        situation: String,
        affectedTasks: [String],
        remainingTime: String
    ) -> String {
        """
        The user's schedule has been disrupted:

        Situation: \(situation)

        Affected tasks:
        \(affectedTasks.joined(separator: "\n"))

        Remaining time today: \(remainingTime)

        Suggest how to adjust the schedule. Options include:
        - Shift tasks later
        - Move tasks to tomorrow
        - Shorten task durations
        - Skip low-priority tasks

        Return JSON:
        {
            "strategy": "shift|compress|skip|move_tomorrow|hybrid",
            "adjustments": [
                {
                    "task_title": "task name",
                    "action": "move|shorten|skip|keep",
                    "new_time": "HH:mm or null",
                    "new_duration_minutes": new duration or null,
                    "reason": "why this adjustment"
                }
            ],
            "summary": "brief explanation of the new plan",
            "trade_offs": ["what the user is giving up"]
        }
        """
    }

    // MARK: - Insights

    static func generateInsights(
        completionData: String,
        patterns: String,
        recentActivity: String
    ) -> String {
        """
        Analyze this productivity data and generate insights:

        Completion rates:
        \(completionData)

        Observed patterns:
        \(patterns)

        Recent activity:
        \(recentActivity)

        Generate 3-5 actionable insights. Focus on:
        - Productivity patterns (best times, best days)
        - Areas for improvement
        - Positive trends to reinforce
        - Specific, actionable recommendations

        Return JSON:
        {
            "insights": [
                {
                    "type": "productivity|timing|estimation|streak|warning|recommendation",
                    "title": "short insight title",
                    "description": "detailed explanation",
                    "action": "specific action the user can take",
                    "priority": "high|medium|low"
                }
            ],
            "overall_summary": "brief overall assessment"
        }
        """
    }
}
