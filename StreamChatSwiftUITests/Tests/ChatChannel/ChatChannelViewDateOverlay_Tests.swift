//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class ChatChannelViewDateOverlay_Tests: StreamChatTestCase {
    override func setUp() {
        super.setUp()
        DelayedRenderingViewModifier.isEnabled = false
    }

    override func tearDown() {
        super.tearDown()
        DelayedRenderingViewModifier.isEnabled = true
    }

    func test_chatChannelView_snapshot_messageListPlacement() {
        // Given
        let utils = Utils(
            dateFormatter: EmptyDateFormatter(),
            messageListConfig: MessageListConfig(dateIndicatorPlacement: .messageList)
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
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

    func test_chatChannelView_snapshot_overlayPlacement_dateIndicatorAppearsAtTop() {
        // Given
        let utils = Utils(
            dateFormatter: EmptyDateFormatter(),
            messageListConfig: MessageListConfig(dateIndicatorPlacement: .overlay)
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
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

        // When – inject a viewModel with currentDateString set to simulate the overlay being visible.
        // showScrollToLatestButton must also be true: handleMessageAppear calls save(lastDate:) during
        // rendering which triggers handleDateChange(); if showScrollToLatestButton is false that
        // method immediately resets currentDateString back to nil.
        let viewModel = ChatChannelViewModel(channelController: controller)
        viewModel.showScrollToLatestButton = true
        viewModel.currentDateString = "Today"

        let view = NavigationView {
            ScrollView {
                ChatChannelView(
                    viewFactory: DefaultViewFactory.shared,
                    viewModel: viewModel,
                    channelController: controller
                )
                .frame(width: defaultScreenSize.width, height: defaultScreenSize.height - 64)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .applyDefaultSize()

        // Then – date indicator must appear at the top, not the center
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}
