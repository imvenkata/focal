# Focal - Visual Task Manager

A native iOS app for visual task management and scheduling, built with Swift and SwiftUI.

## Requirements

- Xcode 15.0+
- iOS 17.0+
- macOS Sonoma or later

## Quick Start

### Option 1: Run via Xcode (Recommended)

```bash
open /Users/venkata/projects/focal/Focal.xcodeproj
```

Then press **⌘R** (Cmd+R) to build and run.

### Option 2: Run via Command Line

```bash
cd /Users/venkata/projects/focal

# Build the app
xcodebuild -project Focal.xcodeproj -scheme Focal -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -configuration Debug build

# Boot simulator, install and launch
xcrun simctl boot "iPhone 17 Pro" 2>/dev/null
xcrun simctl install booted ~/Library/Developer/Xcode/DerivedData/Focal-*/Build/Products/Debug-iphonesimulator/Focal.app
xcrun simctl launch booted com.focal.app
open -a Simulator
```

### One-liner (after initial build)

```bash
cd /Users/venkata/projects/focal && xcodebuild -project Focal.xcodeproj -scheme Focal -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build && xcrun simctl boot "iPhone 17 Pro" 2>/dev/null; xcrun simctl install booted ~/Library/Developer/Xcode/DerivedData/Focal-*/Build/Products/Debug-iphonesimulator/Focal.app && xcrun simctl launch booted com.focal.app && open -a Simulator
```

## Features

- **Weekly Timeline View** - 7-day overview with task pins
- **Daily Timeline View** - Detailed single-day view with task cards
- **Add Task Sheet** - Create tasks with auto icon/color suggestions
- **Task Detail View** - Edit tasks, manage subtasks, set energy levels
- **Energy Tracking** - 5 levels from Restful to Intense
- **Haptic Feedback** - Tactile responses throughout the app
- **8 Color Palette** - Coral, Sage, Sky, Lavender, Amber, Rose, Slate, Night

## Project Structure

```
Focal/
├── App/
│   ├── FocalApp.swift
│   └── ContentView.swift
├── Models/
│   ├── TaskItem.swift
│   ├── TaskColor.swift
│   ├── Subtask.swift
│   └── EnergyLevel.swift
├── ViewModels/
│   ├── TaskStore.swift
│   └── Tab.swift
├── Views/
│   ├── Timeline/
│   ├── Task/
│   ├── Pickers/
│   ├── Components/
│   └── Navigation/
├── Utilities/
│   ├── DesignSystem.swift
│   ├── IconMapper.swift
│   ├── HapticManager.swift
│   └── DateExtensions.swift
└── Resources/
    └── Assets.xcassets
```

## Tech Stack

- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Data Persistence:** SwiftData
- **Architecture:** MVVM
- **Minimum iOS:** 17.0
