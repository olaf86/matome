import Foundation
import SwiftData
import Photos
import HealthKit

struct AggregatorResult {
    let items: [ReportDataItem]
    let metrics: [Metric]
}

final class ReportAggregatorService {

    private let healthStore = HKHealthStore()
    private let githubTokenKey = "github_token"

    func aggregate(range: ReportRange, context: ModelContext) async -> AggregatorResult {
        let (start, end) = range.dateInterval

        async let logItems    = fetchLogItems(start: start, end: end, context: context)
        async let mediaItems  = fetchMediaItems(start: start, end: end)
        async let healthData  = fetchHealthData(start: start, end: end)
        async let githubItems = fetchGitHubItems(start: start, end: end)

        let (logs, media, (stepCount, healthItem), github) =
            await (logItems, mediaItems, healthData, githubItems)

        var all = logs + media + github
        if let healthItem { all.append(healthItem) }
        all.sort { $0.timestamp > $1.timestamp }

        return AggregatorResult(items: all, metrics: buildMetrics(items: all, stepCount: stepCount))
    }

    // MARK: - Log

    private func fetchLogItems(start: Date, end: Date, context: ModelContext) async -> [ReportDataItem] {
        let descriptor = FetchDescriptor<LogEntry>(
            predicate: #Predicate<LogEntry> { entry in
                entry.date >= start && entry.date <= end
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let entries = (try? context.fetch(descriptor)) ?? []
        return entries.map { ReportDataItem(source: .log, title: $0.text, timestamp: $0.date) }
    }

    // MARK: - Media

    private func fetchMediaItems(start: Date, end: Date) async -> [ReportDataItem] {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(
            format: "creationDate >= %@ AND creationDate <= %@",
            start as NSDate, end as NSDate
        )
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        var items: [ReportDataItem] = []
        let assets = PHAsset.fetchAssets(with: options)
        assets.enumerateObjects { asset, _, _ in
            let title = asset.mediaType == .video ? "Video" : "Photo"
            let date = asset.creationDate ?? start
            items.append(ReportDataItem(source: .media, title: title, timestamp: date))
        }
        return items
    }

    // MARK: - Health

    private func fetchHealthData(start: Date, end: Date) async -> (stepCount: Int, item: ReportDataItem?) {
        guard
            HKHealthStore.isHealthDataAvailable(),
            let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)
        else { return (0, nil) }

        let steps = await withCheckedContinuation { (cont: CheckedContinuation<Int, Never>) in
            let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in
                let count = Int(result?.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                cont.resume(returning: count)
            }
            healthStore.execute(query)
        }

        guard steps > 0 else { return (0, nil) }
        let item = ReportDataItem(source: .health, title: "\(steps) steps", timestamp: end)
        return (steps, item)
    }

    // MARK: - GitHub

    private func fetchGitHubItems(start: Date, end: Date) async -> [ReportDataItem] {
        guard let token = KeychainHelper.load(forKey: githubTokenKey) else { return [] }

        var request = URLRequest(url: URL(string: "https://api.github.com/user/events?per_page=100")!)
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        guard
            let (data, _) = try? await URLSession.shared.data(for: request),
            let events = try? decoder.decode([GitHubEvent].self, from: data)
        else { return [] }

        return events
            .filter { $0.createdAt >= start && $0.createdAt <= end }
            .map { ReportDataItem(source: .github, title: $0.displayTitle, timestamp: $0.createdAt) }
    }

    // MARK: - Metrics

    private func buildMetrics(items: [ReportDataItem], stepCount: Int) -> [Metric] {
        func count(of source: ReportDataSource) -> Double {
            Double(items.filter { $0.source == source }.count)
        }
        return [
            Metric(title: "Logs",   value: count(of: .log),    unit: nil, systemImage: "note.text",                     delta: nil),
            Metric(title: "Media",  value: count(of: .media),  unit: nil, systemImage: "photo.on.rectangle",            delta: nil),
            Metric(title: "GitHub", value: count(of: .github), unit: nil, systemImage: "chevron.left.slash.chevron.right", delta: nil),
            Metric(title: "Steps",  value: Double(stepCount),  unit: nil, systemImage: "figure.walk",                   delta: nil),
        ]
    }
}

// MARK: - GitHub Event model (file-private)

private struct GitHubEvent: Decodable {
    let type: String
    let createdAt: Date
    let repo: Repo

    struct Repo: Decodable {
        let name: String
    }

    var displayTitle: String {
        let shortName = repo.name.split(separator: "/").last.map(String.init) ?? repo.name
        switch type {
        case "PushEvent":        return "Pushed to \(shortName)"
        case "PullRequestEvent": return "Pull request in \(shortName)"
        case "IssuesEvent":      return "Issue in \(shortName)"
        case "CreateEvent":      return "Created \(shortName)"
        default:                 return shortName
        }
    }
}
