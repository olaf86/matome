//
//  Untitled.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/19.
//

import SwiftUI

struct LogView: View {
    
    @State private var logs: [LogEntry] = []
    @State private var message: String = ""
    @State private var isPresentingNewEntry: Bool = false
    @State private var draftMessage: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(logs) { log in
                        LogRow(log: log)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical)
            }
            .navigationTitle("My Logs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
            .sheet(isPresented: $isPresentingNewEntry) {
                NewLogEntrySheetView(
                    isPresented: $isPresentingNewEntry,
                    draftMessage: $draftMessage
                ) { text in
                    let newLog = LogEntry(text: text, date: Date())
                    logs.append(newLog)
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}

#Preview("LogView") {
    LogView()
}

