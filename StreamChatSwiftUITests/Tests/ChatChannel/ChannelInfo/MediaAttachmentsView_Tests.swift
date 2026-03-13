//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class MediaAttachmentsView_Tests: StreamChatTestCase {
    func test_mediaAttachmentsView_notEmptySnapshot() {
        // Given
        let messages = ChannelInfoMockUtils.generateMessagesWithAttachments(
            withImages: 6,
            withVideos: 6
        )
        let messageSearchController = ChatMessageSearchController_Mock.mock(client: chatClient)
        messageSearchController.messages_mock = messages
        let viewModel = MediaAttachmentsViewModel(
            channel: .mockDMChannel(),
            messageSearchController: messageSearchController
        )

        // When
        let view = MediaAttachmentsView(viewModel: viewModel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }

    func test_mediaAttachmentsView_emptySnapshot() {
        // Given
        let viewModel = MediaAttachmentsViewModel(channel: .mockDMChannel())
        viewModel.loading = false

        // When
        let view = MediaAttachmentsView(viewModel: viewModel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }

    func test_mediaAttachmentsView_loading() {
        // Given
        let viewModel = MediaAttachmentsViewModel(channel: .mockDMChannel())
        viewModel.loading = true

        // When
        let view = MediaAttachmentsView(viewModel: viewModel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }
    
    func test_mediaAttachmentsView_themedSnapshot() {
        // Given
        setThemedNavigationBarAppearance()
        let messages = ChannelInfoMockUtils.generateMessagesWithAttachments(
            withImages: 6,
            withVideos: 6
        )
        let messageSearchController = ChatMessageSearchController_Mock.mock(client: chatClient)
        messageSearchController.messages_mock = messages
        let viewModel = MediaAttachmentsViewModel(
            channel: .mockDMChannel(),
            messageSearchController: messageSearchController
        )

        // When
        let view = NavigationContainerView(embedInNavigationView: true) {
            MediaAttachmentsView(viewModel: viewModel)
        }.applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }

    func test_mediaAttachmentsView_iPadSnapshot() {
        // Given
        let iPadSize = CGSize(width: 820, height: 1180)
        let messages = ChannelInfoMockUtils.generateMessagesWithAttachments(
            withImages: 6,
            withVideos: 6
        )
        let messageSearchController = ChatMessageSearchController_Mock.mock(client: chatClient)
        messageSearchController.messages_mock = messages
        let viewModel = MediaAttachmentsViewModel(
            channel: .mockDMChannel(),
            messageSearchController: messageSearchController
        )

        // When
        let view = MediaAttachmentsView(viewModel: viewModel)
            .applySize(iPadSize)

        // Then
        AssertSnapshot(view, size: iPadSize)
    }
}
