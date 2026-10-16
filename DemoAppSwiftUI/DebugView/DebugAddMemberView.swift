//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

struct DebugAddMemberView: View {
    let cid: ChannelId
    let dismissActions: DismissAction

    @Injected(\.chatClient) private var chatClient

    @State private var userId = ""
    @State private var days = ""
    @State private var isRunning = false
    @State private var errorMessage = ""
    @State private var isErrorShown = false

    var body: some View {
        Form {
            Section {
                TextField("User ID", text: $userId)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("Days of history", text: $days)
                    .keyboardType(.numberPad)
            } footer: {
                Text("Leave days empty to show the full history")
            }
            Section("Demo users") {
                ForEach(demoUsers) { user in
                    Button {
                        userId = user.id
                    } label: {
                        HStack {
                            Text(user.name)
                            Spacer()
                            if user.id == trimmedUserId {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .accessibilityAddTraits(user.id == trimmedUserId ? .isSelected : [])
                }
            }
        }
        .navigationTitle("Add member")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    Task { await addMember() }
                }
                .disabled(trimmedUserId.isEmpty || isRunning)
            }
        }
        .alert("Couldn't add user \(trimmedUserId) to channel \(cid.rawValue)", isPresented: $isErrorShown) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private var trimmedUserId: String {
        userId.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var demoUsers: [UserCredentials] {
        UserCredentials.builtInUsers.filter { $0.id != chatClient.currentUserId }
    }

    private func addMember() async {
        isRunning = true
        defer { isRunning = false }
        let hideHistoryBefore = Int(days).flatMap { Calendar.current.date(byAdding: .day, value: -$0, to: Date()) }
        do {
            try await chatClient.makeChat(for: cid).addMembers(
                [trimmedUserId],
                systemMessage: "Members added to the channel",
                hideHistoryBefore: hideHistoryBefore
            )
            dismissActions()
        } catch {
            errorMessage = (error as? ClientError)?.localizedDescription ?? error.localizedDescription
            isErrorShown = true
        }
    }
}
