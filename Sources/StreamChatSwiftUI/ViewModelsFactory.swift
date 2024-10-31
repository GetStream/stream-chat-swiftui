//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// Factory used to create view models.
public class ViewModelsFactory {
    private init() { /* Private init */ }

    /// Creates the `ChannelListViewModel`.
    ///
    /// - Parameters:
    ///    - channelListController: possibility to inject custom channel list controller.
    ///    - selectedChannelId: pre-selected channel id (used for deeplinking).
    ///    - searchType: The type of data the channel list should perform a search. By default it searches messages.
    /// - Returns: `ChatChannelListViewModel`.
    public static func makeChannelListViewModel(
        channelListController: ChatChannelListController? = nil,
        selectedChannelId: String? = nil,
        searchType: ChannelListSearchType = .messages
    ) -> ChatChannelListViewModel {
        ChatChannelListViewModel(
            channelListController: channelListController,
            selectedChannelId: selectedChannelId,
            searchType: searchType
        )
    }

    /// Creates the `ChatChannelViewModel`.
    /// - Parameters:
    ///    - channelController: the channel controller.
    ///    - messageController: optional message controller (used in threads).
    public static func makeChannelViewModel(
        with channelController: ChatChannelController,
        messageController: ChatMessageController?,
        scrollToMessage: ChatMessage?
    ) -> ChatChannelViewModel {
        let viewModel = ChatChannelViewModel(
            channelController: channelController,
            messageController: messageController,
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
        with channelController: ChatChannelController,
        messageController: ChatMessageController?
    ) -> MessageComposerViewModel {
        MessageComposerViewModel(
            channelController: channelController,
            messageController: messageController
        )
    }

    /// Makes the reactions overlay view model.
    /// - Parameter message: the chat message.
    /// - Returns: `ReactionsOverlayViewModel`.
    public static func makeReactionsOverlayViewModel(
        message: ChatMessage
    ) -> ReactionsOverlayViewModel {
        ReactionsOverlayViewModel(message: message)
    }

    /// Makes the message actions view model.
    /// - Parameter messageActions: the available message actions.
    /// - Returns: `MessageActionsViewModel`.
    public static func makeMessageActionsViewModel(
        messageActions: [MessageAction]
    ) -> MessageActionsViewModel {
        MessageActionsViewModel(messageActions: messageActions)
    }

    /// Creates the `ChatThreadListViewModel`.
    ///
    /// - Parameters:
    ///    - threadListController: The controller that manages the thread list data.
    /// - Returns: `ChatThreadListViewModel`.
    public static func makeThreadListViewModel(
        threadListController: ChatThreadListController? = nil
    ) -> ChatThreadListViewModel {
        ChatThreadListViewModel(
            threadListController: threadListController
        )
    }
}
