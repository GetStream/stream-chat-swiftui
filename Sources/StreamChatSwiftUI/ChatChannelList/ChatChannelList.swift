//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Stateless component for the channel list.
/// If used directly, you should provide the channel list.
public struct ChannelList<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    
    private var factory: Factory
    var channels: LazyCachedMapCollection<ChatChannel>
    @Binding var selectedChannel: ChannelSelectionInfo?
    @Binding var swipedChannelId: String?
    @Binding var scrolledChannelId: String?
    private var scrollable: Bool
    private var onlineIndicatorShown: (ChatChannel) -> Bool
    private var imageLoader: (ChatChannel) -> UIImage
    private var onItemTap: (ChatChannel) -> Void
    private var onItemAppear: (Int) -> Void
    private var channelNaming: (ChatChannel) -> String
    private var channelDestination: (ChannelSelectionInfo) -> Factory.ChannelDestination
    private var trailingSwipeRightButtonTapped: (ChatChannel) -> Void
    private var trailingSwipeLeftButtonTapped: (ChatChannel) -> Void
    private var leadingSwipeButtonTapped: (ChatChannel) -> Void

    public init(
        factory: Factory,
        channels: LazyCachedMapCollection<ChatChannel>,
        selectedChannel: Binding<ChannelSelectionInfo?>,
        swipedChannelId: Binding<String?>,
        scrolledChannelId: Binding<String?> = .constant(nil),
        scrollable: Bool = true,
        onlineIndicatorShown: ((ChatChannel) -> Bool)? = nil,
        imageLoader: ((ChatChannel) -> UIImage)? = nil,
        onItemTap: @escaping (ChatChannel) -> Void,
        onItemAppear: @escaping (Int) -> Void,
        channelNaming: ((ChatChannel) -> String)? = nil,
        channelDestination: @escaping (ChannelSelectionInfo) -> Factory.ChannelDestination,
        trailingSwipeRightButtonTapped: @escaping (ChatChannel) -> Void = { _ in },
        trailingSwipeLeftButtonTapped: @escaping (ChatChannel) -> Void = { _ in },
        leadingSwipeButtonTapped: @escaping (ChatChannel) -> Void = { _ in }
    ) {
        self.factory = factory
        self.channels = channels
        self.onItemTap = onItemTap
        self.onItemAppear = onItemAppear
        if let channelNaming {
            self.channelNaming = channelNaming
        } else {
            let channelNamer = InjectedValues[\.utils].channelNamer
            self.channelNaming = { channel in
                channelNamer(channel, InjectedValues[\.chatClient].currentUserId) ?? ""
            }
        }
        self.channelDestination = channelDestination
        if let imageLoader {
            self.imageLoader = imageLoader
        } else {
            self.imageLoader = InjectedValues[\.utils].channelHeaderLoader.image(for:)
        }
        if let onlineIndicatorShown {
            self.onlineIndicatorShown = onlineIndicatorShown
        } else {
            self.onlineIndicatorShown = { channel in
                channel.shouldShowOnlineIndicator
            }
        }
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
            onlineIndicatorShown: onlineIndicatorShown,
            imageLoader: imageLoader,
            onItemTap: onItemTap,
            onItemAppear: onItemAppear,
            channelNaming: channelNaming,
            channelDestination: channelDestination,
            trailingSwipeRightButtonTapped: trailingSwipeRightButtonTapped,
            trailingSwipeLeftButtonTapped: trailingSwipeLeftButtonTapped,
            leadingSwipeButtonTapped: leadingSwipeButtonTapped
        )
    }
}

/// LazyVStack displaying list of channels.
public struct ChannelsLazyVStack<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    private var factory: Factory
    var channels: LazyCachedMapCollection<ChatChannel>
    @Binding var selectedChannel: ChannelSelectionInfo?
    @Binding var swipedChannelId: String?
    private var onlineIndicatorShown: @MainActor (ChatChannel) -> Bool
    private var imageLoader: @MainActor (ChatChannel) -> UIImage
    private var onItemTap: @MainActor (ChatChannel) -> Void
    private var onItemAppear: @MainActor (Int) -> Void
    private var channelNaming: @MainActor (ChatChannel) -> String
    private var channelDestination: @MainActor (ChannelSelectionInfo) -> Factory.ChannelDestination
    private var trailingSwipeRightButtonTapped: @MainActor (ChatChannel) -> Void
    private var trailingSwipeLeftButtonTapped: @MainActor (ChatChannel) -> Void
    private var leadingSwipeButtonTapped: @MainActor (ChatChannel) -> Void

    public init(
        factory: Factory,
        channels: LazyCachedMapCollection<ChatChannel>,
        selectedChannel: Binding<ChannelSelectionInfo?>,
        swipedChannelId: Binding<String?>,
        onlineIndicatorShown: @escaping @MainActor (ChatChannel) -> Bool,
        imageLoader: @escaping @MainActor (ChatChannel) -> UIImage,
        onItemTap: @escaping @MainActor (ChatChannel) -> Void,
        onItemAppear: @escaping @MainActor (Int) -> Void,
        channelNaming: @escaping @MainActor (ChatChannel) -> String,
        channelDestination: @escaping @MainActor (ChannelSelectionInfo) -> Factory.ChannelDestination,
        trailingSwipeRightButtonTapped: @escaping @MainActor (ChatChannel) -> Void,
        trailingSwipeLeftButtonTapped: @escaping @MainActor (ChatChannel) -> Void,
        leadingSwipeButtonTapped: @escaping @MainActor (ChatChannel) -> Void
    ) {
        self.factory = factory
        self.channels = channels
        self.onItemTap = onItemTap
        self.onItemAppear = onItemAppear
        self.channelNaming = channelNaming
        self.channelDestination = channelDestination
        self.imageLoader = imageLoader
        self.onlineIndicatorShown = onlineIndicatorShown
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
                        channelName: channelNaming(channel),
                        avatar: imageLoader(channel),
                        onlineIndicatorShown: onlineIndicatorShown(channel),
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
        .modifier(factory.makeChannelListModifier(options: ChannelListModifierOptions()))
    }
}

/// Determines the uniqueness of the channel list item.
extension ChatChannel: Identifiable {
    public var id: String {
        cid.rawValue
    }
}
