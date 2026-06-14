# Alarmcal

## Purpose
iOS 26 calendar app that looks and works like Apple's native Calendar (month grid, day/agenda view, event creation), but any event can trigger a real AlarmKit alarm — full alarm-clock behavior (rings, vibrates, demands dismissal), not a dismissible notification.

## Architecture
- **Platform:** iOS 26+, SwiftUI, Swift 6 concurrency (MainActor default)
- **Persistence:** SwiftData for events
- **Alarms:** AlarmKit framework — schedule/cancel alarms tied to calendar events
- **Bundle ID:** sloop.alarmcal
- **Team:** B928V37KFD

## Project Structure
```
alarmcal/
  alarmcalApp.swift          — App entry point
  Models/                    — SwiftData models (CalendarEvent)
  Views/                     — SwiftUI views (MonthView, DayView, EventEditor, etc.)
  Services/                  — AlarmKitManager (schedule/cancel/auth)
  Assets.xcassets/           — Colors, app icon
alarmcalTests/               — Unit tests
alarmcalUITests/             — UI tests
```

## AlarmKit Integration (ported from slooops/Moonbeam)
Key patterns:
- `AlarmMetadata` conformance (empty struct is fine)
- `AlarmManager.shared.requestAuthorization()` for permission
- `AlarmManager.shared.schedule(id:configuration:)` / `.cancel(id:)` for lifecycle
- `AlarmConfiguration` uses `AlarmAttributes` with `AlarmPresentation(alert:)`, `AlarmButton` for stop/snooze
- Info.plist requires `NSAlarmKitUsageDescription`
- No separate widget/Live Activity extension target needed

## Build & Run
Open `alarmcal.xcodeproj` in Xcode 26+, build for iOS 26 simulator or device.

## Conventions
- SwiftUI with Swift 6 strict concurrency
- `@MainActor` isolation by default (set in build settings)
- No third-party dependencies
