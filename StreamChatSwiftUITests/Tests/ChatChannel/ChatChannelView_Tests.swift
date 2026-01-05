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

class ChatChannelView_Tests: StreamChatTestCase {
    override func setUp() {
        super.setUp()
        DelayedRenderingViewModifier.isEnabled = false
    }

    override func tearDown() {
        super.tearDown()
        DelayedRenderingViewModifier.isEnabled = true
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

    func test_chatChannelView_snapshotEmpty() {
        // Given
        let controller = ChatChannelController_Mock.mock(
            channelQuery: .init(cid: .unique),
            channelListQuery: nil,
            client: chatClient
        )
        let messages = [ChatMessage]()
        controller.simulateInitial(
            channel: .mock(cid: .unique, name: "Test channel"),
            messages: messages,
            state: .remoteDataFetched
        )

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

    func test_chatChannelView_snapshotLoading() {
        // Given
        let controller = ChatChannelController_Mock.mock(
            channelQuery: .init(cid: .unique),
            channelListQuery: nil,
            client: chatClient
        )

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
    
    func test_chatChannelView_themedNavigationBar_snapshot() {
        // Given
        setThemedNavigationBarAppearance()
        let controller = ChatChannelController_Mock.mock(
            channelQuery: .init(cid: .unique),
            channelListQuery: nil,
            client: chatClient
        )
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
        controller.simulateInitial(channel: mockChannel, messages: messages, state: .remoteDataFetched)

        // When
        let view = NavigationContainerView {
            ChatChannelView(
                viewFactory: DefaultViewFactory.shared,
                channelController: controller
            )
        }.applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    // MARK: - Reactions Overlay Tests
    
    func test_chatChannelView_doesNotCrash_whenCurrentSnapshotIsNil_andReactionsShownIsTrue() {
        // Given
        let controller = ChatChannelController_Mock.mock(
            channelQuery: .init(cid: .unique),
            channelListQuery: nil,
            client: chatClient
        )
        let mockChannel = ChatChannel.mock(cid: .unique, name: "Test channel")
        let message = ChatMessage.mock(
            id: .unique,
            cid: mockChannel.cid,
            text: "Test message",
            author: .mock(id: .unique, name: "User")
        )
        controller.simulateInitial(channel: mockChannel, messages: [message], state: .remoteDataFetched)
        
        let viewModel = ChatChannelViewModel(channelController: controller)
        
        // When
        viewModel.currentSnapshot = nil
        viewModel.reactionsShown = true
        
        let view = ChatChannelView(
            viewFactory: DefaultViewFactory.shared,
            viewModel: viewModel,
            channelController: controller
        )
        
        // Then - Should not crash when rendering
        let hostingController = UIHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        XCTAssertNil(viewModel.currentSnapshot)
        XCTAssertTrue(viewModel.reactionsShown)
    }
    
    func test_chatChannelView_doesNotCrash_whenMessageDisplayInfoIsNil_andReactionsShownIsTrue() {
        // Given
        let controller = ChatChannelController_Mock.mock(
            channelQuery: .init(cid: .unique),
            channelListQuery: nil,
            client: chatClient
        )
        let mockChannel = ChatChannel.mock(cid: .unique, name: "Test channel")
        let message = ChatMessage.mock(
            id: .unique,
            cid: mockChannel.cid,
            text: "Test message",
            author: .mock(id: .unique, name: "User")
        )
        controller.simulateInitial(channel: mockChannel, messages: [message], state: .remoteDataFetched)
        
        let viewModel = ChatChannelViewModel(channelController: controller)
        
        // When
        viewModel.showReactionOverlay(for: AnyView(EmptyView()))
        // messageDisplayInfo remains nil (not set)
        
        let view = ChatChannelView(
            viewFactory: DefaultViewFactory.shared,
            viewModel: viewModel,
            channelController: controller
        )
        
        // Then - Should not crash when rendering
        let hostingController = UIHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
        XCTAssertNotNil(viewModel.currentSnapshot)
        XCTAssertTrue(viewModel.reactionsShown)
    }
}
