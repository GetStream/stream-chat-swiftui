//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

/// Handles the unmute command.
public class UnmuteCommandHandler: TwoStepMentionCommand {

    @Injected(\.images) private var images
    @Injected(\.chatClient) private var chatClient

    public init(
        chat: Chat,
        commandSymbol: String,
        id: String = "/unmute"
    ) {
        super.init(
            chat: chat,
            commandSymbol: commandSymbol,
            id: id
        )
        let displayInfo = CommandDisplayInfo(
            displayName: L10n.Composer.Commands.unmute,
            icon: images.commandUnmute,
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
                .unmute { [weak self] error in
                    self?.selectedUser = nil
                    completion(error)
                }

            return
        }
    }
}
