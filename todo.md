 Findings

  - [High] Save failures are swallowed (try?), so todo creation can “succeed” while
    silently failing to persist; this is a release‑blocker for reliability and trust.
    Focal/ViewModels/TodoStore.swift:70, Focal/ViewModels/TodoStore.swift:232
  - [High] Parsed date preview is shown but never applied to the created todo (no
    dueDate/dueTime), so the UI promises scheduling without actually doing it. Focal/
    Views/Components/FloatingTaskInputCard.swift:75, Focal/Views/Components/
    FloatingTaskInputCard.swift:359, Focal/Views/Todo/TodoView.swift:510
  - [Medium] Category selection has no visible effect: it’s stored as a tag but not
    surfaced or used for grouping/filtering, so users can’t see the category they
    picked. Focal/Views/Todo/TodoView.swift:510, Focal/Views/Todo/TodoView.swift:337
  - [Medium] “More” and “Voice input” controls are active but do nothing beyond
    haptics; shipping inert controls is a product‑quality risk. Focal/Views/
    Components/FloatingTaskInputCard.swift:212, Focal/Views/Components/
    FloatingTaskInputCard.swift:223
  - [Medium] Double success haptics on submit (UI + store) will feel glitchy. Focal/
    Views/Components/FloatingTaskInputCard.swift:449, Focal/ViewModels/
    TodoStore.swift:232
  - [Medium] UI test is now stale and will fail: it still expects the old quick‑add
    text field and button, and doesn’t cover the new floating flow. Focal/
    FocalUITests/TodoE2ETests.swift:31
  - [Low] Keyboard height uses UIScreen.main.bounds which breaks in split view/
    rotation and can misplace the floating card. Focal/Views/Todo/TodoView.swift:136
  - [Low] Accessibility: when the floating input is shown, background content remains
    reachable by VoiceOver (not marked as modal/hidden). Focal/Views/Todo/
    TodoView.swift:101

  Open Questions / Assumptions

  - Should category map to a real field (or priority) and appear in the list/
    filtering UI, or is it just metadata for future features?
  - Should parsed date be converted to a real dueDate/dueTime and optionally removed
    from the title?
  - Should success haptic be emitted at the store layer or the UI layer (not both)?

  No code changes in this review.

  If you want me to move this to production‑ready, I can:

  1. Implement date parsing → dueDate/dueTime + optional title cleanup.
  2. Make category first‑class (model + UI badges/filters) or remove it from the card
     until supported.
  3. Add save error surfacing + update UI tests to cover the floating flow.