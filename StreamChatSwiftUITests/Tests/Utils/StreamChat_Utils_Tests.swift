//
// Copyright © 2024 Stream.io Inc. All rights reserved.
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
            videoPreviewLoader: VideoPreviewLoader_Mock(),
            imageLoader: ImageLoaderUtils_Mock()
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }

    func test_streamChatUtils_injectVideoPreviewLoader() {
        // Given
        let videoPreviewLoader = utils.videoPreviewLoader as! VideoPreviewLoader_Mock

        // When
        videoPreviewLoader.loadPreviewForVideo(at: testURL, completion: { _ in })

        // Then
        XCTAssert(videoPreviewLoader.loadPreviewVideoCalled == true)
    }

    func test_streamChatUtils_injectImageLoader() {
        // Given
        let imageLoader = utils.imageLoader as! ImageLoaderUtils_Mock

        // When
        imageLoader.loadImage(
            url: testURL,
            imageCDN: utils.imageCDN,
            resize: true,
            preferredSize: nil,
            completion: { _ in }
        )

        // Then
        XCTAssert(imageLoader.loadImageCalled == true)
    }
}
