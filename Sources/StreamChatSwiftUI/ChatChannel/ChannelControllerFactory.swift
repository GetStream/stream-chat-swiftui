//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

class ChannelControllerFactory {
    
    @Injected(\.chatClient) var chatClient
    
    private var currentChannelController: ChatChannelController?
    
    func makeChannelController(for channelId: ChannelId) -> ChatChannelController {
        if let currentChannelController = currentChannelController, channelId == currentChannelController.cid {
            return currentChannelController
        }
        let controller = chatClient.channelController(for: channelId)
        currentChannelController = controller
        return controller
    }
    
    func clearCurrentController() {
        currentChannelController = nil
    }
}
