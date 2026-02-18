//
//  ReportView.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/28.
//

import SwiftUI

struct ReportView: View {
    
    @StateObject private var viewModel = ReportViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Range selector
                    Picker("Range", selection: $viewModel.selectedRange) {
                        ForEach(ReportRange.allCases, id: \.self) { range in
                            Text(range.title).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)

                    // Summary metrics
                    SummarySection(metrics: viewModel.metrics)

                    // Chart placeholder
                    ChartPlaceholder()
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.quaternary, lineWidth: 1)
                        )
                }
                .padding()
            }
            .navigationTitle("Report")
        }
    }
}
// MARK: - Supporting UI

private struct SummarySection: View {
    let metrics: [Metric]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Summary")
                .font(.headline)
            LazyVGrid(columns: [
                GridItem(.flexible(minimum: 100, maximum: .infinity)),
                GridItem(.flexible(minimum: 100, maximum: .infinity))
            ], spacing: 12) {
                ForEach(metrics) { metric in
                    MetricCard(metric: metric)
                }
            }
        }
    }
}

private struct MetricCard: View {
    let metric: Metric

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: metric.systemImage)
                    .foregroundStyle(.secondary)
                Text(metric.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Text(metric.formattedValue)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
            if let delta = metric.deltaDescription {
                Text(delta)
                    .font(.footnote)
                    .foregroundStyle(metric.deltaColor)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary, lineWidth: 1)
        )
    }
}

private struct ChartPlaceholder: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.blue.opacity(0.15), Color.clear], startPoint: .top, endPoint: .bottom)
            VStack(spacing: 8) {
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 28))
                    .foregroundStyle(.blue)
                Text("Chart will appear here")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .background(Color(.secondarySystemBackground))
    }
}

#Preview {
    ReportView()
}

