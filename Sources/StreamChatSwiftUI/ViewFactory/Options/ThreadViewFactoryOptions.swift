//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

// MARK: - Thread List Options

/// Options for creating the thread list item.
public struct ThreadListItemOptions<ThreadDestination: View> {
    /// The thread to display.
    public let thread: ChatThread
    /// The destination view for thread navigation.
    public let threadDestination: @MainActor(ChatThread) -> ThreadDestination
    /// Binding to the currently selected thread.
    public let selectedThread: Binding<ThreadSelectionInfo?>
    
    public init(
        thread: ChatThread,
        threadDestination: @escaping @MainActor(ChatThread) -> ThreadDestination,
        selectedThread: Binding<ThreadSelectionInfo?>
    ) {
        self.thread = thread
        self.threadDestination = threadDestination
        self.selectedThread = selectedThread
    }
}

/// Options for creating the thread list error banner view.
public struct ThreadListErrorBannerViewOptions {
    /// Callback when the refresh action is triggered.
    public let onRefreshAction: @MainActor() -> Void
    
    public init(onRefreshAction: @escaping @MainActor() -> Void) {
        self.onRefreshAction = onRefreshAction
    }
}

/// Options for creating the thread list container view modifier.
public struct ThreadListContainerModifierOptions {
    /// The view model for the thread list.
    public let viewModel: ChatThreadListViewModel
    
    public init(viewModel: ChatThreadListViewModel) {
        self.viewModel = viewModel
    }
}

/// Options for creating the thread list header view modifier.
public struct ThreadListHeaderViewModifierOptions {
    /// The title to display in the header.
    public let title: String
    
    public init(title: String) {
        self.title = title
    }
}

/// Options for creating the thread list header view.
public struct ThreadListHeaderViewOptions {
    /// The view model for the thread list.
    public let viewModel: ChatThreadListViewModel
    
    public init(viewModel: ChatThreadListViewModel) {
        self.viewModel = viewModel
    }
}

/// Options for creating the thread list footer view.
public struct ThreadListFooterViewOptions {
    /// The view model for the thread list.
    public let viewModel: ChatThreadListViewModel
    
    public init(viewModel: ChatThreadListViewModel) {
        self.viewModel = viewModel
    }
}

/// Options for creating the thread list background.
public struct ThreadListBackgroundOptions {
    /// The color palette to use.
    public let colors: ColorPalette
    
    public init(colors: ColorPalette) {
        self.colors = colors
    }
}

/// Options for creating the thread list item background.
public struct ThreadListItemBackgroundOptions {
    /// The thread for the item.
    public let thread: ChatThread
    /// Whether the item is selected.
    public let isSelected: Bool
    
    public init(thread: ChatThread, isSelected: Bool) {
        self.thread = thread
        self.isSelected = isSelected
    }
}
