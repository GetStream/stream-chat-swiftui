//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// Configuration for the commands in the composer.
public protocol CommandsConfig {
    
    /// The symbol that invokes mentions command.
    var mentionsSymbol: String { get }
    
    /// The symbol that invokes giphy command.
    var giphySymbol: String { get }
    
    /// Creates the main commands handler.
    /// - Parameter channelController: the controller of the channel.
    /// - Returns: `CommandsHandler`.
    func makeCommandsHandler(
        with channelController: ChatChannelController
    ) -> CommandsHandler
}

/// Default commands configuration.
public class DefaultCommandsConfig: CommandsConfig {
    
    public init() {}
    
    public let mentionsSymbol: String = "@"
    public let giphySymbol: String = "/"
    
    public func makeCommandsHandler(
        with channelController: ChatChannelController
    ) -> CommandsHandler {
        let mentionsCommand = MentionsCommandHandler(
            channelController: channelController,
            commandSymbol: mentionsSymbol,
            mentionAllAppUsers: false
        )
        return CommandsHandler(commands: [mentionsCommand])
    }
}
