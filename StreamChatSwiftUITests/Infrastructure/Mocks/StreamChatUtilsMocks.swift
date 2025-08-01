//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChatSwiftUI
import UIKit

/// Mock implementation of `VideoPreviewLoader`.
class VideoPreviewLoader_Mock: VideoPreviewLoader {
    var loadPreviewVideoCalled = false

    func loadPreviewForVideo(at url: URL, completion: @escaping @MainActor @Sendable(Result<UIImage, Error>) -> Void) {
        loadPreviewVideoCalled = true
    }
}

/// Mock implementation of `ImageLoading`.
class ImageLoaderUtils_Mock: ImageLoading {
    var loadImageCalled = false

    func loadImage(
        url: URL?,
        imageCDN: ImageCDN,
        resize: Bool,
        preferredSize: CGSize?,
        completion: @escaping @MainActor @Sendable(Result<UIImage, Error>) -> Void
    ) {
        loadImageCalled = true
    }
}
