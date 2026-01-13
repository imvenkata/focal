# Focal (Structured Planner) - Claude Notes

## Project snapshot
- Native iOS app for visual task management and scheduling.
- Swift 5.9+, SwiftUI, SwiftData, MVVM, iOS 17+.
- Design goal: 60% Structured (clarity) / 40% Tiimo (warmth).

## Common commands
- Open Xcode project: `open Focal.xcodeproj`
- Build (Debug): `xcodebuild -project Focal.xcodeproj -scheme Focal -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -configuration Debug build`
- Run tests: `xcodebuild -project Focal.xcodeproj -scheme Focal -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test`
- See `README.md` for full simulator boot/install/run steps.

## Key locations
- App entry: `Focal/App/FocalApp.swift`, `Focal/App/ContentView.swift`
- Models: `Focal/Models/TaskItem.swift`, `Focal/Models/TaskColor.swift`, `Focal/Models/Subtask.swift`, `Focal/Models/EnergyLevel.swift`, `Focal/Models/Todo*.swift`
- ViewModels: `Focal/ViewModels/TaskStore.swift`, `Focal/ViewModels/TodoStore.swift`, `Focal/ViewModels/Tab.swift`, `Focal/ViewModels/TaskDragState.swift`
- Views: `Focal/Views/Timeline/`, `Focal/Views/Task/`, `Focal/Views/Pickers/`, `Focal/Views/Components/`, `Focal/Views/Navigation/`, `Focal/Views/Todo/`
- Utilities: `Focal/Utilities/DesignSystem.swift`, `Focal/Utilities/IconMapper.swift`, `Focal/Utilities/HapticManager.swift`, `Focal/Utilities/ScaledFont.swift`, `Focal/Utilities/DateExtensions.swift`
- Resources: `Focal/Resources/Assets.xcassets`
- Design docs: `DESIGN_SYSTEM.md`, `DESIGN_DOCUMENT.md`
- Agent rules: `agents.md`

## Design and code style
- Use `DS` tokens from `Focal/Utilities/DesignSystem.swift` for colors, spacing, radius, sizes, and animations. Avoid hardcoded values.
- Prefer `DS.Animation.spring` (or `DS.Animation.quick`/`DS.Animation.gentle`) for transitions.
- Haptics:
  - Task completion: `HapticManager.shared.notification(.success)`
  - Delete: `HapticManager.shared.notification(.warning)`
  - Icon/color selection: `HapticManager.shared.impact(.light)`
  - Time snap: `HapticManager.shared.selection()`
- Add `.accessibilityLabel()` and `.accessibilityHint()` to interactive elements.
- Support Dynamic Type via `ScaledFont` or `.relativeTo`.
- Keep view logic thin; put business logic in stores (`TaskStore`, `TodoStore`) and use `@Observable`, `@State`, `@Binding` appropriately.
- Use `TaskColor` for task color mapping and `IconMapper` for icon suggestions.

## Testing and QA
- UI tests live in `FocalUITests/` and `Focal/FocalUITests/`.
- Run with the `xcodebuild test` command above.
- Manual checklist before finishing a screen:
  - Light mode, haptics, VoiceOver labels, Dynamic Type.
  - Small and large devices (iPhone SE and iPhone 15 Pro Max).
  - Keyboard avoidance in sheets, empty states, smooth animations.

## Repo etiquette and warnings
- Do not read or modify `DerivedData/`.
- Keep changes focused; avoid large refactors unless asked.
- Do not add new dependencies or change build settings without approval.
