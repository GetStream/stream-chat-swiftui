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
    @Binding private var selectedThread: ThreadSelectionInfo?

    public init(
        thread: ChatThread,
        threadListItem: ThreadListItem,
        threadDestination: @escaping (ChatThread) -> ThreadDestination,
        selectedThread: Binding<ThreadSelectionInfo?>,
        handleTabBarVisibility: Bool
    ) {
        self.thread = thread
        self.threadListItem = threadListItem
        self.threadDestination = threadDestination
        _selectedThread = selectedThread
        self.handleTabBarVisibility = handleTabBarVisibility
    }

    public var body: some View {
        ZStack {
            threadListItem
            NavigationLink(
                tag: ThreadSelectionInfo(thread: thread),
                selection: $selectedThread
            ) {
                LazyView(
                    threadDestination(thread)
                        .modifier(HideTabBarModifier(
                            handleTabBarVisibility: handleTabBarVisibility
                        ))
                )
            } label: {
                EmptyView()
            }
        }
        .foregroundColor(.black)
    }
}

public struct ThreadSelectionInfo: Identifiable {
    public let id: String
    public let thread: ChatThread

    public init(thread: ChatThread) {
        self.thread = thread
        id = thread.id
    }
}

extension ThreadSelectionInfo: Hashable, Equatable {

    public static func == (lhs: ThreadSelectionInfo, rhs: ThreadSelectionInfo) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
