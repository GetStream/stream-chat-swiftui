//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatSwiftUI
import UIKit
import XCTest

/// Mock implementation of `VideoPreviewLoader`.
class VideoPreviewLoader_Mock: VideoPreviewLoader {
    var loadPreviewVideoCalled = false

    func loadPreviewForVideo(at url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        loadPreviewVideoCalled = true

        completion(.success(ImageLoader_Mock.defaultLoadedImage))
    }
}
