//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat
import StreamChatSwiftUI
import UIKit

/// Mock implementation of `ImageLoading` that always returns a failure.
class FailingImageLoader_Mock: ImageLoading, @unchecked Sendable {
    struct MockError: Error {}

    var loadImageCalled = false
    var loadImageCallCount = 0

    func loadImage(
        url: URL?,
        imageCDN: ImageCDN,
        resize: Bool,
        preferredSize: CGSize?,
        completion: @escaping @MainActor (Result<UIImage, Error>) -> Void
    ) {
        loadImageCalled = true
        loadImageCallCount += 1
        StreamConcurrency.onMain {
            completion(.failure(MockError()))
        }
    }

    func loadImages(
        from urls: [URL],
        placeholders: [UIImage],
        loadThumbnails: Bool,
        thumbnailSize: CGSize,
        imageCDN: ImageCDN,
        completion: @escaping @MainActor ([UIImage]) -> Void
    ) {
        loadImageCalled = true
        loadImageCallCount += 1
        StreamConcurrency.onMain {
            completion(placeholders)
        }
    }
}
