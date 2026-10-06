//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

@MainActor final class MessageViewModel_Tests: StreamChatTestCase {
    private var statusStrings: [String] {
        [
            L10n.Message.Accessibility.statusRead,
            L10n.Message.Accessibility.statusDelivered,
            L10n.Message.Accessibility.statusSent
        ]
    }

    // MARK: - accessibilitySenderName

    func test_accessibilitySenderName_whenSentByCurrentUser_returnsYou() {
        let viewModel = makeViewModel(for: makeMessage(isSentByCurrentUser: true))

        XCTAssertEqual(viewModel.accessibilitySenderName, L10n.Message.Accessibility.you)
    }

    func test_accessibilitySenderName_whenFromOtherUser_returnsAuthorName() {
        let message = makeMessage(author: .mock(id: "yoda", name: "Yoda"), isSentByCurrentUser: false)
        let viewModel = makeViewModel(for: message)

        XCTAssertEqual(viewModel.accessibilitySenderName, "Yoda")
    }

    // MARK: - accessibilityLabel

    func test_accessibilityLabel_incomingMessage_combinesSenderContentAndTime() {
        let message = makeMessage(
            author: .mock(id: "yoda", name: "Yoda"),
            isSentByCurrentUser: false,
            text: "Hello there"
        )
        let viewModel = makeViewModel(for: message)

        XCTAssertEqual(
            viewModel.accessibilityLabel(showsAllInfo: false),
            expectedLabel(sender: "Yoda", content: "Hello there", message: message)
        )
    }

    func test_accessibilityLabel_incomingMessage_neverAnnouncesDeliveryStatus() {
        let message = makeMessage(
            author: .mock(id: "yoda", name: "Yoda"),
            isSentByCurrentUser: false,
            text: "Hello there"
        )
        let viewModel = makeViewModel(for: message)

        let label = viewModel.accessibilityLabel(showsAllInfo: true)

        XCTAssertEqual(label, expectedLabel(sender: "Yoda", content: "Hello there", message: message))
        XCTAssertFalse(statusStrings.contains { label.contains($0) })
    }

    func test_accessibilityLabel_ownMessage_announcesDeliveryStatusOnlyWhenShowingAllInfo() {
        let message = makeMessage(
            author: .mock(id: Self.currentUserId, name: "Me"),
            isSentByCurrentUser: true,
            text: "Hello there"
        )
        let viewModel = makeViewModel(for: message)

        let withoutStatus = viewModel.accessibilityLabel(showsAllInfo: false)
        let withStatus = viewModel.accessibilityLabel(showsAllInfo: true)

        XCTAssertFalse(statusStrings.contains { withoutStatus.contains($0) })
        XCTAssertTrue(statusStrings.contains { withStatus == "\(withoutStatus), \($0)" })
    }

    func test_accessibilityLabel_deletedMessage_usesPlaceholderAndOmitsStatus() {
        let message = makeMessage(
            author: .mock(id: Self.currentUserId, name: "Me"),
            isSentByCurrentUser: true,
            text: "Hello there",
            deletedAt: Date()
        )
        let viewModel = makeViewModel(for: message)

        let label = viewModel.accessibilityLabel(showsAllInfo: true)

        XCTAssertEqual(
            label,
            expectedLabel(sender: L10n.Message.Accessibility.you, content: L10n.Message.deletedMessagePlaceholder, message: message)
        )
        XCTAssertFalse(statusStrings.contains { label.contains($0) })
    }

    // MARK: - captionAccessibilityLabel

    func test_captionAccessibilityLabel_withoutCaption_returnsNil() {
        let message = makeMessage(
            author: .mock(id: "yoda", name: "Yoda"),
            isSentByCurrentUser: false,
            text: "Hello there"
        )
        let viewModel = makeViewModel(for: message)

        XCTAssertNil(viewModel.captionAccessibilityLabel(showsAllInfo: false))
    }

    func test_captionAccessibilityLabel_withCaption_matchesAccessibilityLabel() {
        let message = makeMessage(
            author: .mock(id: "yoda", name: "Yoda"),
            isSentByCurrentUser: false,
            text: "Look at this",
            attachments: [ChatChannelTestHelpers.imageAttachment(state: .uploaded)]
        )
        let viewModel = makeViewModel(for: message)

        XCTAssertEqual(
            viewModel.captionAccessibilityLabel(showsAllInfo: false),
            viewModel.accessibilityLabel(showsAllInfo: false)
        )
    }

    // MARK: - keepsBubbleAccessibilityChildrenFocusable

    func test_keepsBubbleAccessibilityChildrenFocusable_plainTextMessage_isFalse() {
        let message = makeMessage(isSentByCurrentUser: false, text: "Hello there")
        let viewModel = makeViewModel(for: message)

        XCTAssertFalse(viewModel.keepsBubbleAccessibilityChildrenFocusable)
    }

    func test_keepsBubbleAccessibilityChildrenFocusable_deletedMessage_isFalse() {
        let message = makeMessage(isSentByCurrentUser: false, text: "Hello there", deletedAt: Date())
        let viewModel = makeViewModel(for: message)

        XCTAssertFalse(viewModel.keepsBubbleAccessibilityChildrenFocusable)
    }

    func test_keepsBubbleAccessibilityChildrenFocusable_withAttachment_isTrue() {
        let message = makeMessage(
            isSentByCurrentUser: false,
            attachments: [ChatChannelTestHelpers.imageAttachment(state: .uploaded)]
        )
        let viewModel = makeViewModel(for: message)

        XCTAssertTrue(viewModel.keepsBubbleAccessibilityChildrenFocusable)
    }

    func test_keepsBubbleAccessibilityChildrenFocusable_withQuotedMessage_isTrue() {
        let message = makeMessage(
            isSentByCurrentUser: false,
            text: "Hello there",
            quotedMessage: .mock(id: .unique, cid: .unique, text: "Quoted", author: .mock(id: .unique))
        )
        let viewModel = makeViewModel(for: message)

        XCTAssertTrue(viewModel.keepsBubbleAccessibilityChildrenFocusable)
    }

    func test_keepsBubbleAccessibilityChildrenFocusable_withPoll_isTrue() {
        let message = makeMessage(isSentByCurrentUser: false, poll: .mock())
        let viewModel = makeViewModel(for: message)

        XCTAssertTrue(viewModel.keepsBubbleAccessibilityChildrenFocusable)
    }

    func test_keepsBubbleAccessibilityChildrenFocusable_withFailedMessage_isTrue() {
        let message = makeMessage(
            isSentByCurrentUser: true,
            text: "Hello there",
            localState: .sendingFailed
        )
        let viewModel = makeViewModel(for: message)

        XCTAssertTrue(viewModel.keepsBubbleAccessibilityChildrenFocusable)
    }

    // MARK: - isDeliveryStatusShown

    func test_isDeliveryStatusShown_ownMessageWithReadEventsEnabled_isTrue() {
        let message = makeMessage(author: .mock(id: Self.currentUserId), isSentByCurrentUser: true)

        XCTAssertTrue(MessageViewModel.isDeliveryStatusShown(for: message, in: makeChannel(readEventsEnabled: true)))
    }

    func test_isDeliveryStatusShown_ownMessageWithReadEventsDisabled_isFalse() {
        let message = makeMessage(author: .mock(id: Self.currentUserId), isSentByCurrentUser: true)

        XCTAssertFalse(MessageViewModel.isDeliveryStatusShown(for: message, in: makeChannel(readEventsEnabled: false)))
    }

    func test_isDeliveryStatusShown_ownMessageReadByParticipantWithReadEventsDisabled_isFalse() {
        let message = makeMessage(author: .mock(id: Self.currentUserId), isSentByCurrentUser: true)
        let channel = makeChannel(readEventsEnabled: false, readBy: .mock(id: "yoda"), after: message)

        XCTAssertFalse(MessageViewModel.isDeliveryStatusShown(for: message, in: channel))
    }

    func test_isDeliveryStatusShown_deletedOwnMessageWithReadEventsDisabled_isFalse() {
        let message = makeMessage(
            author: .mock(id: Self.currentUserId),
            isSentByCurrentUser: true,
            deletedAt: Date()
        )

        XCTAssertFalse(MessageViewModel.isDeliveryStatusShown(for: message, in: makeChannel(readEventsEnabled: false)))
    }

    func test_isDeliveryStatusShown_incomingMessage_isFalse() {
        let message = makeMessage(isSentByCurrentUser: false)

        XCTAssertFalse(MessageViewModel.isDeliveryStatusShown(for: message, in: makeChannel(readEventsEnabled: true)))
    }

    func test_accessibilityLabel_ownMessageReadByParticipant_announcesRead() {
        let message = makeMessage(
            author: .mock(id: Self.currentUserId, name: "Me"),
            isSentByCurrentUser: true,
            text: "Hello there"
        )
        let channel = makeChannel(readEventsEnabled: true, readBy: .mock(id: "yoda"), after: message)
        let viewModel = MessageViewModel(message: message, channel: channel)

        let label = viewModel.accessibilityLabel(showsAllInfo: true)

        XCTAssertTrue(label.hasSuffix(", \(L10n.Message.Accessibility.statusRead)"))
    }

    func test_accessibilityLabel_ownMessageReadByParticipantWithReadEventsDisabled_omitsStatus() {
        let message = makeMessage(
            author: .mock(id: Self.currentUserId, name: "Me"),
            isSentByCurrentUser: true,
            text: "Hello there"
        )
        let channel = makeChannel(readEventsEnabled: false, readBy: .mock(id: "yoda"), after: message)
        let viewModel = MessageViewModel(message: message, channel: channel)

        let label = viewModel.accessibilityLabel(showsAllInfo: true)

        XCTAssertFalse(statusStrings.contains { label.contains($0) })
    }

    // MARK: - reactionsShown

    func test_reactionsShown_incomingMessageWithReactions_isTrue() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello there",
            author: .mock(id: "yoda"),
            reactionScores: [MessageReactionType(rawValue: "love"): 1],
            isSentByCurrentUser: false
        )

        XCTAssertTrue(makeViewModel(for: message).reactionsShown)
    }

    func test_reactionsShown_messageWithoutReactions_isFalse() {
        let message = makeMessage(isSentByCurrentUser: false, text: "Hello there")

        XCTAssertFalse(makeViewModel(for: message).reactionsShown)
    }

    // MARK: - isHighlighted

    func test_isHighlighted_whenJumpedToThisMessage_returnsTrue() {
        let message = makeMessage(isSentByCurrentUser: false, text: "Hello there")
        let viewModel = makeViewModel(for: message)

        XCTAssertTrue(viewModel.isHighlighted(messageId: message.messageId))
    }

    func test_isHighlighted_whenJumpedToAnotherMessage_returnsFalse() {
        let viewModel = makeViewModel(for: makeMessage(isSentByCurrentUser: false, text: "Hello there"))

        XCTAssertFalse(viewModel.isHighlighted(messageId: "another-message"))
        XCTAssertFalse(viewModel.isHighlighted(messageId: nil))
    }

    func test_isHighlighted_whenHighlightingIsDisabled_returnsFalse() {
        streamChat = StreamChat(
            chatClient: chatClient,
            utils: Utils(messageListConfig: MessageListConfig(highlightMessageWhenJumping: false))
        )
        let message = makeMessage(isSentByCurrentUser: false, text: "Hello there")
        let viewModel = makeViewModel(for: message)

        XCTAssertFalse(viewModel.isHighlighted(messageId: message.messageId))
    }

    // MARK: - Helpers

    private func makeMessage(
        author: ChatUser = .mock(id: "yoda", name: "Yoda"),
        isSentByCurrentUser: Bool,
        text: String = "",
        deletedAt: Date? = nil,
        quotedMessage: ChatMessage? = nil,
        attachments: [AnyChatMessageAttachment] = [],
        poll: Poll? = nil,
        localState: LocalMessageState? = nil
    ) -> ChatMessage {
        ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: text,
            author: author,
            createdAt: Date(timeIntervalSince1970: 100),
            deletedAt: deletedAt,
            quotedMessage: quotedMessage,
            attachments: attachments,
            localState: localState,
            isSentByCurrentUser: isSentByCurrentUser,
            poll: poll
        )
    }

    private func makeViewModel(for message: ChatMessage) -> MessageViewModel {
        MessageViewModel(message: message, channel: .mockDMChannel())
    }

    private func makeChannel(
        readEventsEnabled: Bool,
        readBy reader: ChatUser? = nil,
        after message: ChatMessage? = nil
    ) -> ChatChannel {
        let reads: [ChatChannelRead] = reader.map { reader in
            [
                .mock(
                    lastReadAt: (message?.createdAt ?? Date()).addingTimeInterval(10),
                    lastReadMessageId: message?.id,
                    unreadMessagesCount: 0,
                    user: reader
                )
            ]
        } ?? []
        return .mockDMChannel(config: .mock(readEventsEnabled: readEventsEnabled), reads: reads)
    }

    private func expectedLabel(sender: String, content: String, message: ChatMessage) -> String {
        let time = streamChat?.utils.dateFormatter.string(from: message.createdAt) ?? ""
        return [sender, content, L10n.Message.Accessibility.sentTime(time)]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}
