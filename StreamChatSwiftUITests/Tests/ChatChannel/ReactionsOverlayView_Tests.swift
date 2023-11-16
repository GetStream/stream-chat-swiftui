//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class ReactionsOverlayView_Tests: StreamChatTestCase {
    
    private static let screenSize = CGSize(width: 393, height: 852)

    private let testMessage = ChatMessage.mock(
        id: "test",
        cid: .unique,
        text: "This is a test message 1",
        author: .mock(id: "test", name: "martin")
    )

    private let messageDisplayInfo = MessageDisplayInfo(
        message: .mock(id: .unique, cid: .unique, text: "test", author: .mock(id: .unique)),
        frame: CGRect(x: 44, y: 200, width: 80, height: 50),
        contentWidth: 200,
        isFirst: true
    )

    private let overlayImage = UIColor
        .black
        .withAlphaComponent(0.2)
        .image(screenSize)

    func test_reactionsOverlayView_snapshot() {
        // Given
        let view = VerticallyCenteredView {
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
        let view = VerticallyCenteredView {
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
            frame: CGRect(x: 44, y: 200, width: 80, height: 50),
            contentWidth: 200,
            isFirst: true,
            showsMessageActions: false
        )

        // When
        let channel = ChatChannel.mockDMChannel()
        let view = VerticallyCenteredView {
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
            frame: CGRect(x: 44, y: 105, width: defaultScreenSize.width - 60, height: defaultScreenSize.height * 2),
            contentWidth: 200,
            isFirst: true
        )

        // When
        let view = VerticallyCenteredView {
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
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
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
            onReactionTap: { _ in }
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
            onReactionTap: { _ in }
        )

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_chatMessage_reactionOffsetCurrentUser() {
        // Given
        let message = ChatMessage.mock(text: "Test message", isSentByCurrentUser: true)

        // When
        let offset = message.reactionOffsetX(
            for: .init(origin: .zero, size: .init(width: 50, height: 50)),
            reactionsSize: 25
        )

        // Then
        XCTAssert(offset == -12.5)
    }

    func test_chatMessage_reactionOffsetOtherUser() {
        // Given
        let message = ChatMessage.mock(text: "Test message", isSentByCurrentUser: false)

        // When
        let offset = message.reactionOffsetX(
            for: .init(origin: .zero, size: .init(width: 50, height: 50)),
            reactionsSize: 25
        )

        // Then
        XCTAssert(offset == 12.5)
    }
}

struct VerticallyCenteredView<Content: View>: View {

    var content: () -> Content

    var body: some View {
        VStack {
            Spacer()
            content()
            Spacer()
        }
    }
}
