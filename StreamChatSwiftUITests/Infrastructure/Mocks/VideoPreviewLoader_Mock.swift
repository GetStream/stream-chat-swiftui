//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
import StreamChatCommonUI
@testable import StreamChatSwiftUI
import UIKit
import XCTest

/// Mock implementation of `VideoLoader`.
class VideoLoader_Mock: VideoLoader, @unchecked Sendable {
    var loadPreviewCalled = false
    var loadPreviewWithAttachmentCalled = false

    func loadPreview(at url: URL, completion: @escaping @MainActor (Result<UIImage, Error>) -> Void) {
        loadPreviewCalled = true

        StreamConcurrency.onMain {
            completion(.success(ImageLoader_Mock.defaultLoadedImage))
        }
    }

    @MainActor func loadPreview(
        with attachment: ChatMessageVideoAttachment,
        completion: @escaping @MainActor (Result<UIImage, Error>) -> Void
    ) {
        loadPreviewWithAttachmentCalled = true

        completion(.success(ImageLoader_Mock.defaultLoadedImage))
    }
}
