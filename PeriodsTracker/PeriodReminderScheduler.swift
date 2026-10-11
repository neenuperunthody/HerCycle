import Foundation
import UserNotifications

enum PeriodReminderScheduler {
    static let reminderLeadDays = 5
    static let requestIdentifier = "period-prediction-reminder"

    enum SchedulingResult: Equatable {
        case scheduled
        case disabled
        case noPrediction
        case reminderDatePassed
        case permissionDenied
    }

    static func updateReminder(
        isEnabled: Bool,
        periodDates: [Date],
        typicalCycleLength: Int,
        requestAuthorizationIfNeeded: Bool = false,
        calendar: Calendar = .current,
        now: Date = .now
    ) async -> SchedulingResult {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [requestIdentifier])

        guard isEnabled else {
            return .disabled
        }

        let settings = await center.notificationSettings()
        let isAuthorized: Bool

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            isAuthorized = true
        case .notDetermined where requestAuthorizationIfNeeded:
            isAuthorized = (try? await center.requestAuthorization(options: [.alert, .sound])) == true
        case .denied, .notDetermined:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }

        guard isAuthorized else {
            return .permissionDenied
        }

        let calculator = CycleCalculator(typicalCycleLength: typicalCycleLength)
        guard let expectedDate = calculator.expectedPeriodDate(
            for: periodDates,
            today: now
        ) else {
            return .noPrediction
        }

        guard let reminderDay = calendar.date(
            byAdding: .day,
            value: -reminderLeadDays,
            to: expectedDate
        ) else {
            return .noPrediction
        }

        var reminderComponents = calendar.dateComponents(
            [.year, .month, .day],
            from: reminderDay
        )
        reminderComponents.hour = 9
        reminderComponents.minute = 0

        guard let reminderDate = calendar.date(from: reminderComponents),
              reminderDate > now else {
            return .reminderDatePassed
        }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "A gentle reminder")
        content.body = String(
            localized: "Something you asked Her Cycle to remember is coming up in five days."
        )
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: reminderComponents,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: requestIdentifier,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            return .scheduled
        } catch {
            return .noPrediction
        }
    }
}

struct PeriodReminderConfiguration: Equatable {
    let isEnabled: Bool
    let periodDates: [Date]
    let typicalCycleLength: Int
}
