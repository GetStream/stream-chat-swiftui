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
        completion: @escaping @MainActor(Result<UIImage, Error>) -> Void
    ) {
        loadImageCalled = true
        StreamConcurrency.onMain {
            completion(.success(Self.defaultLoadedImage))
        }
    }

    func loadImages(
        from urls: [URL],
        placeholders: [UIImage],
        loadThumbnails: Bool,
        thumbnailSize: CGSize,
        imageCDN: ImageCDN,
        completion: @escaping @MainActor([UIImage]) -> Void
    ) {
        loadImageCalled = true

        StreamConcurrency.onMain {
            completion([Self.defaultLoadedImage])
        }
    }
}
