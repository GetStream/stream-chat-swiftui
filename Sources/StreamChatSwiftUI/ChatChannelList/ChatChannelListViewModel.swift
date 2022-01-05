//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI
import UIKit

/// View model for the `ChatChannelListView`.
open class ChatChannelListViewModel: ObservableObject, ChatChannelListControllerDelegate {
    /// Context provided dependencies.
    @Injected(\.chatClient) private var chatClient: ChatClient
    @Injected(\.images) private var images: Images
    @Injected(\.utils) private var utils: Utils
    
    /// Context provided utils.
    internal lazy var channelNamer = utils.channelNamer
        
    /// The maximum number of images that combine to form a single avatar
    private let maxNumberOfImagesInCombinedAvatar = 4
    
    private var controller: ChatChannelListController!
    
    /// Used when screen is shown from a deeplink.
    private var selectedChannelId: String?
    
    /// Temporarly holding changes while message list is shown.
    private var queuedChannelsChanges = LazyCachedMapCollection<ChatChannel>()
    
    /// Controls loading the channels.
    @Atomic private var loadingNextChannels: Bool = false
    
    /// Published variables.
    @Published public var channels = LazyCachedMapCollection<ChatChannel>() {
        didSet {
            queuedChannelsChanges = []
        }
    }

    @Published public var selectedChannel: ChatChannel? {
        didSet {
            if oldValue != nil && selectedChannel == nil {
                // pop happened, apply the queued changes.
                if !queuedChannelsChanges.isEmpty {
                    channels = queuedChannelsChanges
                }
            }
        }
    }

    @Published public var deeplinkChannel: ChatChannel?
    @Published public var currentChannelId: String?
    @Published public var channelAlertType: ChannelAlertType? {
        didSet {
            if channelAlertType != nil {
                alertShown = true
            }
        }
    }

    @Published public var customChannelPopupType: ChannelPopupType? {
        didSet {
            if customChannelPopupType != nil {
                customAlertShown = true
            } else {
                customAlertShown = false
            }
        }
    }

    @Published public var alertShown = false
    @Published public var loading = false
    @Published public var customAlertShown = false
    
    public init(
        channelListController: ChatChannelListController? = nil,
        selectedChannelId: String? = nil
    ) {
        self.selectedChannelId = selectedChannelId
        if let channelListController = channelListController {
            controller = channelListController
        } else {
            makeDefaultChannelListController()
        }
        setupChannelListController()
    }
    
    /// Returns the name for the specified channel.
    ///
    /// - Parameter channel: the channel whose display name is asked for.
    /// - Returns: `String` with the channel name.
    public func name(forChannel channel: ChatChannel) -> String {
        channelNamer(channel, chatClient.currentUserId) ?? ""
    }
    
    /// Checks if there are new channels to be loaded.
    ///
    /// - Parameter index: the currently displayed index.
    public func checkForChannels(index: Int) {
        if index < controller.channels.count - 10 {
            return
        }

        if _loadingNextChannels.compareAndSwap(old: false, new: true) {
            controller.loadNextChannels { [weak self] _ in
                guard let self = self else { return }
                self.loadingNextChannels = false
                self.channels = self.controller.channels
            }
        }
    }
    
    /// Determines whether an online indicator is shown.
    ///
    /// - Parameter channel: the provided channel.
    /// - Returns: Boolean whether the indicator is shown.
    public func onlineIndicatorShown(for channel: ChatChannel) -> Bool {
        !channel.lastActiveMembers.filter { member in
            member.isOnline && member.id != chatClient.currentUserId
        }
        .isEmpty
    }
    
    public func onDeleteTapped(channel: ChatChannel) {
        channelAlertType = .deleteChannel(channel)
    }
    
    public func onMoreTapped(channel: ChatChannel) {
        customChannelPopupType = .moreActions(channel)
    }
    
    public func delete(channel: ChatChannel) {
        let controller = chatClient.channelController(
            for: .init(type: .messaging, id: channel.cid.id)
        )
         
        controller.deleteChannel { [weak self] error in
            if error != nil {
                // handle error
                self?.channelAlertType = .error
            }
        }
    }
    
    public func showErrorPopup(_ error: Error?) {
        channelAlertType = .error
    }
    
    // MARK: - ChatChannelListControllerDelegate
    
    public func controllerWillChangeChannels(_ controller: ChatChannelListController) {
        handleChannelListChanges(controller)
    }
    
    public func controller(
        _ controller: ChatChannelListController,
        didChangeChannels changes: [ListChange<ChatChannel>]
    ) {
        handleChannelListChanges(controller)
    }
    
    public func controller(
        _ controller: ChatChannelListController,
        shouldAddNewChannelToList channel: ChatChannel
    ) -> Bool {
        true
    }
    
    public func controller(
        _ controller: ChatChannelListController,
        shouldListUpdatedChannel channel: ChatChannel
    ) -> Bool {
        true
    }
    
    // MARK: - private
    
    private func handleChannelListChanges(_ controller: ChatChannelListController) {
        if selectedChannel != nil {
            queuedChannelsChanges = controller.channels
        } else {
            channels = controller.channels
        }
    }
    
    private func checkForDeeplinks() {
        if let selectedChannelId = selectedChannelId,
           let channelId = try? ChannelId(cid: selectedChannelId) {
            let chatController = chatClient.channelController(
                for: channelId,
                messageOrdering: .topToBottom
            )
            deeplinkChannel = chatController.channel
            self.selectedChannelId = nil
        }
    }
    
    private func makeDefaultChannelListController() {
        controller = chatClient.channelListController(
            query: .init(filter: .containMembers(userIds: [chatClient.currentUserId!]))
        )
    }
    
    private func setupChannelListController() {
        controller.delegate = self
        
        channels = controller.channels
        
        loading = true
        controller.synchronize { [weak self] error in
            guard let self = self else { return }
            self.loading = false
            if error != nil {
                // handle error
                self.channelAlertType = .error
            } else {
                // access channels
                self.channels = self.controller.channels
                self.checkForDeeplinks()
            }
        }
    }
    
    private func lastActiveMembers(for channel: ChatChannel) -> [ChatChannelMember] {
        channel.lastActiveMembers
            .sorted { $0.memberCreatedAt < $1.memberCreatedAt }
            .filter { $0.id != chatClient.currentUserId }
    }
}

/// Enum for the type of alert presented in the channel list view.
public enum ChannelAlertType {
    case deleteChannel(ChatChannel)
    case error
}

/// Enum describing the type of the custom popup for channel actions.
public enum ChannelPopupType {
    /// Shows the 'more actions' popup.
    case moreActions(ChatChannel)
}
