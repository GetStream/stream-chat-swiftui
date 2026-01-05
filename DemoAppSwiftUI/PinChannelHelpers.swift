//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

struct DemoAppChatChannelListItem: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils
    @Injected(\.images) private var images
    @Injected(\.chatClient) private var chatClient

    var channel: ChatChannel
    var channelName: String
    var injectedChannelInfo: InjectedChannelInfo?
    var avatar: UIImage
    var onlineIndicatorShown: Bool
    var disabled = false
    var onItemTap: (ChatChannel) -> Void

    public var body: some View {
        Button {
            onItemTap(channel)
        } label: {
            HStack {
                ChannelAvatarView(
                    channel: channel,
                    showOnlineIndicator: onlineIndicatorShown
                )

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        ChatTitleView(name: channelName)

                        Spacer()

                        if injectedChannelInfo == nil && channel.unreadCount != .noUnread {
                            UnreadIndicatorView(
                                unreadCount: channel.unreadCount.messages
                            )
                        }
                    }

                    HStack {
                        subtitleView

                        Spacer()

                        HStack(spacing: 4) {
                            if shouldShowReadEvents {
                                MessageReadIndicatorView(
                                    readUsers: channel.readUsers(
                                        currentUserId: chatClient.currentUserId,
                                        message: channel.latestMessages.first
                                    ),
                                    showReadCount: false,
                                    localState: channel.latestMessages.first?.localState
                                )
                            }
                            SubtitleText(text: injectedChannelInfo?.timestamp ?? channel.timestampText)
                                .accessibilityIdentifier("timestampView")
                        }
                    }
                }
            }
            .padding(.all, 8)
        }
        .foregroundColor(.black)
        .disabled(disabled)
        .background(channel.isPinned ? Color(colors.pinnedBackground) : .clear)
    }

    private var subtitleView: some View {
        HStack(spacing: 4) {
            if let image = image {
                Image(uiImage: image)
                    .customizable()
                    .frame(maxHeight: 12)
                    .foregroundColor(Color(colors.subtitleText))
            } else {
                if channel.shouldShowTypingIndicator {
                    TypingIndicatorView()
                }
            }
            if let draftText = channel.draftMessageText {
                HStack(spacing: 2) {
                    Text("Draft:")
                        .font(fonts.caption1).bold()
                        .foregroundColor(Color(colors.highlightedAccentBackground))
                    SubtitleText(text: draftText)
                }
            } else {
                SubtitleText(text: injectedChannelInfo?.subtitle ?? channel.subtitleText)
            }
            Spacer()
        }
        .accessibilityIdentifier("subtitleView")
    }

    private var shouldShowReadEvents: Bool {
        if let message = channel.latestMessages.first,
           message.isSentByCurrentUser,
           !message.isDeleted {
            return channel.config.readEventsEnabled
        }

        return false
    }

    private var image: UIImage? {
        if channel.isMuted {
            return images.muted
        }
        return nil
    }
}

struct DemoAppChatChannelNavigatableListItem<ChannelDestination: View>: View {
    private var channel: ChatChannel
    private var channelName: String
    private var avatar: UIImage
    private var disabled: Bool
    private var onlineIndicatorShown: Bool
    @Binding private var selectedChannel: ChannelSelectionInfo?
    private var channelDestination: (ChannelSelectionInfo) -> ChannelDestination
    private var onItemTap: (ChatChannel) -> Void

    init(
        channel: ChatChannel,
        channelName: String,
        avatar: UIImage,
        onlineIndicatorShown: Bool,
        disabled: Bool = false,
        selectedChannel: Binding<ChannelSelectionInfo?>,
        channelDestination: @escaping (ChannelSelectionInfo) -> ChannelDestination,
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
            if AppConfiguration.default.isChannelPinningFeatureEnabled {
                DemoAppChatChannelListItem(
                    channel: channel,
                    channelName: channelName,
                    injectedChannelInfo: injectedChannelInfo,
                    avatar: avatar,
                    onlineIndicatorShown: onlineIndicatorShown,
                    disabled: disabled,
                    onItemTap: onItemTap
                )
            } else {
                ChatChannelListItem(
                    channel: channel,
                    channelName: channelName,
                    injectedChannelInfo: injectedChannelInfo,
                    avatar: avatar,
                    onlineIndicatorShown: onlineIndicatorShown,
                    disabled: disabled,
                    onItemTap: onItemTap
                )
            }

            NavigationLink(
                tag: channel.channelSelectionInfo,
                selection: $selectedChannel
            ) {
                LazyView(
                    channelDestination(channel.channelSelectionInfo)
                        .modifier(TabBarVisibilityModifier())
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
