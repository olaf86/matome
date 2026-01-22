//
//  SourceViewModel.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/21.
//

import Foundation
internal import Combine

@MainActor
final class SourceViewModel: ObservableObject {
    
    @Published var isGitHubConnected = false
    private let gitHubService = GitHubService()
    private let tokenKey = "github_token"
    
    init() {
        isGitHubConnected = UserDefaults.standard.string(forKey: tokenKey) != nil
    }
    
    func connectGitHub() {
        gitHubService.login { token in
            UserDefaults.standard.set(token, forKey: self.tokenKey)
            self.isGitHubConnected = true
        }
    }
    
    func disconnectGitHub() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        isGitHubConnected = false
    }
}
