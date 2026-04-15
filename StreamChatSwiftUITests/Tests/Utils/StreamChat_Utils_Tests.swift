//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat
import StreamChatCommonUI
@testable import StreamChatSwiftUI
import XCTest

class StreamChat_Utils_Tests: StreamChatTestCase {
    private let testURL = URL(string: "https://example.com")!

    @Injected(\.utils) var utils

    override func setUp() {
        let utils = Utils(
            mediaLoader: ImageLoader_Mock()
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }

    func test_streamChatUtils_injectMediaLoader_videoPreview() {
        // Given
        let mediaLoader = utils.mediaLoader as! ImageLoader_Mock

        // When
        mediaLoader.loadVideoPreview(at: testURL, options: VideoLoadOptions(cdnRequester: CDNRequester_Mock()), completion: { _ in })

        // Then
        XCTAssert(mediaLoader.loadVideoPreviewCalled == true)
    }

    func test_streamChatUtils_injectMediaLoader_imageLoading() {
        // Given
        let mediaLoader = utils.mediaLoader as! ImageLoader_Mock

        // When
        mediaLoader.loadImage(
            url: testURL,
            options: ImageLoadOptions(cdnRequester: CDNRequester_Mock()),
            completion: { _ in }
        )

        // Then
        XCTAssert(mediaLoader.loadImageCalled == true)
    }
}
