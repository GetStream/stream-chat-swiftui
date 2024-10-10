//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Stateless component for the channel list.
/// If used directly, you should provide the thread list.
public struct ThreadList<Factory: ViewFactory, HeaderView: View, FooterView: View>: View {
    var threads: LazyCachedMapCollection<ChatThread>
    private var factory: Factory
    private var threadDestination: (ChatThread) -> Factory.ThreadDestination
    private var onItemAppear: (Int) -> Void

    @ViewBuilder
    private var headerView: () -> HeaderView

    @ViewBuilder
    private var footerView: () -> FooterView

    public init(
        factory: Factory,
        threads: LazyCachedMapCollection<ChatThread>,
        threadDestination: @escaping (ChatThread) -> Factory.ThreadDestination,
        onItemAppear: @escaping (Int) -> Void,
        headerView: @escaping () -> HeaderView,
        footerView: @escaping () -> FooterView
    ) {
        self.factory = factory
        self.threads = threads
        self.threadDestination = threadDestination
        self.onItemAppear = onItemAppear
        self.headerView = headerView
        self.footerView = footerView
    }

    public var body: some View {
        ScrollView {
            headerView()
            ThreadsLazyVStack(
                factory: factory,
                threads: threads,
                threadDestination: threadDestination,
                onItemAppear: onItemAppear
            )
            footerView()
        }
    }
}

/// LazyVStack displaying list of threads.
public struct ThreadsLazyVStack<Factory: ViewFactory>: View {
    private var factory: Factory
    var threads: LazyCachedMapCollection<ChatThread>
    private var threadDestination: (ChatThread) -> Factory.ThreadDestination
    private var onItemAppear: (Int) -> Void

    public init(
        factory: Factory,
        threads: LazyCachedMapCollection<ChatThread>,
        threadDestination: @escaping (ChatThread) -> Factory.ThreadDestination,
        onItemAppear: @escaping (Int) -> Void
    ) {
        self.factory = factory
        self.threads = threads
        self.threadDestination = threadDestination
        self.onItemAppear = onItemAppear
    }

    public var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(threads) { thread in
                factory.makeThreadListItem(
                    thread: thread,
                    threadDestination: threadDestination
                )
                .onAppear {
                    if let index = threads.firstIndex(where: { chatThread in
                        chatThread.id == thread.id
                    }) {
                        onItemAppear(index)
                    }
                }
                factory.makeThreadListDividerItem()
            }
        }
    }
}

/// Determines the uniqueness of the channel list item.
extension ChatThread: Identifiable {
    public var id: String {
        parentMessageId
    }
}
