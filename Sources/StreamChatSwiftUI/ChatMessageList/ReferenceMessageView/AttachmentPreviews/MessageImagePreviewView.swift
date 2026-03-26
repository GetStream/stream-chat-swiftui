//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Image attachment preview for messages.
public struct MessageImagePreviewView: View {
    @Injected(\.tokens) private var tokens

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
        LazyLoadingImage(
            source: MediaAttachment(url: url, type: .image),
            width: size,
            height: size,
            resize: true,
            showVideoIcon: false
        )
        .clipShape(RoundedRectangle(cornerRadius: tokens.radiusMd, style: .continuous))
    }
}
