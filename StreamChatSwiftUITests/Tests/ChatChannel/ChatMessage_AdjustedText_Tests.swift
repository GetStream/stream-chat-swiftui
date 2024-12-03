//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

class ChatMessage_AdjustedText_Tests: StreamChatTestCase {

    override func setUp() {
        super.setUp()
        let composerConfig = ComposerConfig(adjustMessageOnSend: { message in
            "some prefix \(message)"
        }, adjustMessageOnRead: { message in
            "bla bla \(message)"
        })
        let utils = Utils(composerConfig: composerConfig)
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }

    func test_chatMessage_adjustMessageOnRead() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Text",
            author: .mock(id: .unique)
        )

        // When
        let adjustedText = message.adjustedText

        // Then
        XCTAssert(adjustedText == "bla bla Text")
    }

    func test_composerVM_adjustMessageOnSend() {
        // Given
        let viewModel = makeComposerViewModel()

        // Then
        viewModel.text = "Text"
        let adjustedText = viewModel.adjustedText

        // Then
        XCTAssert(adjustedText == "some prefix Text")
    }

    // MARK: - private

    private func makeComposerViewModel() -> MessageComposerViewModel {
        let channelController = makeChannelController()
        let viewModel = MessageComposerViewModel(
            channelController: channelController,
            messageController: nil
        )
        return viewModel
    }

    private func makeChannelController(
        messages: [ChatMessage] = []
    ) -> ChatChannelController_Mock {
        ChatChannelTestHelpers.makeChannelController(
            chatClient: chatClient,
            messages: messages
        )
    }
}
