//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

// MARK: - Default Message Actions

public extension MessageAction {
    /// Returns the default message actions.
    ///
    ///  - Parameters:
    ///     - message: the current message.
    ///     - chatClient: the chat client.
    ///     - onDimiss: called when the action is executed.
    ///  - Returns: array of `MessageAction`.
    static func defaultActions<Factory: ViewFactory>(
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
            && message.allAttachments.contains(where: { $0.uploadingState?.state == .uploadingFailed }) {
            messageActions = editAndDeleteActions(
                for: message,
                channel: channel,
                chatClient: chatClient,
                onFinish: onFinish,
                onError: onError
            )
            return messageActions
        } else if message.isBounced {
            let title = MessageAction(
                title: L10n.Message.Bounce.title,
                iconName: "exclamationmark.octagon.fill",
                action: {},
                confirmationPopup: nil,
                isDestructive: false
            )
            messageActions = messageNotSentActions(
                for: message,
                channel: channel,
                chatClient: chatClient,
                onFinish: onFinish,
                onError: onError
            )
            messageActions.insert(title, at: 0)
            return messageActions
        }

        if channel.config.quotesEnabled {
            let replyAction = replyAction(
                for: message,
                channel: channel,
                onFinish: onFinish
            )
            messageActions.append(replyAction)
        }

        // At the moment, this is the only way to know if we are inside a thread.
        // This should be optimised in the future and provide the view context.
        let messageController = InjectedValues[\.utils]
            .channelControllerFactory
            .makeMessageController(for: message.id, channelId: channel.cid)
        let isInsideThreadView = messageController.replies.count > 0

        if channel.config.repliesEnabled && !message.isPartOfThread && !isInsideThreadView {
            let replyThread = threadReplyAction(
                factory: factory,
                for: message,
                channel: channel
            )
            messageActions.append(replyThread)
        }

        if channel.canPinMessage {
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
        }

        if !message.text.isEmpty {
            let copyAction = copyMessageAction(
                for: message,
                onFinish: onFinish
            )

            messageActions.append(copyAction)
        }

        if message.isRootOfThread && isInsideThreadView {
            let markThreadUnreadAction = markThreadAsUnreadAction(
                messageController: messageController,
                message: message,
                onFinish: onFinish,
                onError: onError
            )
            messageActions.append(markThreadUnreadAction)
        } else if !message.isSentByCurrentUser && channel.canReceiveReadEvents {
            if !message.isPartOfThread || message.showReplyInChannel {
                let markUnreadAction = markAsUnreadAction(
                    for: message,
                    channel: channel,
                    chatClient: chatClient,
                    onFinish: onFinish,
                    onError: onError
                )

                messageActions.append(markUnreadAction)
            }
        }

        if message.poll == nil, message.giphyAttachments.isEmpty {
            if channel.canUpdateAnyMessage || channel.canUpdateOwnMessage && message.isSentByCurrentUser {
                let editAction = editMessageAction(
                    for: message,
                    channel: channel,
                    onFinish: onFinish
                )
                messageActions.append(editAction)
            }
        }
        
        if channel.canDeleteAnyMessage || channel.canDeleteOwnMessage && message.isSentByCurrentUser {
            let deleteAction = deleteMessageAction(
                for: message,
                channel: channel,
                chatClient: chatClient,
                onFinish: onFinish,
                onError: onError
            )

            messageActions.append(deleteAction)
        }

        if !message.isSentByCurrentUser {
            if channel.canFlagMessage {
                let flagAction = flagMessageAction(
                    for: message,
                    channel: channel,
                    chatClient: chatClient,
                    onFinish: onFinish,
                    onError: onError
                )
                
                messageActions.append(flagAction)
            }

            if channel.config.mutesEnabled {
                let author = message.author
                let currentUser = chatClient.currentUserController().currentUser
                let isMuted = currentUser?.mutedUsers.contains(where: { $0.id == author.id }) ?? false
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
            
            if InjectedValues[\.utils].messageListConfig.userBlockingEnabled {
                let userController = chatClient.currentUserController()
                let blockedUserIds = userController.dataStore.currentUser()?.blockedUserIds ?? []
                if blockedUserIds.contains(message.author.id) {
                    let unblockAction = unblockUserAction(
                        for: message,
                        channel: channel,
                        chatClient: chatClient,
                        userToUnblock: message.author,
                        onFinish: onFinish,
                        onError: onError
                    )
                    messageActions.append(unblockAction)
                } else {
                    let blockAction = blockUserAction(
                        for: message,
                        channel: channel,
                        chatClient: chatClient,
                        userToBlock: message.author,
                        onFinish: onFinish,
                        onError: onError
                    )
                    messageActions.append(blockAction)
                }
            }
        }

        return messageActions
    }

    /// The action to copy the message text.
    static func copyMessageAction(
        for message: ChatMessage,
        onFinish: @escaping (MessageActionInfo) -> Void
    ) -> MessageAction {
        let copyAction = MessageAction(
            id: MessageActionId.copy,
            title: L10n.Message.Actions.copy,
            iconName: "icn_copy",
            action: {
                UIPasteboard.general.string = message.adjustedText
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

    /// The action to edit the message.
    static func editMessageAction(
        for message: ChatMessage,
        channel: ChatChannel,
        onFinish: @escaping (MessageActionInfo) -> Void
    ) -> MessageAction {
        let editAction = MessageAction(
            id: MessageActionId.edit,
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

    /// The action to pin the message.
    static func pinMessageAction(
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
            id: MessageActionId.pin,
            title: L10n.Message.Actions.pin,
            iconName: "icn_pin",
            action: pinMessage,
            confirmationPopup: nil,
            isDestructive: false
        )

        return pinAction
    }

    /// The action to unpin the message.
    static func unpinMessageAction(
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
            id: MessageActionId.unpin,
            title: L10n.Message.Actions.unpin,
            iconName: "pin.slash",
            action: pinMessage,
            confirmationPopup: nil,
            isDestructive: false
        )

        return pinAction
    }

    /// The action to reply to the message
    static func replyAction(
        for message: ChatMessage,
        channel: ChatChannel,
        onFinish: @escaping (MessageActionInfo) -> Void
    ) -> MessageAction {
        let replyAction = MessageAction(
            id: MessageActionId.reply,
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

    /// The action to reply to the message in a thread
    static func threadReplyAction<Factory: ViewFactory>(
        factory: Factory,
        for message: ChatMessage,
        channel: ChatChannel
    ) -> MessageAction {
        let replyThread = MessageAction(
            id: MessageActionId.threadReply,
            title: L10n.Message.Actions.threadReply,
            iconName: "icn_thread_reply",
            action: {
                NotificationCenter.default.post(
                    name: NSNotification.Name(MessageRepliesConstants.selectedMessageThread),
                    object: nil,
                    userInfo: [MessageRepliesConstants.selectedMessage: message]
                )
            },
            confirmationPopup: nil,
            isDestructive: false
        )

        return replyThread
    }

    /// The action to delete the message.
    static func deleteMessageAction(
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
            id: MessageActionId.delete,
            title: L10n.Message.Actions.delete,
            iconName: "trash",
            action: deleteAction,
            confirmationPopup: confirmationPopup,
            isDestructive: true
        )

        return deleteMessage
    }

    /// The action to flag the message.
    static func flagMessageAction(
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
            id: MessageActionId.flag,
            title: L10n.Message.Actions.flag,
            iconName: "flag",
            action: flagAction,
            confirmationPopup: confirmationPopup,
            isDestructive: false
        )

        return flagMessage
    }

    /// The action to mark the message as unread.
    static func markAsUnreadAction(
        for message: ChatMessage,
        channel: ChatChannel,
        chatClient: ChatClient,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> MessageAction {
        let channelController = InjectedValues[\.utils]
            .channelControllerFactory
            .makeChannelController(for: channel.cid)
        let action = {
            channelController.markUnread(from: message.id) { result in
                if case let .failure(error) = result {
                    onError(error)
                } else {
                    onFinish(
                        MessageActionInfo(
                            message: message,
                            identifier: MessageActionId.markUnread
                        )
                    )
                }
            }
        }
        let unreadAction = MessageAction(
            id: MessageActionId.markUnread,
            title: L10n.Message.Actions.markUnread,
            iconName: "message.badge",
            action: action,
            confirmationPopup: nil,
            isDestructive: false
        )
        
        return unreadAction
    }

    /// The action to mark the thread as unread.
    static func markThreadAsUnreadAction(
        messageController: ChatMessageController,
        message: ChatMessage,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> MessageAction {
        let action = {
            messageController.markThreadUnread { error in
                if let error {
                    onError(error)
                } else {
                    onFinish(
                        MessageActionInfo(
                            message: message,
                            identifier: MessageActionId.markUnread
                        )
                    )
                }
            }
        }
        let unreadAction = MessageAction(
            id: MessageActionId.markUnread,
            title: L10n.Message.Actions.markUnread,
            iconName: "message.badge",
            action: action,
            confirmationPopup: nil,
            isDestructive: false
        )

        return unreadAction
    }

    /// The action to mute the user.
    static func muteAction(
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
            id: MessageActionId.mute,
            title: L10n.Message.Actions.userMute,
            iconName: "speaker.slash",
            action: muteAction,
            confirmationPopup: nil,
            isDestructive: false
        )

        return muteUser
    }

    /// The action to block the user
    static func blockUserAction(
        for message: ChatMessage,
        channel: ChatChannel,
        chatClient: ChatClient,
        userToBlock: ChatUser,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> MessageAction {
        let blockController = chatClient.userController(userId: userToBlock.id)
        let blockAction = {
            blockController.block { error in
                if let error = error {
                    onError(error)
                } else {
                    onFinish(
                        MessageActionInfo(
                            message: message,
                            identifier: "block"
                        )
                    )
                }
            }
        }

        let blockUser = MessageAction(
            id: MessageActionId.block,
            title: L10n.Message.Actions.userBlock,
            iconName: "circle.slash",
            action: blockAction,
            confirmationPopup: ConfirmationPopup(
                title: L10n.Message.Actions.userBlock,
                message: L10n.Message.Actions.UserBlock.confirmationMessage,
                buttonTitle: L10n.Alert.Actions.ok
            ),
            isDestructive: true
        )

        return blockUser
    }

    /// The action to unmute the user.
    static func unmuteAction(
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
            id: MessageActionId.unmute,
            title: L10n.Message.Actions.userUnmute,
            iconName: "speaker.wave.1",
            action: unmuteAction,
            confirmationPopup: nil,
            isDestructive: false
        )

        return unmuteUser
    }

    /// The action to unblock the user.
    static func unblockUserAction(
        for message: ChatMessage,
        channel: ChatChannel,
        chatClient: ChatClient,
        userToUnblock: ChatUser,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> MessageAction {
        let blockController = chatClient.userController(userId: userToUnblock.id)
        let unblockAction = {
            blockController.unblock { error in
                if let error = error {
                    onError(error)
                } else {
                    onFinish(
                        MessageActionInfo(
                            message: message,
                            identifier: "unblock"
                        )
                    )
                }
            }
        }

        let unblockUser = MessageAction(
            id: MessageActionId.unblock,
            title: L10n.Message.Actions.userUnblock,
            iconName: "circle.slash",
            action: unblockAction,
            confirmationPopup: ConfirmationPopup(
                title: L10n.Message.Actions.userUnblock,
                message: L10n.Message.Actions.UserUnblock.confirmationMessage,
                buttonTitle: L10n.Alert.Actions.ok
            ),
            isDestructive: false
        )

        return unblockUser
    }

    /// The action to resend the message.
    static func resendMessageAction(
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
            id: MessageActionId.resend,
            title: L10n.Message.Actions.resend,
            iconName: "icn_resend",
            action: resendAction,
            confirmationPopup: nil,
            isDestructive: false
        )

        return messageAction
    }

    /// The actions for a message that was not sent.
    static func messageNotSentActions(
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

    // MARK: - Helpers

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

/// Message action identifiers used in the SDK.
public enum MessageActionId {
    public static let copy = "copy_message_action"
    public static let reply = "reply_message_action"
    public static let threadReply = "thread_message_action"
    public static let edit = "edit_message_action"
    public static let delete = "delete_message_action"
    public static let mute = "mute_message_action"
    public static let unmute = "unmute_message_action"
    public static let flag = "flag_message_action"
    public static let pin = "pin_message_action"
    public static let unpin = "unpin_message_action"
    public static let resend = "resend_message_action"
    public static let markUnread = "mark_unread_action"
    public static let block = "block_user_action"
    public static let unblock = "unblock_user_action"
}
