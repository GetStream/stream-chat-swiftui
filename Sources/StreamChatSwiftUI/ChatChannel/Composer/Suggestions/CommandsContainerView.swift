//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Default implementation of the commands container.
struct CommandsContainerView<Factory: ViewFactory>: View {
    var factory: Factory
    var suggestions: [String: Any]
    var handleCommand: ([String: Any]) -> Void

    init(
        factory: Factory = DefaultViewFactory.shared,
        suggestions: [String: Any],
        handleCommand: @escaping ([String: Any]) -> Void
    ) {
        self.factory = factory
        self.suggestions = suggestions
        self.handleCommand = handleCommand
    }

    var body: some View {
        ZStack {
            if let suggestedUsers = suggestions["mentions"] as? [ChatUser] {
                MentionUsersView(
                    factory: factory,
                    users: suggestedUsers,
                    userSelected: { user in
                        handleCommand(["chatUser": user])
                    }
                )
                .accessibilityIdentifier("MentionUsersView")
            }

            if let instantCommands = suggestions["instantCommands"] as? [CommandHandler] {
                InstantCommandsView(
                    instantCommands: instantCommands,
                    commandSelected: { command in
                        handleCommand(["instantCommand": command])
                    }
                )
                .accessibilityIdentifier("InstantCommandsView")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("CommandsContainerView")
    }
}
