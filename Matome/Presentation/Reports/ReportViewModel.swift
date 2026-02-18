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

    // Any cancellables if needed later
    private var cancellables: Set<AnyCancellable> = []

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

    private static func deltaDescription(from delta: Int) -> String? {
        if delta == 0 { return "No change" }
        if delta > 0 { return "+\(delta) vs previous" }
        return "\(delta) vs previous"
    }
}
