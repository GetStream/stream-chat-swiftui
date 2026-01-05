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
                        parentMessageText: placeholder(length: 50),
                        unreadRepliesCount: 0,
                        replyAuthorId: placeholder(length: 8),
                        replyAuthorName: placeholder(length: 8),
                        replyAuthorUrl: URL(string: "url"),
                        replyAuthorIsOnline: false,
                        replyMessageText: placeholder(length: 50),
                        replyTimestampText: placeholder(length: 8)
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
