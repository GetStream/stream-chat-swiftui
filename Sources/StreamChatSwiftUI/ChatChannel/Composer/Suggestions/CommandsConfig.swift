//
// Copyright © 2024 Stream.io Inc. All rights reserved.
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

    public init() {
        // Public init.
    }

    public let mentionsSymbol: String = "@"
    public let instantCommandsSymbol: String = "/"

    public func makeCommandsHandler(
        with channelController: ChatChannelController
    ) -> CommandsHandler {
        let mentionsCommandHandler = MentionsCommandHandler(
            channelController: channelController,
            commandSymbol: mentionsSymbol,
            mentionAllAppUsers: false
        )

        var instantCommands = [CommandHandler]()

        let channelConfig = channelController.channel?.config

        let giphyEnabled = channelConfig?.commands.first(where: { command in
            command.name == "giphy"
        }) != nil

        if giphyEnabled {
            let giphyCommand = GiphyCommandHandler(commandSymbol: "/giphy")
            instantCommands.append(giphyCommand)
        }

        if channelConfig?.mutesEnabled == true {
            let muteCommand = MuteCommandHandler(
                channelController: channelController,
                commandSymbol: "/mute"
            )
            let unmuteCommand = UnmuteCommandHandler(
                channelController: channelController,
                commandSymbol: "/unmute"
            )
            instantCommands.append(muteCommand)
            instantCommands.append(unmuteCommand)
        }

        let instantCommandsHandler = InstantCommandsHandler(
            commands: instantCommands
        )
        return CommandsHandler(commands: [mentionsCommandHandler, instantCommandsHandler])
    }
}
