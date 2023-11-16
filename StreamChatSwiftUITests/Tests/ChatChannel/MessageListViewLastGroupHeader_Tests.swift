//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class MessageListViewLastGroupHeader_Tests: StreamChatTestCase {

    override func setUp() {
        super.setUp()
        let messageDisplayOptions = MessageDisplayOptions(
            showMessageDate: false,
            showAuthorName: false,
            lastInGroupHeaderSize: 24
        )
        let messageListConfig = MessageListConfig(messageDisplayOptions: messageDisplayOptions)
        let utils = Utils(messageListConfig: messageListConfig)
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }

    func test_messageListView_headerOnTop() {
        // Given
        let controller = ChatChannelController_Mock.mock(
            channelQuery: .init(cid: .unique),
            channelListQuery: nil,
            client: chatClient
        )
        let mockChannel = ChatChannel.mock(cid: .unique, name: "Test channel", memberCount: 3)
        let users = ["Martin", "Stefan", "Adolfo"]
        var messages = [ChatMessage]()
        for user in users {
            messages.append(
                ChatMessage.mock(
                    id: .unique,
                    cid: mockChannel.cid,
                    text: "Test \(user)",
                    author: .mock(id: .unique, name: user)
                )
            )
        }
        controller.simulateInitial(channel: mockChannel, messages: messages, state: .remoteDataFetched)

        // When
        let view = NavigationView {
            ScrollView {
                ChatChannelView(
                    viewFactory: CustomHeaderViewFactory(),
                    channelController: controller
                )
                .frame(width: defaultScreenSize.width, height: defaultScreenSize.height - 64)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}

class CustomHeaderViewFactory: ViewFactory {

    @Injected(\.chatClient) var chatClient: ChatClient

    func makeLastInGroupHeaderView(for message: ChatMessage) -> some View {
        HStack {
            MessageAuthorView(message: message)
            Spacer()
        }
        .padding(.leading, CGSize.messageAvatarSize.width + 24)
    }
}
