//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine
import Foundation
import StreamChat
import SwiftUI
import UIKit

/// View model for the `ChatChannelListView`.
@MainActor open class ChatChannelListViewModel: ObservableObject {
    /// Context provided dependencies.
    @Injected(\.chatClient) private var chatClient: ChatClient
    @Injected(\.images) private var images: Images
    @Injected(\.utils) private var utils: Utils

    /// Context provided utils.
    internal let channelNamer = InjectedValues[\.utils].channelNamer

    /// The maximum number of images that combine to form a single avatar
    private let maxNumberOfImagesInCombinedAvatar = 4

    private var channelList: ChannelList? {
        didSet {
            if channelList != nil {
                subscribeToChannelListChanges()
            }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()

    /// Used when screen is shown from a deeplink.
    private var selectedChannelId: String?

    /// Temporarly holding changes while message list is shown.
    private var queuedChannelsChanges = StreamCollection<ChatChannel>([])

    private var messageSearch: MessageSearch?

    private var timer: Timer?

    /// Controls loading the channels.
    public private(set) var loadingNextChannels: Bool = false

    /// Checks if internet connection is available.
    private let networkReachability = NetworkReachability()

    /// Checks if the queued changes are completely applied.
    private var markDirty = false

    /// Index of the selected channel.
    private var selectedChannelIndex: Int?

    /// Published variables.
    @Published public var channels = StreamCollection<ChatChannel>([]) {
        didSet {
            if !markDirty {
                queuedChannelsChanges = StreamCollection<ChatChannel>([])
            } else {
                markDirty = false
            }
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
            if newValue == nil {
                selectedChannelIndex = nil
            } else if utils.messageListConfig.updateChannelsFromMessageList {
                selectedChannelIndex = channels.firstIndex(where: { channel in
                    channel.cid.rawValue == newValue?.channel.cid.rawValue
                })
            }
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

    public var isSearching: Bool {
        !searchText.isEmpty
    }

    public init(
        channelList: ChannelList? = nil,
        selectedChannelId: String? = nil
    ) {
        self.selectedChannelId = selectedChannelId
        self.channels = channelList?.state.channels ?? StreamCollection([])
        setupChannelList(channelList)
        observeChannelDismiss()
        observeHideTabBar()
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

        if index < (channelList?.state.channels.count ?? 0) - 15 {
            return
        }

        if !loadingNextChannels {
            loadingNextChannels = true
            Task {
                _ = try? await channelList?.loadMoreChannels()
                self.loadingNextChannels = false
            }
        }
    }

    public func loadAdditionalSearchResults(index: Int) {
        guard let messageSearch = messageSearch else {
            return
        }

        if index < messageSearch.state.messages.count - 10 {
            return
        }

        if !loadingNextChannels {
            loadingNextChannels = true
            Task {
                do {
                    try await messageSearch.loadMoreMessages()
                    updateSearchResults()
                } catch {
                    log.error("Error loading search results")
                }
                self.loadingNextChannels = false
            }
        }
    }

    /// Determines whether an online indicator is shown.
    ///
    /// - Parameter channel: the provided channel.
    /// - Returns: Boolean whether the indicator is shown.
    public func onlineIndicatorShown(for channel: ChatChannel) -> Bool {
        channel.shouldShowOnlineIndicator
    }

    public func onDeleteTapped(channel: ChatChannel) {
        channelAlertType = .deleteChannel(channel)
    }

    public func onMoreTapped(channel: ChatChannel) {
        customChannelPopupType = .moreActions(channel)
    }

    public func delete(channel: ChatChannel) {
        let chat = chatClient.makeChat(for: channel.cid)
        Task {
            do {
                try await chat.delete()
            } catch {
                channelAlertType = .error
            }
        }
    }

    public func showErrorPopup(_ error: Error?) {
        channelAlertType = .error
    }
    
    func checkTabBarAppearance() {
        guard #available(iOS 15, *) else { return }
        if hideTabBar != false {
            hideTabBar = false
        }
    }
    
    public func preselectChannelIfNeeded() {
        if isIPad && selectedChannel == nil && utils.messageListConfig.iPadSplitViewEnabled {
            selectedChannel = channels.first?.channelSelectionInfo
        }
    }

    // MARK: - private
    
    private func subscribeToChannelListChanges() {
        channelList?.state.$channels
            .sink(receiveValue: { [weak self] channels in
            self?.handleChannelListChanges(channels)
        })
        .store(in: &cancellables)
    }

    private func handleChannelListChanges(_ channels: StreamCollection<ChatChannel>) {
        if selectedChannel != nil || !searchText.isEmpty {
            queuedChannelsChanges = channels
            updateChannelsIfNeeded()
        } else {
            self.channels = channels
        }
    }

    private func checkForDeeplinks() {
        if let selectedChannelId = selectedChannelId,
           let channelId = try? ChannelId(cid: selectedChannelId) {
            let chat = chatClient.makeChat(for: channelId)
            selectedChannel = chat.state.channel?.channelSelectionInfo
            self.selectedChannelId = nil
        }
    }

    private func setupChannelList(_ list: ChannelList? = nil) {
        guard let currentUserId = chatClient.currentUserId else {
            observeClientIdChange()
            return
        }
        Task {
            do {
                if let list {
                    channelList = list
                } else {
                    let query = ChannelListQuery(filter: .containMembers(userIds: [currentUserId]))
                    channelList = chatClient.makeChannelList(with: query)
                    loading = true
                    try await channelList?.get()
                    self.loading = false
                }
                // access channels
                if self.selectedChannel == nil {
                    self.updateChannels()
                }
                self.checkForDeeplinks()
            } catch {
                self.loading = false
                self.channelAlertType = .error
            }
        }
    }

    private func lastActiveMembers(for channel: ChatChannel) -> [ChatChannelMember] {
        channel.lastActiveMembers
            .sorted { $0.memberCreatedAt < $1.memberCreatedAt }
            .filter { $0.id != chatClient.currentUserId }
    }

    private func updateSearchResults() {
        guard let messageSearch = messageSearch else {
            return
        }

        searchResults = messageSearch.state.messages
            .compactMap { message in
                message.makeChannelSelectionInfo(with: chatClient)
            }
    }

    private func handleSearchTextChange() {
        if !searchText.isEmpty {
            guard let userId = chatClient.currentUserId else { return }
            messageSearch = chatClient.makeMessageSearch()
            let query = MessageSearchQuery(
                channelFilter: .containMembers(userIds: [userId]),
                messageFilter: .autocomplete(.text, text: searchText)
            )
            loadingSearchResults = true
            Task {
                do {
                    try await messageSearch?.search(query: query)
                } catch {
                    log.error("Error loading search results")
                }
                loadingSearchResults = false
                updateSearchResults()
            }
        } else {
            messageSearch = nil
            searchResults = []
            updateChannels()
        }
    }

    private func observeClientIdChange() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            runOnMainActor {
                if self.chatClient.currentUserId != nil {
                    self.stopTimer()
                    self.setupChannelList()
                }
            }
        })
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateChannels() {
        channels = channelList?.state.channels ?? StreamCollection<ChatChannel>([])
    }

    private func handleChannelAppearance() {
        if !queuedChannelsChanges.isEmpty && selectedChannel == nil {
            channels = queuedChannelsChanges
        } else if !queuedChannelsChanges.isEmpty {
            handleQueuedChanges()
        } else if queuedChannelsChanges.isEmpty && selectedChannel != nil {
            if selectedChannel?.injectedChannelInfo == nil {
                selectedChannel?.injectedChannelInfo = InjectedChannelInfo(unreadCount: 0)
            }
        }
    }

    private func updateChannelsIfNeeded() {
        if utils.messageListConfig.updateChannelsFromMessageList
            && ((selectedChannelIndex ?? 0) < 8)
            && !utils.messageCachingUtils.messageThreadShown {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.handleChannelAppearance()
            }
        }
    }

    private func handleQueuedChanges() {
        let selected = selectedChannel?.channel
        var index: Int?
        var temp = Array(queuedChannelsChanges)
        for i in 0..<temp.count {
            let current = temp[i]
            if current.cid == selected?.cid {
                index = i
                selectedChannel?.injectedChannelInfo = InjectedChannelInfo(
                    subtitle: current.subtitleText,
                    unreadCount: 0,
                    timestamp: current.timestampText,
                    lastMessageAt: current.lastMessageAt,
                    latestMessages: current.latestMessages
                )
                break
            }
        }
        if let index = index, let selected = selected {
            temp[index] = selected
        }
        markDirty = true
        channels = StreamCollection(temp)
    }

    private func observeChannelDismiss() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dismissPresentedChannel),
            name: NSNotification.Name(dismissChannel),
            object: nil
        )
    }

    private func observeHideTabBar() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleHideTabBar),
            name: NSNotification.Name(hideTabBarNotification),
            object: nil
        )
    }

    @objc private func dismissPresentedChannel() {
        selectedChannel = nil
    }

    @objc private func handleHideTabBar() {
        hideTabBar = true
    }
}

private let dismissChannel = "io.getstream.dismissChannel"

private let hideTabBarNotification = "io.getstream.hideTabBar"

func notifyChannelDismiss() {
    NotificationCenter.default.post(name: NSNotification.Name(dismissChannel), object: nil)
}

public func notifyHideTabBar() {
    NotificationCenter.default.post(name: NSNotification.Name(hideTabBarNotification), object: nil)
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
