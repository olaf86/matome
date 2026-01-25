//
//  Untitled.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/19.
//

import SwiftUI
import PhotosUI

struct SourceView: View {

    @StateObject private var vm = SourceViewModel()

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - GitHub Section
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "chevron.left.slash.chevron.right")
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("GitHub")
                                .font(.headline)

                            Text(vm.isGitHubConnected ? "Connected" : "Not Connected")
                                .font(.subheadline)
                                .foregroundStyle(
                                    vm.isGitHubConnected ? .green : .secondary
                                )
                        }

                        Spacer()

                        Image(systemName: vm.isGitHubConnected ? "checkmark.circle.fill" : "xmark.circle")
                            .foregroundStyle(
                                vm.isGitHubConnected ? .green : .secondary
                            )
                    }
                    .padding(.vertical, 4)
                }

                // MARK: - GitHub Action Section
                Section {
                    if vm.isGitHubConnected {
                        Button(role: .destructive) {
                            vm.disconnectGitHub()
                        } label: {
                            Label("Disconnect GitHub", systemImage: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    } else {
                        Button {
                            vm.connectGitHub()
                        } label: {
                            Label("Connect GitHub", systemImage: "link")
                        }
                    }
                }
                
                // MARK: - Media Permission Section
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
            .navigationTitle("Source")
        }
    }
}
