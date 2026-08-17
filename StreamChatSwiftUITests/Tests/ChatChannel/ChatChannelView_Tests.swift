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

@MainActor class ChatChannelView_Tests: StreamChatTestCase {
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
            shouldShowTypingIndicator: false,
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
    
    // MARK: - Typing indicator in an empty channel

    func test_chatChannelView_emptyChannelTypingIndicator_snapshot() {
        // Given
        let controller = emptyChannelController()

        // When
        let view = emptyChannelViewWithTypingUser(
            for: controller,
            viewFactory: DefaultViewFactory.shared
        )

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_chatChannelView_emptyChannelTypingIndicatorMessagesStartAtTheTop_snapshot() {
        // Given
        let utils = Utils(
            dateFormatter: EmptyDateFormatter(),
            messageListConfig: MessageListConfig(shouldMessagesStartAtTheTop: true)
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        let controller = emptyChannelController()

        // When
        let view = emptyChannelViewWithTypingUser(
            for: controller,
            viewFactory: DefaultViewFactory.shared
        )

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_chatChannelView_emptyChannelTypingIndicatorFloatingComposer_snapshot() {
        // Given
        let controller = emptyChannelController()

        // When
        let view = emptyChannelViewWithTypingUser(
            for: controller,
            viewFactory: LiquidGlassViewFactory()
        )

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    // MARK: - LiquidGlass Style Tests

    func test_chatChannelView_liquidGlassStyle_composer_snapshot() {
        // Given
        let controller = ChatChannelController_Mock.mock(
            channelQuery: .init(cid: .unique),
            channelListQuery: nil,
            client: chatClient
        )
        let mockChannel = ChatChannel.mock(cid: .unique, name: "Test channel")
        var messages = [ChatMessage]()
        for i in 0..<5 {
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
        let viewFactory = LiquidGlassViewFactory()
        let view = NavigationView {
            ScrollView {
                ChatChannelView(
                    viewFactory: viewFactory,
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

    // MARK: - Helpers

    private func emptyChannelController() -> ChatChannelController_Mock {
        let controller = ChatChannelController_Mock.mock(
            channelQuery: .init(cid: .unique),
            channelListQuery: nil,
            client: chatClient
        )
        controller.simulateInitial(
            channel: .mock(cid: .unique, name: "Test channel"),
            messages: [],
            state: .remoteDataFetched
        )
        return controller
    }

    private func emptyChannelViewWithTypingUser<Factory: ViewFactory>(
        for controller: ChatChannelController_Mock,
        viewFactory: Factory
    ) -> some SwiftUI.View {
        let viewModel = ChatChannelViewModel(channelController: controller)
        let typingUser: ChatChannelMember = .mock(id: .unique, name: "Martin")
        let channel: ChatChannel = .mock(
            cid: controller.cid!,
            name: "Test channel",
            currentlyTypingUsers: [typingUser]
        )
        controller.simulate(channel: channel, change: .update(channel), typingUsers: [typingUser])

        return NavigationView {
            ScrollView {
                ChatChannelView(
                    viewFactory: viewFactory,
                    viewModel: viewModel,
                    channelController: controller
                )
                .frame(width: defaultScreenSize.width, height: defaultScreenSize.height - 64)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .applyDefaultSize()
    }
}

// MARK: - LiquidGlass Test ViewFactory

class LiquidGlassViewFactory: ViewFactory {
    @Injected(\.chatClient) public var chatClient
    
    public var styles = LiquidGlassStyles()
    
    init() {}
}
