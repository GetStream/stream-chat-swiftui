//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// Configuration for the commands in the composer.
public protocol CommandsConfig {
    
    /// Creates the main commands handler.
    /// - Parameter channelController: the controller of the channel.
    /// - Returns: `CommandsHandler`.
    func makeCommandsHandler(
        with channelController: ChatChannelController
    ) -> CommandsHandler
}

/// Default commands configuration.
public struct DefaultCommandsConfig: CommandsConfig {
    
    public init() {}
    
    public func makeCommandsHandler(
        with channelController: ChatChannelController
    ) -> CommandsHandler {
        let mentionsCommand = MentionsCommandHandler(
            channelController: channelController,
            commandSymbol: "@",
            mentionAllAppUsers: false
        )
        return CommandsHandler(commands: [mentionsCommand])
    }
}
