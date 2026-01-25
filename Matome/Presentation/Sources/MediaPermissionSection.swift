//
//  MediaPermissionSection.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/25.
//

import SwiftUI

struct MediaPermissionSection: View {
    
    @StateObject private var vm = MediaPermissionSectionViewModel()
    
    var body: some View {
        Section("Media Permission") {
            Section("Media Access") {
                LabeledContent("Status") {
                    Text(vm.statusText)
                        .foregroundStyle(vm.statusColor)
                }
                Button("Change Permissions") {
                    vm.handleChangePhotoLibraryPermissions()
                }
            }
            .onAppear {
                vm.refreshPhotoLibraryAuthorizationStatus()
            }
            
//                    PhotosPicker(
//                        selection: $vm.mediaSelections,
//                        photoLibrary: .shared()
//                    ) {
//                        Label("Select media", systemImage: "photo.on.rectangle.angled")
//                    }
//                    .padding()
//                    .onChange(of: vm.mediaSelections) {
//                        vm.saveMediaSelections()
//                    }
//
//                    AssetGridView(assets: vm.assets)
//                        .onChange(of: vm.assets, initial: true) {
//                            vm.loadMediaSelections()
//                        }
        }
    }
}
