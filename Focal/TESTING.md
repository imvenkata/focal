# Focal App - Testing Checklist

## Testing Priorities (from agents.md)

### ✅ Completed
- [x] Light mode support
- [x] Animations at 60fps
- [x] Haptic feedback triggers
- [x] VoiceOver accessibility labels
- [x] Empty states display

### 🔄 In Progress
- [ ] Dark mode support (see Dark Mode section below)
- [ ] Dynamic Type scaling (see Dynamic Type section below)

### ⏳ Device Testing
- [ ] iPhone SE (small screen - 4.7" / 375pt)
- [ ] iPhone 15 (standard - 6.1" / 393pt)
- [ ] iPhone 15 Pro Max (large screen - 6.7" / 430pt)

### ⏳ UI Features
- [ ] Keyboard avoidance in sheets
- [ ] Pull to refresh (if applicable)

---

## Dynamic Type Testing

### Overview
Dynamic Type allows users to adjust text size system-wide. Focal should scale all text while maintaining layout integrity.

### Text Sizes to Test
1. **Extra Small** (xSmall)
2. **Small**
3. **Medium** (Default)
4. **Large**
5. **Extra Large** (xLarge)
6. **Extra Extra Large** (xxLarge)
7. **Extra Extra Extra Large** (xxxLarge)

### How to Test

**Simulator:**
1. Settings → Accessibility → Display & Text Size → Larger Text
2. Drag slider to test each size
3. Return to Focal and verify all screens

**Device:**
1. Settings → Display & Brightness → Text Size
2. Adjust slider
3. Test Focal screens

### What to Verify

#### Typography Scaling
- [ ] All text increases/decreases proportionally
- [ ] No text truncation at largest size
- [ ] No overlapping text at any size

#### Layout Flexibility
- [ ] Task cards expand vertically as needed
- [ ] Timeline maintains proportions
- [ ] Bottom nav bar remains readable
- [ ] Sheet content stays scrollable

#### Component Behavior
- [ ] **TaskCardView**: Title wraps, no overflow
- [ ] **StatsBar**: Numbers remain readable
- [ ] **WeekSelector**: Day labels scale
- [ ] **DailyTimelineView**: Time labels proportional
- [ ] **AddTaskSheet**: All input fields accessible

### Current Implementation Status
- ✅ Using system fonts (`.system(size:)`)
- ⚠️ Some hardcoded sizes need `.dynamic()` modifier
- ❌ Layout constraints not all flexible

### Recommended Fixes
1. Replace fixed `.frame(height:)` with `idealHeight` where possible
2. Use `.minimumScaleFactor()` for constrained text
3. Add `.lineLimit(nil)` for critical text
4. Test with `@ScaledMetric` for custom sizes

---

## Dark Mode Support

### Current Status
❌ Not implemented - all colors use light mode values

### Implementation Strategy

#### 1. Update DesignSystem.swift Colors

Add dark mode variants:

```swift
enum Colors {
    // Background
    static let background = Color("Background") // Use Asset Catalog
    static let cardBackground = Color("CardBackground")
    
    // Text
    static let textPrimary = Color.primary // Adapts automatically
    static let textSecondary = Color.secondary
    
    // Task colors remain the same (vibrant in both modes)
    static let coral = Color(hex: "#E8847C")
    static let sage = Color(hex: "#7BAE7F")
    // ... etc
}
```

#### 2. Asset Catalog Colors

Create color sets in `Assets.xcassets`:
- `Background`: Light #F8F7F4 / Dark #1C1917 (stone-900)
- `CardBackground`: Light #FFFFFF / Dark #292524 (stone-800)
- `Divider`: Light #E7E5E4 / Dark #57534E (stone-600)

#### 3. Manual Hex Colors to Convert

Search and replace in codebase:
- `Color(hex: "#F8F7F4")` → `DS.Colors.background`
- `Color(hex: "#F5F5F5")` → Asset catalog color
- `.white` → `DS.Colors.cardBackground`

#### 4. Testing Dark Mode

**Enable Dark Mode:**
- Simulator: Settings → Developer → Dark Appearance
- Device: Settings → Display & Brightness → Dark

**Verify:**
- [ ] All screens readable
- [ ] No pure white backgrounds (use stone-900)
- [ ] Task colors maintain vibrancy
- [ ] Contrast meets WCAG AA (4.5:1 for text)
- [ ] Shadows still visible (adjust opacity)

#### 5. Optional: Auto-Switching

Respect user's system preference:
```swift
@Environment(\.colorScheme) private var colorScheme
```

Use in components that need mode-specific behavior.

---

## Device Screen Size Testing

### iPhone SE (375pt width)
**Concerns:**
- Bottom nav + FAB spacing
- Week view day columns (7 columns at 50pt each)
- Day view task cards width

**Test:**
- [ ] All text readable
- [ ] No horizontal scrolling
- [ ] FAB doesn't overlap content
- [ ] Sheets fit without clipping

### iPhone 15 Pro Max (430pt width)
**Concerns:**
- Week view columns too wide
- Excessive whitespace
- Touch targets too far apart

**Test:**
- [ ] Layout scales appropriately
- [ ] No stretched UI elements
- [ ] Comfortable one-handed reach

---

## Keyboard Avoidance

### Affected Screens
- AddTaskSheet (title input, notes)
- TaskDetailView (title, notes, add subtask)

### Testing Steps
1. Tap text field
2. Verify keyboard doesn't cover input
3. Verify can still see "Done" button
4. Test on both iPhone SE and Pro Max

### Implementation
Use `.scrollDismissesKeyboard(.interactively)` on ScrollViews.

---

## Continuous Testing

### Before Each Release
1. Run through all screens
2. Test at smallest and largest text sizes
3. Test in light and dark mode
4. Test on iPhone SE and Pro Max
5. Run VoiceOver through critical flows

### Automated Testing (Future)
- UI snapshot tests for both modes
- Accessibility audit with XCTest
- Performance testing for 60fps animations
