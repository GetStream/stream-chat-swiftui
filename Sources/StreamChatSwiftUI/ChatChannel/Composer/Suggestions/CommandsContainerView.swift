//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Default implementation of the commands container.
struct CommandsContainerView: View {

    var suggestions: [String: Any]
    var handleCommand: ([String: Any]) -> Void
    
    var suggestedUsers: [ChatUser]? {
        if let suggestedUsers = suggestions["mentions"] as? StreamCollection<ChatUser> {
            return Array(suggestedUsers)
        }
        if let suggestedUsers = suggestions["mentions"] as? [ChatUser] {
            return suggestedUsers
        }
        
        return nil
    }

    var body: some View {
        ZStack {
            if let suggestedUsers {
                MentionUsersView(
                    users: Array(suggestedUsers),
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
