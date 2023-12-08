//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Defines methods for resolving message actions after execution.
public protocol MessageActionsResolving {

    /// Resolves an executed message action.
    /// - Parameters:
    ///  - info: the message action info.
    ///  - viewModel: used to modify a state after action execution.
    func resolveMessageAction(
        info: MessageActionInfo,
        viewModel: ChatChannelViewModel
    )
}

/// Default implementation of the `MessageActionsResolving` protocol.
public class MessageActionsResolver: MessageActionsResolving {

    public init() {
        // Public init.
    }

    public func resolveMessageAction(
        info: MessageActionInfo,
        viewModel: ChatChannelViewModel
    ) {
        if info.identifier == "inlineReply" {
            withAnimation {
                viewModel.quotedMessage = info.message
                viewModel.editedMessage = nil
            }
        } else if info.identifier == "edit" {
            withAnimation {
                viewModel.editedMessage = info.message
                viewModel.quotedMessage = nil
            }
        } else if info.identifier == MessageActionId.markUnread {
            viewModel.firstUnreadMessageId = info.message.messageId
        }

        viewModel.reactionsShown = false
    }
}
