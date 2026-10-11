//
//  CalanderViewModel.swift
//  PeriodsTracker
//
//  Created by Neenu on 11/10/26.
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class CalanderViewModel {
    private(set) var selectedMonth: Date?
    private(set) var selectedEntry: PeriodEntry?
    private(set) var pendingDeletionEntry: PeriodEntry?
    var datePickerDate: Date
    var isDatePickerPresented = false
    var isSaveErrorPresented = false
    var isDeleteConfirmationPresented = false

    private let calendar: Calendar
    private let now: () -> Date

    init(calendar: Calendar = .current, now: @escaping () -> Date = Date.init) {
        self.calendar = calendar
        self.now = now
        datePickerDate = calendar.startOfDay(for: now())
    }

    var currentMonth: Date {
        calendar.dateInterval(of: .month, for: now())?.start ?? now()
    }

    var previousMonths: [Date] {
        (1..<3).compactMap { offset in
            calendar.date(byAdding: .month, value: -offset, to: currentMonth)
        }
    }

    var selectableDates: ClosedRange<Date> {
        let month = selectedMonth ?? currentMonth
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else {
            let today = calendar.startOfDay(for: now())
            return today...today
        }

        let today = calendar.startOfDay(for: now())
        let lastDay = calendar.date(byAdding: .day, value: -1, to: monthInterval.end)
            ?? monthInterval.start
        let latestSelectableDate = calendar.isDate(month, equalTo: today, toGranularity: .month)
            ? today
            : lastDay

        return monthInterval.start...latestSelectableDate
    }

    func entries(for month: Date, in entries: [PeriodEntry]) -> [PeriodEntry] {
        entries
            .filter { calendar.isDate($0.date, equalTo: month, toGranularity: .month) }
            .sorted { $0.date < $1.date }
    }

    func entry(on date: Date, in entries: [PeriodEntry]) -> PeriodEntry? {
        entries.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func presentDatePicker(for month: Date, editing entry: PeriodEntry? = nil) {
        selectedMonth = month
        selectedEntry = entry
        let defaultDate = calendar.isDate(month, equalTo: now(), toGranularity: .month)
            ? now()
            : month
        datePickerDate = calendar.startOfDay(for: entry?.date ?? defaultDate)
        isDatePickerPresented = true
    }

    func dismissDatePicker() {
        isDatePickerPresented = false
        selectedMonth = nil
        selectedEntry = nil
    }

    func requestDeletion(of entry: PeriodEntry) {
        pendingDeletionEntry = entry
        isDeleteConfirmationPresented = true
    }

    func cancelDeletion() {
        pendingDeletionEntry = nil
    }

    func saveSelectedDate(entries: [PeriodEntry], modelContext: ModelContext) {
        guard selectedMonth != nil else {
            return
        }

        let periodDate = calendar.startOfDay(for: datePickerDate)
        let duplicateEntry = entry(on: periodDate, in: entries)

        if let selectedEntry {
            if duplicateEntry == nil || duplicateEntry === selectedEntry {
                selectedEntry.date = periodDate
            } else {
                dismissDatePicker()
                return
            }
        } else if duplicateEntry == nil {
            modelContext.insert(PeriodEntry(date: periodDate))
        } else {
            dismissDatePicker()
            return
        }

        saveChanges(in: modelContext) {
            dismissDatePicker()
        }
    }

    func deletePendingEntry(modelContext: ModelContext) {
        guard let pendingDeletionEntry else {
            return
        }

        modelContext.delete(pendingDeletionEntry)
        saveChanges(in: modelContext) {
            self.pendingDeletionEntry = nil
        }
    }

    private func saveChanges(in modelContext: ModelContext, onSuccess: () -> Void = {}) {
        do {
            try modelContext.save()
            onSuccess()
        } catch {
            modelContext.rollback()
            isSaveErrorPresented = true
        }
    }
}
