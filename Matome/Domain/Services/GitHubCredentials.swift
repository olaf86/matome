//
//  GitHubCredentials.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/21.
//

import Foundation

final class GitHubCredentials {
    private init() {}
    static var shared = GitHubCredentials()
    let clientID = Bundle.main.object(forInfoDictionaryKey: "GITHUB_CLIENT_ID") as? String ?? ""
    let clientSecret = Bundle.main.object(forInfoDictionaryKey: "GITHUB_CLIENT_SECRET") as? String ?? ""
}
