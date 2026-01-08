---
name: structured-planner-core
description: Use when working on core models, TaskStore state, and DesignSystem updates for the Planner iOS app.
---

# Structured Planner Core

Use this skill when editing models, TaskStore, or DesignSystem tokens.

## Quick Start
1. Read `AGENTS.md` for project rules (especially no DerivedData).
2. Review `Focal/Utilities/DesignSystem.swift` for DS tokens; use DS constants instead of hard-coded values.
3. Review `Focal/Models/TaskItem.swift`, `Focal/Models/TaskColor.swift`, `Focal/Models/Subtask.swift`.
4. Review `Focal/ViewModels/TaskStore.swift` for computed properties and actions.

## Workflow
- Keep MVVM: computed logic in models/store, views format only.
- Use SwiftData `@Model` updates; include migrations if fields change.
- Update TaskStore computed collections when model fields change.
- Use `HapticManager` convenience methods for state changes.
- Add accessibility labels/hints for new interactive elements.

## Guardrails
- iOS 17 minimum, Swift 5.9+, SwiftUI + `@Observable`.
- Avoid DerivedData scanning.
- Prefer `@Bindable` for store bindings; use `@State` for view-local state.
- Use `Focal/Utilities/DateExtensions.swift` for time/date formatting helpers.
- Use `Focal/Utilities/IconMapper.swift` for auto icon and color suggestions.
