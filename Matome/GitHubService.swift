//
//  GithubService.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/21.
//

import ObjectiveC
import Foundation
import AuthenticationServices
import SwiftUI

final class GitHubService: NSObject {
    
    func login(completion: @escaping (String) -> Void) {
        
        let clientID = GitHubCredentials.shared.clientID
        let redirectURL = "matome://github-callback"
        
        let authURL = URL(string: "https://github.com/login/oauth/authorize?client_id=\(clientID)&\(redirectURL)&scope=repo")!
        
        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "matome") { callbackURL, error in
            print(error?.localizedDescription ?? "no error")
            guard
                let callbackURL,
                let code = URLComponents(
                    url: callbackURL,
                    resolvingAgainstBaseURL: false
                )?
                .queryItems?
                .first(where: { $0.name == "code" })?
                .value
            else { return }
            self.fetchAccessToken(code: code, completion: completion)
        }
        session.presentationContextProvider = self
        session.start()
    }
    
    private func fetchAccessToken(code: String, completion: @escaping (String) -> Void) {
        
        let url = URL(string: "https://github.com/login/oauth/access_token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "client_id": GitHubCredentials.shared.clientID,
            "client_secret": GitHubCredentials.shared.clientSecret,
            "code": code
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard
                let data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let token = json["access_token"] as? String
            else { return }
            
            Task.detached { @MainActor in
                completion(token)
            }
        }.resume()
    }
}

extension GitHubService: ASWebAuthenticationPresentationContextProviding {
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Prefer an existing key window's presentation anchor
        if let anchor = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) {
            return anchor
        }
        
        // Fall back to the first available window in any scene
        if let anyWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return anyWindow
        }
        
        // As a last resort, create a temporary window with a valid windowScene
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first {
                let tempWindow = UIWindow(windowScene: scene)
                return tempWindow
            }
        
        fatalError("No windows in the application")
    }
}
