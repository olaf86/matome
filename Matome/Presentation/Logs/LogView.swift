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
                    ToolbarItem(placement: .topBarLeading) {
                        DatePicker("Jump Date", selection: $calendarDate, displayedComponents: [.date])
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                    ToolbarItem(placement: .topBarTrailing) {
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
            .navigationBarTitleDisplayMode(.inline)
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
}


#Preview("LogView") {
    LogView()
}
