//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat

/// Data source providing the chat messages.
protocol MessagesDataSource: AnyObject {

    /// Called when the messages are updated.
    ///
    /// - Parameters:
    ///  - channelDataSource, the channel's data source.
    ///  - messages, the collection of updated messages.
    func dataSource(
        channelDataSource: ChannelDataSource,
        didUpdateMessages messages: LazyCachedMapCollection<ChatMessage>,
        changes: [ListChange<ChatMessage>]
    )

    /// Called when the channel is updated.
    /// - Parameters:
    ///  - channelDataSource: the channel's data source.
    ///  - channel: the updated channel.
    ///  - channelController: the channel's controller.
    func dataSource(
        channelDataSource: ChannelDataSource,
        didUpdateChannel channel: EntityChange<ChatChannel>,
        channelController: ChatChannelController
    )
}

/// The data source for the channel.
protocol ChannelDataSource: AnyObject {

    /// Delegate implementing the `MessagesDataSource`.
    var delegate: MessagesDataSource? { get set }

    /// List of the messages.
    var messages: LazyCachedMapCollection<ChatMessage> { get }
    
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
        limit: Int,
        completion: ((Error?) -> Void)?
    )
    
    /// Loads newer messages.
    /// - Parameters:
    ///  - limit: the max number of messages to be retrieved.
    ///  - completion: called when the messages are loaded.
    func loadNextMessages(
        limit: Int,
        completion: ((Error?) -> Void)?
    )
    
    /// Loads a page around the provided message id.
    /// - Parameters:
    ///  - messageId: the id of the message.
    ///  - completion: called when the messages are loaded.
    func loadPageAroundMessageId(
        _ messageId: MessageId,
        completion: ((Error?) -> Void)?
    )
    
    /// Loads the first page of the channel.
    ///  - Parameter completion: called when the initial page is loaded.
    func loadFirstPage(_ completion: ((_ error: Error?) -> Void)?)
}

/// Implementation of `ChannelDataSource`. Loads the messages of the channel.
class ChatChannelDataSource: ChannelDataSource, ChatChannelControllerDelegate {

    let controller: ChatChannelController
    weak var delegate: MessagesDataSource?
    
    var messages: LazyCachedMapCollection<ChatMessage> {
        controller.messages
    }
    
    var hasLoadedAllNextMessages: Bool {
        controller.hasLoadedAllNextMessages
    }
    
    var firstUnreadMessageId: String? {
        controller.firstUnreadMessageId
    }

    init(controller: ChatChannelController) {
        self.controller = controller
        self.controller.delegate = self
    }

    public func channelController(
        _ channelController: ChatChannelController,
        didUpdateMessages changes: [ListChange<ChatMessage>]
    ) {
        delegate?.dataSource(
            channelDataSource: self,
            didUpdateMessages: channelController.messages,
            changes: changes
        )
    }

    func channelController(
        _ channelController: ChatChannelController,
        didUpdateChannel channel: EntityChange<ChatChannel>
    ) {
        delegate?.dataSource(
            channelDataSource: self,
            didUpdateChannel: channel,
            channelController: channelController
        )
    }

    func loadPreviousMessages(
        before messageId: MessageId?,
        limit: Int,
        completion: ((Error?) -> Void)?
    ) {
        controller.loadPreviousMessages(
            before: messageId,
            limit: limit,
            completion: completion
        )
    }
    
    func loadNextMessages(limit: Int, completion: ((Error?) -> Void)?) {
        controller.loadNextMessages(limit: limit, completion: completion)
    }
    
    func loadPageAroundMessageId(
        _ messageId: MessageId,
        completion: ((Error?) -> Void)?
    ) {
        controller.loadPageAroundMessageId(messageId, completion: completion)
    }
    
    func loadFirstPage(_ completion: ((_ error: Error?) -> Void)?) {
        controller.loadFirstPage(completion)
    }
}

/// Implementation of the `ChannelDataSource`. Loads the messages in a reply thread.
class MessageThreadDataSource: ChannelDataSource, ChatMessageControllerDelegate {

    let channelController: ChatChannelController
    let messageController: ChatMessageController
    
    weak var delegate: MessagesDataSource?
    
    var messages: LazyCachedMapCollection<ChatMessage> {
        messageController.replies
    }
    
    var hasLoadedAllNextMessages: Bool {
        messageController.hasLoadedAllNextReplies
    }
    
    var firstUnreadMessageId: String? {
        channelController.firstUnreadMessageId
    }

    init(
        channelController: ChatChannelController,
        messageController: ChatMessageController
    ) {
        self.channelController = channelController
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
            didUpdateMessages: controller.replies,
            changes: changes
        )
    }

    func messageController(
        _ controller: ChatMessageController,
        didChangeMessage change: EntityChange<ChatMessage>
    ) {
        delegate?.dataSource(
            channelDataSource: self,
            didUpdateMessages: controller.replies,
            changes: []
        )
    }

    func loadPreviousMessages(
        before messageId: MessageId?,
        limit: Int,
        completion: ((Error?) -> Void)?
    ) {
        messageController.loadPreviousReplies(
            before: messageId,
            limit: limit,
            completion: completion
        )
    }
    
    func loadNextMessages(limit: Int, completion: ((Error?) -> Void)?) {
        messageController.loadNextReplies(limit: limit, completion: completion)
    }
    
    func loadPageAroundMessageId(
        _ messageId: MessageId,
        completion: ((Error?) -> Void)?
    ) {
        messageController.loadPageAroundReplyId(messageId, completion: completion)
    }
    
    func loadFirstPage(_ completion: ((_ error: Error?) -> Void)?) {
        messageController.loadFirstPage(completion)
    }
}
