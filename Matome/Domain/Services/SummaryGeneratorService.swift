import Foundation
import FoundationModels

@available(iOS 26.0, *)
final class SummaryGeneratorService {

    static var isAvailable: Bool {
        if case .available = SystemLanguageModel.default.availability { return true }
        return false
    }

    /// Streams a Markdown summary. Each yielded value is the fully accumulated text so far.
    func stream(items: [ReportDataItem], range: ReportRange) -> AsyncThrowingStream<String, Error> {
        let prompt = buildPrompt(items: items, range: range)
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let session = LanguageModelSession(
                        instructions: "You are a personal diary assistant. Summarize activity data in concise, friendly Markdown."
                    )
                    for try await partial in session.streamResponse(to: prompt) {
                        continuation.yield(partial.content)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private func buildPrompt(items: [ReportDataItem], range: ReportRange) -> String {
        var lines = ["Summarize my personal activity for the past \(range.rawValue)."]

        let grouped = Dictionary(grouping: items, by: \.source)
        for source in ReportDataSource.allCases {
            guard let sourceItems = grouped[source], !sourceItems.isEmpty else { continue }
            lines.append("\n### \(source.title) (\(sourceItems.count))")
            for item in sourceItems.prefix(20) {
                let dateStr = item.timestamp.formatted(date: .abbreviated, time: .shortened)
                lines.append("- \(dateStr): \(item.title)")
            }
        }

        lines.append("\nWrite a concise Markdown summary with key highlights and brief insights.")
        return lines.joined(separator: "\n")
    }
}
