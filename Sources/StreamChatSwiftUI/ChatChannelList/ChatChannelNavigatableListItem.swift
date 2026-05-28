//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Chat channel list item wrapper that adds navigation behavior to any
/// channel row view.
///
/// Use the convenience initializer (`init(factory:channel:channelName:...)`)
/// to wrap the default ``ChatChannelListItem`` with navigation, or the
/// composable initializer (`init(channelListItem:factory:channel:...)`) to
/// inject a custom row view between this wrapper and any outer wrapper such
/// as ``ChatChannelSwipeableListItem``.
public struct ChatChannelNavigatableListItem<
    Factory: ViewFactory,
    ChannelDestination: View,
    ChannelListItem: View
>: View {
    private var channel: ChatChannel
    private var handleTabBarVisibility: Bool
    @Binding private var selectedChannel: ChannelSelectionInfo?
    private var channelDestination: ((ChannelSelectionInfo) -> ChannelDestination)?
    private var content: (Binding<ChannelSelectionInfo?>) -> ChannelListItem

    /// Wraps a pre-built channel list item view with navigation behavior.
    ///
    /// The provided `channelListItem` is rendered as-is and is responsible
    /// for handling its own taps. To trigger navigation, the row should
    /// mutate the `selectedChannel` binding (typically by invoking the
    /// `onItemTap` callback from ``ChannelListItemOptions``) so the
    /// navigation overlay can push the configured destination.
    ///
    /// - Parameters:
    ///   - channelListItem: The custom view rendered as the row content.
    ///   - factory: View factory used by sibling wrappers (kept for
    ///     generic-parameter inference; not used to build the row).
    ///   - channel: The channel represented by this row.
    ///   - handleTabBarVisibility: Whether to hide the tab bar when the
    ///     destination is presented on iOS 16.0-16.2.
    ///   - selectedChannel: Binding to the currently selected channel; the
    ///     navigation link activates when this matches the current channel.
    ///   - channelDestination: Closure that builds the destination view for
    ///     the channel.
    public init(
        channelListItem: ChannelListItem,
        factory: Factory = DefaultViewFactory.shared,
        channel: ChatChannel,
        handleTabBarVisibility: Bool = true,
        selectedChannel: Binding<ChannelSelectionInfo?>,
        channelDestination: ((ChannelSelectionInfo) -> ChannelDestination)? = nil
    ) {
        self.channel = channel
        self.handleTabBarVisibility = handleTabBarVisibility
        _selectedChannel = selectedChannel
        self.channelDestination = channelDestination
        content = { _ in channelListItem }
        _ = factory
    }

    /// Convenience initializer that constructs the default
    /// ``ChatChannelListItem`` internally.
    public init(
        factory: Factory,
        channel: ChatChannel,
        channelName: String,
        disabled: Bool = false,
        handleTabBarVisibility: Bool = true,
        selectedChannel: Binding<ChannelSelectionInfo?>,
        channelDestination: ((ChannelSelectionInfo) -> ChannelDestination)? = nil,
        onItemTap: @escaping (ChatChannel) -> Void
    ) where ChannelListItem == ChatChannelListItem<Factory> {
        self.channel = channel
        self.handleTabBarVisibility = handleTabBarVisibility
        _selectedChannel = selectedChannel
        self.channelDestination = channelDestination
        content = { binding in
            ChatChannelListItem(
                factory: factory,
                channel: channel,
                channelName: channelName,
                isSelected: binding.wrappedValue?.channel.cid == channel.cid,
                disabled: disabled,
                onItemTap: onItemTap
            )
        }
    }

    public var body: some View {
        ZStack {
            content($selectedChannel)

            if let channelDestination {
                NavigationLink(
                    tag: channel.channelSelectionInfo,
                    selection: $selectedChannel
                ) {
                    LazyView(
                        channelDestination(channel.channelSelectionInfo)
                            .modifier(
                                HideTabBarModifierForiOS16(
                                    handleTabBarVisibility: handleTabBarVisibility
                                )
                            )
                    )
                } label: {
                    EmptyView()
                }
                .opacity(0) // Fixes showing accessibility button shape
            }
        }
    }
}

/// Used for representing selection of an item in the channel list.
/// The optional message is used in case we need to scroll to a particular one in the message list.
public final class ChannelSelectionInfo: Identifiable, @unchecked Sendable {
    public let id: String
    public let channel: ChatChannel
    public let message: ChatMessage?
    public let searchType: ChannelListSearchType

    public init(
        channel: ChatChannel,
        message: ChatMessage?,
        searchType: ChannelListSearchType = .messages
    ) {
        self.channel = channel
        self.message = message
        self.searchType = searchType
        if let message {
            id = "\(channel.cid.id)-\(message.id)"
        } else {
            id = channel.cid.id
        }
    }
}

extension ChannelSelectionInfo: Hashable, Equatable {
    public static func == (lhs: ChannelSelectionInfo, rhs: ChannelSelectionInfo) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ChatChannel {
    public var channelSelectionInfo: ChannelSelectionInfo {
        ChannelSelectionInfo(channel: self, message: nil)
    }
}

/// Modifier to fix tab bar visibility issue on iOS 16.0, 16.1, 16.2.
struct HideTabBarModifierForiOS16: ViewModifier {
    var handleTabBarVisibility: Bool

    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            if #unavailable(iOS 16.3) {
                content
                    .modifier(HideTabBarModifier(
                        handleTabBarVisibility: handleTabBarVisibility
                    ))
            } else {
                content
            }
        } else {
            content
        }
    }
}
