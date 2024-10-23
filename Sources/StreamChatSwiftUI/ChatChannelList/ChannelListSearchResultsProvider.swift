//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat

/// The type of data the channel list should perform a search.
public struct ChannelListSearchType: Equatable {
    let type: String

    private init(type: String) {
        self.type = type
    }

    public static var channels = Self(type: "channels")
    public static var messages = Self(type: "messages")
}

/// Protocol for providing search results in the channel list
protocol ChannelListSearchResultsProvider: ObservableObject {
    var searchResults: AnyPublisher<[ChannelSelectionInfo], Never> { get }
    var loadingSearchResults: AnyPublisher<Bool, Never> { get }
    var loadingNextSearchResults: AnyPublisher<Bool, Never> { get }

    func performSearch(searchText: String)
    func loadAdditionalSearchResults(at index: Int)
    func clearSearchResults()
}

/// Provider for searching messages in the channel list
class ChannelListSearchMessagesProvider: ChannelListSearchResultsProvider, ChatMessageSearchControllerDelegate {
    @Injected(\.chatClient) public var chatClient: ChatClient

    @Published private var _searchResults: [ChannelSelectionInfo] = []
    public var searchResults: AnyPublisher<[ChannelSelectionInfo], Never> {
        $_searchResults.eraseToAnyPublisher()
    }

    @Published private var _loadingSearchResults: Bool = false
    public var loadingSearchResults: AnyPublisher<Bool, Never> {
        $_loadingSearchResults.eraseToAnyPublisher()
    }

    @Published private var _loadingNextSearchResults: Bool = false
    public var loadingNextSearchResults: AnyPublisher<Bool, Never> {
        $_loadingNextSearchResults.eraseToAnyPublisher()
    }

    private var messageSearchController: ChatMessageSearchController?

    public func performSearch(searchText: String) {
        guard let userId = chatClient.currentUserId else { return }
        messageSearchController = chatClient.messageSearchController()
        messageSearchController?.delegate = self
        let query = MessageSearchQuery(
            channelFilter: .containMembers(userIds: [userId]),
            messageFilter: .autocomplete(.text, text: searchText)
        )
        _loadingSearchResults = true
        messageSearchController?.search(query: query, completion: { [weak self] _ in
            self?._loadingSearchResults = false
            self?.updateSearchResults()
        })
    }

    public func loadAdditionalSearchResults(at index: Int) {
        guard let messageSearchController = messageSearchController else { return }

        if index < messageSearchController.messages.count - 10 { return }

        if !_loadingNextSearchResults {
            _loadingNextSearchResults = true
            messageSearchController.loadNextMessages { [weak self] _ in
                guard let self = self else { return }
                self._loadingNextSearchResults = false
                self.updateSearchResults()
            }
        }
    }

    public func clearSearchResults() {
        messageSearchController?.delegate = nil
        messageSearchController = nil
        _searchResults = []
    }

    public func controller(_ controller: ChatMessageSearchController, didChangeMessages changes: [ListChange<ChatMessage>]) {
        updateSearchResults()
    }

    private func updateSearchResults() {
        guard let messageSearchController = messageSearchController else { return }

        _searchResults = messageSearchController.messages
            .compactMap { message in
                message.makeChannelSelectionInfo(with: chatClient)
            }
    }
}

/// Provider for searching channels in the channel list
class ChannelListSearchChannelsProvider: ChannelListSearchResultsProvider, ChatChannelListControllerDelegate {
    @Injected(\.chatClient) public var chatClient: ChatClient
    private var channelListSearchController: ChatChannelListController?

    @Published private var _searchResults: [ChannelSelectionInfo] = []
    public var searchResults: AnyPublisher<[ChannelSelectionInfo], Never> {
        $_searchResults.eraseToAnyPublisher()
    }

    @Published private var _loadingSearchResults: Bool = false
    public var loadingSearchResults: AnyPublisher<Bool, Never> {
        $_loadingSearchResults.eraseToAnyPublisher()
    }

    @Published private var _loadingNextSearchResults: Bool = false
    public var loadingNextSearchResults: AnyPublisher<Bool, Never> {
        $_loadingNextSearchResults.eraseToAnyPublisher()
    }

    public func performSearch(searchText: String) {
        guard let userId = chatClient.currentUserId else { return }
        var query = ChannelListQuery(
            filter: .and([
                .autocomplete(.name, text: searchText),
                .containMembers(userIds: [userId])
            ])
        )
        query.options = []
        channelListSearchController = chatClient.channelListController(query: query)
        channelListSearchController?.delegate = self
        _loadingSearchResults = true
        channelListSearchController?.synchronize { [weak self] _ in
            self?._loadingSearchResults = false
            self?.updateSearchResults()
        }
    }

    public func loadAdditionalSearchResults(at index: Int) {
        guard let channelListSearchController = self.channelListSearchController else { return }

        if index < channelListSearchController.channels.count - 10 { return }

        if !_loadingNextSearchResults {
            _loadingNextSearchResults = true
            channelListSearchController.loadNextChannels { [weak self] _ in
                guard let self = self else { return }
                self._loadingNextSearchResults = false
                self.updateSearchResults()
            }
        }
    }

    public func clearSearchResults() {
        channelListSearchController?.delegate = nil
        channelListSearchController = nil
        _searchResults = []
    }

    public func controller(
        _ controller: ChatChannelListController,
        didChangeChannels changes: [ListChange<ChatChannel>]
    ) {
        updateSearchResults()
    }

    private func updateSearchResults() {
        guard let channelListSearchController = self.channelListSearchController else { return }

        _searchResults = channelListSearchController.channels
            .compactMap { channel in
                ChannelSelectionInfo(
                    channel: channel,
                    message: channel.previewMessage,
                    searchType: .channels
                )
            }
    }
}
