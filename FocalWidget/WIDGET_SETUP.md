# Focal Widget Setup Guide

This guide walks through adding the Widget Extension target to the Focal Xcode project.

## Prerequisites
- Xcode 15+
- iOS 17+ deployment target
- Apple Developer account (for App Groups)

## Step 1: Add Widget Extension Target

1. Open `Focal.xcodeproj` in Xcode
2. Go to **File > New > Target**
3. Select **Widget Extension** under iOS
4. Configure the widget:
   - Product Name: `FocalWidget`
   - Team: (Select your team)
   - Bundle Identifier: `com.focal.app.widget` (adjust to match your main app's bundle ID pattern)
   - Include Configuration App Intent: **Unchecked** (we use StaticConfiguration)
   - Include Live Activity: **Unchecked** (optional, can add later)
5. Click **Finish**
6. When prompted to activate the scheme, click **Activate**

## Step 2: Delete Auto-Generated Files

Xcode creates template files. Delete these and use the pre-created ones:

1. Delete the auto-generated Swift files in the FocalWidget group
2. Add the existing files from `FocalWidget/` folder:
   - `FocalWidgetBundle.swift`
   - `TodayTasksWidget.swift`
   - `Info.plist`

## Step 3: Configure App Groups

App Groups allow the main app and widget to share data.

### In the Main App (Focal):
1. Select the **Focal** target
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Add **App Groups**
5. Create a new group: `group.com.focal.app`

### In the Widget Extension (FocalWidget):
1. Select the **FocalWidget** target
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Add **App Groups**
5. Select the same group: `group.com.focal.app`

## Step 4: Update Bundle Identifiers

Ensure your bundle identifiers follow this pattern:
- Main App: `com.focal.app` (or your chosen identifier)
- Widget: `com.focal.app.widget` (must be prefixed with main app's ID)

## Step 5: Add Widget Files to Target

1. Select `FocalWidgetBundle.swift` in Project Navigator
2. In File Inspector, check **FocalWidget** under Target Membership
3. Repeat for `TodayTasksWidget.swift`

## Step 6: Shared Code (Optional)

If you want to share models between the app and widget:

1. Create a new framework target (e.g., `FocalCore`)
2. Move shared models (`TaskItem`, `TaskColor`, etc.) to the framework
3. Link both Focal and FocalWidget to FocalCore

For simplicity, the widget uses its own `WidgetTask` model that mirrors task data via App Groups.

## Step 7: Build and Run

1. Select the **FocalWidget** scheme
2. Build to ensure no errors
3. Select the **Focal** scheme
4. Run on simulator or device
5. Add widget from Home Screen:
   - Long press on Home Screen
   - Tap **+** button
   - Search for "Focal"
   - Add the widget

## Troubleshooting

### Widget Not Appearing
- Ensure widget extension is embedded in the main app
- Check **Embed App Extensions** in Build Phases
- Restart simulator/device

### Data Not Syncing
- Verify App Groups capability is added to BOTH targets
- Ensure group identifier matches: `group.com.focal.app`
- Check that `WidgetDataService.swift` is in the main app target

### Build Errors
- Ensure deployment target matches (iOS 17+)
- Verify signing team is set for both targets
- Clean build folder: **Product > Clean Build Folder**

## Widget Features

The Today Tasks Widget supports:
- **Small**: Progress ring + next task preview
- **Medium**: Progress + task list (4 items)
- **Large**: Full task list with times (6 items)

### Planned Enhancements
- Interactive widgets (iOS 17+) for quick task completion
- Lock Screen widgets
- Live Activities for current task

## File Structure

```
FocalWidget/
├── FocalWidgetBundle.swift    # Widget entry point
├── TodayTasksWidget.swift     # Widget views and provider
├── Info.plist                 # Widget configuration
└── WIDGET_SETUP.md            # This guide

Focal/Utilities/
└── WidgetDataService.swift    # App Group data sync
```
