//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVKit
@testable import StreamChat
import StreamChatCommonUI
@testable import StreamChatSwiftUI
import UIKit
import XCTest

/// Mock implementation of `MediaLoader` for video-focused tests.
class VideoLoader_Mock: MediaLoader, @unchecked Sendable {
    var loadVideoPreviewCalled = false
    var loadVideoPreviewWithAttachmentCalled = false

    func loadImage(
        url: URL?,
        options: ImageLoadOptions,
        completion: @escaping @MainActor (Result<UIImage, Error>) -> Void
    ) {
        StreamConcurrency.onMain {
            completion(.success(ImageLoader_Mock.defaultLoadedImage))
        }
    }

    func loadImages(
        from urls: [URL],
        options: ImageBatchLoadOptions,
        completion: @escaping @MainActor ([UIImage]) -> Void
    ) {
        StreamConcurrency.onMain {
            completion([ImageLoader_Mock.defaultLoadedImage])
        }
    }

    func videoAsset(at url: URL, options: VideoLoadOptions) -> AVURLAsset {
        AVURLAsset(url: url)
    }

    func loadVideoPreview(at url: URL, options: VideoLoadOptions, completion: @escaping @MainActor (Result<UIImage, Error>) -> Void) {
        loadVideoPreviewCalled = true

        StreamConcurrency.onMain {
            completion(.success(ImageLoader_Mock.defaultLoadedImage))
        }
    }

    @MainActor func loadVideoPreview(
        with attachment: ChatMessageVideoAttachment,
        options: VideoLoadOptions,
        completion: @escaping @MainActor (Result<UIImage, Error>) -> Void
    ) {
        loadVideoPreviewWithAttachmentCalled = true

        completion(.success(ImageLoader_Mock.defaultLoadedImage))
    }
}
