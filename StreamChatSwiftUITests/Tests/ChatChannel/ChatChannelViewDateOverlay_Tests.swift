//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class ChatChannelViewDateOverlay_Tests: StreamChatTestCase {

    override func setUp() {
        super.setUp()
        DateFormatter.messageListDateOverlay = {
            let df = DateFormatter()
            df.setLocalizedDateFormatFromTemplate("MMMdd")
            df.locale = .init(identifier: "en_US")
            return df
        }()
        let utils = Utils(
            dateFormatter: EmptyDateFormatter(),
            messageListConfig: MessageListConfig(dateIndicatorPlacement: .messageList)
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }

    @MainActor func test_chatChannelView_snapshot() {
        // Given
        let mockChannel = ChatChannel.mock(cid: .unique, name: "Test channel")
        var messages = [ChatMessage]()
        let baseIntervalDistance: TimeInterval = 10000
        for i in 0..<3 {
            messages.append(
                ChatMessage.mock(
                    id: .unique,
                    cid: mockChannel.cid,
                    text: "Test \(i)",
                    author: .mock(id: .unique, name: "Martin"),
                    createdAt: Date(timeIntervalSince1970: -TimeInterval(i) * baseIntervalDistance)
                )
            )
        }
        let chat = Chat_Mock.mock(bundle: Bundle(for: Self.self))
        chat.simulateInitial(channel: mockChannel, messages: messages)

        // When
        let view = NavigationView {
            ScrollView {
                ChatChannelView(
                    viewFactory: DefaultViewFactory.shared,
                    chat: chat
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
