//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct CommandsContainerView: View {
    
    var suggestedUsers: [ChatUser]
    var userSelected: (ChatUser) -> Void
    
    var body: some View {
        ZStack {
            MentionUsersView(
                users: suggestedUsers,
                userSelected: userSelected
            )
        }
    }
}
