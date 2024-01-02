//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

extension ChannelAction {
    /// Returns the default channel actions.
    ///
    ///  - Parameters:
    ///     - channel: the current channel.
    ///     - chatClient: the chat client.
    ///     - onDimiss: called when the action is executed.
    ///  - Returns: array of `ChannelAction`.
    public static func defaultActions(
        for channel: ChatChannel,
        chatClient: ChatClient,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> [ChannelAction] {
        var actions = [ChannelAction]()

        let viewInfo = viewInfo(for: channel)

        actions.append(viewInfo)

        if !channel.isDirectMessageChannel, let userId = chatClient.currentUserId {
            let leaveGroup = leaveGroup(
                for: channel,
                chatClient: chatClient,
                userId: userId,
                onDismiss: onDismiss,
                onError: onError
            )

            actions.append(leaveGroup)
        }

        if channel.config.mutesEnabled {
            if channel.isMuted {
                let unmuteUser = unmuteAction(
                    for: channel,
                    chatClient: chatClient,
                    onDismiss: onDismiss,
                    onError: onError
                )
                actions.append(unmuteUser)
            } else {
                let muteUser = muteAction(
                    for: channel,
                    chatClient: chatClient,
                    onDismiss: onDismiss,
                    onError: onError
                )
                actions.append(muteUser)
            }
        }

        if channel.ownCapabilities.contains(.deleteChannel) {
            let deleteConversation = deleteAction(
                for: channel,
                chatClient: chatClient,
                onDismiss: onDismiss,
                onError: onError
            )
            actions.append(deleteConversation)
        }

        let cancel = ChannelAction(
            title: L10n.Alert.Actions.cancel,
            iconName: "xmark.circle",
            action: onDismiss,
            confirmationPopup: nil,
            isDestructive: false
        )

        actions.append(cancel)

        return actions
    }

    private static func muteAction(
        for channel: ChatChannel,
        chatClient: ChatClient,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> ChannelAction {
        let muteAction = {
            let controller = chatClient.channelController(for: channel.cid)
            controller.muteChannel { error in
                if let error = error {
                    onError(error)
                } else {
                    onDismiss()
                }
            }
        }
        let confirmationPopup = ConfirmationPopup(
            title: "\(L10n.Channel.Item.mute) \(naming(for: channel))",
            message: "\(L10n.Alert.Actions.muteChannelTitle) \(naming(for: channel))?",
            buttonTitle: L10n.Channel.Item.mute
        )
        let muteUser = ChannelAction(
            title: "\(L10n.Channel.Item.mute) \(naming(for: channel))",
            iconName: "speaker.slash",
            action: muteAction,
            confirmationPopup: confirmationPopup,
            isDestructive: false
        )
        return muteUser
    }

    private static func unmuteAction(
        for channel: ChatChannel,
        chatClient: ChatClient,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> ChannelAction {
        let unMuteAction = {
            let controller = chatClient.channelController(for: channel.cid)
            controller.unmuteChannel { error in
                if let error = error {
                    onError(error)
                } else {
                    onDismiss()
                }
            }
        }
        let confirmationPopup = ConfirmationPopup(
            title: "\(L10n.Channel.Item.unmute) \(naming(for: channel))",
            message: "\(L10n.Alert.Actions.unmuteChannelTitle) \(naming(for: channel))?",
            buttonTitle: L10n.Channel.Item.unmute
        )
        let unmuteUser = ChannelAction(
            title: "\(L10n.Channel.Item.unmute) \(naming(for: channel))",
            iconName: "speaker.wave.1",
            action: unMuteAction,
            confirmationPopup: confirmationPopup,
            isDestructive: false
        )

        return unmuteUser
    }

    private static func deleteAction(
        for channel: ChatChannel,
        chatClient: ChatClient,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> ChannelAction {
        let deleteConversationAction = {
            let controller = chatClient.channelController(for: channel.cid)
            controller.deleteChannel { error in
                if let error = error {
                    onError(error)
                } else {
                    onDismiss()
                }
            }
        }
        let confirmationPopup = ConfirmationPopup(
            title: L10n.Alert.Actions.deleteChannelTitle,
            message: L10n.Alert.Actions.deleteChannelMessage,
            buttonTitle: L10n.Alert.Actions.delete
        )
        let deleteConversation = ChannelAction(
            title: L10n.Alert.Actions.deleteChannelTitle,
            iconName: "trash",
            action: deleteConversationAction,
            confirmationPopup: confirmationPopup,
            isDestructive: true
        )

        return deleteConversation
    }

    private static func leaveGroup(
        for channel: ChatChannel,
        chatClient: ChatClient,
        userId: String,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> ChannelAction {
        let leaveAction = {
            let controller = chatClient.channelController(for: channel.cid)
            controller.removeMembers(userIds: [userId]) { error in
                if let error = error {
                    onError(error)
                } else {
                    onDismiss()
                }
            }
        }
        let confirmationPopup = ConfirmationPopup(
            title: L10n.Alert.Actions.leaveGroupTitle,
            message: L10n.Alert.Actions.leaveGroupMessage,
            buttonTitle: L10n.Alert.Actions.leaveGroupButton
        )
        let leaveConversation = ChannelAction(
            title: L10n.Alert.Actions.leaveGroupTitle,
            iconName: "person.fill.xmark",
            action: leaveAction,
            confirmationPopup: confirmationPopup,
            isDestructive: false
        )

        return leaveConversation
    }

    private static func viewInfo(for channel: ChatChannel) -> ChannelAction {
        var viewInfo = ChannelAction(
            title: L10n.Alert.Actions.viewInfoTitle,
            iconName: "person.fill",
            action: { /* no-op */ },
            confirmationPopup: nil,
            isDestructive: false
        )

        viewInfo.navigationDestination = AnyView(ChatChannelInfoView(channel: channel))

        return viewInfo
    }

    private static func naming(for channel: ChatChannel) -> String {
        channel.isDirectMessageChannel ? L10n.Channel.Name.directMessage : L10n.Channel.Name.group
    }
}
