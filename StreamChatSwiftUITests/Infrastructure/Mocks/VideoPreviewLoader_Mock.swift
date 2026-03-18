//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import UIKit
import XCTest

/// Mock implementation of `VideoPreviewLoader`.
class VideoPreviewLoader_Mock: VideoPreviewLoader {
    var loadPreviewVideoCalled = false
    var loadPreviewVideoWithAttachmentCalled = false

    func loadPreviewForVideo(at url: URL, completion: @escaping @MainActor (Result<UIImage, Error>) -> Void) {
        loadPreviewVideoCalled = true

        StreamConcurrency.onMain {
            completion(.success(ImageLoader_Mock.defaultLoadedImage))
        }
    }

    func loadPreviewForVideo(
        with attachment: ChatMessageVideoAttachment,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        loadPreviewVideoWithAttachmentCalled = true

        completion(.success(ImageLoader_Mock.defaultLoadedImage))
    }
}
