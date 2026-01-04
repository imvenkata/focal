 Core Structure
   - View mode toggle - Week/Day switching exists in PlannerHeader
   - Week selector - Day circles with task indicators
   - TaskStore - Observable state management with view modes
   - Design System - Colors, spacing, typography constants
   - Navigation - Bottom tab bar with 4 tabs (Inbox, Planner, AI/Insights, Settings)
  Timeline Views
   - WeeklyTimelineView - Grid with time labels, day columns, task pins
   - DailyTimelineView - Vertical timeline with time slots, task cards
   - Current time indicator - Red line showing current time
  ❌ Missing Features from React Reference
  1. View Toggle UX Mismatch
  React: Segmented control (Week/Day pills) in header
  Focal: Dropdown-style button with chevron

  Recommendation: Replace ViewModeToggle with proper segmented control:

   HStack(spacing: 2) {
       ForEach(TaskStore.ViewMode.allCases) { mode in
           Button {
               viewMode = mode
           } label: {
               Text(mode.rawValue.capitalized)
                   .font(.system(size: 12, weight: .semibold))
                   .foregroundStyle(viewMode == mode ? DS.Colors.textPrimary : DS.Colors.textSecondary)
                   .padding(.horizontal, 12)
                   .padding(.vertical, 6)
                   .background(viewMode == mode ? .white : .clear)
                   .clipShape(RoundedRectangle(cornerRadius: 8))
           }
       }
   }
   .padding(2)
   .background(DS.Colors.background)
   .clipShape(RoundedRectangle(cornerRadius: 10))


  2. Week View Visual Differences
  React:
   - Colored task dots under day circles (lines 165-173)
   - Vertical track lines connecting tasks (lines 227-235)
   - Duration bars extending below task pills (lines 251-259)

  Focal:
   - ❌ No task dots preview under day circles in WeekSelector
   - ✅ Has grid lines but missing vertical tracks
   - ❌ No duration visualization bars

  3. Day View Layout
  React:
   - White card with rounded top corners (line 294)
   - Handle bar at top (lines 296-298)
   - Energy circular progress + stats row (lines 301-327)
   - Vertical dashed line with task pills (lines 333-334)

  Focal:
   - ✅ Has stats bar but different layout
   - ❌ No rounded card container
   - ❌ No handle bar
   - ✅ Has dashed line
   - ❌ Task pills don't match design (should be larger with centered icon)

  4. Task Card Design
  React Day View (lines 344-356):
   - Large rounded pill (56px min, scales with duration)
   - Icon centered vertically
   - Time range + duration badge next to title
   - Checkbox on right

  Focal: Uses TaskCardView which likely has different styling

  5. Empty State Messaging
  React: "A well-spent interval" with 💤 emoji (lines 394-399)
  Focal: "Free time" with add button

  6. Progress/Stats Bar
  React:
   - Streak indicator (🔥 20)
   - Horizontal progress bar
   - Fraction display (12/20)

  Focal: Has ProgressBar component but verify it matches design

  7. Current Time Indicator
  React: Red gradient line with pulsing dot (lines 264-282)
  Focal: ✅ Has CurrentTimeIndicator - verify styling

  8. FAB Placement
  React: Bottom right, above nav bar (lines 465-470)
  Focal: Handled by BottomTabBar onAddTapped - verify visual match

  🔧 Priority Fixes
  High Priority
   1. Fix view mode toggle to match segmented control design
   2. Add task dot indicators under day circles in WeekSelector
   3. Update day view container with rounded card + handle
   4. Standardize task pill sizing - 56px default, scales with duration
  Medium Priority
   5. Add vertical track lines in week view
   6. Add duration bars below task pills in week view
   7. Match empty state messaging style
   8. Verify current time indicator styling (gradient + pulse)
  Low Priority
   9. Match exact spacing/padding values
   10. Verify all color usage matches DS.Colors
  📁 Files to Modify
   1. Focal/Views/Timeline/PlannerView.swift - ViewModeToggle component
   2. Focal/Views/Components/WeekSelector.swift - Add task dots
   3. Focal/Views/Timeline/DailyTimelineView.swift - Wrap in card container
   4. Focal/Views/Timeline/WeeklyTimelineView.swift - Add track lines + duration bars
   5. Focal/Views/Task/TaskCardView.swift - Verify day view styling
   6. Focal/Views/Task/TaskPinView.swift - Verify week view pill sizing
  Let me know which component you'd like to fix first!


    📋 Action Plan (Priority Order)
  Phase 1: Fix Header & Day Circles (Highest Impact)
   1. ✅ Update header title to show day number in day view
   2. ✅ Change selected day circle from blue to stone-800
   3. ✅ Fix today indicator to use amber colors
   4. ✅ Make task dots use actual task colors (not all blue)
   5. ✅ Increase dot size from 4px to 8px
  Phase 2: Fix Layout Structure
   6. ✅ Move ProgressBar inside WeeklyTimelineView
   7. ✅ Wrap DailyTimelineView in white card container
   8. ✅ Add handle bar to day view
   9. ✅ Adjust day view to slide up animation
  Phase 3: Polish Details
   10. Verify StatsBar matches React design (circular progress)
   11. Add vertical track lines in week view
   12. Add duration bars below task pills
   13. Match task pill sizing in day view