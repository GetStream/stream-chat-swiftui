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

    private func expectedLabel(sender: String, content: String, message: ChatMessage) -> String {
        let time = streamChat?.utils.dateFormatter.string(from: message.createdAt) ?? ""
        return [sender, content, L10n.Message.Accessibility.sentTime(time)]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}
