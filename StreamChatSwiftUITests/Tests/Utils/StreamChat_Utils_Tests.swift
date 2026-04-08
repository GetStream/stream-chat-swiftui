//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class StreamChat_Utils_Tests: StreamChatTestCase {
    private let testURL = URL(string: "https://example.com")!

    @Injected(\.utils) var utils

    override func setUp() {
        let utils = Utils(
            videoLoader: VideoLoader_Mock(),
            imageLoader: ImageLoader_Mock()
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }

    func test_streamChatUtils_injectVideoLoader() {
        // Given
        let videoLoader = utils.videoLoader as! VideoLoader_Mock

        // When
        videoLoader.loadPreview(at: testURL, completion: { _ in })

        // Then
        XCTAssert(videoLoader.loadPreviewCalled == true)
    }

    func test_streamChatUtils_injectImageLoader() {
        // Given
        let imageLoader = utils.imageLoader as! ImageLoader_Mock

        // When
        imageLoader.loadImage(
            url: testURL,
            resize: nil,
            completion: { _ in }
        )

        // Then
        XCTAssert(imageLoader.loadImageCalled == true)
    }
}
