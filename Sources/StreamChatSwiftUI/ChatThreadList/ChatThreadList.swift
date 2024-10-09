//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Stateless component for the channel list.
/// If used directly, you should provide the thread list.
public struct ThreadList<Factory: ViewFactory>: View {
    var threads: LazyCachedMapCollection<ChatThread>
    private var factory: Factory
    private var threadDestination: (ChatThread) -> Factory.ThreadDestination

    public init(
        factory: Factory,
        threads: LazyCachedMapCollection<ChatThread>,
        threadDestination: @escaping (ChatThread) -> Factory.ThreadDestination
    ) {
        self.factory = factory
        self.threads = threads
        self.threadDestination = threadDestination
    }

    public var body: some View {
        ScrollView {
            ThreadsLazyVStack(
                factory: factory,
                threads: threads,
                threadDestination: threadDestination
            )
        }
    }
}

/// LazyVStack displaying list of threads.
public struct ThreadsLazyVStack<Factory: ViewFactory>: View {
    private var factory: Factory
    var threads: LazyCachedMapCollection<ChatThread>
    private var threadDestination: (ChatThread) -> Factory.ThreadDestination

    public init(
        factory: Factory,
        threads: LazyCachedMapCollection<ChatThread>,
        threadDestination: @escaping (ChatThread) -> Factory.ThreadDestination
    ) {
        self.factory = factory
        self.threads = threads
        self.threadDestination = threadDestination
    }

    public var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(threads) { thread in
                factory.makeThreadListItem(
                    thread: thread,
                    threadDestination: threadDestination
                )
                factory.makeThreadListDividerItem()
            }
        }
        .modifier(factory.makeThreadListModifier())
    }
}

/// Determines the uniqueness of the channel list item.
extension ChatThread: Identifiable {
    public var id: String {
        parentMessageId
    }
}
