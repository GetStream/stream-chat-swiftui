//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat
import StreamChatCommonUI
import StreamChatSwiftUI
import UIKit
import XCTest

/// Mock implementation of `ImageLoader`.
class ImageLoader_Mock: ImageLoader, @unchecked Sendable {
    static let defaultLoadedImage = XCTestCase.TestImages.yoda.image
    var loadImageCalled = false
    var loadImageCallCount = 0
    var loadedURLs: [URL?] = []

    func loadImage(
        url: URL?,
        resize: ImageResize?,
        completion: @escaping @MainActor (Result<UIImage, Error>) -> Void
    ) {
        loadImageCalled = true
        loadImageCallCount += 1
        loadedURLs.append(url)
        StreamConcurrency.onMain {
            completion(.success(Self.defaultLoadedImage))
        }
    }

    func loadImages(
        from urls: [URL],
        placeholders: [UIImage],
        loadThumbnails: Bool,
        thumbnailSize: CGSize,
        completion: @escaping @MainActor ([UIImage]) -> Void
    ) {
        loadImageCalled = true
        loadImageCallCount += 1
        loadedURLs.append(contentsOf: urls)

        StreamConcurrency.onMain {
            completion([Self.defaultLoadedImage])
        }
    }
}

/// Mock implementation of `ImageLoader` that returns different TestImages based on URL.
class TestImagesLoader_Mock: ImageLoader, @unchecked Sendable {
    var loadImageCalled = false
    var loadImagesCalled = false

    func loadImage(
        url: URL?,
        resize: ImageResize?,
        completion: @escaping @MainActor (Result<UIImage, Error>) -> Void
    ) {
        loadImageCalled = true

        let image = imageForURL(url)
        StreamConcurrency.onMain {
            completion(.success(image))
        }
    }

    func loadImages(
        from urls: [URL],
        placeholders: [UIImage],
        loadThumbnails: Bool,
        thumbnailSize: CGSize,
        completion: @escaping @MainActor ([UIImage]) -> Void
    ) {
        loadImagesCalled = true

        let images = urls.map { imageForURL($0) }
        StreamConcurrency.onMain {
            completion(images)
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
