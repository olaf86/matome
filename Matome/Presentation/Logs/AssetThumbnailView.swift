//
//  AssetThumbnailView.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/25.
//

import SwiftUI
import Photos

struct AssetThumbnailView: View {
    
    let asset: PHAsset
    let size: CGSize
    
    @State private var image: UIImage? = nil
    
    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.secondary.opacity(0.3)
            }
            
            if asset.mediaType == .video {
                ZStack {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                        .shadow(radius: 4)
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .clipped()
        .cornerRadius(8)
        .task {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default()
            .requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { image, info in
                self.image = image
            }
    }
}
