//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class MessageListView_Tests: XCTestCase {

    private var chatClient: ChatClient = {
        let client = ChatClient.mock()
        client.currentUserId = .unique
        return client
    }()
    
    private var streamChat: StreamChat?
        
    override func setUp() {
        super.setUp()
        streamChat = StreamChat(chatClient: chatClient)
    }
    
    func test_messageListView_withReactions() {
        // Given
        let channelConfig = ChannelConfig(reactionsEnabled: true)
        let messageListView = makeMessageListView(channelConfig: channelConfig)
            .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)
        
        // Then
        assertSnapshot(matching: messageListView, as: .image)
    }
    
    func test_messageListView_noReactions() {
        // Given
        let channelConfig = ChannelConfig(reactionsEnabled: false)
        let messageListView = makeMessageListView(channelConfig: channelConfig)
            .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)
        
        // Then
        assertSnapshot(matching: messageListView, as: .image)
    }
    
    // MARK: - private
    
    private func makeMessageListView(channelConfig: ChannelConfig) -> MessageListView<DefaultViewFactory> {
        let reactions = [MessageReactionType(rawValue: "like"): 2]
        let channel = ChatChannel.mockDMChannel(config: channelConfig)
        let temp = [ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Test",
            author: .mock(id: .unique),
            reactionScores: reactions
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
            onMessageAppear: { _ in },
            onScrollToBottom: {},
            onLongPress: { _ in }
        )
        
        return messageListView
    }
}
