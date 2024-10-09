//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// The thread list item that supports navigating to a destination.
/// It's generic over the thread destination.
public struct ChatThreadListNavigatableItem<ThreadListItem: View, ThreadDestination: View>: View {
    private var thread: ChatThread
    private var threadListItem: ThreadListItem
    private var threadDestination: (ChatThread) -> ThreadDestination
    private var handleTabBarVisibility: Bool

    public init(
        thread: ChatThread,
        threadListItem: ThreadListItem,
        threadDestination: @escaping (ChatThread) -> ThreadDestination,
        handleTabBarVisibility: Bool
    ) {
        self.thread = thread
        self.threadListItem = threadListItem
        self.threadDestination = threadDestination
        self.handleTabBarVisibility = handleTabBarVisibility
    }

    public var body: some View {
        NavigationLink(
            destination: {
                threadDestination(thread)
                    .modifier(HideTabBarModifier(
                        handleTabBarVisibility: handleTabBarVisibility
                    ))
            },
            label: {
                threadListItem
            }
        )
        .foregroundColor(.black)
    }
}
