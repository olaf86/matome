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
