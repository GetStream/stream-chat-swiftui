//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatCommonUI
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class MessageItemView_Tests: StreamChatTestCase {
    @Injected(\.colors) private var colors

    override func setUp() {
        super.setUp()

        let imageLoader = TestImagesLoader_Mock()
        let utils = Utils(
            videoPreviewLoader: VideoPreviewLoader_Mock(),
            imageLoader: imageLoader,
            composerConfig: ComposerConfig(isVoiceRecordingEnabled: true)
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }

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
        let colors = Appearance.ColorPalette()
        colors.chatTextOutgoing = .red
        var appearance = Appearance()
        appearance.colorPalette = colors
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
        let colors = Appearance.ColorPalette()
        colors.chatTextIncoming = .red
        var appearance = Appearance()
        appearance.colorPalette = colors
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

    func test_messageContainerViewDeleted_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "This was the original message",
            author: .mock(id: Self.currentUserId, name: "Martin"),
            deletedAt: Date(),
            isSentByCurrentUser: true
        )

        // When
        let view = testMessageViewContainer(message: message)

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
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.videoAttachments
        )

        // When
        let view = MessageMediaAttachmentsContainerView(
            factory: DefaultViewFactory.shared,
            message: message,
            width: 2 * defaultScreenSize.width / 3
        )
        .frame(width: 200)
        .padding()

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
        let view = MessageMediaAttachmentsContainerView(
            factory: DefaultViewFactory.shared,
            message: message,
            width: 2 * defaultScreenSize.width / 3
        )
        .frame(width: 200)
        .padding()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    // MARK: - Media Gallery (orientation × count)

    func test_mediaGallery_landscape_1_snapshot() {
        assertMediaGallerySnapshot(orientation: .landscape, count: 1)
    }

    func test_mediaGallery_landscape_2_snapshot() {
        assertMediaGallerySnapshot(orientation: .landscape, count: 2)
    }

    func test_mediaGallery_landscape_3_snapshot() {
        assertMediaGallerySnapshot(orientation: .landscape, count: 3)
    }

    func test_mediaGallery_landscape_4_snapshot() {
        assertMediaGallerySnapshot(orientation: .landscape, count: 4)
    }

    func test_mediaGallery_landscape_5_snapshot() {
        assertMediaGallerySnapshot(orientation: .landscape, count: 5)
    }

    func test_mediaGallery_portrait_1_snapshot() {
        assertMediaGallerySnapshot(orientation: .portrait, count: 1)
    }

    func test_mediaGallery_portrait_2_snapshot() {
        assertMediaGallerySnapshot(orientation: .portrait, count: 2)
    }

    func test_mediaGallery_portrait_3_snapshot() {
        assertMediaGallerySnapshot(orientation: .portrait, count: 3)
    }

    func test_mediaGallery_portrait_4_snapshot() {
        assertMediaGallerySnapshot(orientation: .portrait, count: 4)
    }

    func test_mediaGallery_portrait_5_snapshot() {
        assertMediaGallerySnapshot(orientation: .portrait, count: 5)
    }

    func test_mediaGallery_square_1_snapshot() {
        assertMediaGallerySnapshot(orientation: .square, count: 1)
    }

    func test_mediaGallery_square_2_snapshot() {
        assertMediaGallerySnapshot(orientation: .square, count: 2)
    }

    func test_mediaGallery_square_3_snapshot() {
        assertMediaGallerySnapshot(orientation: .square, count: 3)
    }

    func test_mediaGallery_square_4_snapshot() {
        assertMediaGallerySnapshot(orientation: .square, count: 4)
    }

    func test_mediaGallery_square_5_snapshot() {
        assertMediaGallerySnapshot(orientation: .square, count: 5)
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
        let view = testMessageViewContainer(message: message, channel: .mockNonDMChannel(), height: 300)

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
        let view = testMessageViewContainer(message: message, channel: .mockNonDMChannel(), height: 300)

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
        let view = MessageItemView(
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

        view.handleGestureForMessage(showsMessageActions: false)

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
        let view = MessageItemView(
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

        view.handleGestureForMessage(showsMessageActions: false)

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

    // MARK: - shownAsPreview

    func test_messagePreview_threadReplies_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message with thread replies",
            author: .mock(id: .unique, name: "Martin"),
            replyCount: 3
        )

        // When
        let view = testMessageViewContainer(message: message, shownAsPreview: true)
            .background(Color(colors.backgroundCoreScrim))

        // Then
        AssertSnapshot(view, size: CGSize(width: 375, height: 200))
    }

    func test_messagePreview_timestampOnly_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message with timestamp",
            author: .mock(id: .unique, name: "Martin")
        )

        // When
        let view = testMessageViewContainer(message: message, shownAsPreview: true)
            .background(Color(colors.backgroundCoreScrim))

        // Then
        AssertSnapshot(view, size: CGSize(width: 375, height: 200))
    }

    func test_messagePreview_authorAndTimestamp_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message with author and timestamp",
            author: .mock(id: .unique, name: "Martin")
        )
        let channel = ChatChannel.mockNonDMChannel(memberCount: 5)

        // When
        let view = testMessageViewContainer(
            message: message,
            channel: channel,
            shownAsPreview: true
        )
        .background(Color(colors.backgroundCoreScrim))

        // Then
        AssertSnapshot(view, size: CGSize(width: 375, height: 200))
    }

    func test_messagePreview_translatedText_snapshot() {
        // Given
        let channel = ChatChannel.mock(
            cid: .unique,
            membership: .mock(id: .unique, language: .spanish)
        )
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello",
            author: .mock(id: .unique, name: "Martin"),
            translations: [
                .spanish: "Hola"
            ]
        )

        // When
        let view = testMessageViewContainer(
            message: message,
            channel: channel,
            shownAsPreview: true
        )
        .background(Color(colors.backgroundCoreScrim))
        .environment(\.channelTranslationLanguage, .spanish)

        // Then
        AssertSnapshot(view, size: CGSize(width: 375, height: 200))
    }

    // MARK: - Avatar Visibility

    func test_messageItemView_outgoingAvatarShown_snapshot() {
        // Given
        let messageDisplayOptions = MessageDisplayOptions(
            showOutgoingMessageAvatar: true
        )
        let messageListConfig = MessageListConfig(messageDisplayOptions: messageDisplayOptions)
        let utils = Utils(messageListConfig: messageListConfig)
        streamChat = StreamChat(chatClient: chatClient, utils: utils)

        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Outgoing message with avatar",
            author: .mock(id: Self.currentUserId, name: "Martin"),
            isSentByCurrentUser: true
        )

        // When
        let view = testMessageViewContainer(message: message)

        // Then
        AssertSnapshot(view, size: CGSize(width: 375, height: 200))
    }

    func test_messageItemView_incomingAvatarHidden_snapshot() {
        // Given
        let messageDisplayOptions = MessageDisplayOptions(
            showIncomingMessageAvatar: false
        )
        let messageListConfig = MessageListConfig(messageDisplayOptions: messageDisplayOptions)
        let utils = Utils(messageListConfig: messageListConfig)
        streamChat = StreamChat(chatClient: chatClient, utils: utils)

        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Incoming message without avatar",
            author: .mock(id: .unique, name: "Alice")
        )

        // When
        let view = testMessageViewContainer(message: message)

        // Then
        AssertSnapshot(view, size: CGSize(width: 375, height: 200))
    }

    // MARK: - Top reactions + annotations

    func test_messageContainerView_topReactionsWithPinnedAnnotation_snapshot() {
        // Given
        let reactions: [MessageReactionType: Int] = [
            MessageReactionType(rawValue: "like"): 2,
            MessageReactionType(rawValue: "love"): 1
        ]
        let channel = ChatChannel.mockNonDMChannel()
        let message = ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Pinned message with reactions",
            author: .mock(id: .unique, name: "Martin"),
            reactionScores: reactions,
            reactionCounts: reactions,
            pinDetails: MessagePinDetails(
                pinnedAt: Date(),
                pinnedBy: .mock(id: .unique, name: "Martin"),
                expiresAt: nil
            )
        )

        // When
        let view = testMessageViewContainer(message: message, channel: channel)

        // Then
        AssertSnapshot(view, size: CGSize(width: 375, height: 200))
    }

    func test_messageContainerView_topReactionsWithThreadReplyAnnotation_snapshot() {
        // Given
        let reactions: [MessageReactionType: Int] = [
            MessageReactionType(rawValue: "like"): 1
        ]
        let channel = ChatChannel.mockNonDMChannel()
        let message = ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Thread reply shown in channel",
            author: .mock(id: .unique, name: "Martin"),
            parentMessageId: .unique,
            showReplyInChannel: true,
            reactionScores: reactions,
            reactionCounts: reactions
        )

        // When
        let view = testMessageViewContainer(message: message, channel: channel)

        // Then
        AssertSnapshot(view, size: CGSize(width: 375, height: 200))
    }

    func test_messageContainerView_topReactionsWithReminderAnnotation_snapshot() {
        // Given
        let reactions: [MessageReactionType: Int] = [
            MessageReactionType(rawValue: "like"): 1
        ]
        let channel = ChatChannel.mockNonDMChannel(
            config: .mock(messageRemindersEnabled: true)
        )
        let message = ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Message with reminder and reactions",
            author: .mock(id: .unique, name: "Martin"),
            reactionScores: reactions,
            reactionCounts: reactions,
            reminder: MessageReminderInfo(
                remindAt: Date().addingTimeInterval(3600),
                createdAt: Date(),
                updatedAt: Date()
            )
        )

        // When
        let view = testMessageViewContainer(message: message, channel: channel)

        // Then
        AssertSnapshot(view, size: CGSize(width: 375, height: 200))
    }

    // MARK: - Swipe to reply indicator

    func test_swipeToReplyIndicator_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Swipe to reply message",
            author: .mock(id: .unique, name: "Martin"),
            localState: nil
        )
        let channel = ChatChannel.mockDMChannel(config: .mock(repliesEnabled: true))
        let offset: CGFloat = 50

        let view = testMessageViewContainer(message: message, channel: channel)
            .modifier(SwipeToReplyModifier(
                message: message,
                channel: channel,
                isSwipeToQuoteReplyPossible: true,
                quotedMessage: .constant(nil),
                initialOffsetX: offset
            )
            )
            .offset(x: offset)

        // Then
        AssertSnapshot(view, size: CGSize(width: 375, height: 200))
    }

    // MARK: - Single media without caption (sharp tail corner)

    func test_singleImageNoCaption_outgoing_firstInGroup_snapshot() {
        // Given
        let attachments = ChatChannelTestHelpers.imageAttachments(
            count: 1,
            originalWidth: 1600,
            originalHeight: 1200
        )
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: Self.currentUserId, name: "Martin"),
            attachments: attachments,
            isSentByCurrentUser: true
        )

        // When
        let view = testMessageViewContainer(message: message, height: 300)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_singleImageNoCaption_incoming_firstInGroup_snapshot() {
        // Given
        let attachments = ChatChannelTestHelpers.imageAttachments(
            count: 1,
            originalWidth: 1600,
            originalHeight: 1200
        )
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique, name: "Alice"),
            attachments: attachments,
            isSentByCurrentUser: false
        )

        // When
        let view = testMessageViewContainer(message: message, channel: .mockNonDMChannel(), height: 300)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_singleImageNoCaption_notFirstInGroup_snapshot() {
        // Given
        let attachments = ChatChannelTestHelpers.imageAttachments(
            count: 1,
            originalWidth: 1600,
            originalHeight: 1200
        )
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: Self.currentUserId, name: "Martin"),
            attachments: attachments,
            isSentByCurrentUser: true
        )

        // When
        let view = testMessageViewContainer(message: message, height: 300, showsAllInfo: false)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_singleImageWithCaption_outgoing_snapshot() {
        // Given
        let attachments = ChatChannelTestHelpers.imageAttachments(
            count: 1,
            originalWidth: 1600,
            originalHeight: 1200
        )
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Photo caption",
            author: .mock(id: Self.currentUserId, name: "Martin"),
            attachments: attachments,
            isSentByCurrentUser: true
        )

        // When
        let view = testMessageViewContainer(message: message, height: 300)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_singleVideoNoCaption_outgoing_firstInGroup_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: Self.currentUserId, name: "Martin"),
            attachments: ChatChannelTestHelpers.videoAttachments,
            isSentByCurrentUser: true
        )

        // When
        let view = testMessageViewContainer(message: message, height: 300)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_singleImageNoCaption_portrait_outgoing_snapshot() {
        // Given
        let attachments = ChatChannelTestHelpers.imageAttachments(
            count: 1,
            originalWidth: 1200,
            originalHeight: 1600
        )
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: Self.currentUserId, name: "Martin"),
            attachments: attachments,
            isSentByCurrentUser: true
        )

        // When
        let view = testMessageViewContainer(message: message, height: 300)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    // MARK: - private

    func testMessageViewContainer(
        message: ChatMessage,
        channel: ChatChannel? = nil,
        shownAsPreview: Bool = false,
        messageViewModel: MessageViewModel? = nil,
        highlightedMessageId: String? = nil,
        height: CGFloat = 200,
        showsAllInfo: Bool = true
    ) -> some View {
        let channelOrMock = channel ?? .mockDMChannel()
        return MessageItemView(
            factory: DefaultViewFactory.shared,
            channel: channelOrMock,
            message: message,
            width: defaultScreenSize.width,
            showsAllInfo: showsAllInfo,
            shownAsPreview: shownAsPreview,
            isInThread: false,
            isLast: false,
            scrolledId: .constant(nil),
            quotedMessage: .constant(nil),
            onLongPress: { _ in },
            viewModel: messageViewModel ?? MessageViewModel(message: message, channel: channelOrMock)
        )
        .environment(\.highlightedMessageId, highlightedMessageId)
        .frame(width: 375, height: height)
    }

    private func assertMediaGallerySnapshot(
        orientation: MediaGalleryOrientation,
        count: Int,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line
    ) {
        let dimensions: (width: Double, height: Double) = {
            switch orientation {
            case .landscape: return (1600, 1200)
            case .portrait: return (1200, 1600)
            case .square: return (1200, 1200)
            }
        }()

        let attachments = ChatChannelTestHelpers.imageAttachments(
            count: count,
            originalWidth: dimensions.width,
            originalHeight: dimensions.height
        )

        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            attachments: attachments
        )

        let view = testMessageViewContainer(message: message, height: 300)
        assertSnapshot(
            matching: view,
            as: .image(perceptualPrecision: precision),
            file: file,
            testName: testName,
            line: line
        )
    }
}

class MessageViewModel_Mock: MessageViewModel {
    var mockOriginalTextShown: Bool = false

    override var originalTextShown: Bool {
        mockOriginalTextShown
    }
}
