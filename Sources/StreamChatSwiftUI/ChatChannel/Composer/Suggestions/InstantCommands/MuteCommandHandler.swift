//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

/// Handles the mute command.
public class MuteCommandHandler: TwoStepMentionCommand {

    @Injected(\.images) private var images
    @Injected(\.chatClient) private var chatClient

    public init(
        channelController: ChatChannelController,
        commandSymbol: String,
        id: String = "/mute"
    ) {
        super.init(
            channelController: channelController,
            commandSymbol: commandSymbol,
            id: id
        )
        let displayInfo = CommandDisplayInfo(
            displayName: L10n.Composer.Commands.mute,
            icon: images.commandMute,
            format: "\(id) [\(L10n.Composer.Commands.Format.username)]",
            isInstant: true
        )
        self.displayInfo = displayInfo
    }

    override public func executeOnMessageSent(
        composerCommand: ComposerCommand,
        completion: @escaping (Error?) -> Void
    ) {
        if let mutedUser = selectedUser {
            chatClient
                .userController(userId: mutedUser.id)
                .mute { [weak self] error in
                    self?.selectedUser = nil
                    completion(error)
                }

            return
        }
    }
}
