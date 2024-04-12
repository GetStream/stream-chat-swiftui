//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class MediaAttachmentsView_Tests: StreamChatTestCase {

    @MainActor func test_mediaAttachmentsView_notEmptySnapshot() {
        // Given
        let messages = ChannelInfoMockUtils.generateMessagesWithAttachments(
            withImages: 10,
            withVideos: 5
        )
        let messageSearch = MessageSearch_Mock.mock()
        messageSearch.messages_mock = messages
        let viewModel = MediaAttachmentsViewModel(
            channel: .mockDMChannel(),
            messageSearch: messageSearch
        )
        viewModel.loading = false

        // When
        let view = MediaAttachmentsView(viewModel: viewModel)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    @MainActor func test_mediaAttachmentsView_emptySnapshot() {
        // Given
        let viewModel = MediaAttachmentsViewModel(channel: .mockDMChannel())
        viewModel.loading = false

        // When
        let view = MediaAttachmentsView(viewModel: viewModel)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    @MainActor func test_mediaAttachmentsView_loading() {
        // Given
        let viewModel = MediaAttachmentsViewModel(channel: .mockDMChannel())
        viewModel.loading = true

        // When
        let view = MediaAttachmentsView(viewModel: viewModel)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}
