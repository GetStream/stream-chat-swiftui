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
        completion: @escaping @MainActor (Result<MediaLoaderImage, Error>) -> Void
    ) {
        StreamConcurrency.onMain {
            completion(.success(MediaLoaderImage(image: ImageLoader_Mock.defaultLoadedImage)))
        }
    }

    func loadImages(
        from urls: [URL],
        options: ImageBatchLoadOptions,
        completion: @escaping @MainActor ([MediaLoaderImage]) -> Void
    ) {
        StreamConcurrency.onMain {
            completion([MediaLoaderImage(image: ImageLoader_Mock.defaultLoadedImage)])
        }
    }

    func videoAsset(
        at url: URL,
        options: VideoLoadOptions,
        completion: @escaping @MainActor (Result<MediaLoaderVideoAsset, Error>) -> Void
    ) {
        StreamConcurrency.onMain {
            completion(.success(MediaLoaderVideoAsset(asset: AVURLAsset(url: url))))
        }
    }

    func loadVideoPreview(
        at url: URL,
        options: VideoLoadOptions,
        completion: @escaping @MainActor (Result<MediaLoaderVideoPreview, Error>) -> Void
    ) {
        loadVideoPreviewCalled = true

        StreamConcurrency.onMain {
            completion(.success(MediaLoaderVideoPreview(image: ImageLoader_Mock.defaultLoadedImage)))
        }
    }

    @MainActor func loadVideoPreview(
        with attachment: ChatMessageVideoAttachment,
        options: VideoLoadOptions,
        completion: @escaping @MainActor (Result<MediaLoaderVideoPreview, Error>) -> Void
    ) {
        loadVideoPreviewWithAttachmentCalled = true

        completion(.success(MediaLoaderVideoPreview(image: ImageLoader_Mock.defaultLoadedImage)))
    }
}
