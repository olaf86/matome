import SwiftUI
import Foundation

public enum ReportRange: String, CaseIterable, Identifiable {
    case day, week, month, year

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .day: return "Today"
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        }
    }

    public var dateInterval: (start: Date, end: Date) {
        let now = Date()
        let calendar = Calendar.current
        let start: Date
        switch self {
        case .day:   start = calendar.startOfDay(for: now)
        case .week:  start = calendar.date(byAdding: .day,   value: -7,  to: now)!
        case .month: start = calendar.date(byAdding: .month, value: -1,  to: now)!
        case .year:  start = calendar.date(byAdding: .year,  value: -1,  to: now)!
        }
        return (start, now)
    }
}

public enum ReportDataSource: String, CaseIterable, Identifiable {
    case log
    case media
    case health
    case github

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .log: return "Log"
        case .media: return "Media"
        case .health: return "Health"
        case .github: return "GitHub"
        }
    }

    public var systemImage: String {
        switch self {
        case .log: return "note.text"
        case .media: return "photo.on.rectangle"
        case .health: return "heart"
        case .github: return "chevron.left.slash.chevron.right"
        }
    }
}

public struct ReportDataItem: Identifiable {
    public let id = UUID()
    public let source: ReportDataSource
    public let title: String
    public let timestamp: Date

    public init(source: ReportDataSource, title: String, timestamp: Date) {
        self.source = source
        self.title = title
        self.timestamp = timestamp
    }
}

public struct Metric: Identifiable {
    public let id = UUID()
    public let title: String
    public let value: Double
    public let unit: String?
    public let systemImage: String
    public let delta: Double?

    public init(title: String, value: Double, unit: String?, systemImage: String, delta: Double?) {
        self.title = title
        self.value = value
        self.unit = unit
        self.systemImage = systemImage
        self.delta = delta
    }

    public var formattedValue: String {
        if let unit = unit {
            return String(format: "%.0f %@", value, unit)
        } else {
            return String(format: "%.0f", value)
        }
    }

    public var deltaDescription: String? {
        guard let delta else { return nil }
        let symbol = delta >= 0 ? "+" : ""
        return "\(symbol)\(Int(delta))% vs prev"
    }

    public var deltaColor: Color {
        guard let delta else { return .secondary }
        return delta >= 0 ? .green : .red
    }
}
