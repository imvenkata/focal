# Focal Design System

**A neurodivergent-friendly planning app design system**
*Style: 60% Structured (clarity + productivity) / 40% Tiimo (warmth + support)*
*Philosophy: Calm, not clinical. Friendly, not childish. Minimal, not sterile.*

---

## Table of Contents
1. [Typography](#typography)
2. [Spacing & Layout](#spacing--layout)
3. [Color System](#color-system)
4. [Components](#components)
5. [Interaction & Motion](#interaction--motion)
6. [Iconography](#iconography)
7. [States](#states)
8. [Design Tokens (Swift)](#design-tokens-swift)

---

## Typography

### Font Family
Use **SF Pro** as the primary font for most UI elements. Use **SF Pro Rounded** selectively for warmth in specific contexts:

| Context | Font | Rationale |
|---------|------|-----------|
| Body text, labels, navigation | SF Pro | Clean, professional readability |
| Task titles (optional) | SF Pro Rounded | Adds warmth, approachable feel |
| Time displays | SF Pro (Monospaced) | Alignment in timelines |
| Buttons (primary CTA) | SF Pro Rounded Medium | Friendly, inviting |
| Section headers | SF Pro | Clear hierarchy |

### Type Scale

| Token | Size | Weight | Line Height | Letter Spacing | Use Case |
|-------|------|--------|-------------|----------------|----------|
| `largeTitle` | 34pt | Bold | 41pt (1.2×) | -0.4pt | Screen titles, empty states |
| `title` | 28pt | Bold | 34pt (1.2×) | 0.36pt | Section headers |
| `title2` | 22pt | Bold | 28pt (1.27×) | 0.35pt | Card titles, modal headers |
| `title3` | 20pt | Semibold | 25pt (1.25×) | 0.38pt | Subsection headers |
| `headline` | 17pt | Semibold | 22pt (1.29×) | -0.4pt | Emphasized body, task titles |
| `body` | 17pt | Regular | 22pt (1.29×) | -0.4pt | Primary content |
| `callout` | 16pt | Regular | 21pt (1.31×) | -0.3pt | Secondary content, descriptions |
| `subheadline` | 15pt | Regular | 20pt (1.33×) | -0.2pt | Supporting text |
| `footnote` | 13pt | Regular | 18pt (1.38×) | -0.1pt | Timestamps, metadata |
| `caption` | 12pt | Regular | 16pt (1.33×) | 0pt | Labels, hints |
| `caption2` | 11pt | Regular | 13pt (1.18×) | 0.1pt | Tertiary info, badges |

### Dynamic Type Support
All typography MUST scale with Dynamic Type using `@ScaledMetric` or `.relativeTo()`:

```swift
// Existing implementation - use this pattern
.scaledFont(size: 16, weight: .semibold, relativeTo: .body)

// For standard semantic styles
Text("Title").font(.title2.weight(.bold))
```

**Accessibility Notes:**
- Minimum body text: 17pt (iOS default)
- Never disable Dynamic Type scaling
- Test at AX5 (largest accessibility size)
- Truncate gracefully with ellipsis, never clip
- Ensure touch targets remain 44pt minimum even at large text sizes

### Neurodivergent-Friendly Typography Rules
1. **Line length**: 50-75 characters max per line
2. **Paragraph spacing**: 1.5× line height between paragraphs
3. **Avoid all-caps**: Except for very short labels (2-3 words max)
4. **Left-align text**: Avoid justified text (harder to track)
5. **High contrast**: Minimum 4.5:1 for body, 3:1 for large text

---

## Spacing & Layout

### Spacing Scale (4pt/8pt Grid)

| Token | Value | Use Case |
|-------|-------|----------|
| `xs` | 4pt | Icon-to-text, tight grouping |
| `sm` | 8pt | Related elements, list item padding |
| `md` | 12pt | Component internal padding |
| `lg` | 16pt | Card padding, section gaps |
| `xl` | 20pt | Screen margins, major sections |
| `xxl` | 24pt | Large component gaps |
| `xxxl` | 32pt | Screen section dividers |
| `xxxxl` | 48pt | Major layout breaks |

### Layout Grid
- **Screen margins**: 20pt (DS.Spacing.xl)
- **Card padding**: 16pt (DS.Spacing.lg)
- **Component gap**: 12pt (DS.Spacing.md)
- **Minimum touch target**: 44pt × 44pt

### Corner Radii

| Token | Value | Use Case |
|-------|-------|----------|
| `xs` | 4pt | Tags, small chips, progress bars |
| `sm` | 8pt | Input fields, small buttons |
| `md` | 12pt | Cards, task pills, medium buttons |
| `lg` | 16pt | Sheets, large cards, modals |
| `xl` | 20pt | Bottom sheets, large containers |
| `xxl` | 24pt | Full-screen overlays |
| `xxxl` | 32pt | Hero cards |
| `pill` | 100pt | Pills, fully rounded elements |

### Elevation & Shadows

| Level | Shadow | Use Case |
|-------|--------|----------|
| `flat` | none | Inline elements, dividers |
| `raised` | `0 2px 4px rgba(0,0,0,0.06)` | Cards at rest |
| `elevated` | `0 4px 12px rgba(0,0,0,0.08)` | Floating cards, dropdowns |
| `floating` | `0 8px 20px rgba(0,0,0,0.12)` | FAB, modals |
| `overlay` | `0 16px 32px rgba(0,0,0,0.16)` | Sheets, full overlays |
| `colored` | `0 4px 8px {color}@45%` | Task pills with brand color |

```swift
// Shadow implementations
extension View {
    func shadowRaised() -> some View {
        self.shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    func shadowElevated() -> some View {
        self.shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    func shadowFloating() -> some View {
        self.shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
    }

    func shadowColored(_ color: Color) -> some View {
        self.shadow(color: color.opacity(0.45), radius: 8, x: 0, y: 4)
    }
}
```

### Safe Area & Layout Density

| Zone | Inset | Notes |
|------|-------|-------|
| Top safe area | System default | Respect notch/dynamic island |
| Bottom safe area | 34pt (home indicator) | Add 34pt to bottom nav |
| Keyboard | Dynamic | Use `.ignoresSafeArea(.keyboard)` selectively |
| Tab bar height | 83pt total | 49pt bar + 34pt safe area |

### Low Clutter Mode (Optional Feature)
For users who prefer reduced visual density:

| Setting | Default | Low Clutter |
|---------|---------|-------------|
| Card padding | 16pt | 20pt |
| List item spacing | 8pt | 16pt |
| Section headers | Visible | Collapsible |
| Decorative elements | Shown | Hidden |
| Animations | Full | Reduced |
| Color saturation | 100% | 85% |
| Shadow intensity | 100% | 50% |

```swift
@AppStorage("lowClutterMode") var lowClutterMode = false

var adaptiveSpacing: CGFloat {
    lowClutterMode ? DS.Spacing.xl : DS.Spacing.lg
}
```

---

## Color System

### Semantic Colors

#### Background Layers

| Token | Light Mode | Dark Mode | Use Case |
|-------|------------|-----------|----------|
| `bgPrimary` | #FAFAF9 | #0D0D0D | Main screen background |
| `bgSecondary` | #FFFFFF | #1A1A1A | Cards, elevated surfaces |
| `bgTertiary` | #F5F5F4 | #2A2A2A | Input fields, subtle areas |
| `bgElevated` | #FFFFFF | #333333 | Floating elements, modals |

#### Text Colors

| Token | Light Mode | Dark Mode | Contrast | Use Case |
|-------|------------|-----------|----------|----------|
| `textPrimary` | #1C1917 | #FFFFFF | 15.4:1 / 21:1 | Headlines, body text |
| `textSecondary` | #78716C | #FFFFFF@60% | 4.9:1 / 8.4:1 | Supporting text |
| `textMuted` | #A8A29E | #FFFFFF@40% | 3.5:1 / 5.6:1 | Hints, placeholders |
| `textInverse` | #FFFFFF | #1C1917 | - | On colored backgrounds |

#### Border & Divider

| Token | Light Mode | Dark Mode | Use Case |
|-------|------------|-----------|----------|
| `border` | #E7E5E4 | #FFFFFF@12% | Input borders |
| `borderFocused` | #78716C | #FFFFFF@40% | Active inputs |
| `divider` | #E7E5E4 | #FFFFFF@8% | Section dividers |
| `dividerStrong` | #D6D3D1 | #FFFFFF@16% | Prominent dividers |

### Brand/Task Colors

| Name | Primary | Light (tint) | Dark (shade) | Meaning |
|------|---------|--------------|--------------|---------|
| `coral` | #E8847C | #FDF2F1 | #D66B63 | Creative, social |
| `sage` | #7BAE7F | #F2F7F2 | #5C8D60 | Health, calm |
| `sky` | #6BA3D6 | #F0F6FB | #4A8BC7 | Work, focus |
| `lavender` | #9B8EC2 | #F5F3F9 | #7A6BA8 | Personal, rest |
| `amber` | #D4A853 | #FBF7EE | #B8923F | Urgent, energy |
| `rose` | #C97B8E | #FAF1F3 | #A85D71 | Self-care |
| `slate` | #64748B | #F4F5F7 | #475569 | Neutral, misc |
| `night` | #5C6B7A | #F3F4F5 | #3F4D5A | Evening, wind-down |

### Status Colors

| Status | Color | Light Tint | Icon | Use Case |
|--------|-------|------------|------|----------|
| `success` | #10B981 | #ECFDF5 | checkmark.circle.fill | Completed, saved |
| `warning` | #F59E0B | #FFFBEB | exclamationmark.triangle.fill | Attention needed |
| `error` | #EF4444 | #FEF2F2 | xmark.circle.fill | Failed, delete |
| `info` | #6BA3D6 | #F0F6FB | info.circle.fill | Informational |

### Interactive States

| State | Modification | Example |
|-------|--------------|---------|
| Default | Base color | `sky` #6BA3D6 |
| Hover/Focused | +8% brightness | #7EB3E0 |
| Pressed | -12% brightness, scale 0.97 | #5A8EC5 |
| Disabled | 40% opacity | #6BA3D6@40% |
| Selected | Base + ring/check | `sky` + white checkmark |

### Color Blind Safe Guidance
The palette is designed to be distinguishable for common color vision deficiencies:

| Pair | Protanopia | Deuteranopia | Tritanopia |
|------|------------|--------------|------------|
| Coral vs Sage | ✓ (value contrast) | ✓ | ✓ |
| Sky vs Lavender | ✓ | ✓ | ⚠️ Add icon |
| Amber vs Sage | ⚠️ Add pattern | ⚠️ Add pattern | ✓ |

**Best Practices:**
1. Never rely on color alone—pair with icons or patterns
2. Use value (lightness) contrast, not just hue
3. Test with Sim Daltonism or similar tools
4. Provide option to add patterns to colored blocks

### WCAG Contrast Targets

| Element | Minimum | Target | Current |
|---------|---------|--------|---------|
| Body text on bgPrimary | 4.5:1 | 7:1 | 15.4:1 ✓ |
| Large text (18pt+) | 3:1 | 4.5:1 | 15.4:1 ✓ |
| UI components | 3:1 | 4.5:1 | Varies |
| Focus indicators | 3:1 | 4.5:1 | 4.9:1 ✓ |

---

## Components

### Buttons

#### Primary Button
```
┌─────────────────────────────────┐
│        Create Task              │  <- 16pt semibold, white
│                                 │  <- height: 50pt
└─────────────────────────────────┘  <- radius: 16pt (lg)
```

| Property | Value |
|----------|-------|
| Height | 50pt |
| Padding | 16pt horizontal |
| Corner radius | 16pt (lg) |
| Font | 16pt semibold SF Pro |
| Background | `sky` (active) / `slate` (disabled) |
| Text | white |
| Press state | scale 0.98, -8% brightness |

#### Secondary Button
| Property | Value |
|----------|-------|
| Height | 44pt |
| Corner radius | 12pt (md) |
| Background | `bgSecondary` |
| Border | 1pt `border` |
| Text | `textPrimary` |

#### Ghost Button
| Property | Value |
|----------|-------|
| Height | 44pt |
| Background | transparent |
| Text | `sky` or `textSecondary` |
| Press state | bgTertiary background |

#### Icon Button
| Property | Value |
|----------|-------|
| Size | 44pt × 44pt (touch target) |
| Visual size | 40pt × 40pt |
| Corner radius | 50% (circle) or 8pt |
| Icon size | 20pt |

#### FAB (Floating Action Button)
| Property | Value |
|----------|-------|
| Size | 56pt × 56pt |
| Corner radius | 50% (circle) |
| Background | Linear gradient stone700 → stone900 |
| Icon | 28pt, white, "plus" |
| Shadow | `0 8px 16px stone900@30%` |
| Press state | scale 0.95 |

### Cards

#### Task Card (List View)
```
┌──────────────────────────────────────────────┐
│ ┌────┐                                  ○    │
│ │ 📝 │  9:00 AM - 10:00 AM · (1h)            │
│ └────┘  Task Title Here                      │
│         ○ Subtask 1                          │
│         ○ Subtask 2                          │
└──────────────────────────────────────────────┘
```

| Property | Value |
|----------|-------|
| Padding | 8pt vertical, 8pt horizontal |
| Corner radius | 16pt |
| Background | transparent (bgSecondary when active) |
| Active state | Light tint background + 1.5pt color border |
| Completed | 55% opacity, strikethrough title |
| Past | 75% opacity |

#### Task Pill
| Property | Value |
|----------|-------|
| Width | 44pt |
| Height | 44-80pt (scales with duration) |
| Corner radius | 12pt |
| Background | Task color + gradient overlay |
| Border | 1.5pt saturated color |
| Shadow | Colored shadow 45% opacity |
| Icon size | 20pt centered |

#### Standard Card
| Property | Value |
|----------|-------|
| Padding | 16pt |
| Corner radius | 16pt |
| Background | `bgSecondary` |
| Shadow | shadowRaised |

### Chips & Tags

#### Duration Chip
```
┌───────┐
│  1h   │  <- 14pt medium
└───────┘
```
| Property | Value |
|----------|-------|
| Height | 32pt |
| Padding | 12pt horizontal, 8pt vertical |
| Corner radius | 8pt |
| Background | `bgSecondary` (unselected), `sky` (selected) |
| Text | `textPrimary` (unselected), white (selected) |

#### Day Chip (Calendar)
| Property | Value |
|----------|-------|
| Size | 28pt circle |
| Background | clear (default), `stone800` (selected), `amber100` (today) |
| Text | 12pt semibold |
| Task dots | 5pt circles, max 3 visible |

#### Color Chip
| Property | Value |
|----------|-------|
| Size | 32pt circle (touch: 44pt) |
| Selected indicator | 2pt white inner ring |
| Shadow | colored shadow |

### Calendar Blocks

#### Timeline Block (Week View)
| Property | Value |
|----------|-------|
| Min height | 24pt (15min) |
| Border radius | 8pt |
| Background | Task color 85% opacity |
| Left accent | 3pt solid task color (saturated) |

#### Day Column (Week View)
| Property | Value |
|----------|-------|
| Width | Equal flex |
| Gap | 2pt between blocks |
| Header | 28pt circle with day number |

### Task Items

See Task Card above. Additional variants:

#### Compact Task (Timeline)
```
┌─────────────────────────────────────┐
│ ┌──┐  Task Title         9:00 AM   │
│ │📝│                               │
│ └──┘                               │
└─────────────────────────────────────┘
```
| Property | Value |
|----------|-------|
| Height | 44pt |
| Icon size | 32pt |
| Corner radius | 12pt |

#### Subtask Row
| Property | Value |
|----------|-------|
| Height | 32pt minimum |
| Checkbox | 16pt circle |
| Completed | Strikethrough, muted color |

### Timers

#### Focus Timer Display
```
      ┌─────────────┐
      │   25:00     │  <- 48pt monospaced
      │  focusing   │  <- 14pt secondary
      └─────────────┘
```
| Property | Value |
|----------|-------|
| Time font | 48pt SF Pro Rounded Bold Monospaced |
| Label font | 14pt secondary |
| Progress ring | 8pt stroke, task color |

### Progress Indicators

#### Linear Progress Bar
| Property | Value |
|----------|-------|
| Height | 6pt |
| Corner radius | 4pt (xs) |
| Track | `divider` |
| Fill | Animated, task color |

#### Circular Progress
| Property | Value |
|----------|-------|
| Size | 64pt |
| Stroke | 6pt |
| Track | `divider` 20% opacity |
| Fill | Task color |

### Inputs

#### Text Field
| Property | Value |
|----------|-------|
| Height | 44pt minimum |
| Padding | 16pt |
| Corner radius | 16pt |
| Background | `bgSecondary` |
| Border | none (default), `borderFocused` (active) |
| Placeholder | `textMuted` |

#### Text Editor (Notes)
| Property | Value |
|----------|-------|
| Min height | 80pt |
| Padding | 12pt |
| Corner radius | 16pt |
| Background | `bgSecondary` |

### Modals & Sheets

#### Bottom Sheet
| Property | Value |
|----------|-------|
| Corner radius | 24pt (top only) |
| Handle | 36pt × 5pt, `divider` color, 2.5pt radius |
| Background | `bgPrimary` |
| Detents | .medium, .large |

#### Modal/Alert
| Property | Value |
|----------|-------|
| Width | Screen - 48pt margin |
| Corner radius | 24pt |
| Padding | 24pt |
| Background | `bgSecondary` |
| Shadow | shadowOverlay |

### Navigation

#### Tab Bar
| Property | Value |
|----------|-------|
| Height | 83pt (49pt + 34pt safe) |
| Background | .ultraThinMaterial |
| Top border | 1pt `stone100` |
| Icon size | 20pt |
| Label size | 10pt medium |
| Active color | `stone800` |
| Inactive color | `stone400` |

#### Navigation Bar
| Property | Value |
|----------|-------|
| Height | 44pt (+ safe area) |
| Title | 17pt semibold |
| Back button | 44pt touch target |

### Close Button (Sheet)
```
    ╭───╮
    │ ✕ │  <- 11pt semibold
    ╰───╯
```
| Property | Value |
|----------|-------|
| Size | 32pt |
| Corner radius | 50% |
| Background | `stone100` |
| Border | 1pt `stone200` |
| Icon | 11pt semibold, `stone500` |
| Shadow | subtle |

---

## Interaction & Motion

### Animation Tokens

| Token | Response | Damping | Use Case |
|-------|----------|---------|----------|
| `quick` | 0.25s | 0.7 | Micro-interactions, toggles |
| `spring` | 0.4s | 0.8 | Standard transitions |
| `gentle` | 0.5s | 0.85 | Page transitions, large moves |
| `bounce` | 0.3s | 0.6 | Playful feedback, success |

```swift
enum DS.Animation {
    static let quick = Animation.spring(response: 0.25, dampingFraction: 0.7)
    static let spring = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let gentle = Animation.spring(response: 0.5, dampingFraction: 0.85)
    static let bounce = Animation.spring(response: 0.3, dampingFraction: 0.6)
}
```

### Easing (Non-Spring)
When springs aren't appropriate:

| Token | Curve | Duration | Use Case |
|-------|-------|----------|----------|
| `easeOut` | .easeOut | 0.2s | Exits, fades |
| `easeInOut` | .easeInOut | 0.3s | State changes |
| `linear` | .linear | varies | Progress, timers |

### Micro-Interactions

| Interaction | Animation | Duration |
|-------------|-----------|----------|
| Button press | Scale to 0.97-0.98 | quick |
| FAB press | Scale to 0.95 | quick |
| Task complete | Check scale + bounce | bounce |
| Card select | Border + bg fade in | spring |
| Toggle switch | Spring to new position | quick |
| Color select | Ring scale in | quick |
| Sheet present | Slide up + spring | gentle |
| Sheet dismiss | Slide down + fade | 0.25s easeOut |

### Transition Patterns

#### Page/View Transitions
```swift
.transition(.asymmetric(
    insertion: .move(edge: .trailing).combined(with: .opacity),
    removal: .move(edge: .leading).combined(with: .opacity)
))
```

#### Modal Presentation
- Slide from bottom
- Background dims to 40% black
- Duration: gentle (0.5s)

#### List Item Animations
- Stagger: 0.03s between items
- Max stagger: 10 items, then all together
- Use `.animation(.spring.delay(Double(index) * 0.03))`

### Haptic Feedback

| Action | Feedback Type | Intensity |
|--------|---------------|-----------|
| Button tap | Impact | Light |
| FAB tap | Impact | Medium |
| Task complete | Notification | Success |
| Delete | Notification | Warning |
| Error | Notification | Error |
| Selection change | Selection | - |
| Color picked | Impact | Light |
| Drag start | Impact | Heavy |
| Drag move | Impact | Soft |
| Drop complete | Notification | Success |
| Time snapped | Selection | - |

```swift
// Use existing HapticManager
HapticManager.shared.taskCompleted()
HapticManager.shared.buttonTapped()
HapticManager.shared.selection()
```

### Reduce Motion Alternatives

When `UIAccessibility.isReduceMotionEnabled`:

| Standard | Reduced Motion |
|----------|----------------|
| Spring animations | Instant or 0.1s linear |
| Scale effects | Opacity fade only |
| Slide transitions | Cross-fade |
| Bounce effects | None |
| Progress animations | Step changes |
| Parallax | Disabled |

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var animation: Animation {
    reduceMotion ? .linear(duration: 0.1) : DS.Animation.spring
}
```

---

## Iconography

### SF Symbols Style Guide

| Context | Style | Weight | Notes |
|---------|-------|--------|-------|
| Tab bar | Outline | Regular/Semibold (selected) | Use hierarchical rendering |
| List icons | Filled | Regular | For visual weight |
| Action buttons | Outline | Medium | Cleaner look |
| Status indicators | Filled | - | Better at small sizes |
| Empty states | Outline | Light/Ultralight | Subtle, not heavy |

### Icon Sizing

| Context | Size | Touch Target |
|---------|------|--------------|
| Tab bar | 20pt | 44pt |
| Navigation | 20pt | 44pt |
| Inline text | Match text size | - |
| List row | 20-24pt | 44pt row |
| Large display | 32-48pt | - |
| Empty state | 64-80pt | - |

### Alignment Rules
1. Icons vertically center with adjacent text
2. Use `.imageScale(.medium)` as default
3. Add 4pt spacing (xs) between icon and text
4. For icon buttons, center icon in 44pt touch target

### Symbol Rendering

```swift
// Hierarchical (depth)
Image(systemName: "bell.badge")
    .symbolRenderingMode(.hierarchical)
    .foregroundStyle(DS.Colors.textPrimary)

// Palette (specific colors)
Image(systemName: "calendar.badge.plus")
    .symbolRenderingMode(.palette)
    .foregroundStyle(DS.Colors.textPrimary, DS.Colors.sky)

// Multicolor (system colors)
Image(systemName: "checkmark.circle.fill")
    .symbolRenderingMode(.multicolor)
```

### Recommended Symbols

| Use Case | Symbol | Variant |
|----------|--------|---------|
| Add | plus | circle for FAB |
| Complete | checkmark | circle.fill when done |
| Delete | trash | - |
| Edit | pencil | - |
| Settings | gearshape | - |
| Calendar | calendar | - |
| Time | clock | - |
| Reminder | bell | badge for active |
| Energy | bolt | fill for high |
| Expand | chevron.right/down | - |
| Close | xmark | - |
| Back | chevron.left | - |
| More | ellipsis | circle for button |
| Inbox | tray | - |
| Insights | chart.bar | - |

---

## States

### Loading States

#### Skeleton/Placeholder
```swift
struct SkeletonView: View {
    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: DS.Radius.sm)
            .fill(DS.Colors.divider)
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.4), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: isAnimating ? 200 : -200)
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}
```

#### Spinner
- Use `ProgressView()` with custom tint
- Size: 20pt default, 32pt for full-page
- Duration: Continuous
- Reduce motion: Static dots or percentage

### Empty States

```
        ┌─────────────────────┐
        │                     │
        │      📝             │  <- 64pt icon/emoji
        │                     │
        │   No tasks yet      │  <- title2 bold
        │   Add your first    │  <- body secondary
        │   task to get       │
        │   started           │
        │                     │
        │   ┌─────────────┐   │
        │   │  Add Task   │   │  <- Primary button
        │   └─────────────┘   │
        └─────────────────────┘
```

| Property | Value |
|----------|-------|
| Icon/Emoji | 64pt |
| Title | title2 bold, textPrimary |
| Description | body, textSecondary, center-aligned |
| Max width | 280pt |
| CTA button | Optional, primary style |

### Error States

#### Inline Error
```
┌─────────────────────────────────┐
│  ⚠️ Connection failed           │
│     Tap to retry                │
└─────────────────────────────────┘
```
- Background: `dangerLight` (#FEF2F2)
- Text: `danger` (#EF4444)
- Icon: exclamationmark.triangle.fill
- Corner radius: md
- Padding: md

#### Full Screen Error
Similar to empty state but with error icon and retry button.

### Success States

#### Inline Success
- Background: success light tint
- Icon: checkmark.circle.fill
- Text: success color
- Auto-dismiss after 3s (optional)

#### Toast/Snackbar
```
┌─────────────────────────────────┐
│  ✓ Task completed               │
└─────────────────────────────────┘
```
- Position: Bottom, above tab bar
- Background: `stone800`
- Text: white
- Duration: 2-3s
- Swipe to dismiss

### Disabled State

| Property | Modification |
|----------|--------------|
| Opacity | 40% |
| Interaction | `.disabled(true)` |
| Cursor | Not applicable (touch) |
| Color | Desaturated or gray |

### Pressed State

| Property | Modification |
|----------|--------------|
| Scale | 0.97-0.98 |
| Brightness | -8% to -12% |
| Animation | DS.Animation.quick |
| Haptic | Impact light |

```swift
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .brightness(configuration.isPressed ? -0.08 : 0)
            .animation(DS.Animation.quick, value: configuration.isPressed)
    }
}
```

### Focus State (Accessibility)

- Add 2-3pt ring in `sky` color
- Ensure 3:1 contrast against background
- Works with VoiceOver cursor

---

## Design Tokens (Swift)

### Complete Token Reference

```swift
import SwiftUI

// MARK: - Design System Namespace
enum DS {

    // MARK: - Colors
    enum Colors {
        // Brand Colors
        static let coral = Color(hex: "#E8847C")
        static let coralLight = Color(hex: "#FDF2F1")
        static let coralDark = Color(hex: "#D66B63")

        static let sage = Color(hex: "#7BAE7F")
        static let sageLight = Color(hex: "#F2F7F2")
        static let sageDark = Color(hex: "#5C8D60")

        static let sky = Color(hex: "#6BA3D6")
        static let skyLight = Color(hex: "#F0F6FB")
        static let skyDark = Color(hex: "#4A8BC7")

        static let lavender = Color(hex: "#9B8EC2")
        static let lavenderLight = Color(hex: "#F5F3F9")
        static let lavenderDark = Color(hex: "#7A6BA8")

        static let amber = Color(hex: "#D4A853")
        static let amberLight = Color(hex: "#FBF7EE")
        static let amberDark = Color(hex: "#B8923F")

        static let rose = Color(hex: "#C97B8E")
        static let roseLight = Color(hex: "#FAF1F3")
        static let roseDark = Color(hex: "#A85D71")

        static let slate = Color(hex: "#64748B")
        static let slateLight = Color(hex: "#F4F5F7")
        static let slateDark = Color(hex: "#475569")

        static let night = Color(hex: "#5C6B7A")
        static let nightLight = Color(hex: "#F3F4F5")
        static let nightDark = Color(hex: "#3F4D5A")

        // Neutral Scale (Stone)
        static let stone50 = Color(hex: "#FAFAF9")
        static let stone100 = Color(hex: "#F5F5F4")
        static let stone200 = Color(hex: "#E7E5E4")
        static let stone300 = Color(hex: "#D6D3D1")
        static let stone400 = Color(hex: "#A8A29E")
        static let stone500 = Color(hex: "#78716C")
        static let stone700 = Color(hex: "#44403C")
        static let stone800 = Color(hex: "#292524")
        static let stone900 = Color(hex: "#1C1917")

        // Semantic - Background
        static let bgPrimary = Color("Background") // Asset catalog
        static let bgSecondary = Color("CardBackground")
        static let bgTertiary = stone100
        static let bgElevated = Color.white // or asset

        // Semantic - Text
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let textMuted = stone400
        static let textInverse = Color.white

        // Semantic - Border
        static let border = stone200
        static let borderFocused = stone500
        static let divider = Color("Divider")
        static let dividerStrong = stone300

        // Status Colors
        static let success = Color(hex: "#10B981")
        static let successLight = Color(hex: "#ECFDF5")
        static let warning = Color(hex: "#F59E0B")
        static let warningLight = Color(hex: "#FFFBEB")
        static let danger = Color(hex: "#EF4444")
        static let dangerLight = Color(hex: "#FEF2F2")
        static let info = sky
        static let infoLight = skyLight

        // Utility
        static let emerald500 = Color(hex: "#10B981")
        static let teal500 = Color(hex: "#14B8A6")
        static let amber100 = Color(hex: "#FEF3C7")
        static let amber600 = Color(hex: "#D97706")

        // Planner (Dark Mode)
        static let plannerBackground = Color(hex: "#0D0D0D")
        static let plannerSurface = Color(hex: "#1A1A1A")
        static let plannerSurfaceTertiary = Color(hex: "#2A2A2A")
        static let plannerSurfaceElevated = Color(hex: "#333333")
        static let plannerTextPrimary = Color.white
        static let plannerTextSecondary = Color.white.opacity(0.6)
        static let plannerTextMuted = Color.white.opacity(0.4)
        static let plannerDivider = Color.white.opacity(0.08)

        // Glass Effect
        static let glassFillStrong = stone900.opacity(0.48)
        static let glassFill = stone900.opacity(0.36)
        static let glassFillLight = stone900.opacity(0.28)
        static let glassStroke = stone700.opacity(0.7)
        static let glassHighlight = Color.white.opacity(0.24)
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
        static let xxxxl: CGFloat = 48
    }

    // MARK: - Radius
    enum Radius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
        static let pill: CGFloat = 100
    }

    // MARK: - Sizes
    enum Sizes {
        // Touch targets
        static let minTouchTarget: CGFloat = 44
        static let iconButtonSize: CGFloat = 40

        // Components
        static let fabSize: CGFloat = 56
        static let bottomNavHeight: CGFloat = 83
        static let sheetHandle: CGFloat = 36
        static let buttonHeight: CGFloat = 50
        static let buttonHeightSmall: CGFloat = 44

        // Task Pills
        static let taskPillSmall: CGFloat = 40
        static let taskPillDefault: CGFloat = 56
        static let taskPillLarge: CGFloat = 80

        // Timeline
        static let timeLabelWidth: CGFloat = 40
        static let weekTimelineHeight: CGFloat = 320

        // Misc
        static let hairline: CGFloat = 1
        static let closeButtonSize: CGFloat = 32
        static let checkboxSize: CGFloat = 28
        static let colorChipSize: CGFloat = 32
    }

    // MARK: - Animation
    enum Animation {
        static let quick = SwiftUI.Animation.spring(response: 0.25, dampingFraction: 0.7)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let gentle = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.85)
        static let bounce = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.6)

        // Non-spring
        static let easeOut = SwiftUI.Animation.easeOut(duration: 0.2)
        static let easeInOut = SwiftUI.Animation.easeInOut(duration: 0.3)
    }

    // MARK: - Typography
    enum Typography {
        // Display
        static func largeTitle() -> Font { .largeTitle.weight(.bold) }
        static func title() -> Font { .title.weight(.bold) }
        static func title2() -> Font { .title2.weight(.bold) }
        static func title3() -> Font { .title3.weight(.semibold) }

        // Body
        static func headline() -> Font { .headline }
        static func body() -> Font { .body }
        static func callout() -> Font { .callout }
        static func subheadline() -> Font { .subheadline }

        // Detail
        static func footnote() -> Font { .footnote }
        static func caption() -> Font { .caption }
        static func caption2() -> Font { .caption2 }

        // Weighted variants
        static func title(weight: Font.Weight) -> Font { .title.weight(weight) }
        static func title2(weight: Font.Weight) -> Font { .title2.weight(weight) }
        static func headline(weight: Font.Weight) -> Font { .headline.weight(weight) }
        static func body(weight: Font.Weight) -> Font { .body.weight(weight) }
    }

    // MARK: - Shadows
    enum Shadows {
        static func raised() -> some View {
            Color.black.opacity(0.06).blur(radius: 4).offset(y: 2)
        }

        static func elevated() -> some View {
            Color.black.opacity(0.08).blur(radius: 12).offset(y: 4)
        }

        static func floating() -> some View {
            Color.black.opacity(0.12).blur(radius: 20).offset(y: 8)
        }
    }

    // MARK: - Haptics
    enum Haptics {
        static func light() { HapticManager.shared.impact(.light) }
        static func medium() { HapticManager.shared.impact(.medium) }
        static func heavy() { HapticManager.shared.impact(.heavy) }
        static func success() { HapticManager.shared.notification(.success) }
        static func warning() { HapticManager.shared.notification(.warning) }
        static func error() { HapticManager.shared.notification(.error) }
        static func selection() { HapticManager.shared.selection() }
    }
}

// MARK: - View Extensions

extension View {
    // Card styles
    func cardStyle() -> some View {
        self
            .background(DS.Colors.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    func elevatedStyle() -> some View {
        self
            .background(DS.Colors.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 8)
    }

    // Shadow helpers
    func shadowRaised() -> some View {
        self.shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    func shadowElevated() -> some View {
        self.shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    func shadowFloating() -> some View {
        self.shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
    }

    func shadowColored(_ color: Color) -> some View {
        self.shadow(color: color.opacity(0.45), radius: 8, x: 0, y: 4)
    }

    // Reduce motion helper
    func adaptiveAnimation<V: Equatable>(_ animation: Animation, value: V) -> some View {
        self.modifier(AdaptiveAnimationModifier(animation: animation, value: value))
    }
}

struct AdaptiveAnimationModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let animation: Animation
    let value: V

    func body(content: Content) -> some View {
        content.animation(
            reduceMotion ? .linear(duration: 0.1) : animation,
            value: value
        )
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: DS.Sizes.buttonHeight)
            .background(isEnabled ? DS.Colors.sky : DS.Colors.slate)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .brightness(configuration.isPressed ? -0.08 : 0)
            .animation(DS.Animation.quick, value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(DS.Colors.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: DS.Sizes.buttonHeightSmall)
            .background(DS.Colors.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .stroke(DS.Colors.border, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(DS.Animation.quick, value: configuration.isPressed)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(DS.Colors.sky)
            .frame(height: DS.Sizes.buttonHeightSmall)
            .background(configuration.isPressed ? DS.Colors.bgTertiary : .clear)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .animation(DS.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Usage Examples
/*

 // Typography
 Text("Title").font(DS.Typography.title2())
 Text("Body").scaledFont(size: 16, weight: .regular, relativeTo: .body)

 // Colors
 .foregroundStyle(DS.Colors.textPrimary)
 .background(DS.Colors.bgPrimary)

 // Spacing
 .padding(DS.Spacing.lg)
 .padding(.horizontal, DS.Spacing.xl)

 // Radius
 .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))

 // Animation
 .animation(DS.Animation.spring, value: isExpanded)
 withAnimation(DS.Animation.quick) { ... }

 // Haptics
 DS.Haptics.success()
 HapticManager.shared.taskCompleted()

 // Button Styles
 Button("Create") { ... }
     .buttonStyle(PrimaryButtonStyle())

 Button("Cancel") { ... }
     .buttonStyle(SecondaryButtonStyle())

 // Shadows
 .shadowRaised()
 .shadowColored(task.color.color)

 // Cards
 VStack { ... }
     .padding(DS.Spacing.lg)
     .cardStyle()

*/
```

### Color Asset Catalog Setup

For light/dark mode support, create these in Assets.xcassets:

| Asset Name | Light | Dark |
|------------|-------|------|
| Background | #FAFAF9 | #0D0D0D |
| CardBackground | #FFFFFF | #1A1A1A |
| Divider | #E7E5E4 | #FFFFFF @ 8% |

---

## Neurodivergent-Friendly Checklist

### Visual Clarity
- [ ] High contrast text (15:1+ ratio)
- [ ] Clear visual hierarchy
- [ ] Consistent spacing
- [ ] No distracting animations
- [ ] Reduce Motion support

### Cognitive Load
- [ ] One primary action per screen
- [ ] Clear, descriptive labels
- [ ] Progress indicators for multi-step flows
- [ ] Undo for destructive actions
- [ ] Confirmations for important actions

### Focus & Attention
- [ ] Minimal distractions
- [ ] Optional low-clutter mode
- [ ] Clear current task indicator
- [ ] Time-blocking visualization
- [ ] Break reminders

### Sensory Considerations
- [ ] Optional haptic feedback
- [ ] No sudden sounds
- [ ] Adjustable brightness/colors
- [ ] Pattern alternatives to color
- [ ] Calm color palette

### Flexibility
- [ ] Customizable colors
- [ ] Adjustable text size
- [ ] Flexible scheduling
- [ ] Multiple view options
- [ ] Forgiving input (undo/edit)

---

*Last updated: January 2026*
*Version: 2.0*
