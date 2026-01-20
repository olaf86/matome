//
//  LogEntry.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/19.
//

import Foundation

struct LogEntry: Codable, Identifiable {
    var id = UUID()
    let text: String
    let date: Date
}
