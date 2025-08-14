//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChatSwiftUI
import UIKit
import XCTest

/// Mock implementation of `VideoPreviewLoader`.
class VideoPreviewLoader_Mock: VideoPreviewLoader {
    var loadPreviewVideoCalled = false

    func loadPreviewForVideo(at url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        loadPreviewVideoCalled = true

        if url.scheme == "test" {
            completion(.success(XCTestCase.TestImages.yoda.image))
        } else {
            completion(.success(ImageLoader_Mock.defaultLoadedImage))
        }
    }
}

/// Mock implementation of `ImageLoading`.
class ImageLoader_Mock: ImageLoading {
    static let defaultLoadedImage = UIImage(systemName: "checkmark")!
    var loadImageCalled = false

    func loadImage(
        url: URL?,
        imageCDN: ImageCDN,
        resize: Bool,
        preferredSize: CGSize?,
        completion: @escaping ((Result<UIImage, Error>) -> Void)
    ) {
        loadImageCalled = true

        if let url = url, url.scheme == "test" {
            completion(.success(XCTestCase.TestImages.yoda.image))
        } else {
            completion(.success(Self.defaultLoadedImage))
        }
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

        let result = urls.map { url in
            if url.scheme == "test" {
                return XCTestCase.TestImages.yoda.image
            } else {
                return Self.defaultLoadedImage
            }
        }
        completion(result)
    }
}
