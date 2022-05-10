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
    
    private var controller: ChatChannelListController?
    
    /// Used when screen is shown from a deeplink.
    private var selectedChannelId: String?
    
    /// Temporarly holding changes while message list is shown.
    private var queuedChannelsChanges = LazyCachedMapCollection<ChatChannel>()
    
    private var messageSearchController: ChatMessageSearchController?
    
    private var timer: Timer?
    
    /// Controls loading the channels.
    private var loadingNextChannels: Bool = false
    
    /// Checks if internet connection is available.
    private let networkReachability = NetworkReachability()
    
    /// Published variables.
    @Published public var channels = LazyCachedMapCollection<ChatChannel>() {
        didSet {
            queuedChannelsChanges = []
        }
    }

    @Published public var selectedChannel: ChannelSelectionInfo? {
        willSet {
            hideTabBar = newValue != nil
            if selectedChannel != nil && newValue == nil {
                // pop happened, apply the queued changes.
                if !queuedChannelsChanges.isEmpty {
                    channels = queuedChannelsChanges
                }
            }
        }
    }

    @Published public var deeplinkChannel: ChannelSelectionInfo? {
        willSet {
            hideTabBar = newValue != nil
        }
    }

    @Published public var swipedChannelId: String?
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
    @Published public var customAlertShown = false {
        didSet {
            hideTabBar = customAlertShown
        }
    }

    @Published public var searchText = "" {
        didSet {
            handleSearchTextChange()
        }
    }

    @Published public var loadingSearchResults = false
    @Published public var searchResults = [ChannelSelectionInfo]()
    @Published var hideTabBar = false
    
    var isSearching: Bool {
        !searchText.isEmpty
    }
    
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
        observeChannelDismiss()
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
        handleChannelAppearance()
        
        if index < (controller?.channels.count ?? 0) - 15 {
            return
        }

        if !loadingNextChannels {
            loadingNextChannels = true
            controller?.loadNextChannels(limit: 30) { [weak self] _ in
                guard let self = self else { return }
                self.loadingNextChannels = false
            }
        }
    }
    
    public func loadAdditionalSearchResults(index: Int) {
        guard let messageSearchController = messageSearchController else {
            return
        }
        
        if index < messageSearchController.messages.count - 10 {
            return
        }
        
        if !loadingNextChannels {
            loadingNextChannels = true
            messageSearchController.loadNextMessages { [weak self] _ in
                guard let self = self else { return }
                self.loadingNextChannels = false
                self.updateSearchResults()
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
        channel.membership != nil
    }
    
    public func controller(
        _ controller: ChatChannelListController,
        shouldListUpdatedChannel channel: ChatChannel
    ) -> Bool {
        channel.membership != nil
    }
    
    func checkTabBarAppearance() {
        guard #available(iOS 15, *) else { return }
        if hideTabBar != false {
            hideTabBar = false
        }
    }
    
    // MARK: - private
    
    private func handleChannelListChanges(_ controller: ChatChannelListController) {
        if selectedChannel != nil || !searchText.isEmpty || deeplinkChannel != nil {
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
            deeplinkChannel = chatController.channel?.channelSelectionInfo
            self.selectedChannelId = nil
        }
    }
    
    private func makeDefaultChannelListController() {
        guard let currentUserId = chatClient.currentUserId else {
            observeClientIdChange()
            return
        }
        controller = chatClient.channelListController(
            query: .init(filter: .containMembers(userIds: [currentUserId]))
        )
    }
    
    private func setupChannelListController() {
        controller?.delegate = self
        
        updateChannels()
        
        if channels.isEmpty {
            loading = networkReachability.isNetworkAvailable()
        }
        
        controller?.synchronize { [weak self] error in
            guard let self = self else { return }
            self.loading = false
            if error != nil {
                // handle error
                self.channelAlertType = .error
            } else {
                // access channels
                if self.selectedChannel == nil {
                    self.updateChannels()
                }
                self.checkForDeeplinks()
                self.setInitialChannelIfSplitView()
            }
        }
    }
    
    private func lastActiveMembers(for channel: ChatChannel) -> [ChatChannelMember] {
        channel.lastActiveMembers
            .sorted { $0.memberCreatedAt < $1.memberCreatedAt }
            .filter { $0.id != chatClient.currentUserId }
    }
    
    private func updateSearchResults() {
        guard let messageSearchController = messageSearchController else {
            return
        }

        searchResults = messageSearchController.messages
            .compactMap { message in
                message.makeChannelSelectionInfo(with: chatClient)
            }
    }
    
    private func handleSearchTextChange() {
        if !searchText.isEmpty {
            guard let userId = chatClient.currentUserId else { return }
            messageSearchController = chatClient.messageSearchController()
            let query = MessageSearchQuery(
                channelFilter: .containMembers(userIds: [userId]),
                messageFilter: .autocomplete(.text, text: searchText)
            )
            loadingSearchResults = true
            messageSearchController?.search(query: query, completion: { [weak self] _ in
                self?.loadingSearchResults = false
                self?.updateSearchResults()
            })
        } else {
            messageSearchController = nil
            searchResults = []
            updateChannels()
        }
    }
    
    private func observeClientIdChange() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            if self.chatClient.currentUserId != nil {
                self.stopTimer()
                self.makeDefaultChannelListController()
                self.setupChannelListController()
            }
        })
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateChannels() {
        channels = controller?.channels ?? LazyCachedMapCollection<ChatChannel>()
    }
    
    private func setInitialChannelIfSplitView() {
        if isIPad && deeplinkChannel == nil {
            selectedChannel = channels.first?.channelSelectionInfo
        }
    }
    
    private func handleChannelAppearance() {
        if !queuedChannelsChanges.isEmpty && selectedChannel == nil && deeplinkChannel == nil {
            channels = queuedChannelsChanges
        }
    }
    
    private func observeChannelDismiss() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateQueuedChannels),
            name: NSNotification.Name(channelDismissed),
            object: nil
        )
    }
    
    @objc private func updateQueuedChannels() {
        if !queuedChannelsChanges.isEmpty {
            withAnimation {
                channels = queuedChannelsChanges
            }
        }
    }
}

private let channelDismissed = "io.getstream.channelDismissed"

public func notifyChannelDismiss() {
    NotificationCenter.default.post(name: NSNotification.Name(channelDismissed), object: nil)
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
