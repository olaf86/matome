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
import SwiftUI

@MainActor
final class MediaPermissionSectionViewModel: ObservableObject {
    
    @Published var mediaSelections: [PhotosPickerItem] = []
    @Published var assets: [PHAsset] = []
    private let mediaAssetIDsKey = "media_asset_ids"
    
    @Published var photoLibraryAuthorizationStatus: PHAuthorizationStatus = .notDetermined
    
    var statusText: String {
        switch photoLibraryAuthorizationStatus {
        case .authorized:
            return "Full Access"
        case .limited:
            return "Limited Access"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .notDetermined:
            return "Not Determined"
        default:
            return "Unknown"
        }
    }
    
    var statusColor: Color {
        switch photoLibraryAuthorizationStatus {
        case .authorized:
            return .green
        case .limited:
            return .orange
        case .denied, .restricted:
            return .red
        default:
            return .secondary
        }
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
    
    func requestPhotoLibraryAuthorization() {
        PHPhotoLibrary.requestAuthorization { status in
            self.photoLibraryAuthorizationStatus = status
        }
    }
    
    func refreshPhotoLibraryAuthorizationStatus() {
        photoLibraryAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    func handleChangePhotoLibraryPermissions() {
        switch photoLibraryAuthorizationStatus {
        case .limited:
            presentLimitedPicker()
        case .denied, .restricted:
            openAppSettings()
        case .notDetermined:
            requestPhotoLibraryAuthorization()
        case .authorized:
            openAppSettings()
        default:
            break
        }
    }
    
    private func presentLimitedPicker() {
        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootVC = scene.windows.first?.rootViewController
        else { return }

        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: rootVC)
    }
    
    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

