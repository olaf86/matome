//
//  LogRow.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/19.
//

import SwiftUI

struct LogRow: View {
    
    let log: LogEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(log.text)
                .font(.headline)
            Text(log.date.formatted())
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
