//
//  LogEntryTests.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/29.
//

import Foundation
import Testing
import SwiftData

@testable import Matome

@Suite("LogEntry read/write with SwiftData")
struct LogEntryTests {

    /// Helper to create an in-memory ModelContext for tests.
    private func makeInMemoryContext() throws -> ModelContext {
        let schema = Schema([LogEntry.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: configuration)
        return ModelContext(container)
    }

    @Test("Save one LogEntry and load it back, sorted by date desc")
    func saveAndLoadSingleLog() throws {
        // Arrange
        let context = try makeInMemoryContext()
        let service = ContextService(context: context)
        let now = Date()
        let log = LogEntry(text: "Hello", date: now)

        // Act
        service.saveLog(log)
        let fetched = service.loadLogs()

        // Assert
        #expect(fetched.count == 1)
        let first = try #require(fetched.first)
        #expect(first.id == log.id)
        #expect(first.text == "Hello")
        #expect(abs(first.date.timeIntervalSince(now)) < 0.01)
    }

    @Test("Save multiple LogEntry items and verify reverse chronological order")
    func saveMultipleLogsAndVerifySort() throws {
        // Arrange
        let context = try makeInMemoryContext()
        let service = ContextService(context: context)

        let older = LogEntry(text: "Older", date: Date(timeIntervalSinceNow: -3600))
        let newer = LogEntry(text: "Newer", date: Date())

        // Act
        service.saveLog(older)
        service.saveLog(newer)
        let fetched = service.loadLogs()

        // Assert
        #expect(fetched.count == 2)
        // Newest first
        #expect(fetched.first?.id == newer.id)
        #expect(fetched.last?.id == older.id)
    }
}
