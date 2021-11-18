//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// Factory used to create view models.
public class ViewModelsFactory {
    private init() {}
    
    /// Creates the `ChannelListViewModel`.
    ///
    /// - Parameters:
    ///    - channelListController: possibility to inject custom channel list controller.
    ///    - selectedChannelId: pre-selected channel id (used for deeplinking).
    /// - Returns: `ChatChannelListViewModel`.
    public static func makeChannelListViewModel(
        channelListController: ChatChannelListController? = nil,
        selectedChannelId: String? = nil
    ) -> ChatChannelListViewModel {
        ChatChannelListViewModel(
            channelListController: channelListController,
            selectedChannelId: selectedChannelId
        )
    }
    
    /// Creates the `ChatChannelViewModel`.
    /// - Parameter channelController: the channel controller.
    public static func makeChannelViewModel(
        with channelController: ChatChannelController
    ) -> ChatChannelViewModel {
        let viewModel = ChatChannelViewModel(channelController: channelController)
        return viewModel
    }
    
    /// Creates the `NewChatViewModel`.
    public static func makeNewChatViewModel() -> NewChatViewModel {
        let viewModel = NewChatViewModel()
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
    /// - Parameter channelController: the channel controller.
    /// - Returns: `MessageComposerViewModel`.
    public static func makeMessageComposerViewModel(
        with channelController: ChatChannelController
    ) -> MessageComposerViewModel {
        MessageComposerViewModel(channelController: channelController)
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
}
