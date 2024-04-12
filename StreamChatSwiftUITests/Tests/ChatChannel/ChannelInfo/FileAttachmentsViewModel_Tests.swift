//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine
@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class FileAttachmentsViewModel_Tests: StreamChatTestCase {

    @MainActor func test_fileAttachmentsViewModel_notEmpty() {
        // Given
        let messages = ChannelInfoMockUtils.generateMessagesWithFileAttachments(count: 10)
        let messageSearch = MessageSearch_Mock.mock()
        messageSearch.messages_mock = messages
        let viewModel = FileAttachmentsViewModel(
            channel: .mockDMChannel(),
            messageSearch: messageSearch
        )

        // When
        let attachmentsDataSource = viewModel.attachmentsDataSource

        // Then
        XCTAssertEqual(attachmentsDataSource.first?.attachments.count, 10)
        XCTAssertEqual(attachmentsDataSource.first?.monthAndYear, "January 1970")
    }

    @MainActor func test_fileAttachmentsViewModel_loadAdditionalAttachments() async throws {
        // Given
        var messages = ChannelInfoMockUtils.generateMessagesWithFileAttachments(count: 20)
        let messageSearch = MessageSearch_Mock.mock()
        messageSearch.messages_mock = messages
        let viewModel = FileAttachmentsViewModel(
            channel: .mockDMChannel(),
            messageSearch: messageSearch
        )

        // When
        let additional = Array(ChannelInfoMockUtils.generateMessagesWithFileAttachments(count: 20))
        var current = Array(messages)
        current.append(contentsOf: additional)
        messages = StreamCollection(current)
        messageSearch.messages_mock = messages

        // Initial load, when only the 5th attachment is displayed.
        let initial = viewModel.attachmentsDataSource[0].attachments
        let initialLoad = initial[5]
        viewModel.loadAdditionalAttachments(
            after: viewModel.attachmentsDataSource[0],
            latest: initialLoad
        )
        let afterFirstLoad = viewModel.attachmentsDataSource[0].attachments

        // Second load, when the 15th attachment is shown, there should be loading of new messages.
        let secondLoad = initial[15]
        viewModel.loadAdditionalAttachments(
            after: viewModel.attachmentsDataSource[0],
            latest: secondLoad
        )
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let afterSecondLoad = viewModel.attachmentsDataSource[0].attachments

        // Then
        XCTAssertEqual(afterFirstLoad.count, 20)
        XCTAssertEqual(afterSecondLoad.count, 40)
    }
}
