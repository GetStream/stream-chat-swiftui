//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import XCTest

class MessageListViewAvatars_Tests: StreamChatTestCase {

    func test_messageListView_defaultDMChannel() {
        // Given
        setupConfig(showAvatars: true, showAvatarsInGroups: nil)
        let channel = ChatChannel.mockDMChannel()

        // When
        let view = makeMessageListView(with: channel).applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageListView_defaultGroupsChannel() {
        // Given
        setupConfig(showAvatars: true, showAvatarsInGroups: nil)
        let channel = ChatChannel.mockNonDMChannel()

        // When
        let view = makeMessageListView(with: channel).applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageListView_dmChannelAvatarsOff() {
        // Given
        setupConfig(showAvatars: false, showAvatarsInGroups: nil)
        let channel = ChatChannel.mockDMChannel()

        // When
        let view = makeMessageListView(with: channel).applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageListView_groupsChannelAvatarsOff() {
        // Given
        setupConfig(showAvatars: true, showAvatarsInGroups: false)
        let channel = ChatChannel.mockNonDMChannel()

        // When
        let view = makeMessageListView(with: channel).applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    private func setupConfig(showAvatars: Bool, showAvatarsInGroups: Bool?) {
        let messageDisplayOptions = MessageDisplayOptions(
            showAvatars: showAvatars,
            showAvatarsInGroups: showAvatarsInGroups
        )
        let messageListConfig = MessageListConfig(messageDisplayOptions: messageDisplayOptions)
        let utils = Utils(messageListConfig: messageListConfig)
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }

    private func makeMessageListView(with channel: ChatChannel) -> MessageListView<DefaultViewFactory> {
        let temp = [ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Test",
            author: .mock(id: .unique)
        )]
        let messages = LazyCachedMapCollection(source: temp, map: { $0 })
        let messageListView = MessageListView(
            factory: DefaultViewFactory.shared,
            channel: channel,
            messages: messages,
            messagesGroupingInfo: [:],
            scrolledId: .constant(nil),
            showScrollToLatestButton: .constant(false),
            quotedMessage: .constant(nil),
            currentDateString: nil,
            listId: "listId",
            isMessageThread: false,
            shouldShowTypingIndicator: false,
            onMessageAppear: { _ in },
            onScrollToBottom: {},
            onLongPress: { _ in }
        )

        return messageListView
    }
}
