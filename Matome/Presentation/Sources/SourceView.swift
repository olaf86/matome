//
//  Untitled.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/19.
//

import SwiftUI
import PhotosUI

struct SourceView: View {

    var body: some View {
        NavigationStack {
            Form {
                GitHubSection()
                MediaPermissionSection()
                HealthPermissionSection()
            }
            .navigationTitle("Source")
        }
    }
}
