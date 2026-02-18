//
//  LogViewModel.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/29.
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class LogViewModel {
    private(set) var logs: [LogEntry] = []
    private(set) var hasMore: Bool = true
    private(set) var isLoading: Bool = false
    var selectedDate: Date = Date()

    private let pageSize: Int = 10
    private var fetchOffset: Int = 0

    func loadInitial(context: ModelContext) {
        fetchOffset = 0
        hasMore = true
        logs = []
        loadMore(context: context)
    }

    func loadMore(context: ModelContext) {
        guard !isLoading, hasMore else { return }
        isLoading = true

        var descriptor = FetchDescriptor<LogEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = pageSize
        descriptor.fetchOffset = fetchOffset

        do {
            let results = try context.fetch(descriptor)
            logs.append(contentsOf: results)
            fetchOffset += results.count
            if results.count < pageSize {
                hasMore = false
            }
        } catch {
            assertionFailure("Failed to fetch LogEntry: \(error)")
            hasMore = false
        }

        isLoading = false
    }

    func shouldLoadMore(currentLog: LogEntry) -> Bool {
        guard let lastLog = logs.last else { return false }
        return lastLog.id == currentLog.id
    }

    func jumpToDate(_ date: Date, context: ModelContext) {
        selectedDate = date
        if logs.isEmpty {
            loadInitial(context: context)
        }

        let calendar = Calendar.current
        while hasMore, let oldest = logs.last?.date, calendar.startOfDay(for: oldest) > calendar.startOfDay(for: date) {
            loadMore(context: context)
        }
    }

    func closestLogID(to date: Date) -> UUID? {
        guard let closest = logs.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }) else {
            return nil
        }
        return closest.id
    }

    func latestLogID() -> UUID? {
        logs.max(by: { $0.date < $1.date })?.id
    }

    func sections() -> [LogSection] {
        let calendar = Calendar.current
        var buckets: [Date: [LogEntry]] = [:]
        let orderedLogs = logs.sorted(by: { $0.date < $1.date })
        for log in orderedLogs {
            let day = calendar.startOfDay(for: log.date)
            buckets[day, default: []].append(log)
        }

        let sortedDays = buckets.keys.sorted(by: <)
        return sortedDays.map { day in
            let dayLogs = (buckets[day] ?? []).sorted(by: { $0.date < $1.date })
            return LogSection(
                id: day,
                title: LogSection.dateFormatter.string(from: day),
                logs: dayLogs
            )
        }
    }

    func insertNewLog(_ log: LogEntry) {
        logs.insert(log, at: 0)
        fetchOffset += 1
    }
}

struct LogSection: Identifiable {
    let id: Date
    let title: String
    let logs: [LogEntry]

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
