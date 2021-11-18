//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat

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

        let deleteConversation = deleteAction(
            for: channel,
            chatClient: chatClient,
            onDismiss: onDismiss,
            onError: onError
        )
        actions.append(deleteConversation)
        
        let cancel = ChannelAction(
            title: "Cancel",
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
            title: "Mute \(naming(for: channel))",
            message: "Are you sure you want to mute this \(naming(for: channel))?",
            buttonTitle: "Mute"
        )
        let muteUser = ChannelAction(
            title: "Mute \(naming(for: channel))",
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
            title: "Unmute \(naming(for: channel))",
            message: "Are you sure you want to unmute this \(naming(for: channel))?",
            buttonTitle: "Unmute"
        )
        let unmuteUser = ChannelAction(
            title: "Unmute \(naming(for: channel))",
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
            title: "Leave group",
            message: "Are you sure you want to leave this group?",
            buttonTitle: "Leave"
        )
        let leaveConversation = ChannelAction(
            title: "Leave group",
            iconName: "person.fill.xmark",
            action: leaveAction,
            confirmationPopup: confirmationPopup,
            isDestructive: false
        )
        
        return leaveConversation
    }
    
    private static func naming(for channel: ChatChannel) -> String {
        channel.isDirectMessageChannel ? "user" : "group"
    }
}
