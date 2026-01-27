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
    @FocusState private var isInputFocused: Bool

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
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 8) {
                    ZStack(alignment: .topLeading) {
                        if message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("メッセージを入力")
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                        }
                        TextEditor(text: $message)
                            .focused($isInputFocused)
                            .lineLimit(2...5)
                            .frame(minHeight: 36, maxHeight: 80)
                            .padding(.horizontal, 8)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                    }

                    Button(action: {
                        sendMessage()
                        isInputFocused = false
                    }) {
                        Image(systemName: "paperplane")
                            .foregroundStyle(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : .primary)
                    }
                    .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
            }
        }
    }

    private func sendMessage() {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let newLog = LogEntry(text: trimmed, date: Date())
        logs.append(newLog)
        message = ""
        isInputFocused = false
    }
}

#Preview("LogView") {
    LogView()
}
