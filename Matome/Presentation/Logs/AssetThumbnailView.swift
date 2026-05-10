//
//  AssetThumbnailView.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/25.
//

import SwiftUI
import Photos
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
private typealias PlatformImage = UIImage
#elseif canImport(AppKit)
private typealias PlatformImage = NSImage
#endif

struct AssetThumbnailView: View {

    let asset: PHAsset
    let size: CGSize

    @State private var image: PlatformImage? = nil

    var body: some View {
        ZStack {
            if let image {
#if canImport(UIKit)
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
#elseif canImport(AppKit)
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
#endif
            } else {
                Color.secondary.opacity(0.3)
            }

            if asset.mediaType == .video {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.black)
                    .shadow(radius: 4)
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
            .requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { image, _ in
                self.image = image
            }
    }
}
