//
// Copyright © 2023 Stream.io Inc. All rights reserved.
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

    func test_chatChannelView_snapshot() {
        // Given
        let controller = ChatChannelController_Mock.mock(
            channelQuery: .init(cid: .unique),
            channelListQuery: nil,
            client: chatClient
        )
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
        controller.simulateInitial(channel: mockChannel, messages: messages, state: .remoteDataFetched)

        // When
        let view = NavigationView {
            ScrollView {
                ChatChannelView(
                    viewFactory: DefaultViewFactory.shared,
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
