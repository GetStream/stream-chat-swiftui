//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

extension MessageAction {
    /// Returns the default message actions.
    ///
    ///  - Parameters:
    ///     - message: the current message.
    ///     - chatClient: the chat client.
    ///     - onDimiss: called when the action is executed.
    ///  - Returns: array of `MessageAction`.
    public static func defaultActions<Factory: ViewFactory>(
        factory: Factory,
        for message: ChatMessage,
        channel: ChatChannel,
        chatClient: ChatClient,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> [MessageAction] {
        var messageActions = [MessageAction]()
        
        let replyAction = replyAction(
            for: message,
            channel: channel,
            onFinish: onFinish
        )
        messageActions.append(replyAction)
        
        if !message.isPartOfThread {
            let replyThread = threadReplyAction(
                factory: factory,
                for: message,
                channel: channel
            )
            messageActions.append(replyThread)
        }
        
        if message.isSentByCurrentUser {
            let editAction = editMessageAction(
                for: message,
                channel: channel,
                onFinish: onFinish
            )
            messageActions.append(editAction)

            let deleteAction = deleteMessageAction(
                for: message,
                channel: channel,
                chatClient: chatClient,
                onFinish: onFinish,
                onError: onError
            )
            
            messageActions.append(deleteAction)
        } else {
            let flagAction = flagMessageAction(
                for: message,
                channel: channel,
                chatClient: chatClient,
                onFinish: onFinish,
                onError: onError
            )
            
            messageActions.append(flagAction)
        }
        
        return messageActions
    }
    
    // MARK: - private
    
    private static func editMessageAction(
        for message: ChatMessage,
        channel: ChatChannel,
        onFinish: @escaping (MessageActionInfo) -> Void
    ) -> MessageAction {
        let editAction = MessageAction(
            title: L10n.Message.Actions.edit,
            iconName: "icn_edit",
            action: {
                onFinish(
                    MessageActionInfo(
                        message: message,
                        identifier: "edit"
                    )
                )
            },
            confirmationPopup: nil,
            isDestructive: false
        )
        
        return editAction
    }
    
    private static func replyAction(
        for message: ChatMessage,
        channel: ChatChannel,
        onFinish: @escaping (MessageActionInfo) -> Void
    ) -> MessageAction {
        let replyAction = MessageAction(
            title: L10n.Message.Actions.inlineReply,
            iconName: "icn_inline_reply",
            action: {
                onFinish(
                    MessageActionInfo(
                        message: message,
                        identifier: "inlineReply"
                    )
                )
            },
            confirmationPopup: nil,
            isDestructive: false
        )
        
        return replyAction
    }
    
    private static func threadReplyAction<Factory: ViewFactory>(
        factory: Factory,
        for message: ChatMessage,
        channel: ChatChannel
    ) -> MessageAction {
        var replyThread = MessageAction(
            title: L10n.Message.Actions.threadReply,
            iconName: "icn_thread_reply",
            action: {},
            confirmationPopup: nil,
            isDestructive: false
        )
        
        let destination = factory.makeMessageThreadDestination()
        replyThread.navigationDestination = AnyView(destination(channel, message))
        return replyThread
    }
    
    private static func deleteMessageAction(
        for message: ChatMessage,
        channel: ChatChannel,
        chatClient: ChatClient,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> MessageAction {
        let messageController = chatClient.messageController(
            cid: channel.cid,
            messageId: message.id
        )
        
        let deleteAction = {
            messageController.deleteMessage { error in
                if let error = error {
                    onError(error)
                } else {
                    onFinish(
                        MessageActionInfo(
                            message: message,
                            identifier: "delete"
                        )
                    )
                }
            }
        }
        
        let confirmationPopup = ConfirmationPopup(
            title: L10n.Message.Actions.Delete.confirmationTitle,
            message: L10n.Message.Actions.Delete.confirmationMessage,
            buttonTitle: L10n.Message.Actions.delete
        )
        
        let deleteMessage = MessageAction(
            title: L10n.Message.Actions.delete,
            iconName: "trash",
            action: deleteAction,
            confirmationPopup: confirmationPopup,
            isDestructive: true
        )
        
        return deleteMessage
    }
    
    private static func flagMessageAction(
        for message: ChatMessage,
        channel: ChatChannel,
        chatClient: ChatClient,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> MessageAction {
        let messageController = chatClient.messageController(
            cid: channel.cid,
            messageId: message.id
        )
        
        let flagAction = {
            messageController.flag { error in
                if let error = error {
                    onError(error)
                } else {
                    onFinish(
                        MessageActionInfo(
                            message: message,
                            identifier: "flag"
                        )
                    )
                }
            }
        }
        
        let confirmationPopup = ConfirmationPopup(
            title: L10n.Message.Actions.Flag.confirmationTitle,
            message: L10n.Message.Actions.Flag.confirmationMessage,
            buttonTitle: L10n.Message.Actions.flag
        )
        
        let flagMessage = MessageAction(
            title: L10n.Message.Actions.flag,
            iconName: "flag",
            action: flagAction,
            confirmationPopup: confirmationPopup,
            isDestructive: false
        )
        
        return flagMessage
    }
}
