//
//  LogViewModel.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/29.
//

import Foundation
import Combine

@MainActor
final class LogViewModel: ObservableObject {
    
    @Published public var logs: [LogEntry] = []
    
}
