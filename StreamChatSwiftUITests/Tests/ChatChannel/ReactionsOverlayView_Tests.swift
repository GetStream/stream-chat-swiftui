//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class ReactionsOverlayView_Tests: StreamChatTestCase {
    private let testMessage = ChatMessage.mock(
        id: "test",
        cid: .unique,
        text: "This is a test message 1",
        author: .mock(id: "test", name: "martin")
    )

    private let messageDisplayInfo = MessageDisplayInfo(
        message: .mock(id: .unique, cid: .unique, text: "test", author: .mock(id: .unique)),
        frame: CGRect(x: 0, y: 200, width: defaultScreenSize.width, height: 70),
        contentWidth: 240,
        isFirst: true
    )

    private let overlayImage = UIColor
        .black
        .withAlphaComponent(0.2)
        .image(defaultScreenSize)

    func test_reactionsOverlayView_snapshot() {
        // Given
        let view = OverlayHostView {
            ReactionsOverlayView(
                factory: DefaultViewFactory.shared,
                channel: .mockDMChannel(),
                currentSnapshot: self.overlayImage,
                messageDisplayInfo: self.messageDisplayInfo,
                onBackgroundTap: {},
                onActionExecuted: { _ in }
            )
        }

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_reactionsOverlayView_noReactions() {
        // Given
        let config = ChannelConfig(reactionsEnabled: false)
        let channel = ChatChannel.mockDMChannel(config: config)
        let view = OverlayHostView {
            ReactionsOverlayView(
                factory: DefaultViewFactory.shared,
                channel: channel,
                currentSnapshot: self.overlayImage,
                messageDisplayInfo: self.messageDisplayInfo,
                onBackgroundTap: {},
                onActionExecuted: { _ in }
            )
        }

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_reactionsOverlayView_usersReactions() {
        // Given
        let author = ChatUser.mock(id: .unique, name: "Martin")
        let reaction = ChatMessageReaction(
            id: .unique,
            type: .init(rawValue: "love"),
            score: 1,
            createdAt: Date(),
            updatedAt: Date(),
            author: author,
            extraData: [:]
        )
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test",
            author: .mock(id: .unique),
            latestReactions: [reaction]
        )
        let messageDisplayInfo = MessageDisplayInfo(
            message: message,
            frame: CGRect(x: 0, y: 200, width: defaultScreenSize.width, height: 70),
            contentWidth: 240,
            isFirst: true,
            showsMessageActions: false
        )

        // When
        let channel = ChatChannel.mockDMChannel()
        let view = OverlayHostView {
            ReactionsOverlayView(
                factory: DefaultViewFactory.shared,
                channel: channel,
                currentSnapshot: self.overlayImage,
                messageDisplayInfo: messageDisplayInfo,
                onBackgroundTap: {},
                onActionExecuted: { _ in }
            )
        }

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_reactionsOverlay_veryLongMessage() {
        // Given
        let messagePart = "this is some random message text repeated several times "
        var messageText = ""
        for _ in 0..<10 {
            messageText += messagePart
        }
        let testMessage = ChatMessage.mock(
            id: "test",
            cid: .unique,
            text: messageText,
            author: .mock(id: "test", name: "martin")
        )
        let messageDisplayInfo = MessageDisplayInfo(
            message: testMessage,
            frame: CGRect(x: 0, y: 200, width: defaultScreenSize.width, height: defaultScreenSize.height * 2),
            contentWidth: 240,
            isFirst: true
        )

        // When
        let view = OverlayHostView {
            ReactionsOverlayView(
                factory: DefaultViewFactory.shared,
                channel: .mockDMChannel(ownCapabilities: [.sendMessage, .uploadFile, .pinMessage, .readEvents]),
                currentSnapshot: self.overlayImage,
                messageDisplayInfo: messageDisplayInfo,
                onBackgroundTap: {},
                onActionExecuted: { _ in }
            )
        }

        // Then
        // Pin the snapshot to the default screen size so layout does not try to
        // measure the unconstrained tall message via sizeThatFits, which can hang on CI.
        assertSnapshot(
            matching: view,
            as: .image(
                perceptualPrecision: precision,
                layout: .fixed(
                    width: defaultScreenSize.width,
                    height: defaultScreenSize.height
                )
            )
        )
    }

    func test_reactionsOverlayView_accessibilityExtraExtraExtraLarge() {
        // Given an incoming message rendered at the maximum accessibility text size, to verify
        // the whole overlay (reactions, message and actions) stays within the screen bounds.
        let messageDisplayInfo = MessageDisplayInfo(
            message: .mock(id: .unique, cid: .unique, text: "Hey", author: .mock(id: .unique)),
            frame: CGRect(x: 0, y: 200, width: defaultScreenSize.width, height: 90),
            contentWidth: 120,
            isFirst: true
        )
        let view = OverlayHostView {
            ReactionsOverlayView(
                factory: DefaultViewFactory.shared,
                channel: .mockDMChannel(),
                currentSnapshot: self.overlayImage,
                messageDisplayInfo: messageDisplayInfo,
                onBackgroundTap: {},
                onActionExecuted: { _ in }
            )
        }

        // Then
        let traits = UITraitCollection(traitsFrom: [
            UITraitCollection(displayScale: 1),
            UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge),
            UITraitCollection(userInterfaceStyle: .light)
        ])
        assertSnapshot(
            matching: view,
            as: .image(
                perceptualPrecision: precision,
                layout: .fixed(width: defaultScreenSize.width, height: defaultScreenSize.height),
                traits: traits
            )
        )
    }

    func test_reactionsOverlayView_actionsMenu_accessibilityExtraExtraExtraLarge() {
        // Given an outgoing (right-aligned) message with a narrow captured frame, so the
        // actions menu naturally sizes wider than the message bubble at large text sizes.
        let currentUserId = StreamChatTestCase.currentUserId
        let testMessage = ChatMessage.mock(
            id: "test",
            cid: .unique,
            text: "test",
            author: .mock(id: currentUserId, name: "martin"),
            isSentByCurrentUser: true
        )
        let messageDisplayInfo = MessageDisplayInfo(
            message: testMessage,
            frame: CGRect(x: defaultScreenSize.width - 150, y: 200, width: 150, height: 70),
            contentWidth: 120,
            isFirst: true
        )
        let channel = ChatChannel.mockDMChannel(
            ownCapabilities: [.sendMessage, .uploadFile, .pinMessage, .updateOwnMessage, .deleteOwnMessage, .readEvents]
        )
        let view = OverlayHostView {
            ReactionsOverlayView(
                factory: DefaultViewFactory.shared,
                channel: channel,
                currentSnapshot: self.overlayImage,
                messageDisplayInfo: messageDisplayInfo,
                onBackgroundTap: {},
                onActionExecuted: { _ in }
            )
        }

        // Then
        let traits = UITraitCollection(traitsFrom: [
            UITraitCollection(displayScale: 1),
            UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge),
            UITraitCollection(userInterfaceStyle: .light)
        ])
        assertSnapshot(
            matching: view,
            as: .image(
                perceptualPrecision: precision,
                layout: .fixed(width: defaultScreenSize.width, height: defaultScreenSize.height),
                traits: traits
            )
        )
    }

    func test_reactionAnimatableView_snapshot() {
        // Given
        let message = ChatMessage.mock(text: "Test message")
        let reactions: [MessageReactionType] = [.init(rawValue: "love"), .init(rawValue: "like")]

        // When
        let view = ReactionAnimatableView(
            message: message,
            reaction: .init(rawValue: "love"),
            reactions: reactions,
            animationStates: .constant([1.0, 1.0]),
            onReactionTap: { _ in }
        )
        .frame(width: 24, height: 24)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_reactionsOverlayContainer_snapshot() {
        // Given
        let message = ChatMessage.mock(text: "Test message")

        // When
        let view = ReactionsOverlayContainer(
            message: message,
            contentRect: .init(x: -60, y: 200, width: 300, height: 300),
            onReactionTap: { _ in },
            onMoreReactionsTap: {}
        )

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_reactionsAnimatableView_snapshot() {
        // Given
        let message = ChatMessage.mock(text: "Test message")
        let reactions: [MessageReactionType] = [.init(rawValue: "love"), .init(rawValue: "like")]

        // When
        let view = ReactionsAnimatableView(
            message: message,
            reactions: reactions,
            onReactionTap: { _ in },
            onMoreReactionsTap: {}
        )

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_reactionsAnimatableView_accessibilityExtraExtraExtraLarge() {
        // Given
        let message = ChatMessage.mock(text: "Test message")
        let reactions: [MessageReactionType] = [.init(rawValue: "love"), .init(rawValue: "like")]

        // When
        let view = ReactionsAnimatableView(
            message: message,
            reactions: reactions,
            onReactionTap: { _ in },
            onMoreReactionsTap: {}
        )

        // Then
        let traits = UITraitCollection(traitsFrom: [
            UITraitCollection(displayScale: 1),
            UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge),
            UITraitCollection(userInterfaceStyle: .light)
        ])
        assertSnapshot(
            matching: view,
            as: .image(perceptualPrecision: precision, layout: .sizeThatFits, traits: traits)
        )
    }

    func test_reactionsOverlayView_translated() {
        // Given
        let testMessage = ChatMessage.mock(
            id: "test",
            cid: .unique,
            text: "Hello",
            author: .mock(id: "test", name: "martin"),
            translations: [.portuguese: "Olá"]
        )
        let messageDisplayInfo = MessageDisplayInfo(
            message: testMessage,
            frame: CGRect(x: 0, y: 200, width: defaultScreenSize.width, height: 85),
            contentWidth: 240,
            isFirst: true
        )
        let channel = ChatChannel.mock(cid: .unique, membership: .mock(id: "test", language: .portuguese))
        let view = OverlayHostView {
            ReactionsOverlayView(
                factory: DefaultViewFactory.shared,
                channel: channel,
                currentSnapshot: self.overlayImage,
                messageDisplayInfo: messageDisplayInfo,
                onBackgroundTap: {},
                onActionExecuted: { _ in }
            )
        }

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_reactionsOverlayView_allAnnotations() {
        // Given
        let currentUserId = StreamChatTestCase.currentUserId
        streamChat = StreamChat(chatClient: chatClient, utils: Utils(
            messageListConfig: .init(messageDisplayOptions: MessageDisplayOptions(showOriginalTranslatedButton: true))
        ))

        let config = ChannelConfig(
            reactionsEnabled: true,
            readEventsEnabled: true,
            messageRemindersEnabled: true
        )
        let channel = ChatChannel.mock(
            cid: .unique,
            config: config,
            ownCapabilities: [.sendMessage, .uploadFile, .readEvents],
            membership: .mock(id: "test", language: .portuguese)
        )

        let readUser = ChatUser.mock(id: .unique, name: "reader")
        let testMessage = ChatMessage.mock(
            id: "test",
            cid: channel.cid,
            text: "Hey, did you get a chance to look at the venue options?",
            author: .mock(id: currentUserId, name: "martin"),
            parentMessageId: .unique,
            showReplyInChannel: true,
            replyCount: 3,
            translations: [.portuguese: "Olá, conseguiu ver as opções de local?"],
            threadParticipants: [.mock(id: .unique, name: "alice")],
            isSentByCurrentUser: true,
            pinDetails: MessagePinDetails(
                pinnedAt: Date(),
                pinnedBy: .mock(id: currentUserId, name: "martin"),
                expiresAt: nil
            ),
            readBy: [readUser],
            reminder: MessageReminderInfo(
                remindAt: Date().addingTimeInterval(3600),
                createdAt: Date(),
                updatedAt: Date()
            )
        )
        let messageDisplayInfo = MessageDisplayInfo(
            message: testMessage,
            frame: CGRect(x: 0, y: 650, width: defaultScreenSize.width, height: 200),
            contentWidth: 240,
            isFirst: true
        )

        let view = OverlayHostView {
            ReactionsOverlayView(
                factory: DefaultViewFactory.shared,
                channel: channel,
                currentSnapshot: self.overlayImage,
                messageDisplayInfo: messageDisplayInfo,
                onBackgroundTap: {},
                onActionExecuted: { _ in }
            )
        }

        // Then
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles, size: defaultScreenSize)
    }
}

private struct OverlayHostView<Content: View>: View {
    var content: () -> Content

    var body: some View {
        VStack {
            Spacer()
            Rectangle()
                .frame(width: 200, height: 50)
                .overlay(content().transaction { transaction in
                    transaction.disablesAnimations = true
                })
                
            Spacer()
        }
        .applyDefaultSize()
    }
}
