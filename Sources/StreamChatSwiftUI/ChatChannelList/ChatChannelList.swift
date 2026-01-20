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
    private var channelDestination: @MainActor (ChannelSelectionInfo) -> Factory.ChannelDestination
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
        channelDestination: @escaping @MainActor (ChannelSelectionInfo) -> Factory.ChannelDestination,
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
    private var channelDestination: @MainActor (ChannelSelectionInfo) -> Factory.ChannelDestination
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
        channelDestination: @escaping @MainActor (ChannelSelectionInfo) -> Factory.ChannelDestination,
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
        LazyVStack(spacing: 0) {
            ForEach(channels) { channel in
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
                .onAppear {
                    if let index = channels.firstIndex(where: { chatChannel in
                        chatChannel.id == channel.id
                    }) {
                        onItemAppear(index)
                    }
                }

                let isLastItem = channels.last?.cid == channel.cid
                let shouldRenderLastItemDivider = utils.channelListConfig.showChannelListDividerOnLastItem
                if !isLastItem || (isLastItem && shouldRenderLastItemDivider) {
                    factory.makeChannelListDividerItem(options: ChannelListDividerItemOptions())
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
}
