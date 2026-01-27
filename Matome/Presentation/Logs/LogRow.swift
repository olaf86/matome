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
        VStack(alignment: .leading, spacing: 4) {
            // Chat bubble
            Text(log.text)
                .foregroundColor(.primary)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )

            // Date under the bubble
            Text(log.date.formatted())
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    LogRow(log: .init(text: "Hello, world!", date: Date()))
}
