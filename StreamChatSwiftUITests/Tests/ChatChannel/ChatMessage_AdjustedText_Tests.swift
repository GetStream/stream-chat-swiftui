//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
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

    @MainActor func test_composerVM_adjustMessageOnSend() {
        // Given
        let viewModel = makeComposerViewModel()

        // Then
        viewModel.text = "Text"
        let adjustedText = viewModel.adjustedText

        // Then
        XCTAssert(adjustedText == "some prefix Text")
    }

    // MARK: - private

    @MainActor private func makeComposerViewModel() -> MessageComposerViewModel {
        let chat = chatClient.makeChat(for: .unique)
        let viewModel = MessageComposerViewModel(
            chat: chat,
            messageId: nil
        )
        return viewModel
    }

    private func makeChat(
        messages: [ChatMessage] = []
    ) -> Chat_Mock {
        ChatChannelTestHelpers.makeChat(
            chatClient: chatClient,
            messages: messages
        )
    }
}
