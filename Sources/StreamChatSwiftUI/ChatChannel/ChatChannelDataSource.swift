//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat

protocol MessagesDataSource: AnyObject {
    
    func dataSource(
        channelDataSource: ChannelDataSource,
        didUpdateMessages messages: LazyCachedMapCollection<ChatMessage>
    )
    
    func dataSource(
        channelDataSource: ChannelDataSource,
        didUpdateChannel channel: EntityChange<ChatChannel>,
        channelController: ChatChannelController
    )
}

protocol ChannelDataSource: AnyObject {
    
    var delegate: MessagesDataSource? { get set }
    
    var messages: LazyCachedMapCollection<ChatMessage> { get }
    
    func loadPreviousMessages(
        before messageId: MessageId?,
        limit: Int,
        completion: ((Error?) -> Void)?
    )
}

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
        self.messageController.loadPreviousReplies()
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
