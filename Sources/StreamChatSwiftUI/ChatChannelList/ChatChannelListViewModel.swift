//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine
import Foundation
import StreamChat
import SwiftUI
import UIKit

/// View model for the `ChatChannelListView`.
open class ChatChannelListViewModel: ObservableObject, ChatChannelListControllerDelegate, ChatMessageSearchControllerDelegate {
    
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
    @Published public var channels = LazyCachedMapCollection<ChatChannel>() {
        didSet {
            if !markDirty {
                queuedChannelsChanges = []
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

    private let searchType: ChannelListSearchType
    internal var channelListSearchController: ChatChannelListController?
    internal var messageSearchController: ChatMessageSearchController?

    @Published public var loadingSearchResults = false
    @Published public var searchResults = [ChannelSelectionInfo]()
    @Published var hideTabBar = false
    @Published public var searchText = "" {
        didSet {
            if searchText != oldValue {
                handleSearchTextChange()
            }
        }
    }

    public var isSearching: Bool {
        !searchText.isEmpty
    }
    
    /// Creates a view model for the `ChatChannelListView`.
    ///
    /// - Parameters:
    ///   - channelListController: A controller providing the list of channels. If nil, a controller with default `ChannelListQuery` is created.
    ///   - selectedChannelId: The id of a channel to select. If the channel is not part of the channel list query, no channel is selected.
    ///   Consider using ``ChatChannelScreen`` for presenting channels what might not be part of the initial page of channels.
    ///   - searchType: The type of data the channel list should perform a search.
    public init(
        channelListController: ChatChannelListController? = nil,
        selectedChannelId: String? = nil,
        searchType: ChannelListSearchType = .channels
    ) {
        self.searchType = searchType
        self.selectedChannelId = selectedChannelId
        if let channelListController = channelListController {
            controller = channelListController
        } else {
            makeDefaultChannelListController()
        }
        setupChannelListController()
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
        switch searchType {
        case .channels:
            loadAdditionalChannelSearchResults(index: index)
        case .messages:
            loadAdditionalMessageSearchResults(index: index)
        default:
            break
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
        let controller = chatClient.channelController(
            for: .init(type: channel.type, id: channel.cid.id)
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

    open func controller(
        _ controller: ChatChannelListController,
        shouldAddNewChannelToList channel: ChatChannel
    ) -> Bool {
        channel.membership != nil
    }

    open func controller(
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
    
    public func preselectChannelIfNeeded() {
        if isIPad && selectedChannel == nil && utils.messageListConfig.iPadSplitViewEnabled {
            selectedChannel = channels.first?.channelSelectionInfo
        }
    }
    
    // MARK: - ChatMessageSearchControllerDelegate
    
    public func controller(_ controller: ChatMessageSearchController, didChangeMessages changes: [ListChange<ChatMessage>]) {
        updateMessageSearchResults()
    }

    // MARK: - private

    private func handleChannelListChanges(_ controller: ChatChannelListController) {
        if selectedChannel != nil || !searchText.isEmpty {
            queuedChannelsChanges = controller.channels
            updateChannelsIfNeeded()
        } else {
            channels = controller.channels
        }
    }

    private var deeplinkCancellable: AnyCancellable?
    
    /// Checks for currently loaded channels for opening a channel with id.
    private func checkForDeeplinks() {
        guard let selectedChannelId else { return }
        do {
            let channelId = try ChannelId(cid: selectedChannelId)
            if let channel = channels.first(where: { $0.cid == channelId }) {
                selectedChannel = channel.channelSelectionInfo
            } else {
                // Start waiting for a channel list change because the channel is not part of the loaded list
                deeplinkCancellable = $channels
                    .map { Array($0) }
                    .compactMap { channels in
                        channels.first(where: { $0.cid == channelId })
                    }
                    .map(\.channelSelectionInfo)
                    .sink { [weak self] selection in
                        self?.deeplinkCancellable = nil
                        self?.selectedChannel = selection
                    }
            }
        } catch {
            log.error("Failed to select a channel with id \(selectedChannelId) (\(error))")
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

        loading = channels.isEmpty

        controller?.synchronize { [weak self] error in
            guard let self = self else { return }
            self.loading = false
            if error != nil {
                // handle error
                self.channelAlertType = .error
            } else {
                // access channels
                self.updateChannels()
                self.checkForDeeplinks()
            }
        }
    }

    private func lastActiveMembers(for channel: ChatChannel) -> [ChatChannelMember] {
        channel.lastActiveMembers
            .sorted { $0.memberCreatedAt < $1.memberCreatedAt }
            .filter { $0.id != chatClient.currentUserId }
    }

    private func handleSearchTextChange() {
        if searchText.isEmpty {
            clearSearchResults()
            return
        }

        switch searchType {
        case .messages:
            performMessageSearch()
        case .channels:
            performChannelSearch()
        default:
            break
        }
    }

    private func loadAdditionalMessageSearchResults(index: Int) {
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
                self.updateMessageSearchResults()
            }
        }
    }

    private func loadAdditionalChannelSearchResults(index: Int) {
        guard let channelListSearchController = self.channelListSearchController else {
            return
        }

        if index < channelListSearchController.channels.count - 10 {
            return
        }

        if !loadingNextChannels {
            loadingNextChannels = true
            channelListSearchController.loadNextChannels { [weak self] _ in
                guard let self = self else { return }
                self.loadingNextChannels = false
                self.updateChannelSearchResults()
            }
        }
    }

    private func performMessageSearch() {
        guard let userId = chatClient.currentUserId else { return }
        messageSearchController = chatClient.messageSearchController()
        messageSearchController?.delegate = self
        let query = MessageSearchQuery(
            channelFilter: .containMembers(userIds: [userId]),
            messageFilter: .autocomplete(.text, text: searchText)
        )
        loadingSearchResults = true
        messageSearchController?.search(query: query, completion: { [weak self] _ in
            self?.loadingSearchResults = false
            self?.updateMessageSearchResults()
        })
    }

    private func performChannelSearch() {
        guard let userId = chatClient.currentUserId else { return }
        var query = ChannelListQuery(
            filter: .and([
                .autocomplete(.name, text: searchText),
                .containMembers(userIds: [userId])
            ])
        )
        query.options = []
        channelListSearchController = chatClient.channelListController(query: query)
        loadingSearchResults = true
        channelListSearchController?.synchronize { [weak self] _ in
            self?.loadingSearchResults = false
            self?.updateChannelSearchResults()
        }
    }

    private func updateMessageSearchResults() {
        guard let messageSearchController = messageSearchController else {
            return
        }

        searchResults = messageSearchController.messages
            .compactMap { message in
                message.makeChannelSelectionInfo(with: chatClient)
            }
    }

    private func updateChannelSearchResults() {
        guard let channelListSearchController = self.channelListSearchController else {
            return
        }

        searchResults = channelListSearchController.channels
            .compactMap { channel in
                ChannelSelectionInfo(
                    channel: channel,
                    message: channel.previewMessage,
                    searchType: .channels
                )
            }
    }

    private func clearSearchResults() {
        messageSearchController?.delegate = nil
        messageSearchController = nil
        channelListSearchController?.delegate = nil
        channelListSearchController = nil
        searchResults = []
        updateChannels()
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
        channels = LazyCachedMapCollection(source: temp, map: { $0 })
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

internal let dismissChannel = "io.getstream.dismissChannel"

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

/// The type of data the channel list should perform a search.
public struct ChannelListSearchType: Equatable {
    let type: String

    private init(type: String) {
        self.type = type
    }

    public static var channels = Self(type: "channels")
    public static var messages = Self(type: "messages")
}
