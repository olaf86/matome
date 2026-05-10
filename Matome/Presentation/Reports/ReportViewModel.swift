import Foundation
import Combine
import SwiftData

@MainActor
final class ReportViewModel: ObservableObject {
    @Published var selectedRange: ReportRange = .week
    @Published var metrics: [Metric] = []
    @Published var dataItems: [ReportDataItem] = []
    @Published var isLoading: Bool = false

    private let aggregator = ReportAggregatorService()

    func load(context: ModelContext) {
        Task {
            isLoading = true
            let result = await aggregator.aggregate(range: selectedRange, context: context)
            metrics = result.metrics
            dataItems = result.items
            isLoading = false
        }
    }
}
