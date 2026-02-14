//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Image attachment preview for messages.
public struct MessageImagePreviewView: View {
    @Injected(\.tokens) private var tokens
    @Injected(\.colors) private var colors

    private let url: URL
    private let size: CGFloat

    /// Creates an image attachment preview with the given URL.
    /// - Parameters:
    ///   - url: The URL of the image to preview.
    ///   - size: The size of the preview (width and height). Defaults to 40.
    public init(url: URL, size: CGFloat = 40) {
        self.url = url
        self.size = size
    }

    public var body: some View {
        StreamAsyncImage(
            url: url,
            thumbnailSize: CGSize(width: size, height: size)
        ) { phase in
            Group {
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: tokens.radiusMd, style: .continuous))
                case .loading, .empty:
                    placeholder
                }
            }
        }
    }
    
    private var placeholder: some View {
        RoundedRectangle(cornerRadius: tokens.radiusMd, style: .continuous)
            .fill(Color(colors.borderCoreOpacity10))
            .frame(width: size, height: size)
    }
}
