//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Chat channel list item wrapper that adds navigation behavior to any
/// channel item view.
///
/// It is generic over the channel item and the channel destination. Inject
/// your own channel item view (for example the default ``ChatChannelListItem``
/// or a fully custom one) and this wrapper renders it alongside a hidden
/// `NavigationLink` that activates when `selectedChannel` matches the channel.
public struct ChatChannelNavigatableListItem<ChannelListItem: View, ChannelDestination: View>: View {
    private var channel: ChatChannel
    private var channelListItem: ChannelListItem
    private var channelDestination: ((ChannelSelectionInfo) -> ChannelDestination)?
    private var handleTabBarVisibility: Bool
    @Binding private var selectedChannel: ChannelSelectionInfo?

    /// Wraps a channel item view with navigation behavior.
    ///
    /// The provided `channelListItem` is rendered as-is and is responsible
    /// for handling its own taps. To trigger navigation, the item should
    /// mutate the `selectedChannel` binding (typically by invoking the
    /// `onItemTap` callback from ``ChannelListItemOptions``) so the
    /// navigation overlay can push the configured destination.
    ///
    /// - Parameters:
    ///   - channel: The channel represented by this item.
    ///   - channelListItem: The view rendered as the channel item content.
    ///   - channelDestination: Closure that builds the destination view for
    ///     the channel.
    ///   - selectedChannel: Binding to the currently selected channel; the
    ///     navigation link activates when this matches the current channel.
    ///   - handleTabBarVisibility: Whether to hide the tab bar when the
    ///     destination is presented on iOS 16.0-16.2.
    public init(
        channel: ChatChannel,
        channelListItem: ChannelListItem,
        channelDestination: ((ChannelSelectionInfo) -> ChannelDestination)? = nil,
        selectedChannel: Binding<ChannelSelectionInfo?>,
        handleTabBarVisibility: Bool = true
    ) {
        self.channel = channel
        self.channelListItem = channelListItem
        self.channelDestination = channelDestination
        _selectedChannel = selectedChannel
        self.handleTabBarVisibility = handleTabBarVisibility
    }

    public var body: some View {
        ZStack {
            channelListItem

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

public extension ChatChannelNavigatableListItem {
    /// Convenience initializer that builds the default ``ChatChannelListItem``
    /// internally and wraps it with navigation behavior.
    @available(
        *,
        deprecated,
        message: "Build the channel item yourself (e.g. ChatChannelListItem) and pass it via init(channel:channelListItem:channelDestination:selectedChannel:handleTabBarVisibility:)."
    )
    init<Factory: ViewFactory>(
        factory: Factory,
        channel: ChatChannel,
        channelName: String,
        disabled: Bool = false,
        handleTabBarVisibility: Bool = true,
        selectedChannel: Binding<ChannelSelectionInfo?>,
        channelDestination: ((ChannelSelectionInfo) -> ChannelDestination)? = nil,
        onItemTap: @escaping (ChatChannel) -> Void
    ) where ChannelListItem == ChatChannelListItem<Factory> {
        self.init(
            channel: channel,
            channelListItem: ChatChannelListItem(
                factory: factory,
                channel: channel,
                channelName: channelName,
                isSelected: selectedChannel.wrappedValue?.channel.cid == channel.cid,
                disabled: disabled,
                onItemTap: onItemTap
            ),
            channelDestination: channelDestination,
            selectedChannel: selectedChannel,
            handleTabBarVisibility: handleTabBarVisibility
        )
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
