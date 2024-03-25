//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// Factory used to create view models.
@MainActor public class ViewModelsFactory {
    private init() { /* Private init */ }

    /// Creates the `ChannelListViewModel`.
    ///
    /// - Parameters:
    ///    - channelListController: possibility to inject custom channel list controller.
    ///    - selectedChannelId: pre-selected channel id (used for deeplinking).
    /// - Returns: `ChatChannelListViewModel`.
    public static func makeChannelListViewModel(
        channelList: ChannelList? = nil,
        selectedChannelId: String? = nil
    ) -> ChatChannelListViewModel {
        ChatChannelListViewModel(
            channelList: channelList,
            selectedChannelId: selectedChannelId
        )
    }

    /// Creates the `ChatChannelViewModel`.
    /// - Parameters:
    ///    - channelController: the channel controller.
    ///    - messageController: optional message controller (used in threads).
    public static func makeChannelViewModel(
        with chat: Chat,
        messageId: MessageId?,
        scrollToMessage: ChatMessage?
    ) -> ChatChannelViewModel {
        let viewModel = ChatChannelViewModel(
            chat: chat,
            messageId: messageId,
            scrollToMessage: scrollToMessage
        )
        return viewModel
    }

    /// Creates the view model for the more channel actions.
    ///
    /// - Parameters:
    ///   - channel: the provided channel.
    ///   - actions: list of the channel actions.
    /// - Returns: `MoreChannelActionsViewModel`.
    public static func makeMoreChannelActionsViewModel(
        channel: ChatChannel,
        actions: [ChannelAction]
    ) -> MoreChannelActionsViewModel {
        let viewModel = MoreChannelActionsViewModel(
            channel: channel,
            channelActions: actions
        )
        return viewModel
    }

    /// Makes the message composer view model.
    /// - Parameters:
    ///  -  channelController: the channel controller.
    ///  - messageController: optional message controller (used in threads).
    /// - Returns: `MessageComposerViewModel`.
    public static func makeMessageComposerViewModel(
        with chat: Chat,
        messageId: MessageId?
    ) -> MessageComposerViewModel {
        MessageComposerViewModel(
            chat: chat,
            messageId: messageId
        )
    }

    /// Makes the reactions overlay view model.
    /// - Parameter message: the chat message.
    /// - Returns: `ReactionsOverlayViewModel`.
    public static func makeReactionsOverlayViewModel(
        chat: Chat,
        message: ChatMessage
    ) -> ReactionsOverlayViewModel {
        ReactionsOverlayViewModel(
            chat: chat,
            message: message
        )
    }

    /// Makes the message actions view model.
    /// - Parameter messageActions: the available message actions.
    /// - Returns: `MessageActionsViewModel`.
    public static func makeMessageActionsViewModel(
        messageActions: [MessageAction]
    ) -> MessageActionsViewModel {
        MessageActionsViewModel(messageActions: messageActions)
    }
}
