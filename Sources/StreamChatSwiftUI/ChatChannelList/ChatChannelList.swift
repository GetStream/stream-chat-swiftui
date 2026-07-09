//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Stateless component for the channel list.
/// If used directly, you should provide the channel list.
public struct ChannelList<Factory: ViewFactory>: View {
    @Injected(\.chatClient) private var chatClient
    @Injected(\.utils) private var utils

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
                if #available(iOS 15.0, *) {
                    ScrollViewReader { scrollView in
                        channelsList
                            .onChange(of: scrolledChannelId) { newValue in
                                if let newValue {
                                    withAnimation {
                                        scrollView.scrollTo(newValue, anchor: .bottom)
                                    }
                                }
                            }
                    }
                } else {
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
                }
            } else {
                channelsVStack
            }
        }
    }

    @available(iOS 15.0, *)
    private var channelsList: some View {
        channelListItems(style: .nativeList)
    }

    private var channelsVStack: some View {
        channelListItems(style: .lazyVStack)
    }

    private func channelListItems(style: ChannelListContainerStyle) -> some View {
        ChannelListItemsContainer(
            factory: factory,
            channels: channels,
            selectedChannel: $selectedChannel,
            swipedChannelId: $swipedChannelId,
            onItemTap: onItemTap,
            onItemAppear: onItemAppear,
            channelDestination: channelDestination,
            trailingSwipeRightButtonTapped: trailingSwipeRightButtonTapped,
            trailingSwipeLeftButtonTapped: trailingSwipeLeftButtonTapped,
            leadingSwipeButtonTapped: leadingSwipeButtonTapped,
            currentUserId: chatClient.currentUserId,
            showChannelListDividerOnLastItem: utils.channelListConfig.showChannelListDividerOnLastItem,
            style: style
        )
    }
}

/// LazyVStack displaying list of channels.
public struct ChannelsLazyVStack<Factory: ViewFactory>: View {
    private var content: ChannelList<Factory>

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
        content = ChannelList(
            factory: factory,
            channels: channels,
            selectedChannel: selectedChannel,
            swipedChannelId: swipedChannelId,
            scrollable: false,
            onItemTap: onItemTap,
            onItemAppear: onItemAppear,
            channelDestination: channelDestination,
            trailingSwipeRightButtonTapped: trailingSwipeRightButtonTapped,
            trailingSwipeLeftButtonTapped: trailingSwipeLeftButtonTapped,
            leadingSwipeButtonTapped: leadingSwipeButtonTapped
        )
    }

    public var body: some View {
        content
    }
}

private enum ChannelListContainerStyle {
    case lazyVStack
    case nativeList
}

private struct ChannelListItemsContainer<Factory: ViewFactory>: View {
    @Injected(\.utils) private var utils

    let factory: Factory
    let channels: [ChatChannel]
    @Binding var selectedChannel: ChannelSelectionInfo?
    @Binding var swipedChannelId: String?
    let onItemTap: @MainActor (ChatChannel) -> Void
    let onItemAppear: @MainActor (Int) -> Void
    let channelDestination: (@MainActor (ChannelSelectionInfo) -> Factory.ChannelDestination)?
    let trailingSwipeRightButtonTapped: @MainActor (ChatChannel) -> Void
    let trailingSwipeLeftButtonTapped: @MainActor (ChatChannel) -> Void
    let leadingSwipeButtonTapped: @MainActor (ChatChannel) -> Void
    let currentUserId: UserId?
    let showChannelListDividerOnLastItem: Bool
    let style: ChannelListContainerStyle

    var body: some View {
        let channelIndexLookup = channelListIndexLookup(for: channels)

        Group {
            switch style {
            case .lazyVStack:
                LazyVStack(spacing: 0) {
                    channelListContent(channelIndexLookup: channelIndexLookup)
                }
            case .nativeList:
                List {
                    channelListContent(channelIndexLookup: channelIndexLookup)
                }
                .listStyle(.plain)
                .modifier(HideListScrollContentBackgroundModifier())
            }
        }
        .modifier(factory.styles.makeChannelListModifier(options: ChannelListModifierOptions()))
    }

    @ViewBuilder
    private func channelListContent(channelIndexLookup: [String: Int]) -> some View {
        channelRows(channelIndexLookup: channelIndexLookup)
        channelListFooter
    }

    @ViewBuilder
    private func channelRows(channelIndexLookup: [String: Int]) -> some View {
        ForEach(channels) { channel in
            let isLastItem = channel.cid == channels.last?.cid
            let showsDivider = !isLastItem || (isLastItem && showChannelListDividerOnLastItem)

            ChannelListItemRow(
                factory: factory,
                channel: channel,
                channelName: utils.channelNameFormatter.format(
                    channel: channel,
                    forCurrentUserId: currentUserId
                ) ?? "",
                showsDivider: showsDivider,
                isSelected: selectedChannel?.channel.id == channel.id,
                isDisabled: swipedChannelId == channel.id,
                selectedChannel: $selectedChannel,
                swipedChannelId: $swipedChannelId,
                channelDestination: channelDestination,
                onItemTap: onItemTap,
                trailingSwipeRightButtonTapped: trailingSwipeRightButtonTapped,
                trailingSwipeLeftButtonTapped: trailingSwipeLeftButtonTapped,
                leadingSwipeButtonTapped: leadingSwipeButtonTapped
            )
            .onAppear {
                if let index = channelIndexLookup[channel.id] {
                    onItemAppear(index)
                }
            }
            .modifier(ChannelListRowStyleModifier(style: style))
        }
    }

    @ViewBuilder
    private var channelListFooter: some View {
        factory.makeChannelListFooterView(options: ChannelListFooterViewOptions())
            .modifier(ChannelListRowStyleModifier(style: style))
    }
}

private struct ChannelListItemRow<Factory: ViewFactory>: View {
    let factory: Factory
    let channel: ChatChannel
    let channelName: String
    let showsDivider: Bool
    let isSelected: Bool
    let isDisabled: Bool
    @Binding var selectedChannel: ChannelSelectionInfo?
    @Binding var swipedChannelId: String?
    let channelDestination: (@MainActor (ChannelSelectionInfo) -> Factory.ChannelDestination)?
    let onItemTap: @MainActor (ChatChannel) -> Void
    let trailingSwipeRightButtonTapped: @MainActor (ChatChannel) -> Void
    let trailingSwipeLeftButtonTapped: @MainActor (ChatChannel) -> Void
    let leadingSwipeButtonTapped: @MainActor (ChatChannel) -> Void

    var body: some View {
        factory.makeChannelListItem(
            options: ChannelListItemOptions(
                channel: channel,
                channelName: channelName,
                disabled: isDisabled,
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
        .overlay(
            Group {
                if showsDivider {
                    factory.makeChannelListDividerItem(options: ChannelListDividerItemOptions())
                }
            },
            alignment: .bottom
        )
    }
}

private struct HideListScrollContentBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.scrollContentBackground(.hidden)
        } else {
            content
        }
    }
}

private struct ChannelListRowStyleModifier: ViewModifier {
    let style: ChannelListContainerStyle

    @ViewBuilder
    func body(content: Content) -> some View {
        switch style {
        case .lazyVStack:
            content
        case .nativeList:
            if #available(iOS 15.0, *) {
                content
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            } else {
                content
            }
        }
    }
}

/// Builds a channel id to index map once per body evaluation so a row's
/// index can be resolved in O(1) on appearance instead of scanning the
/// whole array with `firstIndex(where:)`.
func channelListIndexLookup(for channels: [ChatChannel]) -> [String: Int] {
    var lookup = [String: Int]()
    lookup.reserveCapacity(channels.count)
    for (index, channel) in channels.enumerated() where lookup[channel.id] == nil {
        lookup[channel.id] = index
    }
    return lookup
}
