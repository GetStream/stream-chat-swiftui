//
// Copyright © 2023 Stream.io Inc. All rights reserved.
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
        if let channelNaming = channelNaming {
            self.channelNaming = channelNaming
        } else {
            let channelNamer = InjectedValues[\.utils].channelNamer
            self.channelNaming = { channel in
                channelNamer(channel, InjectedValues[\.chatClient].currentUserId) ?? ""
            }
        }
        self.channelDestination = channelDestination
        if let imageLoader = imageLoader {
            self.imageLoader = imageLoader
        } else {
            self.imageLoader = InjectedValues[\.utils].channelHeaderLoader.image(for:)
        }
        if let onlineIndicatorShown = onlineIndicatorShown {
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
    }

    public var body: some View {
        Group {
            if scrollable {
                ScrollView {
                    channelsVStack
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

    private var factory: Factory
    var channels: LazyCachedMapCollection<ChatChannel>
    @Binding var selectedChannel: ChannelSelectionInfo?
    @Binding var swipedChannelId: String?
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
        onlineIndicatorShown: @escaping (ChatChannel) -> Bool,
        imageLoader: @escaping (ChatChannel) -> UIImage,
        onItemTap: @escaping (ChatChannel) -> Void,
        onItemAppear: @escaping (Int) -> Void,
        channelNaming: @escaping (ChatChannel) -> String,
        channelDestination: @escaping (ChannelSelectionInfo) -> Factory.ChannelDestination,
        trailingSwipeRightButtonTapped: @escaping (ChatChannel) -> Void,
        trailingSwipeLeftButtonTapped: @escaping (ChatChannel) -> Void,
        leadingSwipeButtonTapped: @escaping (ChatChannel) -> Void
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
                .onAppear {
                    if let index = channels.firstIndex(where: { chatChannel in
                        chatChannel.id == channel.id
                    }) {
                        onItemAppear(index)
                    }
                }

                factory.makeChannelListDividerItem()
            }

            factory.makeChannelListFooterView()
        }
        .modifier(factory.makeChannelListModifier())
    }
}

/// Determines the uniqueness of the channel list item.
extension ChatChannel: Identifiable {
    private var mutedString: String {
        isMuted ? "muted" : "unmuted"
    }

    public var id: String {
        "\(cid.id)-\(lastMessageAt ?? createdAt)-\(lastActiveMembersCount)-\(mutedString)-\(typingUsersString)-\(readUsersId)"
    }

    private var readUsersId: String {
        "\(readUsers(currentUserId: nil, message: latestMessages.first).count)"
    }

    private var lastActiveMembersCount: Int {
        lastActiveMembers.filter { member in
            member.isOnline
        }
        .count
    }

    private var typingUsersString: String {
        currentlyTypingUsers.map { user in
            user.id
        }
        .joined(separator: "-")
    }
}
