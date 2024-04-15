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
        didUpdateChannel channel: EntityChange<ChatChannel>
    )
}

/// The data source for the channel.
protocol ChannelDataSource: AnyObject {

    /// Delegate implementing the `MessagesDataSource`.
    var delegate: MessagesDataSource? { get set }

    /// List of the messages.
    var messages: StreamCollection<ChatMessage> { get }
    
    /// Determines whether all new messages have been fetched.
    var hasLoadedAllNextMessages: Bool { get }
    
    /// Returns the first unread message id.
    var firstUnreadMessageId: String? { get }

    /// Loads the previous messages.
    /// - Parameters:
    ///  - messageId: the id of the last received message.
    ///  - limit: the max number of messages to be retrieved.
    ///  - completion: called when the messages are loaded.
    func loadPreviousMessages(
        before messageId: MessageId?,
        limit: Int
    ) async throws
    
    /// Loads newer messages.
    /// - Parameters:
    ///  - limit: the max number of messages to be retrieved.
    ///  - completion: called when the messages are loaded.
    func loadNextMessages(
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
    weak var delegate: MessagesDataSource?
    
    @MainActor var messages: StreamCollection<ChatMessage> {
        chat.state.messages
    }
    
    @MainActor var hasLoadedAllNextMessages: Bool {
        chat.state.hasLoadedAllNextMessages
    }
    
    @MainActor var firstUnreadMessageId: String? {
        chat.state.firstUnreadMessageId
    }

    @MainActor init(chat: Chat) {
        self.chat = chat
        subscribeForMessageUpdates()
        subscribeForChannelUpdates()
    }
    
    @MainActor private func subscribeForMessageUpdates() {
        self.chat.state.$messages.sink { [weak self] messages in
            guard let self else { return }
            delegate?.dataSource(
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
                delegate?.dataSource(
                    channelDataSource: self,
                    didUpdateChannel: .update(channel)
                )
            }
        }
        .store(in: &cancellables)
    }

    func loadPreviousMessages(
        before messageId: MessageId?,
        limit: Int
    ) async throws {
        try await chat.loadPreviousMessages(before: messageId, limit: limit)
    }
    
    func loadNextMessages(limit: Int) async throws {
        try await chat.loadNextMessages(limit: limit)
    }
    
    func loadPageAroundMessageId(
        _ messageId: MessageId
    ) async throws {
        try await chat.loadMessages(around: messageId)
    }
    
    func loadFirstPage() async throws {
        try await chat.loadMessagesFirstPage()
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
    
    @MainActor var hasLoadedAllNextMessages: Bool {
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
            self.messageState = try await chat.makeMessageState(for: messageId)
            self.messageState?.$replies
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] messages in
                guard let self else { return }
                delegate?.dataSource(
                    channelDataSource: self,
                    didUpdateMessages: StreamCollection(messages)
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
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] messages in
                guard let self else { return }
                delegate?.dataSource(
                    channelDataSource: self,
                    didUpdateMessages: StreamCollection(messages)
                )
            })
            .store(in: &cancellables)
        }
        Task {
            try await self.loadFirstPage()
        }
    }

    func loadPreviousMessages(
        before messageId: MessageId?,
        limit: Int
    ) async throws {
        try await chat.loadReplies(before: messageId, of: self.messageId)
    }
    
    func loadNextMessages(limit: Int) async throws {
        try await chat.loadReplies(after: nil, of: messageId, limit: limit)
    }
    
    func loadPageAroundMessageId(
        _ messageId: MessageId
    ) async throws {
        try await chat.loadMessages(around: messageId)
    }
    
    func loadFirstPage() async throws {
        try await chat.loadRepliesFirstPage(of: messageId)
    }
}
