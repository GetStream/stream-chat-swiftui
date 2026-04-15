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
            mediaLoader: MediaLoader_Mock()
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }

    func test_streamChatUtils_injectMediaLoader_videoPreview() {
        // Given
        let mediaLoader = utils.mediaLoader as! MediaLoader_Mock

        // When
        let attachment = ChatMessageVideoAttachment(
            id: .init(cid: .init(type: .messaging, id: "test"), messageId: "msg", index: 0),
            type: .video,
            payload: VideoAttachmentPayload(
                title: nil,
                videoRemoteURL: testURL,
                file: .init(type: .mp4, size: 0, mimeType: nil),
                extraData: nil
            ),
            downloadingState: nil,
            uploadingState: nil
        )
        mediaLoader.loadVideoPreview(
            with: attachment,
            options: VideoLoadOptions(cdnRequester: CDNRequester_Mock()),
            completion: { _ in }
        )

        // Then
        XCTAssert(mediaLoader.loadVideoPreviewWithAttachmentCalled == true)
    }

    func test_streamChatUtils_injectMediaLoader_imageLoading() {
        // Given
        let mediaLoader = utils.mediaLoader as! MediaLoader_Mock

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
