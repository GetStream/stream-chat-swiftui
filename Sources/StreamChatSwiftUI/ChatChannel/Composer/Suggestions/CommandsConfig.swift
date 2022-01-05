//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// Configuration for the commands in the composer.
public protocol CommandsConfig {
    
    /// The symbol that invokes mentions command.
    var mentionsSymbol: String { get }
    
    /// The symbol that invokes instant commands.
    var instantCommandsSymbol: String { get }
    
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
    public let instantCommandsSymbol: String = "/"
    
    public func makeCommandsHandler(
        with channelController: ChatChannelController
    ) -> CommandsHandler {
        let mentionsCommand = MentionsCommandHandler(
            channelController: channelController,
            commandSymbol: mentionsSymbol,
            mentionAllAppUsers: false
        )
        let giphyCommand = GiphyCommandHandler(commandSymbol: "/giphy")
        let muteCommand = MuteCommandHandler(
            channelController: channelController,
            commandSymbol: "/mute"
        )
        let unmuteCommand = UnmuteCommandHandler(
            channelController: channelController,
            commandSymbol: "/unmute"
        )
        let instantCommands = InstantCommandsHandler(
            commands: [giphyCommand, muteCommand, unmuteCommand]
        )
        return CommandsHandler(commands: [mentionsCommand, instantCommands])
    }
}
