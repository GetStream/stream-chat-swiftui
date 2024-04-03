//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class ChatChannelView_Tests: StreamChatTestCase {

    override func setUp() {
        super.setUp()
        let utils = Utils(dateFormatter: EmptyDateFormatter())
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }

    @MainActor func test_chatChannelView_snapshot() {
        // Given
        let mockChannel = ChatChannel.mock(cid: .unique, name: "Test channel")
        var messages = [ChatMessage]()
        for i in 0..<15 {
            messages.append(
                ChatMessage.mock(
                    id: .unique,
                    cid: mockChannel.cid,
                    text: "Test \(i)",
                    author: .mock(id: .unique, name: "Martin")
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

    @MainActor func test_chatChannelView_snapshotEmpty() {
        // Given
        let messages = [ChatMessage]()
        let chat = Chat_Mock.mock(bundle: Bundle(for: Self.self))
        chat.simulateInitial(
            channel: .mock(cid: .unique, name: "Test channel"),
            messages: messages
        )

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

    @MainActor func test_chatChannelView_snapshotLoading() {
        // Given
        let chat = chatClient.makeChat(for: .unique)

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

    func test_defaultChannelHeader_snapshot() {
        // Given
        let header = DefaultChatChannelHeader(
            channel: .mockDMChannel(name: "Test"),
            headerImage: UIImage(systemName: "person")!,
            isActive: .constant(false)
        )
        let view = NavigationView {
            Text("Test")
                .toolbar {
                    header
                }
        }
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}
