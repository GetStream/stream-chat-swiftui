//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

struct DebugRemoveMemberView: View {
    let cid: ChannelId
    let memberIds: [UserId]
    let dismissActions: DismissAction

    @Injected(\.chatClient) private var chatClient

    @State private var isRunning = false
    @State private var failedMemberId = ""
    @State private var errorMessage = ""
    @State private var isErrorShown = false

    var body: some View {
        List(memberIds, id: \.self) { memberId in
            Button(memberId) {
                Task { await removeMember(memberId) }
            }
        }
        .disabled(isRunning)
        .navigationTitle("Remove a member")
        .alert("Couldn't remove user \(failedMemberId) from channel \(cid.rawValue)", isPresented: $isErrorShown) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private func removeMember(_ memberId: UserId) async {
        isRunning = true
        defer { isRunning = false }
        do {
            try await chatClient.makeChat(for: cid).removeMembers(
                [memberId],
                systemMessage: "Members removed from the channel"
            )
            dismissActions()
        } catch {
            failedMemberId = memberId
            errorMessage = (error as? ClientError)?.localizedDescription ?? error.localizedDescription
            isErrorShown = true
        }
    }
}
