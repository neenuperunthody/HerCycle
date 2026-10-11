import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PeriodEntry.date, order: .reverse)
    private var periodEntries: [PeriodEntry]

    @AppStorage("typicalCycleLength") private var storedCycleLength = CycleCalculator.defaultCycleLength
    @AppStorage("typicalPeriodLength") private var storedPeriodLength = CycleCalculator.defaultPeriodLength

    @State private var lastPeriodDate = Date.now
    @State private var cycleLength = CycleCalculator.defaultCycleLength
    @State private var includesPeriodDuration = false
    @State private var periodDuration = CycleCalculator.defaultPeriodLength
    @State private var isSaveErrorPresented = false

    let completionAction: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    OnboardingHeader()
                    LastPeriodCard(date: $lastPeriodDate)
                    CycleLengthCard(cycleLength: $cycleLength)
                    PeriodDurationCard(
                        includesPeriodDuration: $includesPeriodDuration,
                        periodDuration: $periodDuration
                    )

                    Button(action: saveAndContinue) {
                        Label("Start Tracking", systemImage: "arrow.right")
                    }
                    .buttonStyle(LavenderPrimaryButtonStyle())

                    Text("You can update your period dates anytime. Your information stays on this device.")
                        .font(.footnote)
                        .foregroundStyle(AppTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: 560)
                .padding(.horizontal, AppTheme.horizontalPadding)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
            }
            .background(AppTheme.background)
            .navigationTitle("Set up your cycle")
            .navigationBarTitleDisplayMode(.inline)
            .tint(AppTheme.primaryPurple)
            .alert("Unable to Save", isPresented: $isSaveErrorPresented) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your setup could not be saved. Please try again.")
            }
        }
    }

    private func saveAndContinue() {
        storedCycleLength = cycleLength
        storedPeriodLength = includesPeriodDuration
            ? periodDuration
            : CycleCalculator.defaultPeriodLength

        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: lastPeriodDate)
        let alreadyStored = periodEntries.contains {
            calendar.isDate($0.date, inSameDayAs: normalizedDate)
        }

        if !alreadyStored {
            modelContext.insert(PeriodEntry(date: normalizedDate))
        }

        do {
            try modelContext.save()
            completionAction()
        } catch {
            modelContext.rollback()
            isSaveErrorPresented = true
        }
    }
}

private struct OnboardingHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("A few gentle details", systemImage: "sparkles")
                .font(.title2.bold())
                .foregroundStyle(AppTheme.primaryText)
                .accessibilityAddTraits(.isHeader)

            Text("These choices help personalize your starting prediction. You can continue without creating an account.")
                .font(.body)
                .foregroundStyle(AppTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct LastPeriodCard: View {
    @Binding var date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Last period date", systemImage: "calendar")
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText)

            DatePicker(
                "Select the first day",
                selection: $date,
                in: ...Date.now,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(AppTheme.primaryPurple)
        }
        .lavenderCard(fill: AppTheme.card)
    }
}

#Preview("Onboarding") {
    OnboardingView(completionAction: {})
        .modelContainer(for: PeriodEntry.self, inMemory: true)
}
