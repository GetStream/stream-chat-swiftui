//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Chat channel list item that supports navigating to a destination.
/// It's generic over the channel destination.
public struct ChatChannelNavigatableListItem<ChannelDestination: View>: View {
    private var channel: ChatChannel
    private var channelName: String
    private var avatar: UIImage
    private var disabled: Bool
    private var onlineIndicatorShown: Bool
    @Binding private var selectedChannel: ChatChannel?
    private var channelDestination: (ChatChannel) -> ChannelDestination
    private var onItemTap: (ChatChannel) -> Void
    
    public init(
        channel: ChatChannel,
        channelName: String,
        avatar: UIImage,
        onlineIndicatorShown: Bool,
        disabled: Bool = false,
        selectedChannel: Binding<ChatChannel?>,
        channelDestination: @escaping (ChatChannel) -> ChannelDestination,
        onItemTap: @escaping (ChatChannel) -> Void
    ) {
        self.channel = channel
        self.channelName = channelName
        self.channelDestination = channelDestination
        self.onItemTap = onItemTap
        self.avatar = avatar
        self.onlineIndicatorShown = onlineIndicatorShown
        self.disabled = disabled
        _selectedChannel = selectedChannel
    }
    
    public var body: some View {
        ZStack {
            ChatChannelListItem(
                channel: channel,
                channelName: channelName,
                avatar: avatar,
                onlineIndicatorShown: onlineIndicatorShown,
                disabled: disabled,
                onItemTap: onItemTap
            )
                                    
            NavigationLink(tag: channel, selection: $selectedChannel) {
                LazyView(channelDestination(channel))
            } label: {
                EmptyView()
            }
        }
        .id("\(channel.id)-navigatable")
    }
}
