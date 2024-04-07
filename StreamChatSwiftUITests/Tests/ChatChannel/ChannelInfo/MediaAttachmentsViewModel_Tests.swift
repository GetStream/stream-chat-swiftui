//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine
@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class MediaAttachmentsViewModel_Tests: StreamChatTestCase {

    private var cancellables = Set<AnyCancellable>()

    func test_mediaAttachmentsViewModel_attachments() {
        // Given
        let messages = ChannelInfoMockUtils.generateMessagesWithAttachments(
            withImages: 5,
            withVideos: 3
        )
        let channel = ChatChannel.mockDMChannel()
        let messageSearch = MessageSearch_Mock.mock()
        messageSearch.messages_mock = messages
        let viewModel = MediaAttachmentsViewModel(
            channel: channel,
            messageSearch: messageSearch
        )

        // When
        let mediaItems = viewModel.mediaItems
        let imageAttachments = viewModel.allImageAttachments

        // Then
        XCTAssertEqual(mediaItems.count, 8)
        XCTAssertEqual(imageAttachments.count, 5)
    }

    func test_mediaAttachmentsViewModel_onAttachmentAppear() async throws {
        // Given
        var messages = ChannelInfoMockUtils.generateMessagesWithAttachments(
            withImages: 15,
            withVideos: 5
        )
        let channel = ChatChannel.mockDMChannel()
        let messageSearch = MessageSearch_Mock.mock()
        messageSearch.messages_mock = messages
        
        let viewModel = MediaAttachmentsViewModel(
            channel: channel,
            messageSearch: messageSearch
        )

        // When
        let initial = viewModel.mediaItems
        messages = ChannelInfoMockUtils.generateMessagesWithAttachments(
            withImages: 30,
            withVideos: 10
        )
        messageSearch.messages_mock = messages
        viewModel.onMediaAttachmentAppear(with: 5)
        let middle = viewModel.mediaItems
        viewModel.onMediaAttachmentAppear(with: 15)
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let afterLoad = viewModel.mediaItems

        // Then
        XCTAssertEqual(initial.count, 20)
        XCTAssertEqual(middle.count, 20)
        XCTAssertEqual(afterLoad.count, 40)
    }
}
