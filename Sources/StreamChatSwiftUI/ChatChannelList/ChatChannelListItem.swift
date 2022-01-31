//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the channel list item.
public struct ChatChannelListItem: View {
    
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils
    @Injected(\.images) private var images
    @Injected(\.chatClient) private var chatClient
        
    var channel: ChatChannel
    var channelName: String
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
                    avatar: avatar,
                    showOnlineIndicator: onlineIndicatorShown
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        ChatTitleView(name: channelName)
                        
                        Spacer()
                        
                        if channel.unreadCount != .noUnread {
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
                                    showReadCount: false
                                )
                            }
                            SubtitleText(text: timestampText)
                        }
                    }
                }
            }
            .padding(.all, 8)
        }
        .foregroundColor(.black)
        .disabled(disabled)
        .id("\(channel.id)-base")
    }
        
    private var subtitleView: some View {
        HStack(spacing: 4) {
            if let image = image {
                Image(uiImage: image)
                    .customizable()
                    .frame(maxHeight: 12)
                    .foregroundColor(Color(colors.subtitleText))
            } else {
                if shouldShowTypingIndicator {
                    TypingIndicatorView()
                }
            }
            SubtitleText(text: subtitleText)
            Spacer()
        }
    }
    
    private var subtitleText: String {
        if channel.isMuted {
            return L10n.Channel.Item.muted
        } else if shouldShowTypingIndicator {
            return channel.typingIndicatorString(currentUserId: chatClient.currentUserId)
        } else if let lastMessageText = channel.lastMessageText {
            return lastMessageText
        } else {
            return L10n.Channel.Item.emptyMessages
        }
    }
    
    private var shouldShowReadEvents: Bool {
        if let message = channel.latestMessages.first,
           message.isSentByCurrentUser,
           !message.isDeleted {
            return channel.config.readEventsEnabled
        }

        return false
    }
    
    private var shouldShowTypingIndicator: Bool {
        !channel.currentlyTypingUsersFiltered(
            currentUserId: chatClient.currentUserId
        ).isEmpty && channel.config.typingEventsEnabled
    }
    
    private var image: UIImage? {
        if channel.isMuted {
            return images.muted
        }
        return nil
    }
    
    private var timestampText: String {
        if let lastMessageAt = channel.lastMessageAt {
            return utils.dateFormatter.string(from: lastMessageAt)
        } else {
            return ""
        }
    }
}

/// View for the avatar used in channels (includes online indicator overlay).
public struct ChannelAvatarView: View {
        
    var avatar: UIImage
    var showOnlineIndicator: Bool
    var size: CGSize = .defaultAvatarSize
    
    public init(
        avatar: UIImage,
        showOnlineIndicator: Bool,
        size: CGSize = .defaultAvatarSize
    ) {
        self.avatar = avatar
        self.showOnlineIndicator = showOnlineIndicator
        self.size = size
    }
    
    public var body: some View {
        LazyView(
            AvatarView(avatar: avatar, size: size)
                .overlay(
                    showOnlineIndicator ?
                        TopRightView {
                            OnlineIndicatorView(indicatorSize: size.width * 0.3)
                        }
                        .offset(x: 3, y: -1)
                        : nil
                )
        )
    }
}

/// View used for the online indicator.
public struct OnlineIndicatorView: View {
    @Injected(\.colors) private var colors
    
    var indicatorSize: CGFloat
    
    public var body: some View {
        ZStack {
            Circle()
                .fill(Color(colors.textInverted))
                .frame(width: indicatorSize, height: indicatorSize)
            
            Circle()
                .fill(Color(colors.alternativeActiveTint))
                .frame(width: innerCircleSize, height: innerCircleSize)
        }
    }
    
    private var innerCircleSize: CGFloat {
        2 * indicatorSize / 3
    }
}

/// View displaying the user's unread messages in the channel list item.
public struct UnreadIndicatorView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    var unreadCount: Int
    
    public var body: some View {
        Text("\(unreadCount)")
            .lineLimit(1)
            .font(fonts.footnoteBold)
            .foregroundColor(Color(colors.staticColorText))
            .frame(width: unreadCount < 10 ? 18 : nil, height: 18)
            .padding(.horizontal, unreadCount < 10 ? 0 : 6)
            .background(Color(colors.alert))
            .cornerRadius(9)
    }
}

extension ChatChannel {
    
    var lastMessageText: String? {
        if let latestMessage = latestMessages.first {
            return "\(latestMessage.author.name ?? latestMessage.author.id): \(latestMessage.textContent ?? latestMessage.text)"
        } else {
            return nil
        }
    }
}
