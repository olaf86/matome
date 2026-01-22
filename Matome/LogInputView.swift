//
//  LogInputView.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/19.
//

import SwiftUI

struct LogInputView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    let onSave: (LogEntry) -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $text)
                    .padding()
            }
            .navigationTitle("New Log")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let log = LogEntry(text: text, date: Date())
                        onSave(log)
                        dismiss()
                    }
                    .disabled(text.isEmpty)
                }
            }
        }
    }
}
