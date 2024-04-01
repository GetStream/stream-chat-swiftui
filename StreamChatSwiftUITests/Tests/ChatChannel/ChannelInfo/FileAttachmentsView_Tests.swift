//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class FileAttachmentsView_Tests: StreamChatTestCase {

    func test_fileAttachmentsView_nonEmptySnapshot() {
        // Given
        let messages = ChannelInfoMockUtils.generateMessagesWithFileAttachments(count: 20)
//        let messageSearchController = ChatMessageSearchController_Mock.mock(client: chatClient)
//        messageSearchController.messages_mock = messages
        let messageSearch = chatClient.makeMessageSearch()
        let viewModel = FileAttachmentsViewModel(
            channel: .mockDMChannel(),
            messageSearch: messageSearch
        )

        // When
        let view = FileAttachmentsView(viewModel: viewModel)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_fileAttachmentsView_emptySnapshot() {
        // Given
        let viewModel = FileAttachmentsViewModel(
            channel: .mockDMChannel()
        )
        viewModel.loading = false

        // When
        let view = FileAttachmentsView(viewModel: viewModel)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_fileAttachmentsView_loadingSnapshot() {
        // Given
        let viewModel = FileAttachmentsViewModel(
            channel: .mockDMChannel()
        )
        viewModel.loading = true

        // When
        let view = FileAttachmentsView(viewModel: viewModel)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_fileAttachmentsPickerView_snapshot() {
        // Given
        let view = FilePickerView(fileURLs: .constant([]))
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}
