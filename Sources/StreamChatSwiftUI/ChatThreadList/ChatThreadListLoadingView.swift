//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct ChatThreadListLoadingView: View {
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach((0..<10)) { _ in
                    ChatThreadListItemContentView(
                        channelNameText: placeholder(length: 8),
                        parentMessageText: placeholder(length: 50),
                        unreadRepliesCount: 0,
                        replyAuthorName: placeholder(length: 8),
                        replyAuthorUrl: URL(string: "url"),
                        replyAuthorIsOnline: false,
                        replyMessageText: placeholder(length: 50),
                        replyTimestampText: placeholder(length: 8)
                    )
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .shimmering(duration: 0.8, delay: 0.1)
                    .redacted(reason: .placeholder)

                    Divider()
                }
            }
        }.disabled(true)
    }

    func placeholder(length: Int) -> String {
        Array(repeating: "X", count: length).joined()
    }
}
