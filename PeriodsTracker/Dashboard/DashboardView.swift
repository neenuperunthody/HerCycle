//
//  DashboardView.swift
//  PeriodsTracker
//
//  Created by Neenu on 10/10/26.
//

import SwiftData
import SwiftUI

struct DashboardView: View {
    @Query(sort: \PeriodEntry.date, order: .reverse)
    private var periodEntries: [PeriodEntry]

    @AppStorage("typicalCycleLength")
    private var typicalCycleLength = CycleCalculator.defaultCycleLength
    @AppStorage("typicalPeriodLength")
    private var typicalPeriodLength = CycleCalculator.defaultPeriodLength
    @AppStorage("periodRemindersEnabled")
    private var periodRemindersEnabled = false

    private var reminderConfiguration: PeriodReminderConfiguration {
        PeriodReminderConfiguration(
            isEnabled: periodRemindersEnabled,
            periodDates: periodEntries.map(\.date),
            typicalCycleLength: typicalCycleLength
        )
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60 * 60)) { context in
            let periodDates = periodEntries.map(\.date)
            let cycleCalculator = CycleCalculator(
                typicalCycleLength: typicalCycleLength,
                typicalPeriodLength: typicalPeriodLength
            )
            let status = cycleCalculator.status(for: periodDates, today: context.date)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    DashboardHeader()

                    CyclePredictionCard(
                        message: DashboardMessage(status: status),
                        expectedDate: cycleCalculator.expectedPeriodDate(
                            for: periodDates,
                            today: context.date
                        )
                    )

                    WellnessTipCard(status: status)

                    QuickActionsSection()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(AppTheme.background)
        }
        .navigationTitle("Today")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            }
        }
        .foregroundStyle(AppTheme.primaryText)
        .tint(AppTheme.primaryPurple)
        .task(id: reminderConfiguration) {
            _ = await PeriodReminderScheduler.updateReminder(
                isEnabled: reminderConfiguration.isEnabled,
                periodDates: reminderConfiguration.periodDates,
                typicalCycleLength: reminderConfiguration.typicalCycleLength
            )
        }
    }
}

private struct DashboardHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Your cycle, at a glance")
                .font(.title2.bold())
                .foregroundStyle(AppTheme.primaryText)
                .accessibilityAddTraits(.isHeader)

            Text("Gentle insights based on the dates you’ve confirmed.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CyclePredictionCard: View {
    let message: DashboardMessage
    let expectedDate: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label {
                Text(message.contextLabel)
            } icon: {
                Image(systemName: message.symbolName)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(AppTheme.primaryText)

            Text(message.title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppTheme.primaryText)

            if let prominentValue = message.prominentValue {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(prominentValue)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .contentTransition(.numericText())

                    if let prominentLabel = message.prominentLabel {
                        Text(prominentLabel)
                            .font(.headline)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }
                .foregroundStyle(AppTheme.primaryPurple)
            }

            if let expectedDate {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                    Text("Expected period: \(expectedDate, format: .dateTime.day().month(.wide).year())")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.primaryText)
            }

            Text(message.description)
                .font(.body)
                .foregroundStyle(AppTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            if expectedDate != nil {
                Label("Prediction based on your logged period starts", systemImage: "sparkles")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .lavenderCard(fill: AppTheme.card)
        .accessibilityElement(children: .combine)
    }
}

private struct WellnessTipCard: View {
    let status: CycleStatus

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "lightbulb.fill")
                .font(.title2)
                .foregroundStyle(AppTheme.primaryPurple)

            VStack(alignment: .leading, spacing: 6) {
                Text("Daily wellness tip")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)

                Text(tip)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .lavenderCard()
        .accessibilityElement(children: .combine)
    }

    private var tip: LocalizedStringResource {
        switch status {
        case .onPeriod:
            "Stay hydrated and take time to rest."
        case .expected(let days) where days <= 7:
            "Your period is approaching. A little extra self-care may help."
        case .late:
            "Cycles can vary. Keep checking in with your body and log any changes."
        case .noData, .expected:
            "Listen to your body and take good care of yourself."
        }
    }
}

private struct QuickActionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Quick actions")
                .font(.title3.bold())
                .foregroundStyle(AppTheme.primaryText)
                .accessibilityAddTraits(.isHeader)

            NavigationLink {
                CalanderView()
            } label: {
                QuickActionLabel(
                    title: "Log Period",
                    symbolName: "drop.fill",
                    color: AppTheme.primaryPurple
                )
            }
            .buttonStyle(.plain)
        }
    }
}

private struct QuickActionLabel: View {
    let title: LocalizedStringResource
    let symbolName: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: symbolName)
                .font(.title2)
                .foregroundStyle(color)

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 72)
        .lavenderCard(fill: AppTheme.card)
    }
}

struct DashboardMessage {
    let title: LocalizedStringResource
    let description: LocalizedStringResource
    let prominentValue: String?
    let prominentLabel: LocalizedStringResource?
    let contextLabel: LocalizedStringResource
    let symbolName: String
    let accentColor: Color

    init(status: CycleStatus) {
        switch status {
        case .noData:
            title = "Let’s get to know your cycle"
            description = "Add your last period date to start tracking your cycle and get personalized insights."
            prominentValue = nil
            prominentLabel = nil
            contextLabel = "Get started"
            symbolName = "heart.circle.fill"
            accentColor = AppTheme.primaryPurple
        case .onPeriod(let day):
            title = "Your period is here"
            description = "This is confirmed from your most recent logged period start."
            prominentValue = String(day)
            prominentLabel = day == 1 ? "period day" : "period days"
            contextLabel = "Confirmed period"
            symbolName = "drop.fill"
            accentColor = AppTheme.primaryPurple
        case .expected(let days) where days <= 3:
            title = "Your period is around the corner"
            description = "A little extra self-care might feel good right now."
            prominentValue = String(days)
            prominentLabel = days == 1 ? "day to go" : "days to go"
            contextLabel = "Prediction"
            symbolName = "calendar.badge.clock"
            accentColor = AppTheme.primaryPurple
        case .expected(let days) where days <= 7:
            title = "A little self-care goes a long way"
            description = "Listen to your body and take time for yourself."
            prominentValue = String(days)
            prominentLabel = "days to go"
            contextLabel = "Prediction"
            symbolName = "heart.text.square.fill"
            accentColor = AppTheme.primaryPurple
        case .expected(let days):
            title = "Every phase of your cycle matters"
            description = "Keep tracking your cycle and caring for yourself."
            prominentValue = String(days)
            prominentLabel = "days to go"
            contextLabel = "Prediction"
            symbolName = "leaf.fill"
            accentColor = AppTheme.primaryPurple
        case .late:
            title = "Your period is taking a little longer"
            description = "Your period is later than predicted. Cycles can vary, so keep tracking how you feel."
            prominentValue = "—"
            prominentLabel = "later than predicted"
            contextLabel = "Prediction"
            symbolName = "questionmark.circle.fill"
            accentColor = AppTheme.primaryPurple
        }
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
    .modelContainer(for: PeriodEntry.self, inMemory: true)
}
