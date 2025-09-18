//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat
import StreamChatSwiftUI
import UIKit
import XCTest

/// Mock implementation of `ImageLoading`.
class ImageLoader_Mock: ImageLoading {
    static let defaultLoadedImage = XCTestCase.TestImages.yoda.image
    var loadImageCalled = false

    func loadImage(
        url: URL?,
        imageCDN: ImageCDN,
        resize: Bool,
        preferredSize: CGSize?,
        completion: @escaping ((Result<UIImage, Error>) -> Void)
    ) {
        loadImageCalled = true

        completion(.success(Self.defaultLoadedImage))
    }

    func loadImages(
        from urls: [URL],
        placeholders: [UIImage],
        loadThumbnails: Bool,
        thumbnailSize: CGSize,
        imageCDN: ImageCDN,
        completion: @escaping (([UIImage]) -> Void)
    ) {
        loadImageCalled = true

        completion([Self.defaultLoadedImage])
    }
}

/// Mock implementation of `ImageLoading` that returns different TestImages based on URL.
class TestImagesLoader_Mock: ImageLoading {
    var loadImageCalled = false
    var loadImagesCalled = false

    func loadImage(
        url: URL?,
        imageCDN: ImageCDN,
        resize: Bool,
        preferredSize: CGSize?,
        completion: @escaping ((Result<UIImage, Error>) -> Void)
    ) {
        loadImageCalled = true

        let image = imageForURL(url)
        completion(.success(image))
    }

    func loadImages(
        from urls: [URL],
        placeholders: [UIImage],
        loadThumbnails: Bool,
        thumbnailSize: CGSize,
        imageCDN: ImageCDN,
        completion: @escaping (([UIImage]) -> Void)
    ) {
        loadImagesCalled = true

        let images = urls.map { imageForURL($0) }
        completion(images)
    }

    private func imageForURL(_ url: URL?) -> UIImage {
        guard let url = url else {
            return XCTestCase.TestImages.yoda.image
        }

        let urlString = url.absoluteString

        // Return different TestImages based on URL content
        if urlString.contains("yoda") {
            return XCTestCase.TestImages.yoda.image
        } else if urlString.contains("chewbacca") {
            return XCTestCase.TestImages.chewbacca.image
        } else if urlString.contains("r2") || urlString.contains("r2-d2") {
            return XCTestCase.TestImages.r2.image
        } else if urlString.contains("vader") {
            return XCTestCase.TestImages.vader.image
        } else {
            // Default fallback
            return XCTestCase.TestImages.yoda.image
        }
    }
}
