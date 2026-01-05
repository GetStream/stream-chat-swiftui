//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class MessageContainerView_Tests: StreamChatTestCase {
    func test_messageContainerViewSentThisUser_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message sent by current user",
            author: .mock(id: Self.currentUserId, name: "Martin"),
            isSentByCurrentUser: true
        )

        // When
        let view = testMessageViewContainer(message: message)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageContainerEdited_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message sent by current user",
            author: .mock(id: Self.currentUserId, name: "Martin"),
            isSentByCurrentUser: true,
            textUpdatedAt: Date()
        )

        // When
        let view = testMessageViewContainer(message: message)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageContainerEditedAIGenerated_snapshot() {
        // Given
        let key = "ai_generated"
        let utils = Utils(
            dateFormatter: EmptyDateFormatter(),
            messageListConfig: .init(
                skipEditedMessageLabel: { message in
                    message.extraData[key]?.boolValue == true
                }
            )
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message sent by current user",
            author: .mock(id: Self.currentUserId, name: "Martin"),
            extraData: [key: true],
            isSentByCurrentUser: true,
            textUpdatedAt: Date()
        )

        // When
        let view = testMessageViewContainer(message: message)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageContainerCurrentUserColor_snapshot() {
        // Given
        let utils = Utils(dateFormatter: EmptyDateFormatter())
        var colors = ColorPalette()
        colors.messageCurrentUserTextColor = .red
        let appearance = Appearance(colors: colors)
        streamChat = StreamChat(chatClient: chatClient, appearance: appearance, utils: utils)
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message sent by current user",
            author: .mock(id: Self.currentUserId, name: "Martin"),
            isSentByCurrentUser: true,
            textUpdatedAt: Date()
        )

        // When
        let view = testMessageViewContainer(message: message)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageContainerOtherUserColor_snapshot() {
        // Given
        let utils = Utils(dateFormatter: EmptyDateFormatter())
        var colors = ColorPalette()
        colors.messageOtherUserTextColor = .red
        let appearance = Appearance(colors: colors)
        streamChat = StreamChat(chatClient: chatClient, appearance: appearance, utils: utils)
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message sent by other user",
            author: .mock(id: Self.currentUserId, name: "Martin"),
            isSentByCurrentUser: false,
            textUpdatedAt: Date()
        )

        // When
        let view = testMessageViewContainer(message: message, channel: .mockNonDMChannel())

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageContainerViewSentOtherUser_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message sent by other user",
            author: .mock(id: .unique, name: "Martin")
        )

        // When
        let view = testMessageViewContainer(message: message, channel: .mockNonDMChannel())

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageContainerViewPinned_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "This is a pinned message",
            author: .mock(id: .unique, name: "Martin"),
            pinDetails: MessagePinDetails(
                pinnedAt: Date(),
                pinnedBy: .mock(id: .unique, name: "Martin"),
                expiresAt: nil
            )
        )

        // When
        let view = testMessageViewContainer(message: message, channel: .mockNonDMChannel())

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageContainerView_sendingFailed_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Test message",
            author: .mock(id: .unique),
            attachments: [],
            localState: .sendingFailed
        )

        // When
        let view = testMessageViewContainer(message: message, channel: .mockNonDMChannel())

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageContainerView_editingFailed_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Test message",
            author: .mock(id: .unique),
            attachments: [],
            localState: .syncingFailed
        )

        // When
        let view = testMessageViewContainer(message: message, channel: .mockNonDMChannel())

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_videoAttachment_snapshotNoText() {
        // Given
        let attachment = ChatChannelTestHelpers.videoAttachment
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique)
        )

        // When
        let view = VideoAttachmentView(
            attachment: attachment,
            message: message,
            width: 2 * defaultScreenSize.width / 3
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_videoAttachment_snapshotText() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Test message",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.videoAttachments
        )

        // When
        let view = VideoAttachmentsContainer(
            factory: DefaultViewFactory.shared,
            message: message,
            width: 2 * defaultScreenSize.width / 3,
            scrolledId: .constant(nil)
        )
        .frame(width: 200)
        .padding()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_imageAttachments_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Test message",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.imageAttachments
        )

        // When
        let view = ImageAttachmentContainer(
            factory: DefaultViewFactory.shared,
            message: message,
            width: 200,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .frame(width: 200)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_imageAttachments_snapshotFiveImages() {
        // Given
        let attachment = ChatChannelTestHelpers.imageAttachments[0]
        let attachments = [AnyChatMessageAttachment](repeating: attachment, count: 5)
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Test message",
            author: .mock(id: .unique),
            attachments: attachments
        )

        // When
        let view = ImageAttachmentContainer(
            factory: DefaultViewFactory.shared,
            message: message,
            width: 200,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .frame(width: 200)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_imageAttachments_failed_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Test message",
            author: .mock(id: .unique),
            attachments: [ChatChannelTestHelpers.imageAttachment(state: .uploadingFailed)],
            localState: .sendingFailed
        )

        // When
        let view = testMessageViewContainer(message: message, channel: .mockNonDMChannel())

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_imageAttachments_failedWhenMessageTextIsEmpty_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            attachments: [ChatChannelTestHelpers.imageAttachment(state: .uploadingFailed)],
            localState: .sendingFailed
        )

        // When
        let view = testMessageViewContainer(message: message, channel: .mockNonDMChannel())

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_translatedText_participant_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello",
            author: .mock(id: .unique),
            translations: [
                .spanish: "Hola"
            ]
        )
        
        // When
        let view = testMessageViewContainer(message: message)
            .environment(\.channelTranslationLanguage, .spanish)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_translatedText_myMessageIsNotTranslated_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello",
            author: .mock(id: .unique),
            translations: [
                .spanish: "Hola"
            ],
            isSentByCurrentUser: true
        )
        
        // When
        let view = testMessageViewContainer(message: message)
            .environment(\.channelTranslationLanguage, .spanish)

        // Then
        AssertSnapshot(view, size: CGSize(width: 375, height: 200))
    }

    func test_handleGestureForMessage_whenMessageIsInteractable_shouldLongPress() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello",
            localState: nil,
            isSentByCurrentUser: true
        )

        let exp = expectation(description: "Long press triggered")
        let view = MessageContainerView(
            factory: DefaultViewFactory.shared,
            channel: .mockDMChannel(),
            message: message,
            width: defaultScreenSize.width,
            showsAllInfo: true,
            isInThread: false,
            isLast: false,
            scrolledId: .constant(nil),
            quotedMessage: .constant(nil)
        ) { _ in
            exp.fulfill()
        }

        view.handleGestureForMessage(showsMessageActions: false, showsBottomContainer: false)

        waitForExpectations(timeout: defaultTimeout) { error in
            XCTAssertNil(error, "Long press was not triggered")
        }
    }

    func test_handleGestureForMessage_whenMessageNotInteractable_shouldNotLongPress() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello",
            type: .ephemeral,
            localState: nil,
            isSentByCurrentUser: true
        )

        let exp = expectation(description: "Long press should not be triggered")
        exp.isInverted = true
        let view = MessageContainerView(
            factory: DefaultViewFactory.shared,
            channel: .mockDMChannel(),
            message: message,
            width: defaultScreenSize.width,
            showsAllInfo: true,
            isInThread: false,
            isLast: false,
            scrolledId: .constant(nil),
            quotedMessage: .constant(nil)
        ) { _ in
            exp.fulfill()
        }

        view.handleGestureForMessage(showsMessageActions: false, showsBottomContainer: false)

        waitForExpectations(timeout: 1)
    }

    func test_isSwipeToReplyPossible_whenRepliesEnabled_whenMessageInteractable_shouldBeTrue() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello",
            localState: nil,
            isSentByCurrentUser: true
        )

        let viewModel = MessageViewModel(message: message, channel: .mockDMChannel(config: .mock(repliesEnabled: true)))

        XCTAssertTrue(viewModel.isSwipeToQuoteReplyPossible)
    }

    func test_isSwipeToReplyPossible_whenRepliesDisabled_whenMessageInteractable_shouldBeFalse() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello",
            localState: nil,
            isSentByCurrentUser: true
        )

        let viewModel = MessageViewModel(message: message, channel: .mockDMChannel(config: .mock(quotesEnabled: false)))

        XCTAssertFalse(viewModel.isSwipeToQuoteReplyPossible)
    }

    func test_isSwipeToReplyPossible_whenRepliesEnabled_whenMessageNotInteractable_shouldBeFalse() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello",
            type: .ephemeral,
            localState: nil,
            isSentByCurrentUser: true
        )

        let viewModel = MessageViewModel(message: message, channel: .mockDMChannel(config: .mock(repliesEnabled: true)))

        XCTAssertFalse(viewModel.isSwipeToQuoteReplyPossible)
    }

    func test_translatedText_showOriginalTranslatedButtonEnabled_originalTextShown_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello",
            author: .mock(id: .unique),
            translations: [
                .spanish: "Hola"
            ]
        )
        let utils = Utils(
            dateFormatter: EmptyDateFormatter(),
            messageListConfig: .init(
                messageDisplayOptions: MessageDisplayOptions(showOriginalTranslatedButton: true)
            )
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)

        // When
        let messageViewModel = MessageViewModel_Mock(
            message: message,
            channel: .mock(
                cid: .unique,
                membership: .mock(id: .unique, language: .spanish)
            )
        )
        messageViewModel.mockOriginalTextShown = true
        let view = testMessageViewContainer(message: message, messageViewModel: messageViewModel)
            .environment(\.channelTranslationLanguage, .spanish)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_translatedText_showOriginalTranslatedButtonEnabled_translatedTextShown_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello",
            author: .mock(id: .unique),
            translations: [
                .spanish: "Hola"
            ]
        )
        let utils = Utils(
            dateFormatter: EmptyDateFormatter(),
            messageListConfig: .init(
                messageDisplayOptions: MessageDisplayOptions(showOriginalTranslatedButton: true)
            )
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)

        // When
        let messageViewModel = MessageViewModel_Mock(
            message: message,
            channel: .mock(
                cid: .unique,
                membership: .mock(id: .unique, language: .spanish)
            )
        )
        messageViewModel.mockOriginalTextShown = false
        let view = testMessageViewContainer(message: message, messageViewModel: messageViewModel)
            .environment(\.channelTranslationLanguage, .spanish)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_translatedText_showOriginalTranslatedButtonDisabled_translatedTextShown_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello",
            author: .mock(id: .unique),
            translations: [
                .spanish: "Hola"
            ]
        )
        let utils = Utils(
            dateFormatter: EmptyDateFormatter(),
            messageListConfig: .init(
                messageDisplayOptions: MessageDisplayOptions(showOriginalTranslatedButton: false)
            )
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)

        // When
        let messageViewModel = MessageViewModel_Mock(
            message: message,
            channel: .mock(
                cid: .unique,
                membership: .mock(id: .unique, language: .spanish)
            )
        )
        let view = testMessageViewContainer(message: message, messageViewModel: messageViewModel)
            .environment(\.channelTranslationLanguage, .spanish)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageContainerHighlighted_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: "test-message-id",
            cid: .unique,
            text: "This message is highlighted",
            author: .mock(id: .unique, name: "Test User"),
            isSentByCurrentUser: false
        )
        let messageId = message.messageId

        // When
        let view = testMessageViewContainer(
            message: message,
            highlightedMessageId: messageId
        )

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageContainerNotHighlighted_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: "test-message-id",
            cid: .unique,
            text: "This message is not highlighted",
            author: .mock(id: .unique, name: "Test User"),
            isSentByCurrentUser: false
        )

        // When
        let view = testMessageViewContainer(
            message: message,
            highlightedMessageId: "different-message-id"
        )

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    // MARK: - private

    func testMessageViewContainer(
        message: ChatMessage,
        channel: ChatChannel? = nil,
        messageViewModel: MessageViewModel? = nil,
        highlightedMessageId: String? = nil
    ) -> some View {
        MessageContainerView(
            factory: DefaultViewFactory.shared,
            channel: channel ?? .mockDMChannel(),
            message: message,
            width: defaultScreenSize.width,
            showsAllInfo: true,
            isInThread: false,
            isLast: false,
            scrolledId: .constant(nil),
            quotedMessage: .constant(nil),
            onLongPress: { _ in },
            viewModel: messageViewModel ?? MessageViewModel(message: message, channel: channel)
        )
        .environment(\.highlightedMessageId, highlightedMessageId)
        .frame(width: 375, height: 200)
    }
}

class MessageViewModel_Mock: MessageViewModel {
    var mockOriginalTextShown: Bool = false

    override var originalTextShown: Bool {
        mockOriginalTextShown
    }
}
