import Foundation
import Testing
import SwiftData

@testable import Matome

@Suite("LogViewModel paging")
struct LogViewModelTests {

    private func makeInMemoryContext() throws -> ModelContext {
        let schema = Schema([LogEntry.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: configuration)
        return ModelContext(container)
    }

    @Test("Load logs in pages of 10")
    func loadPagedLogs() throws {
        let context = try makeInMemoryContext()
        let baseDate = Date(timeIntervalSince1970: 1_700_000_000)
        _ = try SampleLogDataFactory.seedLogs(
            context: context,
            baseDate: baseDate,
            days: 5,
            logsPerDay: 5
        )

        let viewModel = LogViewModel()
        viewModel.loadInitial(context: context)
        #expect(viewModel.logs.count == 10)
        #expect(viewModel.hasMore == true)

        viewModel.loadMore(context: context)
        #expect(viewModel.logs.count == 20)
        #expect(viewModel.hasMore == true)

        viewModel.loadMore(context: context)
        #expect(viewModel.logs.count == 25)
        #expect(viewModel.hasMore == false)
    }
}
