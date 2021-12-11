//
// Copyright © 2021 Stream.io Inc. All rights reserved.
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
        didUpdateMessages messages: LazyCachedMapCollection<ChatMessage>
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
}

/// Implementation of `ChannelDataSource`. Loads the messages of the channel.
class ChatChannelDataSource: ChannelDataSource, ChatChannelControllerDelegate {

    let controller: ChatChannelController
    weak var delegate: MessagesDataSource?
    var messages: LazyCachedMapCollection<ChatMessage> {
        controller.messages
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
            didUpdateMessages: channelController.messages
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
}

/// Implementation of the `ChannelDataSource`. Loads the messages in a reply thread.
class MessageThreadDataSource: ChannelDataSource, ChatMessageControllerDelegate {
    
    let channelController: ChatChannelController
    let messageController: ChatMessageController
    weak var delegate: MessagesDataSource?
    var messages: LazyCachedMapCollection<ChatMessage> {
        messageController.replies
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
            self.delegate?.dataSource(channelDataSource: self, didUpdateMessages: self.messages)
        }
    }
    
    func messageController(
        _ controller: ChatMessageController,
        didChangeReplies changes: [ListChange<ChatMessage>]
    ) {
        delegate?.dataSource(channelDataSource: self, didUpdateMessages: controller.replies)
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
}
