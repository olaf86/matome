//
//  GitHubSectionViewModel.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/25.
//

import Foundation
import Combine

@MainActor
final class GitHubSectionViewModel: ObservableObject {

    @Published var isGitHubConnected = false
    private let gitHubService = GitHubService()
    private let gitHubTokenKey = "github_token"

    init() {
        isGitHubConnected = KeychainHelper.load(forKey: gitHubTokenKey) != nil
    }

    func connectGitHub() {
        gitHubService.login { token in
            KeychainHelper.save(token, forKey: self.gitHubTokenKey)
            self.isGitHubConnected = true
        }
    }

    func disconnectGitHub() {
        KeychainHelper.delete(forKey: gitHubTokenKey)
        isGitHubConnected = false
    }
}
