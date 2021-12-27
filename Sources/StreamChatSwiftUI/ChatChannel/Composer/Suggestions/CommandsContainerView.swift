//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Default implementation of the commands container.
struct CommandsContainerView: View {
    
    var suggestions: [String: Any]
    var handleCommand: ([String: Any]) -> Void
    
    var body: some View {
        ZStack {
            if let suggestedUsers = suggestions["mentions"] as? [ChatUser] {
                MentionUsersView(
                    users: suggestedUsers,
                    userSelected: { user in
                        handleCommand(["chatUser": user])
                    }
                )
            }
            
            if let instantCommands = suggestions["instantCommands"] as? [CommandHandler] {
                InstantCommandsView(
                    instantCommands: instantCommands,
                    commandSelected: { command in
                        handleCommand(["instantCommand": command])
                    }
                )
            }
        }
    }
}
