//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
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
        let messageSearchController = ChatMessageSearchController_Mock.mock(client: chatClient)
        messageSearchController.messages_mock = messages
        let viewModel = MediaAttachmentsViewModel(
            channel: channel,
            messageSearchController: messageSearchController
        )

        // When
        let mediaItems = viewModel.mediaItems
        let imageAttachments = viewModel.allImageAttachments

        // Then
        XCTAssert(mediaItems.count == 8)
        XCTAssert(imageAttachments.count == 5)
    }

    func test_mediaAttachmentsViewModel_onAttachmentAppear() {
        // Given
        var messages = ChannelInfoMockUtils.generateMessagesWithAttachments(
            withImages: 15,
            withVideos: 5
        )
        let channel = ChatChannel.mockDMChannel()
        let messageSearchController = ChatMessageSearchController_Mock.mock(client: chatClient)
        messageSearchController.messages_mock = messages
        let viewModel = MediaAttachmentsViewModel(
            channel: channel,
            messageSearchController: messageSearchController
        )

        // When
        let initial = viewModel.mediaItems
        messages = ChannelInfoMockUtils.generateMessagesWithAttachments(
            withImages: 30,
            withVideos: 10
        )
        messageSearchController.messages_mock = messages
        viewModel.onMediaAttachmentAppear(with: 5)
        let middle = viewModel.mediaItems
        viewModel.onMediaAttachmentAppear(with: 15)
        let afterLoad = viewModel.mediaItems

        // Then
        XCTAssert(initial.count == 20)
        XCTAssert(middle.count == 20)
        XCTAssert(afterLoad.count == 40)
    }
}
