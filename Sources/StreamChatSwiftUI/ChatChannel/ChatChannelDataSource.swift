//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import Combine

/// Data source providing the chat messages.
protocol MessagesDataSource: AnyObject {

    /// Called when the messages are updated.
    ///
    /// - Parameters:
    ///  - channelDataSource, the channel's data source.
    ///  - messages, the collection of updated messages.
    @MainActor func dataSource(
        channelDataSource: ChannelDataSource,
        didUpdateMessages messages: StreamCollection<ChatMessage>
    )

    /// Called when the channel is updated.
    /// - Parameters:
    ///  - channelDataSource: the channel's data source.
    ///  - channel: the updated channel.
    @MainActor func dataSource(
        channelDataSource: ChannelDataSource,
        didUpdateChannel channel: ChatChannel
    )
}

/// The data source for the channel.
protocol ChannelDataSource: AnyObject {

    /// Delegate implementing the `MessagesDataSource`.
    var delegate: MessagesDataSource? { get set }

    /// List of the messages.
    var messages: StreamCollection<ChatMessage> { get }
    
    /// Determines whether all new messages have been fetched.
    var hasLoadedAllNewerMessages: Bool { get }
    
    /// Returns the first unread message id.
    var firstUnreadMessageId: String? { get }

    /// Loads older messages.
    /// - Parameters:
    ///  - limit: the max number of messages to be retrieved.
    ///  - completion: called when the messages are loaded.
    func loadOlderMessages(
        limit: Int
    ) async throws
    
    /// Loads newer messages.
    /// - Parameters:
    ///  - limit: the max number of messages to be retrieved.
    ///  - completion: called when the messages are loaded.
    func loadNewerMessages(
        limit: Int
    ) async throws
    
    /// Loads a page around the provided message id.
    /// - Parameters:
    ///  - messageId: the id of the message.
    ///  - completion: called when the messages are loaded.
    func loadPageAroundMessageId(
        _ messageId: MessageId
    ) async throws
    
    /// Loads the first page of the channel.
    ///  - Parameter completion: called when the initial page is loaded.
    func loadFirstPage() async throws
}

/// Implementation of `ChannelDataSource`. Loads the messages of the channel.
class ChatChannelDataSource: ChannelDataSource {
    private var cancellables = Set<AnyCancellable>()

    let chat: Chat
    @MainActor weak var delegate: MessagesDataSource? {
        didSet {
            cancellables.removeAll()
            guard delegate != nil else { return }
            subscribeForMessageUpdates()
            subscribeForChannelUpdates()
            Task {
                try await chat.get(watch: true)
            }
        }
    }
    
    @MainActor var messages: StreamCollection<ChatMessage> {
        chat.state.messages
    }
    
    @MainActor var hasLoadedAllNewerMessages: Bool {
        chat.state.hasLoadedAllNewerMessages
    }
    
    @MainActor var firstUnreadMessageId: String? {
        chat.state.firstUnreadMessageId
    }

    @MainActor init(chat: Chat) {
        self.chat = chat
    }
    
    @MainActor private func subscribeForMessageUpdates() {
        self.chat.state.$messages.sink { [weak self] messages in
            guard let self else { return }
            self.delegate?.dataSource(
                channelDataSource: self,
                didUpdateMessages: messages
            )
        }
        .store(in: &cancellables)
    }
    
    @MainActor private func subscribeForChannelUpdates() {
        self.chat.state.$channel.sink { [weak self] (channel: ChatChannel?) in
            guard let self else { return }
            if let channel {
                self.delegate?.dataSource(
                    channelDataSource: self,
                    didUpdateChannel: channel
                )
            }
        }
        .store(in: &cancellables)
    }

    func loadOlderMessages(limit: Int) async throws {
        try await chat.loadOlderMessages(limit: limit)
    }
    
    func loadNewerMessages(limit: Int) async throws {
        try await chat.loadNewerMessages(limit: limit)
    }
    
    func loadPageAroundMessageId(_ messageId: MessageId) async throws {
        try await chat.loadMessages(around: messageId)
    }
    
    func loadFirstPage() async throws {
        try await chat.get(watch: true)
    }
}

/// Implementation of the `ChannelDataSource`. Loads the messages in a reply thread.
class MessageThreadDataSource: ChannelDataSource {

    let chat: Chat
    let messageId: MessageId
    var messageState: MessageState?
    
    weak var delegate: MessagesDataSource?
    
    @MainActor var messages: StreamCollection<ChatMessage> {
        self.messageState?.replies ?? StreamCollection([])
    }
    
    @MainActor var hasLoadedAllNewerMessages: Bool {
        self.messageState?.hasLoadedAllNextReplies ?? false
    }
    
    var firstUnreadMessageId: String? {
        return nil
    }
    
    private var cancellables = Set<AnyCancellable>()

    init(
        chat: Chat,
        messageId: MessageId
    ) {
        self.chat = chat
        self.messageId = messageId
        Task { @MainActor in
            self.messageState = try await chat.messageState(for: messageId)
            self.messageState?.$replies
                .sink(receiveValue: { [weak self] messages in
                guard let self else { return }
                self.delegate?.dataSource(
                    channelDataSource: self,
                    didUpdateMessages: messages
                )
            })
            .store(in: &cancellables)
            try await self.loadFirstPage()
        }
    }
    
    init(
        chat: Chat,
        messageId: MessageId,
        messageState: MessageState
    ) {
        self.chat = chat
        self.messageId = messageId
        self.messageState = messageState
        Task { @MainActor in
            self.messageState?.$replies
                .sink(receiveValue: { [weak self] messages in
                guard let self else { return }
                self.delegate?.dataSource(
                    channelDataSource: self,
                    didUpdateMessages: messages
                )
            })
            .store(in: &cancellables)
        }
        Task {
            try await self.loadFirstPage()
        }
    }

    func loadOlderMessages(limit: Int) async throws {
        try await chat.loadOlderReplies(for: self.messageId, limit: limit)
    }
    
    func loadNewerMessages(limit: Int) async throws {
        try await chat.loadNewerReplies(for: messageId, limit: limit)
    }
    
    func loadPageAroundMessageId(_ messageId: MessageId) async throws {
        try await chat.loadReplies(around: messageId, for: self.messageId)
    }
    
    func loadFirstPage() async throws {
        try await chat.loadReplies(for: messageId, pagination: MessagesPagination(pageSize: .messagesPageSize))
    }
}
