//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVKit
import Foundation
@testable import StreamChat
import StreamChatCommonUI
import StreamChatSwiftUI
import UIKit
import XCTest

/// Mock implementation of `MediaLoader`.
class ImageLoader_Mock: MediaLoader, @unchecked Sendable {
    static let defaultLoadedImage = XCTestCase.TestImages.yoda.image
    var loadImageCalled = false
    var loadImageCallCount = 0
    var loadedURLs: [URL?] = []
    var loadVideoPreviewCalled = false

    func loadImage(
        url: URL?,
        options: ImageLoadOptions,
        completion: @escaping @MainActor (Result<MediaLoaderImage, Error>) -> Void
    ) {
        loadImageCalled = true
        loadImageCallCount += 1
        loadedURLs.append(url)
        StreamConcurrency.onMain {
            completion(.success(MediaLoaderImage(image: Self.defaultLoadedImage)))
        }
    }

    func loadImages(
        from urls: [URL],
        options: ImageBatchLoadOptions,
        completion: @escaping @MainActor ([MediaLoaderImage]) -> Void
    ) {
        loadImageCalled = true
        loadImageCallCount += 1
        loadedURLs.append(contentsOf: urls)

        StreamConcurrency.onMain {
            completion([MediaLoaderImage(image: Self.defaultLoadedImage)])
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
            completion(.success(MediaLoaderVideoPreview(image: Self.defaultLoadedImage)))
        }
    }
}

/// Mock implementation of `MediaLoader` that returns different TestImages based on URL.
class TestImagesLoader_Mock: MediaLoader, @unchecked Sendable {
    var loadImageCalled = false
    var loadImagesCalled = false

    func loadImage(
        url: URL?,
        options: ImageLoadOptions,
        completion: @escaping @MainActor (Result<MediaLoaderImage, Error>) -> Void
    ) {
        loadImageCalled = true

        let image = imageForURL(url)
        StreamConcurrency.onMain {
            completion(.success(MediaLoaderImage(image: image)))
        }
    }

    func loadImages(
        from urls: [URL],
        options: ImageBatchLoadOptions,
        completion: @escaping @MainActor ([MediaLoaderImage]) -> Void
    ) {
        loadImagesCalled = true

        let images = urls.map { MediaLoaderImage(image: imageForURL($0)) }
        StreamConcurrency.onMain {
            completion(images)
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
        StreamConcurrency.onMain {
            completion(.success(MediaLoaderVideoPreview(image: UIImage())))
        }
    }

    private func imageForURL(_ url: URL?) -> UIImage {
        guard let url else {
            return XCTestCase.TestImages.yoda.image
        }

        let urlString = url.absoluteString

        if urlString.contains("yoda") {
            return XCTestCase.TestImages.yoda.image
        } else if urlString.contains("chewbacca") {
            return XCTestCase.TestImages.chewbacca.image
        } else if urlString.contains("r2") || urlString.contains("r2-d2") {
            return XCTestCase.TestImages.r2.image
        } else if urlString.contains("vader") {
            return XCTestCase.TestImages.vader.image
        } else {
            return XCTestCase.TestImages.yoda.image
        }
    }
}
