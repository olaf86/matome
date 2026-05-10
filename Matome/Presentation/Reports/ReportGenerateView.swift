import SwiftUI

struct ReportGenerateView: View {
    let range: ReportRange
    let items: [ReportDataItem]

    @Environment(\.dismiss) private var dismiss
    @State private var generatedSummary: String = ""
    @State private var isGenerating: Bool = false
    @State private var isModelAvailable: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Summary Preview")
                            .font(.headline)
                        Text("Range: \(range.title)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if !isModelAvailable {
                        UnavailableBanner()
                    }

                    IncludedSourcesSection(items: items)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Generated Markdown")
                            .font(.headline)
                        TextEditor(text: $generatedSummary)
                            .frame(minHeight: 200)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.secondaryBackground)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.quaternary, lineWidth: 1)
                            )
                    }

                    Button {
                        generateSummary()
                    } label: {
                        HStack {
                            if isGenerating { ProgressView() }
                            Text(isGenerating ? "Generating..." : "Generate Summary")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isGenerating || !isModelAvailable)
                }
                .padding()
            }
            .navigationTitle("Generate")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                if #available(iOS 26.0, *) {
                    isModelAvailable = SummaryGeneratorService.isAvailable
                }
            }
        }
    }

    private func generateSummary() {
        guard #available(iOS 26.0, *) else { return }
        isGenerating = true
        generatedSummary = ""
        Task {
            do {
                let service = SummaryGeneratorService()
                for try await accumulated in service.stream(items: items, range: range) {
                    generatedSummary = accumulated
                }
            } catch {
                generatedSummary = "_Generation failed: \(error.localizedDescription)_"
            }
            isGenerating = false
        }
    }
}

private struct UnavailableBanner: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "apple.intelligence")
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text("Apple Intelligence required")
                    .font(.subheadline.weight(.semibold))
                Text("Available on iPhone 15 Pro or later with Apple Intelligence enabled.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondaryBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary, lineWidth: 1)
        )
    }
}

private struct IncludedSourcesSection: View {
    let items: [ReportDataItem]

    private var groupedSources: [(ReportDataSource, Int)] {
        ReportDataSource.allCases.compactMap { source in
            let count = items.filter { $0.source == source }.count
            return count > 0 ? (source, count) : nil
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Included Data")
                .font(.headline)
            if groupedSources.isEmpty {
                Text("No data available for this range")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(groupedSources, id: \.0) { source, count in
                    HStack(spacing: 8) {
                        Image(systemName: source.systemImage)
                            .foregroundStyle(.secondary)
                        Text(source.title)
                            .font(.subheadline)
                        Spacer()
                        Text("\(count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondaryBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary, lineWidth: 1)
        )
    }
}

#Preview {
    ReportGenerateView(range: .week, items: [])
}
