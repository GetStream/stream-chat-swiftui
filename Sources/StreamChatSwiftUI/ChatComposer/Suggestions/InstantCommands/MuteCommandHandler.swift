//
// Copyright © 2026 Stream.io Inc. All rights reserved.
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
        self.displayInfo = ComposerCommandFactory.shared.mute().displayInfo
    }

    override public func executeOnMessageSent(
        composerCommand: ComposerCommand,
        completion: @escaping @MainActor (Error?) -> Void
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
