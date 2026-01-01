//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Chat channel list item that supports navigating to a destination.
/// It's generic over the channel destination.
public struct ChatChannelNavigatableListItem<Factory: ViewFactory, ChannelDestination: View>: View {
    private var factory: Factory
    private var channel: ChatChannel
    private var channelName: String
    private var avatar: UIImage
    private var disabled: Bool
    private var onlineIndicatorShown: Bool
    private var handleTabBarVisibility: Bool
    @Binding private var selectedChannel: ChannelSelectionInfo?
    private var channelDestination: (ChannelSelectionInfo) -> ChannelDestination
    private var onItemTap: (ChatChannel) -> Void

    public init(
        factory: Factory = DefaultViewFactory.shared,
        channel: ChatChannel,
        channelName: String,
        avatar: UIImage,
        onlineIndicatorShown: Bool,
        disabled: Bool = false,
        handleTabBarVisibility: Bool = true,
        selectedChannel: Binding<ChannelSelectionInfo?>,
        channelDestination: @escaping (ChannelSelectionInfo) -> ChannelDestination,
        onItemTap: @escaping (ChatChannel) -> Void
    ) {
        self.factory = factory
        self.channel = channel
        self.channelName = channelName
        self.channelDestination = channelDestination
        self.onItemTap = onItemTap
        self.avatar = avatar
        self.onlineIndicatorShown = onlineIndicatorShown
        self.disabled = disabled
        _selectedChannel = selectedChannel
        self.handleTabBarVisibility = true
    }

    public var body: some View {
        ZStack {
            ChatChannelListItem(
                factory: factory,
                channel: channel,
                channelName: channelName,
                injectedChannelInfo: injectedChannelInfo,
                avatar: avatar,
                onlineIndicatorShown: onlineIndicatorShown,
                disabled: disabled,
                onItemTap: onItemTap
            )

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

    private var injectedChannelInfo: InjectedChannelInfo? {
        selectedChannel?.channel.cid.rawValue == channel.cid.rawValue ? selectedChannel?.injectedChannelInfo : nil
    }
}

/// Used for representing selection of an item in the channel list.
/// The optional message is used in case we need to scroll to a particular one in the message list.
public struct ChannelSelectionInfo: Identifiable {
    public let id: String
    public let channel: ChatChannel
    public let message: ChatMessage?
    public var injectedChannelInfo: InjectedChannelInfo?
    public var searchType: ChannelListSearchType

    public init(
        channel: ChatChannel,
        message: ChatMessage?,
        searchType: ChannelListSearchType = .messages
    ) {
        self.channel = channel
        self.message = message
        self.searchType = searchType
        if let message = message {
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
