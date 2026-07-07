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
        let indexLookup = channelIndexLookup
        let lastIndex = channels.count - 1
        return LazyVStack(spacing: 0) {
            ForEach(channels) { channel in
                let channelId = channel.id
                ChannelListRowContainer(
                    factory: factory,
                    channel: channel,
                    disabled: swipedChannelId == channelId,
                    isSelected: selectedChannel?.channel.id == channelId,
                    selectedChannel: $selectedChannel,
                    swipedChannelId: $swipedChannelId,
                    channelDestination: channelDestination,
                    onItemTap: onItemTap,
                    trailingSwipeRightButtonTapped: trailingSwipeRightButtonTapped,
                    trailingSwipeLeftButtonTapped: trailingSwipeLeftButtonTapped,
                    leadingSwipeButtonTapped: leadingSwipeButtonTapped
                )
                .equatable()
                .onAppear {
                    if let index = indexLookup[channelId] {
                        onItemAppear(index)
                    }
                }

                let isLastItem = indexLookup[channelId] == lastIndex
                let shouldRenderLastItemDivider = utils.channelListConfig.showChannelListDividerOnLastItem
                if !isLastItem || (isLastItem && shouldRenderLastItemDivider) {
                    factory.makeChannelListDividerItem(options: ChannelListDividerItemOptions())
                }
            }

            factory.makeChannelListFooterView(options: ChannelListFooterViewOptions())
        }
        .modifier(factory.styles.makeChannelListModifier(options: ChannelListModifierOptions()))
    }

    /// A map from channel id to its index in ``channels``.
    ///
    /// Built once per body evaluation so a row's `onAppear` can resolve its
    /// index in O(1) without either scanning the array (O(n) per row) or
    /// copying the heavy `ChatChannel` values into an enumerated array.
    private var channelIndexLookup: [String: Int] {
        var lookup = [String: Int](minimumCapacity: channels.count)
        for index in channels.indices {
            lookup[channels[index].id] = index
        }
        return lookup
    }
}

/// Renders a single channel list row and skips re-evaluating it when neither
/// the channel content nor the row's selection/swipe state changed.
///
/// The channel comparison relies on `ChatChannel`'s `Equatable` implementation,
/// mirroring the update semantics the UIKit SDK uses when diffing channel list
/// cells. Without this gating, every published change in the channel list view
/// model re-evaluates all materialized rows, which degrades scrolling and
/// navigation performance as more pages are loaded.
struct ChannelListRowContainer<Factory: ViewFactory>: View, Equatable {
    @Injected(\.chatClient) private var chatClient
    @Injected(\.utils) private var utils

    let factory: Factory
    let channel: ChatChannel
    let disabled: Bool
    let isSelected: Bool
    @Binding var selectedChannel: ChannelSelectionInfo?
    @Binding var swipedChannelId: String?
    let channelDestination: (@MainActor (ChannelSelectionInfo) -> Factory.ChannelDestination)?
    let onItemTap: @MainActor (ChatChannel) -> Void
    let trailingSwipeRightButtonTapped: @MainActor (ChatChannel) -> Void
    let trailingSwipeLeftButtonTapped: @MainActor (ChatChannel) -> Void
    let leadingSwipeButtonTapped: @MainActor (ChatChannel) -> Void

    init(
        factory: Factory,
        channel: ChatChannel,
        disabled: Bool,
        isSelected: Bool,
        selectedChannel: Binding<ChannelSelectionInfo?>,
        swipedChannelId: Binding<String?>,
        channelDestination: (@MainActor (ChannelSelectionInfo) -> Factory.ChannelDestination)?,
        onItemTap: @escaping @MainActor (ChatChannel) -> Void,
        trailingSwipeRightButtonTapped: @escaping @MainActor (ChatChannel) -> Void,
        trailingSwipeLeftButtonTapped: @escaping @MainActor (ChatChannel) -> Void,
        leadingSwipeButtonTapped: @escaping @MainActor (ChatChannel) -> Void
    ) {
        self.factory = factory
        self.channel = channel
        self.disabled = disabled
        self.isSelected = isSelected
        _selectedChannel = selectedChannel
        _swipedChannelId = swipedChannelId
        self.channelDestination = channelDestination
        self.onItemTap = onItemTap
        self.trailingSwipeRightButtonTapped = trailingSwipeRightButtonTapped
        self.trailingSwipeLeftButtonTapped = trailingSwipeLeftButtonTapped
        self.leadingSwipeButtonTapped = leadingSwipeButtonTapped
    }

    var body: some View {
        factory.makeChannelListItem(
            options: ChannelListItemOptions(
                channel: channel,
                channelName: channelName,
                disabled: disabled,
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
                isSelected: isSelected
            )
        ))
    }

    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.disabled == rhs.disabled
            && lhs.isSelected == rhs.isSelected
            && lhs.channel == rhs.channel
    }

    private var channelName: String {
        utils.channelNameFormatter.format(
            channel: channel,
            forCurrentUserId: chatClient.currentUserId
        ) ?? ""
    }
}
