//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChatSwiftUI
import SwiftUI

struct BlockedUsersView: View {
    
    @StateObject var viewModel = BlockedUsersViewModel()
    
    var body: some View {
        ZStack {
            if !viewModel.blockedUsers.isEmpty {
                List {
                    ForEach(viewModel.blockedUsers) { blockedUser in
                        HStack {
                            MessageAvatarView(avatarURL: blockedUser.imageURL, size: .init(width: 48, height: 48))
                            Text(blockedUser.name ?? blockedUser.id)
                                .font(.headline)
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    }
                    .onDelete(perform: delete)
                }
                .toolbar {
                    EditButton()
                }
                .listStyle(.plain)
            } else {
                VStack {
                    Text("There are currently no blocked users.")
                        .padding()
                    Spacer()
                }
            }
        }
        .onAppear {
            viewModel.loadBlockedUsers()
        }
        .navigationTitle("Blocked Users")
    }
    
    func delete(at offsets: IndexSet) {
        if let first = offsets.first, first < viewModel.blockedUsers.count {
            viewModel.unblock(user: viewModel.blockedUsers[first])
        }
    }
}
