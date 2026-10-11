# Her Cycle

Her Cycle is a privacy-focused iOS period tracker built with SwiftUI. It helps users record period dates, understand where they are in their cycle, and receive gentle predictions and wellness guidance without creating an account.

## Features

- Guided onboarding for the last period date and typical cycle details
- Calendar-based period logging and history
- Dashboard with the current cycle status and expected next period
- Contextual daily wellness tips
- Optional discreet local reminder five days before the predicted period
- Adjustable cycle and period lengths
- On-device storage with controls to restart setup or delete all saved data
- VoiceOver-friendly labels and scalable system typography

> Predictions are estimates based on the dates and cycle information entered by the user. Her Cycle is not a medical device and should not be used as a substitute for professional medical advice.

## Technology

- Swift and SwiftUI
- SwiftData for local persistence
- UserNotifications for private, on-device reminders
- `AppStorage` for preferences and onboarding state
- SwiftUI previews for development support

## Requirements

- iOS 17 or later
- Xcode 15 or later

## Getting Started

1. Clone this repository.
2. Open the project in Xcode.
3. Select the `PeriodsTracker` scheme and an iOS simulator or connected device.
4. Build and run with **Command-R**.

No external packages, API keys, accounts, or backend services are required.

Notification permission is requested only when private reminders are enabled. The app remains fully usable if permission is declined.

## Project Structure

```text
PeriodsTracker/
├── Dashboard/          # Cycle status, predictions, and quick actions
├── DateModule/         # Calendar UI and cycle calculations
├── Onboarding/         # Welcome and initial cycle setup
├── Settings/           # Preferences, reminders, and data controls
├── AppTheme.swift      # Shared colors and view styling
├── PeriodEntry.swift   # SwiftData models
├── PeriodReminderScheduler.swift
├── ContentView.swift   # Root navigation and onboarding flow
└── MyApp.swift         # Application entry point and model container
```

## Privacy

Cycle and wellness information is stored locally on the device through SwiftData. The app does not require an account and does not send cycle data to a remote service. Reminder notifications use discreet wording and are scheduled locally.

## License

No license has been specified for this project.
