//
//  MediaPermissionSection.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/25.
//

import SwiftUI
import PhotosUI

struct MediaPermissionSection: View {

    @StateObject private var vm = MediaPermissionSectionViewModel()

    private var hasAccess: Bool {
        vm.photoLibraryAuthorizationStatus == .authorized || vm.photoLibraryAuthorizationStatus == .limited
    }

    var body: some View {
        Section("Media") {
            LabeledContent("Status") {
                Text(vm.statusText)
                    .foregroundStyle(vm.statusColor)
            }
            Button("Change Permissions") {
                vm.handleChangePhotoLibraryPermissions()
            }
            if hasAccess {
                PhotosPicker(
                    selection: $vm.mediaSelections,
                    photoLibrary: .shared()
                ) {
                    Label("Select media", systemImage: "photo.on.rectangle.angled")
                }
                .onChange(of: vm.mediaSelections) {
                    vm.saveMediaSelections()
                }
                if !vm.assets.isEmpty {
                    AssetGridView(assets: vm.assets)
                        .frame(height: 220)
                }
            }
        }
        .onAppear {
            vm.refreshPhotoLibraryAuthorizationStatus()
            vm.loadMediaSelections()
        }
    }
}
