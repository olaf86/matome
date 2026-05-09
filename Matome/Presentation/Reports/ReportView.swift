//
//  ReportView.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/28.
//

import SwiftUI

struct ReportView: View {

    @StateObject private var viewModel = ReportViewModel()
    @State private var isPresentingGenerate: Bool = false

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

                    // Data sources used for summary generation
                    DataSourcesSection(items: viewModel.dataItems)

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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Generate") {
                        isPresentingGenerate = true
                    }
                    .accessibilityLabel("Generate Summary")
                }
            }
            .sheet(isPresented: $isPresentingGenerate) {
                ReportGenerateView(
                    range: viewModel.selectedRange,
                    items: viewModel.dataItems
                )
            }
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

private struct DataSourcesSection: View {
    let items: [ReportDataItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Data Sources")
                .font(.headline)
            ForEach(ReportDataSource.allCases) { source in
                let sourceItems = items
                    .filter { $0.source == source }
                    .sorted { $0.timestamp > $1.timestamp }
                DataSourceBlock(
                    source: source,
                    items: sourceItems
                )
            }
        }
    }
}

private struct DataSourceBlock: View {
    let source: ReportDataSource
    let items: [ReportDataItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: source.systemImage)
                    .foregroundStyle(.secondary)
                Text(source.title)
                    .font(.subheadline.weight(.semibold))
            }

            if items.isEmpty {
                Text("No items for this range")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 6) {
                    ForEach(items) { item in
                        DataItemRow(item: item)
                    }
                }
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

private struct DataItemRow: View {
    let item: ReportDataItem

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(item.title)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer(minLength: 8)
            Text(item.timestamp.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
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
