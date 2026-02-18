import Foundation
import SwiftData

@testable import Matome

enum SampleLogDataFactory {
    static func seedLogs(
        context: ModelContext,
        baseDate: Date,
        days: Int,
        logsPerDay: Int
    ) throws -> [LogEntry] {
        let calendar = Calendar.current
        var logs: [LogEntry] = []

        for dayOffset in 0..<days {
            for logIndex in 0..<logsPerDay {
                guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: baseDate) else { continue }
                guard let date = calendar.date(byAdding: .minute, value: -logIndex, to: day) else { continue }
                let log = LogEntry(text: "Sample \(dayOffset)-\(logIndex)", date: date)
                context.insert(log)
                logs.append(log)
            }
        }

        try context.save()
        return logs
    }
}
