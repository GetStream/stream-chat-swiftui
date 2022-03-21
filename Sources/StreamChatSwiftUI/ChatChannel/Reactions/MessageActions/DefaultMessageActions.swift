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
        
        if message.localState == .sendingFailed {
            messageActions = messageNotSentActions(
                for: message,
                channel: channel,
                chatClient: chatClient,
                onFinish: onFinish,
                onError: onError
            )
            return messageActions
        } else if message.localState == .pendingSend
            && message.messageId.contains("\(LocalAttachmentState.uploadingFailed)") {
            messageActions = editAndDeleteActions(
                for: message,
                channel: channel,
                chatClient: chatClient,
                onFinish: onFinish,
                onError: onError
            )
            return messageActions
        }
        
        if channel.config.repliesEnabled {
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
        }
        
        if message.pinDetails != nil {
            let unpinAction = unpinMessageAction(
                for: message,
                channel: channel,
                chatClient: chatClient,
                onFinish: onFinish,
                onError: onError
            )
            
            messageActions.append(unpinAction)
        } else {
            let pinAction = pinMessageAction(
                for: message,
                channel: channel,
                chatClient: chatClient,
                onFinish: onFinish,
                onError: onError
            )
            
            messageActions.append(pinAction)
        }
        
        if !message.text.isEmpty {
            let copyAction = copyMessageAction(
                for: message,
                onFinish: onFinish
            )
            
            messageActions.append(copyAction)
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
            
            if channel.config.mutesEnabled {
                let author = message.author
                let currentUser = chatClient.currentUserController().currentUser
                let isMuted = currentUser?.mutedUsers.contains(message.author) ?? false
                if isMuted {
                    let unmuteAction = unmuteAction(
                        for: message,
                        channel: channel,
                        chatClient: chatClient,
                        userToUnmute: author,
                        onFinish: onFinish,
                        onError: onError
                    )
                    messageActions.append(unmuteAction)
                } else {
                    let muteAction = muteAction(
                        for: message,
                        channel: channel,
                        chatClient: chatClient,
                        userToMute: author,
                        onFinish: onFinish,
                        onError: onError
                    )
                    messageActions.append(muteAction)
                }
            }
        }
        
        return messageActions
    }
    
    // MARK: - private
    
    private static func copyMessageAction(
        for message: ChatMessage,
        onFinish: @escaping (MessageActionInfo) -> Void
    ) -> MessageAction {
        let copyAction = MessageAction(
            title: L10n.Message.Actions.copy,
            iconName: "icn_copy",
            action: {
                UIPasteboard.general.string = message.text
                onFinish(
                    MessageActionInfo(
                        message: message,
                        identifier: "copy"
                    )
                )
            },
            confirmationPopup: nil,
            isDestructive: false
        )
        
        return copyAction
    }
    
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
    
    private static func pinMessageAction(
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
        
        let pinMessage = {
            messageController.pin(MessagePinning.noExpiration) { error in
                if let error = error {
                    onError(error)
                } else {
                    onFinish(
                        MessageActionInfo(
                            message: message,
                            identifier: "pin"
                        )
                    )
                }
            }
        }
        
        let pinAction = MessageAction(
            title: L10n.Message.Actions.pin,
            iconName: "icn_pin",
            action: pinMessage,
            confirmationPopup: nil,
            isDestructive: false
        )
        
        return pinAction
    }
    
    private static func unpinMessageAction(
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
        
        let pinMessage = {
            messageController.unpin { error in
                if let error = error {
                    onError(error)
                } else {
                    onFinish(
                        MessageActionInfo(
                            message: message,
                            identifier: "unpin"
                        )
                    )
                }
            }
        }
        
        let pinAction = MessageAction(
            title: L10n.Message.Actions.unpin,
            iconName: "pin.slash",
            action: pinMessage,
            confirmationPopup: nil,
            isDestructive: false
        )
        
        return pinAction
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
    
    private static func muteAction(
        for message: ChatMessage,
        channel: ChatChannel,
        chatClient: ChatClient,
        userToMute: ChatUser,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> MessageAction {
        let muteController = chatClient.userController(userId: userToMute.id)
        let muteAction = {
            muteController.mute { error in
                if let error = error {
                    onError(error)
                } else {
                    onFinish(
                        MessageActionInfo(
                            message: message,
                            identifier: "mute"
                        )
                    )
                }
            }
        }
        
        let muteUser = MessageAction(
            title: L10n.Message.Actions.userMute,
            iconName: "speaker.slash",
            action: muteAction,
            confirmationPopup: nil,
            isDestructive: false
        )
        
        return muteUser
    }
    
    private static func unmuteAction(
        for message: ChatMessage,
        channel: ChatChannel,
        chatClient: ChatClient,
        userToUnmute: ChatUser,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> MessageAction {
        let unmuteController = chatClient.userController(userId: userToUnmute.id)
        let unmuteAction = {
            unmuteController.unmute { error in
                if let error = error {
                    onError(error)
                } else {
                    onFinish(
                        MessageActionInfo(
                            message: message,
                            identifier: "unmute"
                        )
                    )
                }
            }
        }
        
        let unmuteUser = MessageAction(
            title: L10n.Message.Actions.userUnmute,
            iconName: "speaker.wave.1",
            action: unmuteAction,
            confirmationPopup: nil,
            isDestructive: false
        )
        
        return unmuteUser
    }
    
    private static func resendMessageAction(
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
        
        let resendAction = {
            messageController.resendMessage { error in
                if let error = error {
                    onError(error)
                } else {
                    onFinish(
                        MessageActionInfo(
                            message: message,
                            identifier: "resend"
                        )
                    )
                }
            }
        }
        
        let messageAction = MessageAction(
            title: L10n.Message.Actions.resend,
            iconName: "icn_resend",
            action: resendAction,
            confirmationPopup: nil,
            isDestructive: false
        )

        return messageAction
    }
    
    private static func messageNotSentActions(
        for message: ChatMessage,
        channel: ChatChannel,
        chatClient: ChatClient,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> [MessageAction] {
        var messageActions = [MessageAction]()
        
        let resendAction = resendMessageAction(
            for: message,
            channel: channel,
            chatClient: chatClient,
            onFinish: onFinish,
            onError: onError
        )
        messageActions.append(resendAction)
        
        let editAndDeleteActions = editAndDeleteActions(
            for: message,
            channel: channel,
            chatClient: chatClient,
            onFinish: onFinish,
            onError: onError
        )
        messageActions.append(contentsOf: editAndDeleteActions)
        
        return messageActions
    }
    
    private static func editAndDeleteActions(
        for message: ChatMessage,
        channel: ChatChannel,
        chatClient: ChatClient,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> [MessageAction] {
        var messageActions = [MessageAction]()
        
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
        
        return messageActions
    }
}
