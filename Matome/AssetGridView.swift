//
//  AssetGridView.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/25.
//

import SwiftUI
import Photos

struct AssetGridView: View {
    
    let assets: [PHAsset]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)]) {
                ForEach(assets, id: \.localIdentifier) { asset in
                    AssetThumbnailView(asset: asset, size: CGSize(width: 100, height: 100))
                }
            }
            .padding()
        }
    }
}
