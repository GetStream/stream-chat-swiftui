//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

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
        }
    }
}
