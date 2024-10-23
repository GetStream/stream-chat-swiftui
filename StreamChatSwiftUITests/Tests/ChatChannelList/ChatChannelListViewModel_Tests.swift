//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

class ChatChannelListViewModel_Tests: StreamChatTestCase {

    override open func setUp() {
        super.setUp()
        let utils = Utils(
            messageListConfig: MessageListConfig(updateChannelsFromMessageList: true)
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }

    func test_channelListVMCreation_channelsLoaded() {
        // Given
        let channelListController = makeChannelListController()

        // When
        let viewModel = ChatChannelListViewModel(
            channelListController: channelListController,
            selectedChannelId: nil
        )

        // Then
        XCTAssert(viewModel.channels.count == 1)
    }

    func test_channelListVM_channelAdded() {
        // Given
        let channelListController = makeChannelListController()
        let viewModel = ChatChannelListViewModel(
            channelListController: channelListController,
            selectedChannelId: nil
        )

        // When
        let newChannel1 = ChatChannel.mockDMChannel()
        let newChannel2 = ChatChannel.mockDMChannel()
        channelListController.simulate(
            channels: [newChannel1, newChannel2],
            changes: []
        )

        // Then
        XCTAssert(viewModel.channels.count == 2)
    }

    func test_channelListVM_onChannelAppear_loadNextChannelsCalled() {
        // Given
        let channelListController = makeChannelListController()
        let viewModel = ChatChannelListViewModel(
            channelListController: channelListController,
            selectedChannelId: nil
        )

        // When
        viewModel.checkForChannels(index: 5)

        // Then
        XCTAssert(channelListController.loadNextChannelsIsCalled == true)
    }

    func test_channelListVM_onChannelAppear_loadNextChannelsNotCalled() {
        // Given
        var channels = [ChatChannel]()
        for _ in 0..<20 {
            channels.append(ChatChannel.mockDMChannel())
        }
        let channelListController = makeChannelListController(channels: channels)
        let viewModel = ChatChannelListViewModel(
            channelListController: channelListController,
            selectedChannelId: nil
        )

        // When
        viewModel.checkForChannels(index: 0)

        // Then
        XCTAssert(channelListController.loadNextChannelsIsCalled == false)
    }

    func test_channelListVM_onDeleteTapped() {
        // Given
        let viewModel = makeDefaultChannelListVM()
        let channel = ChatChannel.mockDMChannel()

        // When
        viewModel.onDeleteTapped(channel: channel)

        // Then
        XCTAssert(viewModel.channelAlertType == .deleteChannel(channel))
        XCTAssert(viewModel.alertShown == true)
    }

    func test_channelListVM_showErrorPopup() {
        // Given
        let viewModel = makeDefaultChannelListVM()
        let error = NSError(domain: "test", code: 1, userInfo: nil)

        // When
        viewModel.showErrorPopup(error)

        // Then
        XCTAssert(viewModel.channelAlertType == .error)
        XCTAssert(viewModel.alertShown == true)
    }

    func test_channelListVM_nameForChannel() {
        // Given
        let expectedName = "test"
        let channel = ChatChannel.mockDMChannel(name: expectedName)
        let viewModel = makeDefaultChannelListVM(channels: [channel])

        // When
        let name = viewModel.name(forChannel: channel)

        // Then
        XCTAssert(name == expectedName)
    }

    func test_channelListVM_onlineIndicatorShown() {
        // Given
        let channel = ChatChannel.mockDMChannel(
            lastActiveMembers: [.mock(id: .unique, isOnline: true)]
        )
        let viewModel = makeDefaultChannelListVM(channels: [channel])

        // When
        let onlineIndicatorShown = viewModel.onlineIndicatorShown(for: channel)

        // Then
        XCTAssert(onlineIndicatorShown == true)
    }

    func test_channelListVM_onlineIndicatorNotShown() {
        // Given
        let channel = ChatChannel.mockDMChannel()
        let viewModel = makeDefaultChannelListVM(channels: [channel])

        // When
        let onlineIndicatorShown = viewModel.onlineIndicatorShown(for: channel)

        // Then
        XCTAssert(onlineIndicatorShown == false)
    }

    func test_channelListVM_onMoreTapped() {
        // Given
        let channel = ChatChannel.mockDMChannel()
        let viewModel = makeDefaultChannelListVM(channels: [channel])

        // When
        viewModel.onMoreTapped(channel: channel)

        // Then
        XCTAssert(viewModel.customChannelPopupType == .moreActions(channel))
        XCTAssert(viewModel.customAlertShown == true)
    }

    func test_channelListVM_deleteChannel() {
        // Given
        let channel = ChatChannel.mockDMChannel()
        let channelListController = makeChannelListController(channels: [channel])
        let viewModel = ChatChannelListViewModel(
            channelListController: channelListController,
            selectedChannelId: nil
        )

        // When
        viewModel.delete(channel: channel)
        channelListController.simulate(
            channels: [],
            changes: [
                ListChange.remove(
                    channel, index: .init(row: 0, section: 0)
                )
            ]
        )

        // Then
        XCTAssert(viewModel.channels.isEmpty)
    }

    func test_channelListVM_queuedChangesUpdate() {
        // Given
        let channelId = ChannelId.unique
        var channel = ChatChannel.mock(cid: channelId)
        let channelListController = makeChannelListController(channels: [channel])
        let viewModel = ChatChannelListViewModel(
            channelListController: channelListController,
            selectedChannelId: nil
        )
        viewModel.selectedChannel = ChannelSelectionInfo(channel: channel, message: nil)
        channelListController.simulateInitial(channels: [channel], state: .remoteDataFetched)

        // When
        let message = ChatMessage.mock(
            id: .unique,
            cid: channelId,
            text: "Test message",
            author: .mock(id: .unique, name: "Martin")
        )
        channel = ChatChannel.mock(cid: channelId, unreadCount: .mock(messages: 1), latestMessages: [message])
        channelListController.simulate(
            channels: [channel],
            changes: [.update(channel, index: .init(row: 0, section: 0))]
        )
        viewModel.checkForChannels(index: 0)

        // Then
        let injectedChannelInfo = viewModel.selectedChannel?.injectedChannelInfo!
        let presentedSubtitle = injectedChannelInfo!.subtitle!
        let unreadCount = injectedChannelInfo!.unreadCount
        XCTAssert(presentedSubtitle == channel.subtitleText)
        XCTAssert(viewModel.channels[0].subtitleText == "No messages")
        XCTAssert(unreadCount == 0)
        XCTAssert(channel.shouldShowTypingIndicator == false)
    }

    func test_channelListVM_badgeCountUpdate() {
        // Given
        let channelId = ChannelId.unique
        let channel = ChatChannel.mock(cid: channelId, unreadCount: .mock(messages: 1))
        let channelListController = makeChannelListController(channels: [channel])
        let viewModel = ChatChannelListViewModel(
            channelListController: channelListController,
            selectedChannelId: nil
        )
        viewModel.selectedChannel = ChannelSelectionInfo(channel: channel, message: nil)

        // When
        viewModel.checkForChannels(index: 0)

        // Then
        let injectedChannelInfo = viewModel.selectedChannel?.injectedChannelInfo!
        let unreadCount = injectedChannelInfo!.unreadCount
        XCTAssert(unreadCount == 0)
    }

    func test_channelListVM_channelDismiss() {
        // Given
        let channelId = ChannelId.unique
        let channel = ChatChannel.mock(cid: channelId, unreadCount: .mock(messages: 1))
        let channelListController = makeChannelListController(channels: [channel])
        let viewModel = ChatChannelListViewModel(
            channelListController: channelListController,
            selectedChannelId: nil
        )
        viewModel.selectedChannel = ChannelSelectionInfo(channel: channel, message: nil)

        // When
        notifyChannelDismiss()

        // Then
        XCTAssert(viewModel.selectedChannel == nil)
    }

    func test_channelListVM_hideTabBar() {
        // Given
        let viewModel = makeDefaultChannelListVM()

        // When
        notifyHideTabBar()

        // Then
        XCTAssert(viewModel.hideTabBar == true)
    }
    
    func test_channelListVM_deeplinkToExistingChannel() throws {
        // Given
        let channels = (0..<3).map { ChatChannel.mock(cid: ChannelId(type: .messaging, id: "\($0)")) }
        let channelListController = makeChannelListController(channels: channels)
        let selectedId = channels[1].cid
        let viewModel = ChatChannelListViewModel(
            channelListController: channelListController,
            selectedChannelId: selectedId.rawValue
        )
        
        // Then
        let expectation = XCTestExpectation(description: "SelectedChannel")
        let cancellable = viewModel.$selectedChannel
            .filter { $0?.channel.cid == selectedId }
            .sink { _ in
                expectation.fulfill()
            }
        // Resume synchronize()
        chatClient.mockAPIClient.test_simulateResponse(.success(ChannelListPayload(channels: [])))
        wait(for: [expectation], timeout: defaultTimeout)
        cancellable.cancel()
    }
    
    func test_channelListVM_deeplinkToIncomingChannel() {
        // Given
        let channels = (0..<3).map { ChatChannel.mock(cid: ChannelId(type: .messaging, id: "\($0)")) }
        let channelListController = makeChannelListController(channels: channels)
        let selectedId = ChannelId(type: .messaging, id: "3")
        let viewModel = ChatChannelListViewModel(
            channelListController: channelListController,
            selectedChannelId: selectedId.rawValue
        )
        
        // When
        let expectation = XCTestExpectation(description: "SelectedChannel")
        let cancellable = viewModel.$selectedChannel
            .filter { $0?.channel.cid == selectedId }
            .sink { _ in
                expectation.fulfill()
            }
        let insertedChannel = ChatChannel.mock(cid: selectedId)
        channelListController.simulate(
            channels: channels + [insertedChannel],
            changes: [.insert(insertedChannel, index: IndexPath(item: 0, section: 0))]
        )
        // Resume synchronize()
        chatClient.mockAPIClient.test_simulateResponse(.success(ChannelListPayload(channels: [])))
        
        // Then
        wait(for: [expectation], timeout: defaultTimeout)
        cancellable.cancel()
    }

    // MARK: - Search

    func test_loadAdditionalSearchResults_whenSearchTypeIsChannels_shouldLoadNextChannels() {
        let searchChannelListController = makeChannelListController()
        let viewModel = makeDefaultChannelListVM(searchType: .channels)
        viewModel.channelListSearchController = searchChannelListController
        
        viewModel.loadAdditionalSearchResults(index: 1)

        XCTAssertEqual(searchChannelListController.loadNextChannelsCallCount, 1)
    }

    func test_loadAdditionalSearchResults_whenSearchTypeIsMessages_shouldLoadNextMessages() {
        let messageSearchController = ChatMessageSearchController_Mock.mock()
        let viewModel = makeDefaultChannelListVM(searchType: .messages)
        viewModel.messageSearchController = messageSearchController

        viewModel.loadAdditionalSearchResults(index: 1)

        XCTAssertEqual(messageSearchController.loadNextMessagesCallCount, 1)
    }

    func test_searchText_whenChanged_whenSearchTypeIsChannels_shouldPerformChannelSearch() {
        let viewModel = makeDefaultChannelListVM(searchType: .channels)
        viewModel.searchText = "Hey"
        XCTAssertNotNil(viewModel.channelListSearchController)
        XCTAssertNil(viewModel.messageSearchController)
    }

    func test_searchText_whenChanged_whenSearchTypeIsMessages_shouldPerformMessageSearch() {
        let viewModel = makeDefaultChannelListVM(searchType: .messages)
        viewModel.searchText = "Hey"
        XCTAssertNil(viewModel.channelListSearchController)
        XCTAssertNotNil(viewModel.messageSearchController)
    }

    // MARK: - private

    private func makeChannelListController(
        channels: [ChatChannel] = []
    ) -> ChatChannelListController_Mock {
        let channelListController = ChatChannelListController_Mock.mock(client: chatClient)
        var chatChannels = [ChatChannel]()
        if channels.isEmpty {
            let channel = ChatChannel.mockDMChannel()
            chatChannels = [channel]
        } else {
            chatChannels = channels
        }
        channelListController.simulateInitial(channels: chatChannels, state: .initialized)
        return channelListController
    }

    private func makeDefaultChannelListVM(
        channels: [ChatChannel] = [],
        searchType: ChannelListSearchType = .messages
    ) -> ChatChannelListViewModel {
        let channelListController = makeChannelListController(channels: channels)
        let viewModel = ChatChannelListViewModel(
            channelListController: channelListController,
            selectedChannelId: nil,
            searchType: searchType
        )
        return viewModel
    }
}
