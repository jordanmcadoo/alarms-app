# Alarms App — Hatch Take-Home

A SwiftUI alarm app built for the Hatch mobile interview assignment.

## Setup

**Requirements:** Xcode 16+, [xcodegen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

```bash
xcodegen generate
open AlarmsApp.xcodeproj
```

Run on any iOS 17+ simulator or device.

## Architecture

| File | Role |
|------|------|
| `Models/Alarm.swift` | `Alarm` struct + `RemoteAlarm` Decodable for backend mapping |
| `Stores/AlarmStore.swift` | `@Observable` in-memory store; sorts alarms by time-of-day |
| `Services/AlarmService.swift` | Async fetch from mockapi endpoint |
| `Services/AlarmScheduler.swift` | 1-second `Timer` polling; `AVAudioPlayer` playback |
| `Views/` | SwiftUI views — list, row, add sheet, firing overlay |

## Functional walkthrough

- **List:** Alarms sorted ascending by time-of-day (matching the stock Clock app). Backend-fetched alarms show a cloud badge (☁). Each row has an enable toggle.
- **Add:** Tap **+** → wheel time picker + inline sound picker → **Save** adds locally (no cloud badge).
- **Firing:** `AlarmScheduler` ticks every second comparing hour+minute. When matched it plays the alarm sound and presents `FiringAlarmView` (non-dismissible) with a **Stop** button.
- **Sounds:** Looks for a bundled audio file matching the sound name (e.g. `ocean.mp3`). Falls back to system sound ID 1005 if no file is bundled.

## What I'd add with more time

1. **Bundled audio files** — add actual `.mp3`/`.caf` files for each `AlarmSound` case so the scheduler plays real sounds instead of the system beep fallback.
2. **Snooze** — a Snooze button on `FiringAlarmView` that re-fires after N minutes.
3. **Delete alarms** — swipe-to-delete on list rows.
4. **Recurrence display** — show the `recurring` label (weekly / yearly / one-time) in the row subtitle.
5. **Error UI** — surface a banner when the backend fetch fails rather than silently logging.
6. **Haptics** — `UINotificationFeedbackGenerator` when the alarm fires.
7. **Unit tests** — test `AlarmStore` sort order and `AlarmScheduler` tick logic with an injectable clock.
