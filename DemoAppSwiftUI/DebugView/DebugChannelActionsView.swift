//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct DebugChannelActionsView: View {
    let channel: ChatChannel

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                Section("People") {
                    NavigationLink {
                        DebugMemberActionsView(channel: channel, dismissActions: dismiss)
                    } label: {
                        Label("Members", systemImage: "person.2")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Channel Actions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
