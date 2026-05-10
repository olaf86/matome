//
//  Untitled.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/19.
//

import SwiftUI
import SwiftData

struct LogView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: LogViewModel = LogViewModel()
    @State private var isPresentingNewEntry: Bool = false
    @State private var draftMessage: String = ""
    @State private var calendarDate: Date = Date()
    @State private var needsScrollToLatest: Bool = false
    @State private var isCalendarPresented: Bool = false
#if DEBUG
    @State private var isSeedingSamples: Bool = false
#endif

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.sections()) { section in
                            Section {
                                ForEach(section.logs) { log in
                                    LogRow(log: log)
                                        .id(log.id)
                                        .onAppear {
                                            if viewModel.shouldLoadMore(currentLog: log) {
                                                viewModel.loadMore(context: modelContext)
                                            }
                                        }
                                }
                            } header: {
                                Text(section.title)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 8)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical)
                }
                .onAppear {
                    if viewModel.logs.isEmpty {
                        viewModel.loadInitial(context: modelContext)
                        scrollToLatest(proxy: proxy)
                    }
                }
                .onChange(of: calendarDate) { _, newValue in
                    jumpToDate(newValue, proxy: proxy)
                }
                .onChange(of: needsScrollToLatest) { _, newValue in
                    guard newValue else { return }
                    scrollToLatest(proxy: proxy)
                    needsScrollToLatest = false
                }
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button {
                            isCalendarPresented = true
                        } label: {
                            Image(systemName: "calendar")
                        }
                        .accessibilityLabel("Jump Date")
                        .popover(isPresented: $isCalendarPresented) {
                            DatePicker("Jump Date", selection: $calendarDate, displayedComponents: [.date])
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                                .padding(8)
                                .frame(width: 320)
                                .presentationDetents([.height(340)])
                                .presentationCompactAdaptation(.popover)
                        }
                    }
#if DEBUG
                    ToolbarItem(placement: .primaryAction) {
                        Button("Seed") {
                            seedSampleLogs()
                        }
                        .disabled(isSeedingSamples)
                        .accessibilityLabel("Seed Sample Logs")
                    }
#endif
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            draftMessage = ""
                            isPresentingNewEntry = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                        .accessibilityLabel("New Message")
                    }
                }
            }
            .navigationTitle("My Logs")
            .inlineNavigationTitle()
            .sheet(isPresented: $isPresentingNewEntry) {
                NewLogEntrySheetView(
                    isPresented: $isPresentingNewEntry,
                    draftMessage: $draftMessage
                ) { text in
                    let newLog = LogEntry(text: text, date: Date())
                    modelContext.insert(newLog)
                    do {
                        try modelContext.save()
                        if viewModel.logs.isEmpty {
                            viewModel.loadInitial(context: modelContext)
                        } else {
                            viewModel.insertNewLog(newLog)
                        }
                        needsScrollToLatest = true
                    } catch {
                        assertionFailure("Failed to save LogEntry: \(error)")
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }

    private func jumpToDate(_ date: Date, proxy: ScrollViewProxy) {
        viewModel.jumpToDate(date, context: modelContext)
        if let targetID = viewModel.closestLogID(to: date) {
            withAnimation {
                proxy.scrollTo(targetID, anchor: .center)
            }
        }
    }

    private func scrollToLatest(proxy: ScrollViewProxy) {
        guard let latestID = viewModel.latestLogID() else { return }
        DispatchQueue.main.async {
            proxy.scrollTo(latestID, anchor: .bottom)
        }
    }

#if DEBUG
    private func seedSampleLogs() {
        guard !isSeedingSamples else { return }
        isSeedingSamples = true

        let calendar = Calendar.current
        let baseDate = Date()
        let days = 30
        let logsPerDay = 5

        for dayOffset in 0..<days {
            for logIndex in 0..<logsPerDay {
                guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: baseDate) else { continue }
                guard let date = calendar.date(byAdding: .minute, value: -logIndex, to: day) else { continue }
                let log = LogEntry(text: "Sample \(dayOffset)-\(logIndex)", date: date)
                modelContext.insert(log)
            }
        }

        do {
            try modelContext.save()
            viewModel.loadInitial(context: modelContext)
            needsScrollToLatest = true
        } catch {
            assertionFailure("Failed to seed sample logs: \(error)")
        }

        isSeedingSamples = false
    }
#endif
}


#Preview("LogView") {
    LogView()
}
