//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

class FileAttachmentsViewModel_Tests: StreamChatTestCase {

    func test_fileAttachmentsViewModel_notEmpty() {
        // Given
        let messages = ChannelInfoMockUtils.generateMessagesWithFileAttachments(count: 10)
        let messageSearchController = ChatMessageSearchController_Mock.mock(client: chatClient)
        messageSearchController.messages_mock = messages
        let viewModel = FileAttachmentsViewModel(
            channel: .mockDMChannel(),
            messageSearchController: messageSearchController
        )

        // When
        let attachmentsDataSource = viewModel.attachmentsDataSource

        // Then
        XCTAssert(attachmentsDataSource[0].attachments.count == 10)
        XCTAssert(attachmentsDataSource[0].monthAndYear == "January 1970")
    }

    func test_fileAttachmentsViewModel_loadAdditionalAttachments() {
        // Given
        var messages = ChannelInfoMockUtils.generateMessagesWithFileAttachments(count: 20)
        let messageSearchController = ChatMessageSearchController_Mock.mock(client: chatClient)
        messageSearchController.messages_mock = messages
        let viewModel = FileAttachmentsViewModel(
            channel: .mockDMChannel(),
            messageSearchController: messageSearchController
        )

        // When
        let additional = Array(ChannelInfoMockUtils.generateMessagesWithFileAttachments(count: 20))
        var current = Array(messages)
        current.append(contentsOf: additional)
        messages = LazyCachedMapCollection(source: current) { $0 }
        messageSearchController.messages_mock = messages

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
        let afterSecondLoad = viewModel.attachmentsDataSource[0].attachments

        // Then
        XCTAssert(afterFirstLoad.count == 20)
        XCTAssert(afterSecondLoad.count == 40)
    }
}
