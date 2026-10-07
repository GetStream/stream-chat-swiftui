//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

@MainActor final class ReactionsOverlayViewModel_Tests: StreamChatTestCase {
    private let love = MessageReactionType(rawValue: "love")
    private let wow = MessageReactionType(rawValue: "wow")

    func test_reactionTapped_whenCurrentUserHasNotReacted_thenAddsReaction() {
        // Given
        let message = makeMessage(isSentByCurrentUser: false, currentUserReactions: [])
        let (viewModel, messageController) = makeViewModel(message: message)

        // When
        viewModel.reactionTapped(love)

        // Then
        XCTAssertEqual(messageController.addReaction_types, [love])
        XCTAssertEqual(messageController.addReaction_enforceUnique, false)
        XCTAssertEqual(messageController.deleteReaction_types, [])
    }

    func test_reactionTapped_whenCurrentUserHasReacted_thenDeletesReaction() {
        // Given
        let message = makeMessage(isSentByCurrentUser: false, currentUserReactions: [love])
        let (viewModel, messageController) = makeViewModel(message: message)

        // When
        viewModel.reactionTapped(love)

        // Then
        XCTAssertEqual(messageController.deleteReaction_types, [love])
        XCTAssertEqual(messageController.addReaction_types, [])
    }

    func test_reactionTapped_onOwnMessage_whenCurrentUserHasNotReacted_thenAddsReaction() {
        // Given
        let message = makeMessage(isSentByCurrentUser: true, currentUserReactions: [])
        let (viewModel, messageController) = makeViewModel(message: message)

        // When
        viewModel.reactionTapped(wow)

        // Then
        XCTAssertEqual(messageController.addReaction_types, [wow])
        XCTAssertEqual(messageController.deleteReaction_types, [])
    }

    func test_reactionTapped_onOwnMessage_whenCurrentUserHasReacted_thenDeletesReaction() {
        // Given
        let message = makeMessage(isSentByCurrentUser: true, currentUserReactions: [wow])
        let (viewModel, messageController) = makeViewModel(message: message)

        // When
        viewModel.reactionTapped(wow)

        // Then
        XCTAssertEqual(messageController.deleteReaction_types, [wow])
        XCTAssertEqual(messageController.addReaction_types, [])
    }

    func test_reactionTapped_whenOnlyAnotherReactionIsOwn_thenAddsReaction() {
        // Given
        let message = makeMessage(isSentByCurrentUser: false, currentUserReactions: [wow])
        let (viewModel, messageController) = makeViewModel(message: message)

        // When
        viewModel.reactionTapped(love)

        // Then
        XCTAssertEqual(messageController.addReaction_types, [love])
        XCTAssertEqual(messageController.deleteReaction_types, [])
    }

    func test_reactionTapped_whenUniqueReactionsEnabled_thenAddsUniqueReaction() {
        // Given
        streamChat = StreamChat(
            chatClient: chatClient,
            utils: .init(messageListConfig: .init(uniqueReactionsEnabled: true))
        )
        let message = makeMessage(isSentByCurrentUser: false, currentUserReactions: [])
        let (viewModel, messageController) = makeViewModel(message: message)

        // When
        viewModel.reactionTapped(love)

        // Then
        XCTAssertEqual(messageController.addReaction_types, [love])
        XCTAssertEqual(messageController.addReaction_enforceUnique, true)
    }

    // MARK: - Helpers

    private func makeViewModel(
        message: ChatMessage
    ) -> (ReactionsOverlayViewModel, ChatMessageControllerSUI_Mock) {
        let messageController = ChatMessageControllerSUI_Mock.mock(
            chatClient: chatClient,
            currentUserId: StreamChatTestCase.currentUserId,
            cid: message.cid,
            messageId: message.id
        )
        messageController.message_mock = message
        let factory = ChannelControllerFactory_Mock()
        factory.messageController = messageController
        streamChat?.utils.channelControllerFactory = factory
        return (ReactionsOverlayViewModel(message: message), messageController)
    }

    private func makeMessage(
        isSentByCurrentUser: Bool,
        currentUserReactions: [MessageReactionType]
    ) -> ChatMessage {
        let currentUser = ChatUser.mock(id: StreamChatTestCase.currentUserId)
        let author: ChatUser = isSentByCurrentUser ? currentUser : .mock(id: .unique)
        let reactions = Set(currentUserReactions.map {
            ChatMessageReaction.mock(id: .unique, type: $0, author: currentUser)
        })
        var scores = [MessageReactionType: Int]()
        currentUserReactions.forEach { scores[$0] = 1 }
        return ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Test",
            author: author,
            reactionScores: scores,
            reactionCounts: scores,
            currentUserReactions: reactions,
            isSentByCurrentUser: isSentByCurrentUser
        )
    }
}

private final class ChannelControllerFactory_Mock: ChannelControllerFactory {
    var messageController: ChatMessageController?

    override func makeMessageController(
        for messageId: MessageId,
        channelId: ChannelId
    ) -> ChatMessageController {
        messageController ?? super.makeMessageController(for: messageId, channelId: channelId)
    }
}
