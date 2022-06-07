import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

class MessageListViewLastGroupHeader_Tests: StreamChatTestCase {
    
    override func setUp() {
        super.setUp()
        let messageDisplayOptions = MessageDisplayOptions(
            showAuthorName: false,
            lastInGroupHeaderSize: 32
        )
        let messageListConfig = MessageListConfig(messageDisplayOptions: messageDisplayOptions)
        let utils = Utils(messageListConfig: messageListConfig)
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }
    
    func test_messageListView_headerOnTop() {
        // Given
        let controller = ChatChannelController_Mock(
            channelQuery: .init(cid: .unique),
            channelListQuery: nil,
            client: chatClient
        )
        let mockChannel = ChatChannel.mock(cid: .unique, name: "Test channel")
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
        assertSnapshot(matching: view, as: .image)
    }
    
}

class CustomHeaderViewFactory: ViewFactory {
    
    @Injected(\.chatClient) var chatClient: ChatClient
    
    func makeLastInGroupHeaderView(for message: ChatMessage) -> some View {
        VStack {
            HStack {
                TopLeftView {
                    MessageAuthorView(message: message)
                        .padding(.leading, CGSize.messageAvatarSize.width + 24)
                }
                .padding(.top, !message.reactionScores.isEmpty ? (message.text.count > 8 ? 8 : -16) : -16)
                Spacer()
            }
            Spacer()
        }
    }
    
}
