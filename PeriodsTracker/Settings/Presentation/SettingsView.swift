import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query private var periodEntries: [PeriodEntry]
    @Query private var wellnessEntries: [DailyWellnessEntry]

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("typicalCycleLength") private var typicalCycleLength = CycleCalculator.defaultCycleLength
    @AppStorage("typicalPeriodLength") private var typicalPeriodLength = CycleCalculator.defaultPeriodLength
    @AppStorage("periodRemindersEnabled") private var periodRemindersEnabled = false

    @State private var isResetConfirmationPresented = false
    @State private var isDeleteConfirmationPresented = false
    @State private var isDeleteErrorPresented = false
    @State private var isNotificationPermissionAlertPresented = false

    var body: some View {
        Form {
            Section("Cycle Preferences") {
                Stepper(value: $typicalCycleLength, in: 21...40) {
                    LabeledContent("Typical cycle length", value: "\(typicalCycleLength) days")
                }
                .accessibilityValue("\(typicalCycleLength) days")

                Stepper(value: $typicalPeriodLength, in: 2...10) {
                    LabeledContent("Typical period length", value: "\(typicalPeriodLength) days")
                }
                .accessibilityValue("\(typicalPeriodLength) days")
            }

            Section {
                Toggle("Private cycle reminder", isOn: $periodRemindersEnabled)
            } header: {
                Text("Reminders")
            } footer: {
                Text("Receive a discreet notification five days before your expected date. The notification does not mention periods or cycle information.")
            }

            Section("Privacy") {
                Label("Your cycle information stays on this device.", systemImage: "lock.shield.fill")
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Section {
                Button("Set Up Again", systemImage: "arrow.counterclockwise") {
                    isResetConfirmationPresented = true
                }
            } header: {
                Text("Setup")
            } footer: {
                Text("This returns you to setup without deleting your logged history.")
            }

            Section {
                Button("Delete All Data", systemImage: "trash", role: .destructive) {
                    isDeleteConfirmationPresented = true
                }
            } header: {
                Text("Data")
            } footer: {
                Text("Permanently deletes all logged periods and wellness information from this device.")
            }

            Section {
                HStack {
                    Text("Her Cycle")
                    Spacer()
                    Text("Every cycle matters")
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .appScreenBackground()
        .onChange(of: periodRemindersEnabled) { _, isEnabled in
            Task {
                await updateReminder(
                    isEnabled: isEnabled,
                    requestAuthorizationIfNeeded: isEnabled
                )
            }
        }
        .onChange(of: typicalCycleLength) { _, _ in
            Task {
                await updateReminder(isEnabled: periodRemindersEnabled)
            }
        }
        .confirmationDialog(
            "Set up your cycle again?",
            isPresented: $isResetConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Set Up Again") {
                hasCompletedOnboarding = false
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your logged cycle history will be kept.")
        }
        .confirmationDialog(
            "Delete all cycle data?",
            isPresented: $isDeleteConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Delete All Data", role: .destructive, action: deleteAllData)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
        .alert("Notifications Are Off", isPresented: $isNotificationPermissionAlertPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Allow notifications for Her Cycle in the Settings app to use private reminders.")
        }
        .alert("Unable to Delete Data", isPresented: $isDeleteErrorPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your data could not be deleted. Please try again.")
        }
    }

    private func updateReminder(
        isEnabled: Bool,
        requestAuthorizationIfNeeded: Bool = false
    ) async {
        let result = await PeriodReminderScheduler.updateReminder(
            isEnabled: isEnabled,
            periodDates: periodEntries.map(\.date),
            typicalCycleLength: typicalCycleLength,
            requestAuthorizationIfNeeded: requestAuthorizationIfNeeded
        )

        if result == .permissionDenied, isEnabled {
            periodRemindersEnabled = false
            isNotificationPermissionAlertPresented = true
        }
    }

    private func deleteAllData() {
        periodEntries.forEach(modelContext.delete)
        wellnessEntries.forEach(modelContext.delete)

        do {
            try modelContext.save()
            Task {
                _ = await PeriodReminderScheduler.updateReminder(
                    isEnabled: false,
                    periodDates: [],
                    typicalCycleLength: typicalCycleLength
                )
            }
        } catch {
            modelContext.rollback()
            isDeleteErrorPresented = true
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: [PeriodEntry.self, DailyWellnessEntry.self], inMemory: true)
}
