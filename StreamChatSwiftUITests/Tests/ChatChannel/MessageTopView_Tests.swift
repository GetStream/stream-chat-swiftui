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

@MainActor class MessageTopView_Tests: StreamChatTestCase {
    // MARK: - Pinned

    func test_pinnedAnnotation_snapshot() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Pinned message",
            author: .mock(id: .unique, name: "Martin"),
            pinDetails: MessagePinDetails(
                pinnedAt: Date(),
                pinnedBy: .mock(id: .unique, name: "Martin"),
                expiresAt: nil
            )
        )

        let view = makeAnnotationsView(message: message)

        AssertSnapshot(view, size: CGSize(width: 375, height: 40))
    }

    func test_pinnedByYouAnnotation_snapshot() {
        let currentUserId = StreamChatTestCase.currentUserId
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Pinned by me",
            author: .mock(id: .unique, name: "Martin"),
            pinDetails: MessagePinDetails(
                pinnedAt: Date(),
                pinnedBy: .mock(id: currentUserId, name: "Martin"),
                expiresAt: nil
            )
        )

        let view = makeAnnotationsView(message: message)

        AssertSnapshot(view, size: CGSize(width: 375, height: 40))
    }

    // MARK: - Sent in channel

    func test_sentInChannelAnnotation_snapshot() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Thread reply sent in channel",
            author: .mock(id: .unique),
            parentMessageId: .unique,
            showReplyInChannel: true
        )

        let view = makeAnnotationsView(message: message, isInThread: true)

        AssertSnapshot(view, size: CGSize(width: 375, height: 40))
    }

    // MARK: - Replied to thread

    func test_repliedToThreadAnnotation_snapshot() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message that was replied to in a thread",
            author: .mock(id: .unique),
            parentMessageId: .unique,
            showReplyInChannel: true
        )

        let view = makeAnnotationsView(message: message, isInThread: false)

        AssertSnapshot(view, size: CGSize(width: 375, height: 40))
    }

    // MARK: - Reminder

    func test_reminderAnnotation_snapshot() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message with reminder",
            author: .mock(id: .unique),
            reminder: MessageReminderInfo(
                remindAt: Date().addingTimeInterval(3600),
                createdAt: Date(),
                updatedAt: Date()
            )
        )

        let view = makeAnnotationsView(message: message)

        AssertSnapshot(view, size: CGSize(width: 375, height: 40))
    }

    // MARK: - Translated

    func test_translatedAnnotation_snapshot() {
        streamChat = StreamChat(chatClient: chatClient, utils: Utils(
            messageListConfig: .init(messageDisplayOptions: MessageDisplayOptions(showOriginalTranslatedButton: true))
        ))

        let channel = ChatChannel.mock(
            cid: .unique,
            membership: .mock(id: .unique, language: .spanish)
        )

        let message = ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Hello",
            author: .mock(id: .unique),
            translations: [.spanish: "Hola"]
        )

        let view = makeAnnotationsView(message: message, channel: channel)

        AssertSnapshot(view, size: CGSize(width: 375, height: 40))
    }

    // MARK: - All annotations (not in thread)

    func test_allAnnotations_snapshot() {
        streamChat = StreamChat(chatClient: chatClient, utils: Utils(
            messageListConfig: .init(messageDisplayOptions: MessageDisplayOptions(showOriginalTranslatedButton: true))
        ))

        let channel = ChatChannel.mock(
            cid: .unique,
            membership: .mock(id: .unique, language: .spanish)
        )

        let message = ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Message with all annotations",
            author: .mock(id: .unique),
            parentMessageId: .unique,
            showReplyInChannel: true,
            translations: [.spanish: "Mensaje con todas las anotaciones"],
            pinDetails: MessagePinDetails(
                pinnedAt: Date(),
                pinnedBy: .mock(id: .unique, name: "Martin"),
                expiresAt: nil
            ),
            reminder: MessageReminderInfo(
                remindAt: Date().addingTimeInterval(3600),
                createdAt: Date(),
                updatedAt: Date()
            )
        )

        let view = makeAnnotationsView(message: message, channel: channel, isInThread: false)

        AssertSnapshot(view, size: CGSize(width: 375, height: 140))
    }

    // MARK: - All annotations (in thread)

    func test_allAnnotations_inThread_snapshot() {
        streamChat = StreamChat(chatClient: chatClient, utils: Utils(
            messageListConfig: .init(messageDisplayOptions: MessageDisplayOptions(showOriginalTranslatedButton: true))
        ))

        let channel = ChatChannel.mock(
            cid: .unique,
            membership: .mock(id: .unique, language: .spanish)
        )

        let message = ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Message with all annotations in thread",
            author: .mock(id: .unique),
            parentMessageId: .unique,
            showReplyInChannel: true,
            translations: [.spanish: "Mensaje con todas las anotaciones en hilo"],
            pinDetails: MessagePinDetails(
                pinnedAt: Date(),
                pinnedBy: .mock(id: .unique, name: "Martin"),
                expiresAt: nil
            ),
            reminder: MessageReminderInfo(
                remindAt: Date().addingTimeInterval(3600),
                createdAt: Date(),
                updatedAt: Date()
            )
        )

        let view = makeAnnotationsView(message: message, channel: channel, isInThread: true)

        AssertSnapshot(view, size: CGSize(width: 375, height: 140))
    }

    // MARK: - Helpers

    private func makeAnnotationsView(
        message: ChatMessage,
        channel: ChatChannel? = nil,
        isInThread: Bool = false
    ) -> some View {
        let ch = channel ?? .mockDMChannel()
        let viewModel = MessageViewModel(message: message, channel: ch, isInThread: isInThread)
        return MessageTopView(
            message: message,
            channel: ch,
            messageViewModel: viewModel
        )
        .frame(width: 375)
    }
}
