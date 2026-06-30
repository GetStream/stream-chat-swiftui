//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

extension ChannelAction {
    /// Returns the default channel actions, branching on whether the channel is a DM or a group.
    /// - Parameter options: The configuration options affecting the set of actions.
    /// - Returns: An array of channel actions for the current configuration options.
    @MainActor public static func defaultActions(for options: SupportedMoreChannelActionsOptions) -> [ChannelAction] {
        if options.channel.isDirectMessageChannel {
            return directMessageActions(for: options)
        } else {
            return groupActions(for: options)
        }
    }

    // MARK: - DM actions

    /// Actions for direct-message channels:
    /// View Info → Mute/Unmute User → Archive/Unarchive Conversation → Block/Unblock User → Delete Conversation.
    @MainActor private static func directMessageActions(for options: SupportedMoreChannelActionsOptions) -> [ChannelAction] {
        let channel = options.channel
        let chatClient = InjectedValues[\.chatClient]
        let onDismiss = options.onDismiss
        let onError = options.onError
        var actions = [ChannelAction]()

        actions.append(viewInfo(for: channel))

        if channel.config.mutesEnabled {
            actions.append(muteAction(for: channel, chatClient: chatClient, onDismiss: onDismiss, onError: onError))
        }

        if let otherMember = channel.lastActiveMembers.first(where: { $0.id != chatClient.currentUserId }) {
            let blockedIds = chatClient.currentUserController().currentUser?.blockedUserIds ?? []
            actions.append(
                blockedIds.contains(otherMember.id)
                    ? unblockUserAction(for: otherMember, chatClient: chatClient, onDismiss: onDismiss, onError: onError)
                    : blockUserAction(for: otherMember, chatClient: chatClient, onDismiss: onDismiss, onError: onError)
            )
        }

        if channel.ownCapabilities.contains(.deleteChannel) {
            actions.append(deleteAction(for: channel, chatClient: chatClient, onDismiss: onDismiss, onError: onError))
        }

        return actions
    }

    // MARK: - Group actions

    /// Actions for group channels:
    /// View Info → Mute/Unmute Channel → Archive/Unarchive Channel → Delete Conversation (or Leave Conversation).
    @MainActor private static func groupActions(for options: SupportedMoreChannelActionsOptions) -> [ChannelAction] {
        let channel = options.channel
        let chatClient = InjectedValues[\.chatClient]
        let onDismiss = options.onDismiss
        let onError = options.onError
        var actions = [ChannelAction]()

        actions.append(viewInfo(for: channel))

        if channel.config.mutesEnabled {
            actions.append(muteAction(for: channel, chatClient: chatClient, onDismiss: onDismiss, onError: onError))
        }

        if channel.ownCapabilities.contains(.deleteChannel) {
            actions.append(deleteAction(for: channel, chatClient: chatClient, onDismiss: onDismiss, onError: onError))
        } else if channel.ownCapabilities.contains(.leaveChannel), let userId = chatClient.currentUserId {
            actions.append(leaveGroupAction(for: channel, chatClient: chatClient, userId: userId, onDismiss: onDismiss, onError: onError))
        }

        return actions
    }

    // MARK: - Individual action builders

    @MainActor private static func viewInfo(for channel: ChatChannel) -> ChannelAction {
        let action = ChannelAction(
            title: L10n.Alert.Actions.viewInfoTitle,
            iconName: "info.circle",
            action: { /* no-op — navigation handled via navigationDestination */ },
            confirmationPopup: nil,
            isDestructive: false
        )
        action.navigationDestination = AnyView(ChatChannelInfoView(channel: channel))
        return action
    }

    /// Single mute/unmute builder for both DM and group channels.
    /// Picks titles and confirmation text based on `channel.isDirectMessageChannel` and `channel.isMuted`.
    @MainActor private static func muteAction(
        for channel: ChatChannel,
        chatClient: ChatClient,
        onDismiss: @escaping @MainActor () -> Void,
        onError: @escaping @MainActor (Error) -> Void
    ) -> ChannelAction {
        let muting = !channel.isMuted
        let isDM = channel.isDirectMessageChannel
        let title = muting
            ? (isDM ? L10n.Alert.Actions.muteUser : L10n.Alert.Actions.muteChannel)
            : (isDM ? L10n.Alert.Actions.unmuteUser : L10n.Alert.Actions.unmuteChannel)
        let subject = isDM ? L10n.Channel.Name.directMessage : L10n.Channel.Name.group
        let confirmationPrefix = muting ? L10n.Alert.Actions.muteChannelTitle : L10n.Alert.Actions.unmuteChannelTitle
        let buttonTitle = muting ? L10n.Channel.Item.mute : L10n.Channel.Item.unmute

        return ChannelAction(
            title: title,
            iconName: muting ? "speaker.slash" : "speaker.wave.1",
            action: {
                let controller = chatClient.channelController(for: channel.cid)
                if muting {
                    controller.muteChannel { error in
                        if let error { onError(error) } else { onDismiss() }
                    }
                } else {
                    controller.unmuteChannel { error in
                        if let error { onError(error) } else { onDismiss() }
                    }
                }
            },
            confirmationPopup: ConfirmationPopup(
                title: title,
                message: "\(confirmationPrefix) \(subject)?",
                buttonTitle: buttonTitle
            ),
            isDestructive: false
        )
    }

    /// Single archive/unarchive builder for both DM and group channels.
    /// Picks titles based on `channel.isDirectMessageChannel` and `channel.isArchived`.
    @MainActor private static func archiveAction(
        for channel: ChatChannel,
        chatClient: ChatClient,
        onDismiss: @escaping @MainActor () -> Void,
        onError: @escaping @MainActor (Error) -> Void
    ) -> ChannelAction {
        let archiving = !channel.isArchived
        let isDM = channel.isDirectMessageChannel
        let title = archiving
            ? (isDM ? L10n.Alert.Actions.archiveConversation : L10n.Alert.Actions.archiveChannel)
            : (isDM ? L10n.Alert.Actions.unarchiveConversation : L10n.Alert.Actions.unarchiveChannel)

        return ChannelAction(
            title: title,
            iconName: "archivebox",
            action: {
                let controller = chatClient.channelController(for: channel.cid)
                if archiving {
                    controller.archive { error in
                        if let error { onError(error) } else { onDismiss() }
                    }
                } else {
                    controller.unarchive { error in
                        if let error { onError(error) } else { onDismiss() }
                    }
                }
            },
            confirmationPopup: nil,
            isDestructive: false
        )
    }

    @MainActor private static func blockUserAction(
        for user: ChatChannelMember,
        chatClient: ChatClient,
        onDismiss: @escaping @MainActor () -> Void,
        onError: @escaping @MainActor (Error) -> Void
    ) -> ChannelAction {
        ChannelAction(
            title: L10n.Alert.Actions.blockUser,
            iconName: "nosign",
            action: {
                chatClient.userController(userId: user.id).block { error in
                    if let error { onError(error) } else { onDismiss() }
                }
            },
            confirmationPopup: ConfirmationPopup(
                title: L10n.Alert.Actions.blockUser,
                message: L10n.Message.Actions.UserBlock.confirmationMessage,
                buttonTitle: L10n.Alert.Actions.ok
            ),
            isDestructive: false
        )
    }

    @MainActor private static func unblockUserAction(
        for user: ChatChannelMember,
        chatClient: ChatClient,
        onDismiss: @escaping @MainActor () -> Void,
        onError: @escaping @MainActor (Error) -> Void
    ) -> ChannelAction {
        ChannelAction(
            title: L10n.Alert.Actions.unblockUser,
            iconName: "nosign",
            action: {
                chatClient.userController(userId: user.id).unblock { error in
                    if let error { onError(error) } else { onDismiss() }
                }
            },
            confirmationPopup: nil,
            isDestructive: false
        )
    }

    @MainActor private static func leaveGroupAction(
        for channel: ChatChannel,
        chatClient: ChatClient,
        userId: String,
        onDismiss: @escaping @MainActor () -> Void,
        onError: @escaping @MainActor (Error) -> Void
    ) -> ChannelAction {
        ChannelAction(
            title: L10n.Alert.Actions.leaveConversation,
            iconName: "rectangle.portrait.and.arrow.forward",
            action: {
                chatClient.channelController(for: channel.cid).removeMembers(userIds: [userId]) { error in
                    if let error { onError(error) } else { onDismiss() }
                }
            },
            confirmationPopup: ConfirmationPopup(
                title: L10n.Alert.Actions.leaveConversation,
                message: L10n.Alert.Actions.leaveGroupMessage,
                buttonTitle: L10n.Alert.Actions.leaveGroupButton
            ),
            isDestructive: true
        )
    }

    @MainActor private static func deleteAction(
        for channel: ChatChannel,
        chatClient: ChatClient,
        onDismiss: @escaping @MainActor () -> Void,
        onError: @escaping @MainActor (Error) -> Void
    ) -> ChannelAction {
        ChannelAction(
            title: L10n.Alert.Actions.deleteChannelTitle,
            iconName: "trash",
            action: {
                chatClient.channelController(for: channel.cid).deleteChannel { error in
                    if let error { onError(error) } else { onDismiss() }
                }
            },
            confirmationPopup: ConfirmationPopup(
                title: L10n.Alert.Actions.deleteChannelTitle,
                message: L10n.Alert.Actions.deleteChannelMessage,
                buttonTitle: L10n.Alert.Actions.delete
            ),
            isDestructive: true
        )
    }
}
