//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class ChatChannelListViewModel_Tests: StreamChatTestCase {
    
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
        for _ in 0..<15 {
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
    
    // MARK: - private
    
    private func makeChannelListController(
        channels: [ChatChannel] = []
    ) -> ChatChannelListController_Mock {
        let channelListController = ChatChannelListController_Mock.mock()
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
        channels: [ChatChannel] = []
    ) -> ChatChannelListViewModel {
        let channelListController = makeChannelListController(channels: channels)
        let viewModel = ChatChannelListViewModel(
            channelListController: channelListController,
            selectedChannelId: nil
        )
        
        return viewModel
    }
}
