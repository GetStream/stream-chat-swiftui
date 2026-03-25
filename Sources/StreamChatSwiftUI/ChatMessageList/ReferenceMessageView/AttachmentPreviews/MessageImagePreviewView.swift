//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Image attachment preview for messages.
///
/// Uses direct image loading (bypassing CDN `resize=fill` thumbnail generation)
/// to avoid black borders on non-square images. The original image is loaded and
/// SwiftUI's `aspectFill` + `clipShape` handles the cropping, matching the UIKit
/// `scaleAspectFill` + `masksToBounds` behavior.
public struct MessageImagePreviewView: View {
    @Injected(\.tokens) private var tokens
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    private let url: URL
    private let size: CGFloat

    @State private var image: UIImage?

    /// Creates an image attachment preview with the given URL.
    /// - Parameters:
    ///   - url: The URL of the image to preview.
    ///   - size: The size of the preview (width and height). Defaults to 40.
    public init(url: URL, size: CGFloat = 40) {
        self.url = url
        self.size = size
    }

    public var body: some View {
        content
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: tokens.radiusMd, style: .continuous))
            .onAppear(perform: loadImage)
    }

    @ViewBuilder
    private var content: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: tokens.radiusMd, style: .continuous)
            .fill(Color(colors.borderCoreOpacity10))
    }

    private func loadImage() {
        guard image == nil else { return }
        utils.imageLoader.loadImage(
            url: url,
            imageCDN: utils.imageCDN,
            resize: false,
            preferredSize: nil
        ) { result in
            if case .success(let loadedImage) = result {
                self.image = loadedImage
            }
        }
    }
}
