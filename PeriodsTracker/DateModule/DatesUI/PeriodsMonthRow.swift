import SwiftUI

struct PeriodMonthRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let month: Date
    let entries: [PeriodEntry]
    let addAction: () -> Void
    let editAction: (PeriodEntry) -> Void
    let deleteAction: (PeriodEntry) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(month, format: .dateTime.month(.wide).year())
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText)

            if entries.isEmpty {
                Text("No dates added")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
            } else {
                ForEach(entries) { entry in
                    entryRow(entry)
                }
            }

            Button(entries.isEmpty ? "Add" : "Add another", action: addAction)
                .buttonStyle(LavenderSecondaryButtonStyle())
        }
        .lavenderCard()
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private func entryRow(_ entry: PeriodEntry) -> some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 10))
            : AnyLayout(HStackLayout(spacing: 12))

        layout {
            Text(entry.date, format: .dateTime.day().month(.wide).year())
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)

            if !dynamicTypeSize.isAccessibilitySize {
                Spacer()
            }

            HStack(spacing: 10) {
                Button("Edit") {
                    editAction(entry)
                }
                .buttonStyle(.borderless)

                Button("Delete", role: .destructive) {
                    deleteAction(entry)
                }
                .buttonStyle(.borderless)
                .foregroundStyle(AppTheme.destructive)
            }
        }
    }
}
