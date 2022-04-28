//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

class FileAttachmentsView_Tests: StreamChatTestCase {

    func test_fileAttachmentsView_nonEmptySnapshot() {
        // Given
        let messages = ChannelInfoMockUtils.generateMessagesWithFileAttachments(count: 20)
        let messageSearchController = ChatMessageSearchController_Mock(client: chatClient)
        messageSearchController.messages_mock = messages
        let viewModel = FileAttachmentsViewModel(
            channel: .mockDMChannel(),
            messageSearchController: messageSearchController
        )
        
        // When
        let view = FileAttachmentsView(viewModel: viewModel)
            .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: view, as: .image)
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
        assertSnapshot(matching: view, as: .image)
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
        assertSnapshot(matching: view, as: .image)
    }
}
