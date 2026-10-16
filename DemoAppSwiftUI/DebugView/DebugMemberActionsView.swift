//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct DebugMemberActionsView: View {
    let channel: ChatChannel
    let dismissActions: DismissAction

    var body: some View {
        List {
            Section("Manage") {
                NavigationLink("Add member") {
                    DebugAddMemberView(cid: channel.cid, dismissActions: dismissActions)
                }
                NavigationLink("Remove a member") {
                    DebugRemoveMemberView(
                        cid: channel.cid,
                        memberIds: channel.lastActiveMembers.map(\.id),
                        dismissActions: dismissActions
                    )
                }
            }
            .disabled(!channel.canUpdateChannelMembers)
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Members")
    }
}
