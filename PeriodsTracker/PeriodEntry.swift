import Foundation
import SwiftData

@Model
final class PeriodEntry {
    var date: Date

    init(date: Date) {
        self.date = date
    }
}

@Model
final class DailyWellnessEntry {
    var date: Date
    var selections: [String]

    init(date: Date, selections: [String] = []) {
        self.date = date
        self.selections = selections
    }
}

enum CycleStatus: Equatable {
    case noData
    case onPeriod(day: Int)
    case expected(days: Int)
    case late
}

struct CycleCalculator {
    static let defaultCycleLength = 28
    static let defaultPeriodLength = 5

    let calendar: Calendar
    let typicalCycleLength: Int
    let typicalPeriodLength: Int

    init(
        calendar: Calendar = .current,
        typicalCycleLength: Int = Self.defaultCycleLength,
        typicalPeriodLength: Int = Self.defaultPeriodLength
    ) {
        self.calendar = calendar
        self.typicalCycleLength = typicalCycleLength
        self.typicalPeriodLength = typicalPeriodLength
    }

    func status(for periodDates: [Date], today: Date = .now) -> CycleStatus {
        let dates = periodDates.map(calendar.startOfDay(for:)).sorted()
        guard !dates.isEmpty else {
            return .noData
        }

        let today = calendar.startOfDay(for: today)
        let confirmedDates = dates.filter { $0 <= today }

        if let latestConfirmedDate = confirmedDates.last,
           let daysSinceStart = calendar.dateComponents(
               [.day],
               from: latestConfirmedDate,
               to: today
           ).day,
           (0..<typicalPeriodLength).contains(daysSinceStart) {
            return .onPeriod(day: daysSinceStart + 1)
        }

        let latestDate = dates.last ?? today
        if latestDate > today {
            let days = calendar.dateComponents([.day], from: today, to: latestDate).day ?? 0
            return .expected(days: days)
        }

        guard let expectedDate = calendar.date(
            byAdding: .day,
            value: cycleLength(from: dates),
            to: latestDate
        ) else {
            return .noData
        }

        let days = calendar.dateComponents([.day], from: today, to: expectedDate).day ?? 0
        return days > 0 ? .expected(days: days) : .late
    }

    func expectedPeriodDate(for periodDates: [Date], today: Date = .now) -> Date? {
        let dates = confirmedDates(from: periodDates, today: today)
        guard let latestDate = dates.last else {
            return nil
        }

        return calendar.date(
            byAdding: .day,
            value: predictedCycleLength(from: dates),
            to: latestDate
        )
    }

    func currentCycleDay(for periodDates: [Date], today: Date = .now) -> Int? {
        let dates = confirmedDates(from: periodDates, today: today)
        guard let latestDate = dates.last,
              let elapsedDays = calendar.dateComponents(
                [.day],
                from: latestDate,
                to: calendar.startOfDay(for: today)
              ).day,
              elapsedDays >= 0 else {
            return nil
        }

        return elapsedDays + 1
    }

    func averageCycleLength(for periodDates: [Date], today: Date = .now) -> Int? {
        let dates = confirmedDates(from: periodDates, today: today)
        let intervals = validCycleIntervals(from: dates)
        guard !intervals.isEmpty else {
            return nil
        }

        return Int((Double(intervals.reduce(0, +)) / Double(intervals.count)).rounded())
    }

    private func confirmedDates(from periodDates: [Date], today: Date) -> [Date] {
        let today = calendar.startOfDay(for: today)
        return periodDates
            .map(calendar.startOfDay(for:))
            .filter { $0 <= today }
            .sorted()
    }

    private func validCycleIntervals(from sortedDates: [Date]) -> [Int] {
        zip(sortedDates, sortedDates.dropFirst()).compactMap { earlier, later in
            calendar.dateComponents([.day], from: earlier, to: later).day
        }
        .filter { (15...60).contains($0) }
    }

    private func predictedCycleLength(from sortedDates: [Date]) -> Int {
        averageCycleLength(for: sortedDates) ?? typicalCycleLength
    }

    private func cycleLength(from sortedDates: [Date]) -> Int {
        let intervals = validCycleIntervals(from: sortedDates)

        guard !intervals.isEmpty else {
            return typicalCycleLength
        }

        return Int((Double(intervals.reduce(0, +)) / Double(intervals.count)).rounded())
    }
}
