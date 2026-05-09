//
//  ReportViewModel.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/02/05.
//

import Foundation
import Combine

@MainActor
final class ReportViewModel: ObservableObject {
    // Selected time range for reports (drives the Picker in ReportView)
    @Published var selectedRange: ReportRange = .week {
        didSet { updateMetrics() }
    }

    // Summary metrics displayed in ReportView
    @Published var metrics: [Metric] = []

    // Data items shown per source within the selected range
    @Published var dataItems: [ReportDataItem] = []

    init() {
        updateMetrics()
    }

    // Recompute metrics based on the selected range.
    // This is placeholder logic; replace with real data aggregation.
    private func updateMetrics() {
        // Example placeholder values that vary with range to show UI changes
        switch selectedRange {
        case .day:
            metrics = Self.sampleMetrics(total: 3, completed: 2, delta: 1)
        case .week:
            metrics = Self.sampleMetrics(total: 21, completed: 15, delta: -2)
        case .month:
            metrics = Self.sampleMetrics(total: 90, completed: 70, delta: 5)
        case .year:
            metrics = Self.sampleMetrics(total: 1000, completed: 840, delta: 20)
        }

        dataItems = Self.sampleDataItems(for: selectedRange)
    }

    // MARK: - Sample metric factory
    private static func sampleMetrics(total: Int, completed: Int, delta: Int) -> [Metric] {
        let completionRate = total == 0 ? 0.0 : (Double(completed) / Double(total))
        return [
            Metric(title: "Total", value: Double(total), unit: nil, systemImage: "sum", delta: Double(delta)),
            Metric(title: "Completed", value: Double(completed), unit: nil, systemImage: "checkmark.circle", delta: Double(delta)),
            Metric(title: "Completion Rate", value: Double(completionRate), unit: nil, systemImage: "percent", delta: Double(delta))
        ]
    }

    private static func sampleDataItems(for range: ReportRange) -> [ReportDataItem] {
        let calendar = Calendar.current
        let now = Date()
        let timeOffsets: [Int]

        switch range {
        case .day:
            timeOffsets = [1, 2, 4, 6, 8]
        case .week:
            timeOffsets = [1, 6, 12, 18, 24, 36, 48]
        case .month:
            timeOffsets = [2, 6, 12, 24, 36, 48, 72, 96, 120]
        case .year:
            timeOffsets = [6, 12, 24, 48, 72, 96, 120, 168]
        }

        let logItems: [ReportDataItem] = timeOffsets.prefix(4).compactMap { offset -> ReportDataItem? in
            guard let date = calendar.date(byAdding: .hour, value: -offset, to: now) else { return nil }
            return ReportDataItem(source: .log, title: "Log entry", timestamp: date)
        }

        let mediaItems: [ReportDataItem] = timeOffsets.prefix(3).compactMap { offset -> ReportDataItem? in
            guard let date = calendar.date(byAdding: .hour, value: -(offset + 1), to: now) else { return nil }
            return ReportDataItem(source: .media, title: "Photo/Video", timestamp: date)
        }

        let healthItems: [ReportDataItem] = timeOffsets.prefix(3).compactMap { offset -> ReportDataItem? in
            guard let date = calendar.date(byAdding: .hour, value: -(offset + 2), to: now) else { return nil }
            return ReportDataItem(source: .health, title: "Health data", timestamp: date)
        }

        let githubItems: [ReportDataItem] = timeOffsets.prefix(2).compactMap { offset -> ReportDataItem? in
            guard let date = calendar.date(byAdding: .hour, value: -(offset + 3), to: now) else { return nil }
            return ReportDataItem(source: .github, title: "Commit/PR", timestamp: date)
        }

        return (logItems + mediaItems + healthItems + githubItems)
            .sorted { $0.timestamp > $1.timestamp }
    }
}
