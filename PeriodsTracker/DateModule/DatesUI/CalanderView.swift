//
//  CalanderView.swift
//  PeriodsTracker
//
//  Created by Neenu on 10/10/26.
//

import SwiftData
import SwiftUI

struct CalanderView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PeriodEntry.date, order: .reverse)
    private var periodEntries: [PeriodEntry]
    @State private var viewModel = CalanderViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel
        let currentEntries = viewModel.entries(
            for: viewModel.currentMonth,
            in: periodEntries
        )

        List {
            Section {
                CurrentMonthDetails(
                    month: viewModel.currentMonth,
                    entries: currentEntries,
                    addAction: {
                        viewModel.presentDatePicker(for: viewModel.currentMonth)
                    },
                    editAction: { entry in
                        viewModel.presentDatePicker(
                            for: viewModel.currentMonth,
                            editing: entry
                        )
                    },
                    deleteAction: { entry in
                        viewModel.requestDeletion(of: entry)
                    }
                )
                .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            Section {
                ForEach(viewModel.previousMonths, id: \.self) { month in
                    let entries = viewModel.entries(for: month, in: periodEntries)

                    PeriodMonthRow(
                        month: month,
                        entries: entries,
                        addAction: {
                            viewModel.presentDatePicker(for: month)
                        },
                        editAction: { entry in
                            viewModel.presentDatePicker(for: month, editing: entry)
                        },
                        deleteAction: { entry in
                            viewModel.requestDeletion(of: entry)
                        }
                    )
                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            } header: {
                Text("Previous history")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)
                    .accessibilityAddTraits(.isHeader)
                    .textCase(nil)
                    .padding(.horizontal, 4)
            }
        }
        .listStyle(.plain)
        .appScreenBackground()
        .navigationTitle("Period dates")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $viewModel.isDatePickerPresented) {
            NavigationStack {
                DatePicker(
                    "Period date",
                    selection: $viewModel.datePickerDate,
                    in: viewModel.selectableDates,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                .background(AppTheme.background)
                .foregroundStyle(AppTheme.primaryText)
                .tint(AppTheme.primaryPurple)
                .navigationTitle(
                    viewModel.selectedEntry == nil
                        ? "Add period start"
                        : "Edit period start"
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            viewModel.dismissDatePicker()
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            viewModel.saveSelectedDate(
                                entries: periodEntries,
                                modelContext: modelContext
                            )
                        }
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationBackground(AppTheme.background)
        }
        .alert("Unable to Update Date", isPresented: $viewModel.isSaveErrorPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please try again.")
        }
        .tint(AppTheme.primaryPurple)
        .confirmationDialog(
            "Delete period date?",
            isPresented: $viewModel.isDeleteConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Delete Date", role: .destructive) {
                viewModel.deletePendingEntry(modelContext: modelContext)
            }
            Button("Cancel", role: .cancel) {
                viewModel.cancelDeletion()
            }
        } message: {
            Text("This removes this logged period start and updates your predictions.")
        }
    }
}

#Preview {
    NavigationStack {
        CalanderView()
    }
    .modelContainer(for: PeriodEntry.self, inMemory: true)
}
