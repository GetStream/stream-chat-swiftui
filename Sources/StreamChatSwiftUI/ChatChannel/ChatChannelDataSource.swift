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
    func dataSource(
        channelDataSource: ChannelDataSource,
        didUpdateMessages messages: StreamCollection<ChatMessage>,
        changes: [ListChange<ChatMessage>]
    )

    /// Called when the channel is updated.
    /// - Parameters:
    ///  - channelDataSource: the channel's data source.
    ///  - channel: the updated channel.
    ///  - channelController: the channel's controller.
    func dataSource(
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
class ChatChannelDataSource: ChannelDataSource, ChatChannelControllerDelegate {
    
    private var cancellables = Set<AnyCancellable>()

    let chat: Chat
    weak var delegate: MessagesDataSource?
    
    var messages: StreamCollection<ChatMessage> {
        chat.state.messages
    }
    
    var hasLoadedAllNextMessages: Bool {
        chat.state.hasLoadedAllNextMessages
    }
    
    var firstUnreadMessageId: String? {
//        chat.state.firstUnreadMessageId
        return nil
    }

    init(chat: Chat) {
        self.chat = chat
        subscribeForMessageUpdates()
        subscribeForChannelUpdates()
    }
    
    private func subscribeForMessageUpdates() {
        self.chat.state.$messages.sink { [weak self] messages in
            guard let self else { return }
            delegate?.dataSource(
                channelDataSource: self,
                didUpdateMessages: messages,
                changes: [] //TODO: this
            )
        }
        .store(in: &cancellables)
    }
    
    private func subscribeForChannelUpdates() {
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
        try await chat.loadMessages(before: messageId, limit: limit)
    }
    
    func loadNextMessages(limit: Int) async throws {
        try await chat.loadMessages(after: nil, limit: limit)
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
class MessageThreadDataSource: ChannelDataSource, ChatMessageControllerDelegate {

    let chat: Chat
    let messageController: ChatMessageController
    
    weak var delegate: MessagesDataSource?
    
    var messages: StreamCollection<ChatMessage> {
//        messageController.replies
        StreamCollection(messageController.replies)
    }
    
    var hasLoadedAllNextMessages: Bool {
        messageController.hasLoadedAllNextReplies
    }
    
    var firstUnreadMessageId: String? {
//        channelController.firstUnreadMessageId
        return nil
    }

    init(
        chat: Chat,
        messageController: ChatMessageController
    ) {
        self.chat = chat
        self.messageController = messageController
        self.messageController.delegate = self
        self.messageController.loadPreviousReplies { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.dataSource(
                channelDataSource: self,
                didUpdateMessages: self.messages,
                changes: []
            )
        }
    }

    func messageController(
        _ controller: ChatMessageController,
        didChangeReplies changes: [ListChange<ChatMessage>]
    ) {
        delegate?.dataSource(
            channelDataSource: self,
            didUpdateMessages: StreamCollection(controller.replies),
            changes: changes
        )
    }

    func messageController(
        _ controller: ChatMessageController,
        didChangeMessage change: EntityChange<ChatMessage>
    ) {
        delegate?.dataSource(
            channelDataSource: self,
            didUpdateMessages: StreamCollection(controller.replies),
            changes: []
        )
    }

    func loadPreviousMessages(
        before messageId: MessageId?,
        limit: Int
    ) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            messageController.loadPreviousReplies(
                before: messageId,
                limit: limit,
                completion: { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
            )
        }
    }
    
    func loadNextMessages(limit: Int) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            messageController.loadNextReplies(
                limit: limit,
                completion: { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
            )
        }
    }
    
    func loadPageAroundMessageId(
        _ messageId: MessageId
    ) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            messageController.loadPageAroundReplyId(
                messageId,
                completion: { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
            )
        }
    }
    
    func loadFirstPage() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            messageController.loadFirstPage() { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
            }
    }
}
