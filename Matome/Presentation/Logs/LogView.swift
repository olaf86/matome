//
//  Untitled.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/19.
//

import SwiftUI

struct LogView: View {
    
    @State private var logs: [LogEntry] = []
    @State private var showInput = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(logs) { log in
                    LogRow(log: log)
                }
            }
            .navigationTitle("My Logs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showInput = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showInput) {
                LogInputView { newLog in
                    logs.append(newLog)
                }
            }
        }
    }
}
