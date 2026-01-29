//
//  ContextService.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/28.
//

import Foundation
import SwiftData

final class ContextService {

    // MARK: - SwiftData
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Public API
    /// Save a single LogEntry using SwiftData.
    /// - Parameter log: The LogEntry to persist. Assumes `LogEntry` is annotated with `@Model`.
    func saveLog(_ log: LogEntry) {
        context.insert(log)
        do {
            try context.save()
        } catch {
            assertionFailure("Failed to save LogEntry with SwiftData: \(error)")
        }
    }

    /// Load all stored LogEntry items from SwiftData.
    /// - Returns: An array of LogEntry previously saved, sorted by date descending if `date` exists.
    func loadLogs() -> [LogEntry] {
        do {
            var descriptor = FetchDescriptor<LogEntry>()
            // If LogEntry has a `date` property, sort by newest first. If not, this will be ignored by the compiler.
            descriptor.sortBy = [SortDescriptor(\LogEntry.date, order: .reverse)]
            return try context.fetch(descriptor)
        } catch {
            // In case of failure, return empty list.
            return []
        }
    }
}
