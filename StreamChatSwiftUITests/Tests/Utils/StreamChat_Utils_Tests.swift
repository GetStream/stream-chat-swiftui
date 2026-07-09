//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat
import StreamChatCommonUI
@testable import StreamChatSwiftUI
import UniformTypeIdentifiers
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
            options: VideoLoadOptions(),
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
            options: ImageLoadOptions(),
            completion: { _ in }
        )

        // Then
        XCTAssert(mediaLoader.loadImageCalled == true)
    }

    func test_streamChatUtils_defaultMediaLoader() {
        // Given
        let utils = Utils(mediaLoader: MediaLoader_Mock())
        streamChat = StreamChat(chatClient: chatClient, utils: utils)

        // Then
        XCTAssert(self.utils.mediaLoader is MediaLoader_Mock)
    }

    func test_streamChatUtils_defaultMediaLoader_hasDefaultCDNRequester() {
        // Given
        let utils = Utils()
        streamChat = StreamChat(chatClient: chatClient, utils: utils)

        // Then
        let loader = self.utils.mediaLoader as? StreamMediaLoader
        XCTAssertNotNil(loader)
        XCTAssert(loader?.cdnRequester is StreamCDNRequester)
    }

    func test_streamChatUtils_customDiskCacheSize() {
        // Given
        let config = MessageListConfig(videoAttachmentCachingPolicy: VideoAttachmentCachingPolicy(maxCacheSize: 123))
        let utils = Utils(messageListConfig: config)

        // Then
        XCTAssertEqual(utils.videoAttachmentDiskCache.maxSizeInBytes, 123)
    }

    func test_messageListConfig_videoAttachmentCachingPolicy() {
        let defaultPolicy = MessageListConfig().videoAttachmentCachingPolicy
        XCTAssertEqual(defaultPolicy.maxCacheSize, 0)
        XCTAssertEqual(defaultPolicy.allowedContentTypes, [.movie])

        let policy = VideoAttachmentCachingPolicy(maxCacheSize: 100)
        let configuredPolicy = MessageListConfig(videoAttachmentCachingPolicy: policy).videoAttachmentCachingPolicy
        XCTAssertEqual(configuredPolicy.maxCacheSize, 100)
        XCTAssertEqual(configuredPolicy.allowedContentTypes, [.movie])
    }

    func test_streamChatUtils_customCDNRequester_throughMediaLoader() {
        // Given
        let customRequester = CDNRequester_Mock()
        let customLoader = StreamMediaLoader(downloader: StreamImageDownloader(), cdnRequester: customRequester)
        let utils = Utils(mediaLoader: customLoader)
        streamChat = StreamChat(chatClient: chatClient, utils: utils)

        // Then
        let loader = self.utils.mediaLoader as? StreamMediaLoader
        XCTAssertNotNil(loader)
        XCTAssert(loader?.cdnRequester is CDNRequester_Mock)
    }
}
