//
// Copyright © 2021 Stream.io Inc. All rights reserved.
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
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> [MessageAction] {
        var messageActions = [MessageAction]()
        
        if !message.isPartOfThread {
            var replyThread = MessageAction(
                title: L10n.Message.Actions.threadReply,
                iconName: "icn_thread_reply",
                action: onDismiss,
                confirmationPopup: nil,
                isDestructive: false
            )
            
            let destination = factory.makeMessageThreadDestination()
            replyThread.navigationDestination = AnyView(destination(channel, message))
            
            messageActions.append(replyThread)
        }

        if message.isSentByCurrentUser {
            let deleteAction = deleteMessageAction(
                for: message,
                channel: channel,
                chatClient: chatClient,
                onDismiss: onDismiss,
                onError: onError
            )
            
            messageActions.append(deleteAction)
        } else {
            let flagAction = flagMessageAction(
                for: message,
                channel: channel,
                chatClient: chatClient,
                onDismiss: onDismiss,
                onError: onError
            )
            
            messageActions.append(flagAction)
        }
        
        return messageActions
    }
    
    private static func deleteMessageAction(
        for message: ChatMessage,
        channel: ChatChannel,
        chatClient: ChatClient,
        onDismiss: @escaping () -> Void,
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
                    onDismiss()
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
        onDismiss: @escaping () -> Void,
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
                    onDismiss()
                }
            }
        }
        
        let confirmationPopup = ConfirmationPopup(
            title: L10n.Message.Actions.Flag.confirmationTitle,
            message: L10n.Message.Actions.Flag.confirmationMessage,
            buttonTitle: L10n.Message.Actions.flag
        )
        
        let flageMessage = MessageAction(
            title: L10n.Message.Actions.flag,
            iconName: "flag",
            action: flagAction,
            confirmationPopup: confirmationPopup,
            isDestructive: false
        )
        
        return flageMessage
    }
}
