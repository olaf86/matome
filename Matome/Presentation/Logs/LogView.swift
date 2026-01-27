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
                NavigationStack {
                    VStack(spacing: 0) {
                        TextEditor(text: $draftMessage)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                    }
                    .navigationTitle("New Message")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingNewEntry = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                let trimmed = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                                guard !trimmed.isEmpty else { return }
                                let newLog = LogEntry(text: trimmed, date: Date())
                                logs.append(newLog)
                                isPresentingNewEntry = false
                            }
                            .disabled(draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
}

#Preview("LogView") {
    LogView()
}
