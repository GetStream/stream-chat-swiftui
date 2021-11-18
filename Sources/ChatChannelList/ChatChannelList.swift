//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Stateless component for the channel list.
/// If used directly, you should provide the channel list.
public struct ChannelList<Factory: ViewFactory>: View {
    private var factory: Factory
    var channels: LazyCachedMapCollection<ChatChannel>
    @Binding var selectedChannel: ChatChannel?
    @Binding var currentChannelId: String?
    private var onlineIndicatorShown: (ChatChannel) -> Bool
    private var imageLoader: (ChatChannel) -> UIImage
    private var onItemTap: (ChatChannel) -> Void
    private var onItemAppear: (Int) -> Void
    private var channelNaming: (ChatChannel) -> String
    private var channelDestination: (ChatChannel) -> Factory.ChannelDestination
    private var onDelete: (ChatChannel) -> Void
    private var onMoreTapped: (ChatChannel) -> Void
    
    public init(
        factory: Factory,
        channels: LazyCachedMapCollection<ChatChannel>,
        selectedChannel: Binding<ChatChannel?>,
        currentChannelId: Binding<String?>,
        onlineIndicatorShown: @escaping (ChatChannel) -> Bool,
        imageLoader: @escaping (ChatChannel) -> UIImage,
        onItemTap: @escaping (ChatChannel) -> Void,
        onItemAppear: @escaping (Int) -> Void,
        channelNaming: @escaping (ChatChannel) -> String,
        channelDestination: @escaping (ChatChannel) -> Factory.ChannelDestination,
        onDelete: @escaping (ChatChannel) -> Void,
        onMoreTapped: @escaping (ChatChannel) -> Void
    ) {
        self.factory = factory
        self.channels = channels
        self.onItemTap = onItemTap
        self.onItemAppear = onItemAppear
        self.channelNaming = channelNaming
        self.channelDestination = channelDestination
        self.imageLoader = imageLoader
        self.onlineIndicatorShown = onlineIndicatorShown
        self.onDelete = onDelete
        self.onMoreTapped = onMoreTapped
        _selectedChannel = selectedChannel
        _currentChannelId = currentChannelId
    }
    
    public var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(channels) { channel in
                    factory.makeChannelListItem(
                        currentChannelId: $currentChannelId,
                        channel: channel,
                        channelName: channelNaming(channel),
                        avatar: imageLoader(channel),
                        onlineIndicatorShown: onlineIndicatorShown(channel),
                        disabled: currentChannelId == channel.id,
                        selectedChannel: $selectedChannel,
                        channelDestination: channelDestination,
                        onItemTap: onItemTap,
                        onDelete: onDelete,
                        onMoreTapped: onMoreTapped
                    )
                    .frame(height: 48)
                    .onAppear {
                        if let index = channels.firstIndex(where: { chatChannel in
                            chatChannel.id == channel.id
                        }) {
                            onItemAppear(index)
                        }
                    }
                    
                    Divider()
                }
            }
        }
    }
}

/// Determines the uniqueness of the channel list item.
extension ChatChannel: Identifiable {
    private var mutedString: String {
        isMuted ? "muted" : "unmuted"
    }

    public var id: String {
        "\(cid.id)-\(lastMessageAt ?? createdAt)-\(lastActiveMembersCount)-\(mutedString)-\(unreadCount.messages)"
    }
    
    public var lastActiveMembersCount: Int {
        lastActiveMembers.filter { member in
            member.isOnline
        }
        .count
    }
}
