//
//  GitHubSection.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/25.
//

import SwiftUI

struct GitHubSection: View {
    
    @StateObject private var vm = GitHubSectionViewModel()
    
    var body: some View {
    
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
    }
}
