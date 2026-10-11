import SwiftUI

struct CurrentMonthDetails: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let month: Date
    let entries: [PeriodEntry]
    let addAction: () -> Void
    let editAction: (PeriodEntry) -> Void
    let deleteAction: (PeriodEntry) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label {
                Text(
                    "Period starts for \(month, format: .dateTime.month(.wide))",
                    comment: "Current-month heading listing period start dates; the variable is the month name."
                )
            } icon: {
                Image(systemName: "calendar.badge.clock")
            }
            .font(.title2.bold())
            .foregroundStyle(AppTheme.primaryText)
            .accessibilityAddTraits(.isHeader)

            if entries.isEmpty {
                Text("No dates added yet")
                    .font(.body)
                    .foregroundStyle(AppTheme.secondaryText)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(entries) { entry in
                        periodEntryRow(entry)
                    }
                }
            }

            Button(entries.isEmpty ? "Add date" : "Add another date", action: addAction)
                .buttonStyle(LavenderPrimaryButtonStyle())
        }
        .lavenderCard(fill: AppTheme.card)
    }

    @ViewBuilder
    private func periodEntryRow(_ entry: PeriodEntry) -> some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 10))
            : AnyLayout(HStackLayout(spacing: 12))

        layout {
            Text(entry.date, format: .dateTime.day().month(.wide).year())
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText)

            if !dynamicTypeSize.isAccessibilitySize {
                Spacer()
            }

            HStack(spacing: 12) {
                Button("Edit") {
                    editAction(entry)
                }
                .buttonStyle(LavenderSecondaryButtonStyle())

                Button("Delete", role: .destructive) {
                    deleteAction(entry)
                }
                .buttonStyle(LavenderSecondaryButtonStyle())
                .foregroundStyle(AppTheme.destructive)
            }
        }
    }
}
