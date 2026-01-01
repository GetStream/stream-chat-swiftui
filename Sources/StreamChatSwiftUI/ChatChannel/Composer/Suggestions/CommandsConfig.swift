//
// Copyright © 2026 Stream.io Inc. All rights reserved.
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
        let availableCommands = channelConfig?.commands.map(\.name) ?? []

        if availableCommands.contains("giphy") {
            let giphyCommand = GiphyCommandHandler(commandSymbol: "/giphy")
            instantCommands.append(giphyCommand)
        }

        if availableCommands.contains("mute") {
            let muteCommand = MuteCommandHandler(
                channelController: channelController,
                commandSymbol: "/mute"
            )
            instantCommands.append(muteCommand)
        }

        if availableCommands.contains("unmute") {
            let unmuteCommand = UnmuteCommandHandler(
                channelController: channelController,
                commandSymbol: "/unmute"
            )
            instantCommands.append(unmuteCommand)
        }

        let instantCommandsHandler = InstantCommandsHandler(
            commands: instantCommands
        )
        return CommandsHandler(commands: [mentionsCommandHandler, instantCommandsHandler])
    }
}
