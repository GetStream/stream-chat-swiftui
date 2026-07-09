//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Stateless component for the channel list.
/// If used directly, you should provide the channel list.
public struct ChannelList<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    
    private var factory: Factory
    var channels: [ChatChannel]
    @Binding var selectedChannel: ChannelSelectionInfo?
    @Binding var swipedChannelId: String?
    @Binding var scrolledChannelId: String?
    private var scrollable: Bool
    private var onItemTap: @MainActor (ChatChannel) -> Void
    private var onItemAppear: @MainActor (Int) -> Void
    private var channelDestination: (@MainActor (ChannelSelectionInfo) -> Factory.ChannelDestination)?
    private var trailingSwipeRightButtonTapped: @MainActor (ChatChannel) -> Void
    private var trailingSwipeLeftButtonTapped: @MainActor (ChatChannel) -> Void
    private var leadingSwipeButtonTapped: @MainActor (ChatChannel) -> Void

    public init(
        factory: Factory,
        channels: [ChatChannel],
        selectedChannel: Binding<ChannelSelectionInfo?>,
        swipedChannelId: Binding<String?>,
        scrolledChannelId: Binding<String?> = .constant(nil),
        scrollable: Bool = true,
        onItemTap: @escaping @MainActor (ChatChannel) -> Void,
        onItemAppear: @escaping @MainActor (Int) -> Void,
        channelDestination: (@MainActor (ChannelSelectionInfo) -> Factory.ChannelDestination)? = nil,
        trailingSwipeRightButtonTapped: @escaping @MainActor (ChatChannel) -> Void = { _ in },
        trailingSwipeLeftButtonTapped: @escaping @MainActor (ChatChannel) -> Void = { _ in },
        leadingSwipeButtonTapped: @escaping @MainActor (ChatChannel) -> Void = { _ in }
    ) {
        self.factory = factory
        self.channels = channels
        self.onItemTap = onItemTap
        self.onItemAppear = onItemAppear
        self.channelDestination = channelDestination
        self.trailingSwipeRightButtonTapped = trailingSwipeRightButtonTapped
        self.trailingSwipeLeftButtonTapped = trailingSwipeLeftButtonTapped
        self.leadingSwipeButtonTapped = leadingSwipeButtonTapped
        self.scrollable = scrollable
        _selectedChannel = selectedChannel
        _swipedChannelId = swipedChannelId
        _scrolledChannelId = scrolledChannelId
    }

    public var body: some View {
        Group {
            if scrollable {
                ScrollViewReader { scrollView in
                    ScrollView {
                        channelsVStack
                    }
                    .onChange(of: scrolledChannelId) { newValue in
                        if let newValue {
                            withAnimation {
                                scrollView.scrollTo(newValue, anchor: .bottom)
                            }
                        }
                    }
                }
            } else {
                channelsVStack
            }
        }
    }

    private var channelsVStack: some View {
        ChannelsLazyVStack(
            factory: factory,
            channels: channels,
            selectedChannel: $selectedChannel,
            swipedChannelId: $swipedChannelId,
            onItemTap: onItemTap,
            onItemAppear: onItemAppear,
            channelDestination: channelDestination,
            trailingSwipeRightButtonTapped: trailingSwipeRightButtonTapped,
            trailingSwipeLeftButtonTapped: trailingSwipeLeftButtonTapped,
            leadingSwipeButtonTapped: leadingSwipeButtonTapped
        )
    }
}

/// LazyVStack displaying list of channels.
public struct ChannelsLazyVStack<Factory: ViewFactory>: View {
    @Injected(\.chatClient) private var chatClient
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    private var factory: Factory
    var channels: [ChatChannel]
    @Binding var selectedChannel: ChannelSelectionInfo?
    @Binding var swipedChannelId: String?
    private var onItemTap: @MainActor (ChatChannel) -> Void
    private var onItemAppear: @MainActor (Int) -> Void
    private var channelDestination: (@MainActor (ChannelSelectionInfo) -> Factory.ChannelDestination)?
    private var trailingSwipeRightButtonTapped: @MainActor (ChatChannel) -> Void
    private var trailingSwipeLeftButtonTapped: @MainActor (ChatChannel) -> Void
    private var leadingSwipeButtonTapped: @MainActor (ChatChannel) -> Void

    public init(
        factory: Factory,
        channels: [ChatChannel],
        selectedChannel: Binding<ChannelSelectionInfo?>,
        swipedChannelId: Binding<String?>,
        onItemTap: @escaping @MainActor (ChatChannel) -> Void,
        onItemAppear: @escaping @MainActor (Int) -> Void,
        channelDestination: (@MainActor (ChannelSelectionInfo) -> Factory.ChannelDestination)? = nil,
        trailingSwipeRightButtonTapped: @escaping @MainActor (ChatChannel) -> Void,
        trailingSwipeLeftButtonTapped: @escaping @MainActor (ChatChannel) -> Void,
        leadingSwipeButtonTapped: @escaping @MainActor (ChatChannel) -> Void
    ) {
        self.factory = factory
        self.channels = channels
        self.onItemTap = onItemTap
        self.onItemAppear = onItemAppear
        self.channelDestination = channelDestination
        self.trailingSwipeRightButtonTapped = trailingSwipeRightButtonTapped
        self.trailingSwipeLeftButtonTapped = trailingSwipeLeftButtonTapped
        self.leadingSwipeButtonTapped = leadingSwipeButtonTapped
        _selectedChannel = selectedChannel
        _swipedChannelId = swipedChannelId
    }

    public var body: some View {
        let channelIndexLookup = makeChannelIndexLookup()
        let shouldRenderLastItemDivider = utils.channelListConfig.showChannelListDividerOnLastItem

        return LazyVStack(spacing: 0) {
            ForEach(channels) { channel in
                let isLastItem = channel.cid == channels.last?.cid
                let showsDivider = !isLastItem || (isLastItem && shouldRenderLastItemDivider)

                // Render the divider as a bottom overlay on the row instead of a
                // sibling node, so the list doesn't have to place a separate view
                // per row on every layout pass.
                factory.makeChannelListItem(
                    options: ChannelListItemOptions(
                        channel: channel,
                        channelName: name(for: channel),
                        disabled: swipedChannelId == channel.id,
                        selectedChannel: $selectedChannel,
                        swipedChannelId: $swipedChannelId,
                        channelDestination: channelDestination,
                        onItemTap: onItemTap,
                        trailingSwipeRightButtonTapped: trailingSwipeRightButtonTapped,
                        trailingSwipeLeftButtonTapped: trailingSwipeLeftButtonTapped,
                        leadingSwipeButtonTapped: leadingSwipeButtonTapped
                    )
                )
                .background(factory.makeChannelListItemBackground(
                    options: ChannelListItemBackgroundOptions(
                        channel: channel,
                        isSelected: selectedChannel?.channel.id == channel.id
                    )
                ))
                .overlay(
                    Group {
                        if showsDivider {
                            factory.makeChannelListDividerItem(options: ChannelListDividerItemOptions())
                        }
                    },
                    alignment: .bottom
                )
                .onAppear {
                    if let index = channelIndexLookup[channel.id] {
                        onItemAppear(index)
                    }
                }
            }

            factory.makeChannelListFooterView(options: ChannelListFooterViewOptions())
        }
        .modifier(factory.styles.makeChannelListModifier(options: ChannelListModifierOptions()))
    }

    private func name(for channel: ChatChannel) -> String {
        utils.channelNameFormatter.format(
            channel: channel,
            forCurrentUserId: chatClient.currentUserId
        ) ?? ""
    }

    /// Builds a channel id to index map once per body evaluation so a row's
    /// index can be resolved in O(1) on appearance instead of scanning the
    /// whole array with `firstIndex(where:)`.
    private func makeChannelIndexLookup() -> [String: Int] {
        var lookup = [String: Int]()
        lookup.reserveCapacity(channels.count)
        for (index, channel) in channels.enumerated() where lookup[channel.id] == nil {
            lookup[channel.id] = index
        }
        return lookup
    }
}
