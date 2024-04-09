//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class ChatChannelListViewModel_Tests: StreamChatTestCase {

    override open func setUp() {
        super.setUp()
        let utils = Utils(
            messageListConfig: MessageListConfig(updateChannelsFromMessageList: true)
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }

    @MainActor func test_channelListVMCreation_channelsLoaded() async throws {
        // Given
        let channelList = try await makeChannelList()

        // When
        let viewModel = ChatChannelListViewModel(
            channelList: channelList,
            selectedChannelId: nil
        )

        // Then
        XCTAssert(viewModel.channels.count == 1)
    }

    @MainActor func test_channelListVM_channelAdded() async throws {
        // Given
        let channelList = try await makeChannelList()
        let viewModel = ChatChannelListViewModel(
            channelList: channelList,
            selectedChannelId: nil
        )

        // When
        let newChannel1 = ChatChannel.mockDMChannel()
        let newChannel2 = ChatChannel.mockDMChannel()
        try await channelList.simulate(channels: [newChannel1, newChannel2])

        // Then
        XCTAssertEqual(viewModel.channels.count, 2)
    }

    @MainActor func test_channelListVM_onChannelAppear_loadNextChannelsCalled() async throws {
        // Given
        let channelList = try await makeChannelList()
        let viewModel = ChatChannelListViewModel(
            channelList: channelList,
            selectedChannelId: nil
        )

        // When
        viewModel.checkForChannels(index: 5)
        try await waitForTask()

        // Then
        XCTAssert(channelList.loadNextChannelsIsCalled == true)
    }

    @MainActor func test_channelListVM_onChannelAppear_loadNextChannelsNotCalled() async throws {
        // Given
        var channels = [ChatChannel]()
        for _ in 0..<20 {
            channels.append(ChatChannel.mockDMChannel())
        }
        let channelList = try await makeChannelList(channels: channels)
        let viewModel = ChatChannelListViewModel(
            channelList: channelList,
            selectedChannelId: nil
        )

        // When
        viewModel.checkForChannels(index: 0)

        // Then
        XCTAssert(channelList.loadNextChannelsIsCalled == false)
    }

    @MainActor func test_channelListVM_onDeleteTapped() async throws {
        // Given
        let viewModel = try await makeDefaultChannelListVM()
        let channel = ChatChannel.mockDMChannel()

        // When
        viewModel.onDeleteTapped(channel: channel)

        // Then
        XCTAssert(viewModel.channelAlertType == .deleteChannel(channel))
        XCTAssert(viewModel.alertShown == true)
    }

    @MainActor func test_channelListVM_showErrorPopup() async throws {
        // Given
        let viewModel = try await makeDefaultChannelListVM()
        let error = NSError(domain: "test", code: 1, userInfo: nil)

        // When
        viewModel.showErrorPopup(error)

        // Then
        XCTAssert(viewModel.channelAlertType == .error)
        XCTAssert(viewModel.alertShown == true)
    }

    @MainActor func test_channelListVM_nameForChannel() async throws {
        // Given
        let expectedName = "test"
        let channel = ChatChannel.mockDMChannel(name: expectedName)
        let viewModel = try await makeDefaultChannelListVM(channels: [channel])

        // When
        let name = viewModel.name(forChannel: channel)

        // Then
        XCTAssert(name == expectedName)
    }

    @MainActor func test_channelListVM_onlineIndicatorShown() async throws {
        // Given
        let channel = ChatChannel.mockDMChannel(
            lastActiveMembers: [.mock(id: .unique, isOnline: true)]
        )
        let viewModel = try await makeDefaultChannelListVM(channels: [channel])

        // When
        let onlineIndicatorShown = viewModel.onlineIndicatorShown(for: channel)

        // Then
        XCTAssert(onlineIndicatorShown == true)
    }

    @MainActor func test_channelListVM_onlineIndicatorNotShown() async throws {
        // Given
        let channel = ChatChannel.mockDMChannel()
        let viewModel = try await makeDefaultChannelListVM(channels: [channel])

        // When
        let onlineIndicatorShown = viewModel.onlineIndicatorShown(for: channel)

        // Then
        XCTAssert(onlineIndicatorShown == false)
    }

    @MainActor func test_channelListVM_onMoreTapped() async throws {
        // Given
        let channel = ChatChannel.mockDMChannel()
        let viewModel = try await makeDefaultChannelListVM(channels: [channel])

        // When
        viewModel.onMoreTapped(channel: channel)

        // Then
        XCTAssert(viewModel.customChannelPopupType == .moreActions(channel))
        XCTAssert(viewModel.customAlertShown == true)
    }

    @MainActor func test_channelListVM_deleteChannel() async throws {
        // Given
        let channel = ChatChannel.mockDMChannel()
        let channelList = try await makeChannelList(channels: [channel])
        let viewModel = ChatChannelListViewModel(
            channelList: channelList,
            selectedChannelId: nil
        )

        // When
        viewModel.delete(channel: channel)
        try await channelList.simulate(channels: [])

        // Then
        XCTAssert(viewModel.channels.isEmpty)
    }

    @MainActor func test_channelListVM_queuedChangesUpdate() async throws {
        // Given
        let channelId = ChannelId.unique
        var channel = ChatChannel.mock(cid: channelId)
        let channelList = try await makeChannelList(channels: [channel])
        let viewModel = ChatChannelListViewModel(
            channelList: channelList,
            selectedChannelId: nil
        )
        viewModel.selectedChannel = ChannelSelectionInfo(channel: channel, message: nil)
        try await channelList.simulate(channels: [channel])

        // When
        let message = ChatMessage.mock(
            id: .unique,
            cid: channelId,
            text: "Test message",
            author: .mock(id: .unique, name: "Martin")
        )
        channel = ChatChannel.mock(cid: channelId, unreadCount: .mock(messages: 1), latestMessages: [message])
        try await channelList.simulate(channels: [channel])
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

    @MainActor func test_channelListVM_badgeCountUpdate() async throws {
        // Given
        let channelId = ChannelId.unique
        let channel = ChatChannel.mock(cid: channelId, unreadCount: .mock(messages: 1))
        let channelList = try await makeChannelList(channels: [channel])
        let viewModel = ChatChannelListViewModel(
            channelList: channelList,
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

    @MainActor func test_channelListVM_channelDismiss() async throws {
        // Given
        let channelId = ChannelId.unique
        let channel = ChatChannel.mock(cid: channelId, unreadCount: .mock(messages: 1))
        let channelList = try await makeChannelList(channels: [channel])
        let viewModel = ChatChannelListViewModel(
            channelList: channelList,
            selectedChannelId: nil
        )
        viewModel.selectedChannel = ChannelSelectionInfo(channel: channel, message: nil)

        // When
        notifyChannelDismiss()

        // Then
        XCTAssert(viewModel.selectedChannel == nil)
    }

    @MainActor func test_channelListVM_hideTabBar() async throws {
        // Given
        let viewModel = try await makeDefaultChannelListVM()

        // When
        notifyHideTabBar()

        // Then
        XCTAssert(viewModel.hideTabBar == true)
    }

    // MARK: - private

    private func makeChannelList(
        channels: [ChatChannel] = []
    ) async throws -> ChannelList_Mock {
        let channelList = ChannelList_Mock.mock(client: chatClient)
        var chatChannels = [ChatChannel]()
        if channels.isEmpty {
            let channel = ChatChannel.mockDMChannel()
            chatChannels = [channel]
        } else {
            chatChannels = channels
        }
        try await channelList.simulate(channels: chatChannels)
        return channelList
    }

    private func makeDefaultChannelListVM(
        channels: [ChatChannel] = []
    ) async throws -> ChatChannelListViewModel {
        let channelList = try await makeChannelList(channels: channels)
        let viewModel = await ChatChannelListViewModel(
            channelList: channelList,
            selectedChannelId: nil
        )

        return viewModel
    }
}
