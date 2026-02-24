//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// The default thread list loading view.
public struct ChatThreadListLoadingView<Factory: ViewFactory>: View {
    let factory: Factory

    public init(factory: Factory = DefaultViewFactory.shared) {
        self.factory = factory
    }

    public var body: some View {
        ScrollView {
            LazyVStack {
                ForEach((0..<10)) { _ in
                    ChatThreadListItemContentView(
                        factory: factory,
                        channelNameText: placeholder(length: 8),
                        parentMessageAuthorName: nil,
                        parentMessageContentText: placeholder(length: 50),
                        unreadRepliesCount: 0,
                        parentAuthor: nil,
                        replyCountText: placeholder(length: 8),
                        replyTimestampText: placeholder(length: 8),
                        participantUsers: []
                    )
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
