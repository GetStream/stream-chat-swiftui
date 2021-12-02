//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import XCTest
@testable import StreamChatSwiftUI
@testable import StreamChat

class ChatChannelTestHelpers {
    
    static func makeChannelController(
        chatClient: ChatClient,
        messages: [ChatMessage] = []
    ) -> ChatChannelController_Mock {
        let channel = ChatChannel.mockDMChannel()
        let channelQuery = ChannelQuery(cid: channel.cid)
        let channelListQuery = ChannelListQuery(filter: .containMembers(userIds: [chatClient.currentUserId!]))
        let channelController = ChatChannelController_Mock(
            channelQuery: channelQuery,
            channelListQuery: channelListQuery,
            client: chatClient
        )
        var channelMessages = messages
        if channelMessages.isEmpty {
            let message = ChatMessage.mock(
                id: .unique,
                cid: channel.cid,
                text: "Test message",
                author: ChatUser.mock(id: chatClient.currentUserId!)
            )
            channelMessages = [message]
        }

        channelController.simulateInitial(channel: channel, messages: channelMessages, state: .initialized)
        return channelController
    }
    
}
