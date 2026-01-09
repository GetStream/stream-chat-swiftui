//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

// MARK: - Channel List Options

/// Options for creating the channel list header view modifier.
public final class ChannelListHeaderViewModifierOptions: Sendable {
    /// The title to display in the header.
    public let title: String
    
    public init(title: String) {
        self.title = title
    }
}

/// Options for creating the channel list item.
public final class ChannelListItemOptions<ChannelDestination: View> {
    /// The channel to display.
    public let channel: ChatChannel
    /// The name of the channel.
    public let channelName: String
    /// The avatar image for the channel.
    public let avatar: UIImage
    /// Whether to show the online indicator.
    public let onlineIndicatorShown: Bool
    /// Whether the item is disabled.
    public let disabled: Bool
    /// Binding to the currently selected channel.
    public let selectedChannel: Binding<ChannelSelectionInfo?>
    /// Binding to the currently swiped channel ID.
    public let swipedChannelId: Binding<String?>
    /// The destination view for channel navigation.
    public let channelDestination: @MainActor (ChannelSelectionInfo) -> ChannelDestination
    /// Callback when the item is tapped.
    public let onItemTap: @MainActor (ChatChannel) -> Void
    /// Callback when the trailing right swipe button is tapped.
    public let trailingSwipeRightButtonTapped: @MainActor (ChatChannel) -> Void
    /// Callback when the trailing left swipe button is tapped.
    public let trailingSwipeLeftButtonTapped: @MainActor (ChatChannel) -> Void
    /// Callback when the leading swipe button is tapped.
    public let leadingSwipeButtonTapped: @MainActor (ChatChannel) -> Void
    
    public init(
        channel: ChatChannel,
        channelName: String,
        avatar: UIImage,
        onlineIndicatorShown: Bool,
        disabled: Bool,
        selectedChannel: Binding<ChannelSelectionInfo?>,
        swipedChannelId: Binding<String?>,
        channelDestination: @escaping @MainActor (ChannelSelectionInfo) -> ChannelDestination,
        onItemTap: @escaping @MainActor (ChatChannel) -> Void,
        trailingSwipeRightButtonTapped: @escaping @MainActor (ChatChannel) -> Void,
        trailingSwipeLeftButtonTapped: @escaping @MainActor (ChatChannel) -> Void,
        leadingSwipeButtonTapped: @escaping @MainActor (ChatChannel) -> Void
    ) {
        self.channel = channel
        self.channelName = channelName
        self.avatar = avatar
        self.onlineIndicatorShown = onlineIndicatorShown
        self.disabled = disabled
        self.selectedChannel = selectedChannel
        self.swipedChannelId = swipedChannelId
        self.channelDestination = channelDestination
        self.onItemTap = onItemTap
        self.trailingSwipeRightButtonTapped = trailingSwipeRightButtonTapped
        self.trailingSwipeLeftButtonTapped = trailingSwipeLeftButtonTapped
        self.leadingSwipeButtonTapped = leadingSwipeButtonTapped
    }
}

/// Options for creating the channel avatar view.
public final class ChannelAvatarViewFactoryOptions: Sendable {
    /// The channel to display the avatar for.
    public let channel: ChatChannel
    /// Additional options for the avatar view.
    public let options: ChannelAvatarViewOptions
    
    public init(channel: ChatChannel, options: ChannelAvatarViewOptions) {
        self.channel = channel
        self.options = options
    }
}

/// Options for creating the channel list background.
public final class ChannelListBackgroundOptions: Sendable {}

/// Options for creating the channel list item background.
public final class ChannelListItemBackgroundOptions: Sendable {
    /// The channel for the item.
    public let channel: ChatChannel
    /// Whether the item is selected.
    public let isSelected: Bool
    
    public init(channel: ChatChannel, isSelected: Bool) {
        self.channel = channel
        self.isSelected = isSelected
    }
}

/// Options for creating the more channel actions view.
public final class MoreChannelActionsViewOptions: Sendable {
    /// The channel to show actions for.
    public let channel: ChatChannel
    /// Binding to the currently swiped channel ID.
    public let swipedChannelId: Binding<String?>
    /// Callback when the actions view is dismissed.
    public let onDismiss: @MainActor () -> Void
    /// Callback when an error occurs.
    public let onError: @MainActor (Error) -> Void
    
    public init(
        channel: ChatChannel,
        swipedChannelId: Binding<String?>,
        onDismiss: @escaping @MainActor () -> Void,
        onError: @escaping @MainActor (Error) -> Void
    ) {
        self.channel = channel
        self.swipedChannelId = swipedChannelId
        self.onDismiss = onDismiss
        self.onError = onError
    }
}

/// Options for getting supported more channel actions.
public final class SupportedMoreChannelActionsOptions: Sendable {
    /// The channel to get actions for.
    public let channel: ChatChannel
    /// Callback when the actions view is dismissed.
    public let onDismiss: @MainActor () -> Void
    /// Callback when an error occurs.
    public let onError: @MainActor (Error) -> Void
    
    public init(
        channel: ChatChannel,
        onDismiss: @escaping @MainActor () -> Void,
        onError: @escaping @MainActor (Error) -> Void
    ) {
        self.channel = channel
        self.onDismiss = onDismiss
        self.onError = onError
    }
}

/// Options for creating the trailing swipe actions view.
public final class TrailingSwipeActionsViewOptions: Sendable {
    /// The channel for the swipe actions.
    public let channel: ChatChannel
    /// The current offset in the X direction.
    public let offsetX: CGFloat
    /// The width of the action buttons.
    public let buttonWidth: CGFloat
    /// Binding to the currently swiped channel ID.
    public let swipedChannelId: Binding<String?>
    /// Callback when the left button is tapped.
    public let leftButtonTapped: @MainActor (ChatChannel) -> Void
    /// Callback when the right button is tapped.
    public let rightButtonTapped: @MainActor (ChatChannel) -> Void
    
    public init(
        channel: ChatChannel,
        offsetX: CGFloat,
        buttonWidth: CGFloat,
        swipedChannelId: Binding<String?>,
        leftButtonTapped: @escaping @MainActor (ChatChannel) -> Void,
        rightButtonTapped: @escaping @MainActor (ChatChannel) -> Void
    ) {
        self.channel = channel
        self.offsetX = offsetX
        self.buttonWidth = buttonWidth
        self.swipedChannelId = swipedChannelId
        self.leftButtonTapped = leftButtonTapped
        self.rightButtonTapped = rightButtonTapped
    }
}

/// Options for creating the leading swipe actions view.
public final class LeadingSwipeActionsViewOptions: Sendable {
    /// The channel for the swipe actions.
    public let channel: ChatChannel
    /// The current offset in the X direction.
    public let offsetX: CGFloat
    /// The width of the action buttons.
    public let buttonWidth: CGFloat
    /// Binding to the currently swiped channel ID.
    public let swipedChannelId: Binding<String?>
    /// Callback when the button is tapped.
    public let buttonTapped: @MainActor (ChatChannel) -> Void
    
    public init(
        channel: ChatChannel,
        offsetX: CGFloat,
        buttonWidth: CGFloat,
        swipedChannelId: Binding<String?>,
        buttonTapped: @escaping @MainActor (ChatChannel) -> Void
    ) {
        self.channel = channel
        self.offsetX = offsetX
        self.buttonWidth = buttonWidth
        self.swipedChannelId = swipedChannelId
        self.buttonTapped = buttonTapped
    }
}

/// Options for creating the channel list top view.
public final class ChannelListTopViewOptions: Sendable {
    /// Binding to the search text.
    public let searchText: Binding<String>
    
    public init(searchText: Binding<String>) {
        self.searchText = searchText
    }
}

/// Options for creating the search results view.
public final class SearchResultsViewOptions: Sendable {
    /// Binding to the currently selected channel.
    public let selectedChannel: Binding<ChannelSelectionInfo?>
    /// The search results to display.
    public let searchResults: [ChannelSelectionInfo]
    /// Whether search results are currently loading.
    public let loadingSearchResults: Bool
    /// Function to determine if online indicator should be shown.
    public let onlineIndicatorShown: @MainActor (ChatChannel) -> Bool
    /// Function to get the channel name.
    public let channelNaming: @MainActor (ChatChannel) -> String
    /// Function to load the channel image.
    public let imageLoader: @MainActor (ChatChannel) -> UIImage
    /// Callback when a search result is tapped.
    public let onSearchResultTap: @MainActor (ChannelSelectionInfo) -> Void
    /// Callback when an item appears in the list.
    public let onItemAppear: @MainActor (Int) -> Void
    
    public init(
        selectedChannel: Binding<ChannelSelectionInfo?>,
        searchResults: [ChannelSelectionInfo],
        loadingSearchResults: Bool,
        onlineIndicatorShown: @escaping @MainActor (ChatChannel) -> Bool,
        channelNaming: @escaping @MainActor (ChatChannel) -> String,
        imageLoader: @escaping @MainActor (ChatChannel) -> UIImage,
        onSearchResultTap: @escaping @MainActor (ChannelSelectionInfo) -> Void,
        onItemAppear: @escaping @MainActor (Int) -> Void
    ) {
        self.selectedChannel = selectedChannel
        self.searchResults = searchResults
        self.loadingSearchResults = loadingSearchResults
        self.onlineIndicatorShown = onlineIndicatorShown
        self.channelNaming = channelNaming
        self.imageLoader = imageLoader
        self.onSearchResultTap = onSearchResultTap
        self.onItemAppear = onItemAppear
    }
}

/// Options for creating the channel list search result item.
public final class ChannelListSearchResultItemOptions<ChannelDestination: View> {
    /// The search result to display.
    public let searchResult: ChannelSelectionInfo
    /// Whether to show the online indicator.
    public let onlineIndicatorShown: Bool
    /// The name of the channel.
    public let channelName: String
    /// The avatar image for the channel.
    public let avatar: UIImage
    /// Callback when the search result is tapped.
    public let onSearchResultTap: @MainActor (ChannelSelectionInfo) -> Void
    /// The destination view for channel navigation.
    public let channelDestination: @MainActor (ChannelSelectionInfo) -> ChannelDestination
    
    public init(
        searchResult: ChannelSelectionInfo,
        onlineIndicatorShown: Bool,
        channelName: String,
        avatar: UIImage,
        onSearchResultTap: @escaping @MainActor (ChannelSelectionInfo) -> Void,
        channelDestination: @escaping @MainActor (ChannelSelectionInfo) -> ChannelDestination
    ) {
        self.searchResult = searchResult
        self.onlineIndicatorShown = onlineIndicatorShown
        self.channelName = channelName
        self.avatar = avatar
        self.onSearchResultTap = onSearchResultTap
        self.channelDestination = channelDestination
    }
}

// MARK: - Channel Header Options

/// Options for creating the channel header view modifier.
public final class ChannelHeaderViewModifierOptions: Sendable {
    /// The channel to display in the header.
    public let channel: ChatChannel
    
    public init(channel: ChatChannel) {
        self.channel = channel
    }
}

/// Options for creating the channel bars visibility view modifier.
public final class ChannelBarsVisibilityViewModifierOptions: Sendable {
    /// Whether the bars should be shown.
    public let shouldShow: Bool
    
    public init(shouldShow: Bool) {
        self.shouldShow = shouldShow
    }
}

// MARK: - Add Users Options

/// Options for creating the add users view.
public final class AddUsersViewOptions: Sendable {
    /// Additional options for the add users view.
    public let options: AddUsersOptions
    /// Callback when a user is tapped.
    public let onUserTap: @MainActor (ChatUser) -> Void
    
    public init(options: AddUsersOptions, onUserTap: @escaping @MainActor (ChatUser) -> Void) {
        self.options = options
        self.onUserTap = onUserTap
    }
}
