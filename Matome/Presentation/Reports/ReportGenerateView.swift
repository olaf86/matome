import SwiftUI

struct ReportGenerateView: View {
    let range: ReportRange
    let items: [ReportDataItem]

    @Environment(\.dismiss) private var dismiss
    @State private var generatedSummary: String = ""
    @State private var isGenerating: Bool = false

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

                    IncludedSourcesSection(items: items)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Generated Markdown")
                            .font(.headline)
                        TextEditor(text: $generatedSummary)
                            .frame(minHeight: 200)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.secondarySystemBackground))
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
                            if isGenerating {
                                ProgressView()
                            }
                            Text(isGenerating ? "Generating..." : "Generate Summary")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isGenerating)
                }
                .padding()
            }
            .navigationTitle("Generate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if generatedSummary.isEmpty {
                    generatedSummary = placeholderSummary
                }
            }
        }
    }

    private var placeholderSummary: String {
        let sources = ReportDataSource.allCases
            .filter { source in items.contains { $0.source == source } }
            .map { "- \($0.title)" }
            .joined(separator: "\n")
        return "# Summary\n\n## Included sources\n\n\(sources)\n\n## Highlights\n\n- \n- \n"
    }

    private func generateSummary() {
        isGenerating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            generatedSummary = placeholderSummary
            isGenerating = false
        }
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
                .fill(Color(.secondarySystemBackground))
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
