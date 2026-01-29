//
//  LogEntry.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/19.
//

import Foundation
import SwiftData

@Model
final class LogEntry: Identifiable {
    @Attribute(.unique) var id: UUID
    var text: String
    // TODO: @Attribute(.indexed) ?
    var date: Date

    init(id: UUID = UUID(), text: String, date: Date) {
        self.id = id
        self.text = text
        self.date = date
    }
}
