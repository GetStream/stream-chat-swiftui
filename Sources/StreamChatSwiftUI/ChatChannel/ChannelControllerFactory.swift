//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Factory for creating channel controllers.
public class ChannelControllerFactory {
    
    @Injected(\.chatClient) var chatClient
    
    private var currentChannelController: ChatChannelController?
    
    /// Creates a channel controller with the provided channel id.
    /// - Parameter channelId: the channel's id.
    /// - Returns: `ChatChannelController`
    public func makeChannelController(for channelId: ChannelId) -> ChatChannelController {
        if let currentChannelController = currentChannelController, channelId == currentChannelController.cid {
            return currentChannelController
        }
        let controller = chatClient.channelController(for: channelId)
        currentChannelController = controller
        return controller
    }
    
    /// Clears the current active channel controller.
    func clearCurrentController() {
        currentChannelController = nil
    }
}
