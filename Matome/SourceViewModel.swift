//
//  SourceViewModel.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/21.
//

import Foundation
import Combine
import Photos
import _PhotosUI_SwiftUI

@MainActor
final class SourceViewModel: ObservableObject {
    
    @Published var isGitHubConnected = false
    private let gitHubService = GitHubService()
    private let gitHubTokenKey = "github_token"
    
    @Published var mediaSelections: [PhotosPickerItem] = []
    @Published var assets: [PHAsset] = []
    private let mediaAssetIDsKey = "media_asset_ids"
    
    init() {
        isGitHubConnected = UserDefaults.standard.string(forKey: gitHubTokenKey) != nil
    }
    
    func connectGitHub() {
        gitHubService.login { token in
            UserDefaults.standard.set(token, forKey: self.gitHubTokenKey)
            self.isGitHubConnected = true
        }
    }
    
    func disconnectGitHub() {
        UserDefaults.standard.removeObject(forKey: gitHubTokenKey)
        isGitHubConnected = false
    }
    
    func saveMediaSelections() {
        let ids: [String] = mediaSelections.compactMap { $0.itemIdentifier }
        UserDefaults.standard.set(ids, forKey: mediaAssetIDsKey)
        loadMediaSelections()
    }
    
    func loadMediaSelections() {
        guard
            let ids = UserDefaults.standard.stringArray(forKey: mediaAssetIDsKey)
        else { return }
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: ids, options: nil)
        var fetchedAssets: [PHAsset] = []
        fetchResult.enumerateObjects { asset, _, _ in
            fetchedAssets.append(asset)
        }
        self.assets = fetchedAssets
    }
}

