//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

@MainActor class MessageActions_Tests: StreamChatTestCase {
    func test_messageActions_currentUserDefault() {
        // Given
        let channel = mockDMChannel
        let message = ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Test",
            author: .mock(id: chatClient.currentUserId!),
            isSentByCurrentUser: true
        )
        let factory = DefaultViewFactory.shared

        // When
        let messageActions = MessageAction.defaultActions(
            factory: factory,
            for: message,
            channel: channel,
            chatClient: chatClient,
            onFinish: { _ in },
            onError: { _ in }
        )

        // Then
        XCTAssert(messageActions.count == 6)
        XCTAssert(messageActions[0].title == "Reply")
        XCTAssert(messageActions[1].title == "Thread Reply")
        XCTAssert(messageActions[2].title == "Pin to conversation")
        XCTAssert(messageActions[3].title == "Copy Message")
        XCTAssert(messageActions[4].title == "Edit Message")
        XCTAssert(messageActions[5].title == "Delete Message")
    }

    func test_messageActions_otherUserDefault() {
        // Given
        let channel = mockDMChannel
        let message = ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Test",
            author: .mock(id: .unique),
            isSentByCurrentUser: false
        )
        let factory = DefaultViewFactory.shared

        // When
        let messageActions = MessageAction.defaultActions(
            factory: factory,
            for: message,
            channel: channel,
            chatClient: chatClient,
            onFinish: { _ in },
            onError: { _ in }
        )

        // Then
        XCTAssert(messageActions.count == 6)
        XCTAssert(messageActions[0].title == "Reply")
        XCTAssert(messageActions[1].title == "Thread Reply")
        XCTAssert(messageActions[2].title == "Pin to conversation")
        XCTAssert(messageActions[3].title == "Copy Message")
        XCTAssert(messageActions[4].title == "Mark Unread")
        XCTAssert(messageActions[5].title == "Mute User")
    }

    func test_messageActions_otherUserDefaultReadEventsDisabled() {
        // Given
        let channel = ChatChannel.mockDMChannel(ownCapabilities: [.sendMessage, .uploadFile, .pinMessage])
        let message = ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Test",
            author: .mock(id: .unique),
            isSentByCurrentUser: false
        )
        let factory = DefaultViewFactory.shared

        // When
        let messageActions = MessageAction.defaultActions(
            factory: factory,
            for: message,
            channel: channel,
            chatClient: chatClient,
            onFinish: { _ in },
            onError: { _ in }
        )

        // Then
        XCTAssert(messageActions.count == 5)
        XCTAssert(messageActions[0].title == "Reply")
        XCTAssert(messageActions[1].title == "Thread Reply")
        XCTAssert(messageActions[2].title == "Pin to conversation")
        XCTAssert(messageActions[3].title == "Copy Message")
        XCTAssert(messageActions[4].title == "Mute User")
    }

    func test_messageActions_otherUserDefaultBlockingEnabled() {
        // Given
        streamChat = StreamChat(
            chatClient: chatClient,
            utils: .init(messageListConfig: .init(userBlockingEnabled: true))
        )
        let channel = mockDMChannel
        let message = ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Test",
            author: .mock(id: .unique),
            isSentByCurrentUser: false
        )
        let factory = DefaultViewFactory.shared

        // When
        let messageActions = MessageAction.defaultActions(
            factory: factory,
            for: message,
            channel: channel,
            chatClient: chatClient,
            onFinish: { _ in },
            onError: { _ in }
        )

        // Then
        XCTAssert(messageActions.count == 7)
        XCTAssert(messageActions[0].title == "Reply")
        XCTAssert(messageActions[1].title == "Thread Reply")
        XCTAssert(messageActions[2].title == "Pin to conversation")
        XCTAssert(messageActions[3].title == "Copy Message")
        XCTAssert(messageActions[4].title == "Mark Unread")
        XCTAssert(messageActions[5].title == "Mute User")
        XCTAssert(messageActions[6].title == "Block User")
    }

    func test_messageActions_currentUserPinned() {
        // Given
        let channel = mockDMChannel
        let message = ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Test",
            author: .mock(id: chatClient.currentUserId!),
            isSentByCurrentUser: true,
            pinDetails:
            MessagePinDetails(
                pinnedAt: Date(),
                pinnedBy: .mock(id: .unique),
                expiresAt: nil
            )
        )
        let factory = DefaultViewFactory.shared

        // When
        let messageActions = MessageAction.defaultActions(
            factory: factory,
            for: message,
            channel: channel,
            chatClient: chatClient,
            onFinish: { _ in },
            onError: { _ in }
        )

        // Then
        XCTAssert(messageActions.count == 6)
        XCTAssert(messageActions[0].title == "Reply")
        XCTAssert(messageActions[1].title == "Thread Reply")
        XCTAssert(messageActions[2].title == "Unpin from conversation")
        XCTAssert(messageActions[3].title == "Copy Message")
        XCTAssert(messageActions[4].title == "Edit Message")
        XCTAssert(messageActions[5].title == "Delete Message")
    }

    func test_messageActions_messageNotSent() {
        // Given
        let channel = mockDMChannel
        let message = ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Test",
            author: .mock(id: chatClient.currentUserId!),
            localState: .sendingFailed
        )
        let factory = DefaultViewFactory.shared

        // When
        let messageActions = MessageAction.defaultActions(
            factory: factory,
            for: message,
            channel: channel,
            chatClient: chatClient,
            onFinish: { _ in },
            onError: { _ in }
        )

        // Then
        XCTAssert(messageActions.count == 3)
        XCTAssert(messageActions[0].title == "Resend")
        XCTAssert(messageActions[1].title == "Edit Message")
        XCTAssert(messageActions[2].title == "Delete Message")
    }

    func test_messageActions_attachmentFailure() {
        // Given
        let channel = mockDMChannel
        let attachments = [
            ChatMessageImageAttachment.mock(
                id: .unique,
                localState: .uploadingFailed
            )
            .asAnyAttachment
        ]
        let message = ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Test",
            author: .mock(id: chatClient.currentUserId!),
            attachments: attachments,
            localState: .pendingSend
        )
        let factory = DefaultViewFactory.shared

        // When
        let messageActions = MessageAction.defaultActions(
            factory: factory,
            for: message,
            channel: channel,
            chatClient: chatClient,
            onFinish: { _ in },
            onError: { _ in }
        )

        // Then
        XCTAssert(messageActions.count == 2)
        XCTAssert(messageActions[0].title == "Edit Message")
        XCTAssert(messageActions[1].title == "Delete Message")
    }
    
    func test_messageActions_bouncedMessage() {
        // Given
        let channel = mockDMChannel
        let moderationDetails = MessageModerationDetails(
            originalText: "Some text",
            action: .bounce,
            textHarms: nil,
            imageHarms: nil,
            blocklistMatched: nil,
            semanticFilterMatched: nil,
            platformCircumvented: nil
        )
        let message = ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Test",
            author: .mock(id: chatClient.currentUserId!),
            isBounced: true,
            moderationsDetails: moderationDetails
        )
        let factory = DefaultViewFactory.shared

        // When
        let messageActions = MessageAction.defaultActions(
            factory: factory,
            for: message,
            channel: channel,
            chatClient: chatClient,
            onFinish: { _ in },
            onError: { _ in }
        )

        // Then
        XCTAssert(messageActions.count == 4)
        XCTAssert(messageActions[0].title == "Message was bounced")
        XCTAssert(messageActions[1].title == "Resend")
        XCTAssert(messageActions[2].title == "Edit Message")
        XCTAssert(messageActions[3].title == "Delete Message")
    }

    func test_messageActions_giphyMessage_shouldNotContainEditActtion() throws {
        // Given
        let channel = mockDMChannel
        let message = try ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Test",
            author: .mock(id: chatClient.currentUserId!),
            attachments: [
                .dummy(
                    type: .giphy,
                    payload: JSONEncoder().encode(GiphyAttachmentPayload(
                        title: "Test",
                        previewURL: URL(string: "Url")!
                    ))
                )
            ],
            isSentByCurrentUser: true
        )
        let factory = DefaultViewFactory.shared

        // When
        let messageActions = MessageAction.defaultActions(
            factory: factory,
            for: message,
            channel: channel,
            chatClient: chatClient,
            onFinish: { _ in },
            onError: { _ in }
        )

        // Then
        XCTAssertEqual(messageActions.count, 5)
        XCTAssertEqual(messageActions[0].title, "Reply")
        XCTAssertEqual(messageActions[1].title, "Thread Reply")
        XCTAssertEqual(messageActions[2].title, "Pin to conversation")
        XCTAssertEqual(messageActions[3].title, "Copy Message")
        XCTAssertEqual(messageActions[4].title, "Delete Message")
    }
    
    func test_messageActions_currentUser_editingDisabledWhenNoUpdateCapabilities() {
        // Given
        let channel = ChatChannel.mockDMChannel(ownCapabilities: [])
        let message = ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Test",
            author: .mock(id: chatClient.currentUserId!),
            isSentByCurrentUser: true
        )
        let factory = DefaultViewFactory.shared
        
        // When
        let messageActions = MessageAction.defaultActions(
            factory: factory,
            for: message,
            channel: channel,
            chatClient: chatClient,
            onFinish: { _ in },
            onError: { _ in }
        )
        
        // Then
        XCTAssertFalse(messageActions.contains(where: { $0.title == "Edit Message" }))
    }
    
    func test_messageActions_otherUser_editingEnabledWhenUpdateAnyMessageCapability() {
        // Given
        let channel = ChatChannel.mockDMChannel(ownCapabilities: [.updateAnyMessage])
        let message = ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Test",
            author: .mock(id: .unique),
            isSentByCurrentUser: false
        )
        let factory = DefaultViewFactory.shared
        
        // When
        let messageActions = MessageAction.defaultActions(
            factory: factory,
            for: message,
            channel: channel,
            chatClient: chatClient,
            onFinish: { _ in },
            onError: { _ in }
        )
        
        // Then
        XCTAssertTrue(messageActions.contains(where: { $0.title == "Edit Message" }))
    }
    
    func test_messageActions_otherUser_deletingEnabledWhenDeleteAnyMessageCapability() {
        // Given
        let channel = ChatChannel.mockDMChannel(ownCapabilities: [.deleteAnyMessage])
        let message = ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Test",
            author: .mock(id: .unique),
            isSentByCurrentUser: false
        )
        let factory = DefaultViewFactory.shared
        
        // When
        let messageActions = MessageAction.defaultActions(
            factory: factory,
            for: message,
            channel: channel,
            chatClient: chatClient,
            onFinish: { _ in },
            onError: { _ in }
        )
        
        // Then
        XCTAssertTrue(messageActions.contains(where: { $0.title == "Delete Message" }))
    }

    // MARK: - Private
    
    private var mockDMChannel: ChatChannel {
        ChatChannel.mockDMChannel(
            ownCapabilities: [
                .deleteOwnMessage,
                .updateOwnMessage,
                .sendMessage,
                .uploadFile,
                .pinMessage,
                .readEvents
            ]
        )
    }
}
