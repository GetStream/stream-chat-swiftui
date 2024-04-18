//
// Copyright © 2024 Stream.io Inc. All rights reserved.
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
    @MainActor public static func defaultActions<Factory: ViewFactory>(
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

        if channel.config.repliesEnabled && !message.isPartOfThread {
            let replyThread = threadReplyAction(
                factory: factory,
                for: message,
                channel: channel
            )
            messageActions.append(replyThread)
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
                let currentUser = try? chatClient.makeConnectedUser()
                let isMuted = currentUser?.state.mutedUsers.contains(message.author) ?? false
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

    private static func editMessageAction(
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

    private static func pinMessageAction(
        for message: ChatMessage,
        channel: ChatChannel,
        chatClient: ChatClient,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> MessageAction {
        let pinMessage = { @MainActor in
            let chat = InjectedValues[\.utils]
                .chatCache
                .chat(for: channel.cid)
            do {
                try await chat.pinMessage(message.id, pinning: .noExpiration)
                onFinish(
                    MessageActionInfo(
                        message: message,
                        identifier: "pin"
                    )
                )
            } catch {
                log.error("Error pinning a message \(error.localizedDescription)")
                onError(error)
            }
        }

        let pinAction = MessageAction(
            id: MessageActionId.pin,
            title: L10n.Message.Actions.pin,
            iconName: "icn_pin",
            action: {
                Task {
                    await pinMessage()
                }
            },
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
        let unpinMessage = { @MainActor in
            let chat = InjectedValues[\.utils]
                .chatCache
                .chat(for: channel.cid)
            do {
                try await chat.unpinMessage(message.id)
                onFinish(
                    MessageActionInfo(
                        message: message,
                        identifier: "unpin"
                    )
                )
            } catch {
                log.error("Error unpinning a message \(error.localizedDescription)")
                onError(error)
            }
        }

        let unpinAction = MessageAction(
            id: MessageActionId.unpin,
            title: L10n.Message.Actions.unpin,
            iconName: "pin.slash",
            action: {
                Task {
                    await unpinMessage()
                }
            },
            confirmationPopup: nil,
            isDestructive: false
        )

        return unpinAction
    }

    private static func replyAction(
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

    private static func threadReplyAction<Factory: ViewFactory>(
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

    private static func deleteMessageAction(
        for message: ChatMessage,
        channel: ChatChannel,
        chatClient: ChatClient,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> MessageAction {
        let deleteAction = { @MainActor in
            let chat = InjectedValues[\.utils]
                .chatCache
                .chat(for: channel.cid)
            do {
                try await chat.deleteMessage(message.id)
                onFinish(
                    MessageActionInfo(
                        message: message,
                        identifier: "delete"
                    )
                )
            } catch {
                log.error("Error deleting a message \(error.localizedDescription)")
                onError(error)
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
            action: {
                Task {
                    await deleteAction()
                }
            },
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
        let flagAction = { @MainActor in
            let chat = InjectedValues[\.utils]
                .chatCache
                .chat(for: channel.cid)
            do {
                try await chat.flagMessage(message.id)
                onFinish(
                    MessageActionInfo(
                        message: message,
                        identifier: "flag"
                    )
                )
            } catch {
                log.error("Error flagging a message: \(error.localizedDescription)")
                onError(error)
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
            action: {
                Task {
                    await flagAction()
                }
            },
            confirmationPopup: confirmationPopup,
            isDestructive: false
        )

        return flagMessage
    }
    
    @MainActor private static func markAsUnreadAction(
        for message: ChatMessage,
        channel: ChatChannel,
        chatClient: ChatClient,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> MessageAction {
        let chat = InjectedValues[\.utils]
            .chatCache
            .chat(for: channel.cid)
        let action = { @MainActor in
            do {
                try await chat.markUnread(from: message.id)
                onFinish(
                    MessageActionInfo(
                        message: message,
                        identifier: MessageActionId.markUnread
                    )
                )
            } catch {
                log.error("Error marking message as unread \(error.localizedDescription)")
                onError(error)
            }
        }
        let unreadAction = MessageAction(
            id: MessageActionId.markUnread,
            title: L10n.Message.Actions.markUnread,
            iconName: "message.badge",
            action: {
                Task {
                    await action()
                }
            },
            confirmationPopup: nil,
            isDestructive: false
        )
        
        return unreadAction
    }

    private static func muteAction(
        for message: ChatMessage,
        channel: ChatChannel,
        chatClient: ChatClient,
        userToMute: ChatUser,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> MessageAction {
        let muteAction = { @MainActor in
            do {
                let currentUser = try chatClient.makeConnectedUser()
                try await currentUser.muteUser(userToMute.id)
                onFinish(
                    MessageActionInfo(
                        message: message,
                        identifier: "mute"
                    )
                )
            } catch {
                log.error("Error muting user: \(error.localizedDescription)")
                onError(error)
            }
        }

        let muteUser = MessageAction(
            id: MessageActionId.mute,
            title: L10n.Message.Actions.userMute,
            iconName: "speaker.slash",
            action: {
                Task {
                    await muteAction()
                }
            },
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
        let unmuteAction = { @MainActor in
            do {
                let currentUser = try chatClient.makeConnectedUser()
                try await currentUser.unmuteUser(userToUnmute.id)
                onFinish(
                    MessageActionInfo(
                        message: message,
                        identifier: "unmute"
                    )
                )
            } catch {
                log.error("Error unmuting user: \(error.localizedDescription)")
                onError(error)
            }
        }

        let unmuteUser = MessageAction(
            id: MessageActionId.unmute,
            title: L10n.Message.Actions.userUnmute,
            iconName: "speaker.wave.1",
            action: {
                Task {
                    await unmuteAction()
                }
            },
            confirmationPopup: nil,
            isDestructive: false
        )

        return unmuteUser
    }

    @MainActor private static func resendMessageAction(
        for message: ChatMessage,
        channel: ChatChannel,
        chatClient: ChatClient,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> MessageAction {
        let chat = InjectedValues[\.utils]
            .chatCache
            .chat(for: channel.cid)

        let resendAction = {
            do {
                try await chat.resendMessage(message.id)
                onFinish(
                    MessageActionInfo(
                        message: message,
                        identifier: "resend"
                    )
                )
            } catch {
                onError(error)
            }
        }

        let messageAction = MessageAction(
            id: MessageActionId.resend,
            title: L10n.Message.Actions.resend,
            iconName: "icn_resend",
            action: {
                Task {
                    await resendAction()
                }
            },
            confirmationPopup: nil,
            isDestructive: false
        )

        return messageAction
    }

    @MainActor private static func messageNotSentActions(
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
}
