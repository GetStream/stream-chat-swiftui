//
// Copyright © 2023 Stream.io Inc. All rights reserved.
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
    var injectedChannelInfo: InjectedChannelInfo?
    var avatar: UIImage
    var onlineIndicatorShown: Bool
    var disabled = false
    var onItemTap: (ChatChannel) -> Void

    public init(
        channel: ChatChannel,
        channelName: String,
        injectedChannelInfo: InjectedChannelInfo? = nil,
        avatar: UIImage,
        onlineIndicatorShown: Bool,
        disabled: Bool = false,
        onItemTap: @escaping (ChatChannel) -> Void
    ) {
        self.channel = channel
        self.channelName = channelName
        self.injectedChannelInfo = injectedChannelInfo
        self.avatar = avatar
        self.onlineIndicatorShown = onlineIndicatorShown
        self.disabled = disabled
        self.onItemTap = onItemTap
    }

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
                                    showReadCount: false
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
                if channel.shouldShowTypingIndicator {
                    TypingIndicatorView()
                }
            }
            SubtitleText(text: injectedChannelInfo?.subtitle ?? channel.subtitleText)
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
        .accessibilityIdentifier("ChannelAvatarView")
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

    public init(unreadCount: Int) {
        self.unreadCount = unreadCount
    }

    public var body: some View {
        Text("\(unreadCount)")
            .lineLimit(1)
            .font(fonts.footnoteBold)
            .foregroundColor(Color(colors.staticColorText))
            .frame(width: unreadCount < 10 ? 18 : nil, height: 18)
            .padding(.horizontal, unreadCount < 10 ? 0 : 6)
            .background(Color(colors.alert))
            .cornerRadius(9)
            .accessibilityIdentifier("UnreadIndicatorView")
    }
}

public struct InjectedChannelInfo {
    public var subtitle: String?
    public var unreadCount: Int
    public var timestamp: String?
    public var lastMessageAt: Date?
    public var latestMessages: [ChatMessage]?
}

extension ChatChannel {

    public var lastMessageText: String? {
        if let latestMessage = latestMessages.first {
            return "\(latestMessage.author.name ?? latestMessage.author.id): \(textContent(for: latestMessage))"
        } else {
            return nil
        }
    }

    public var shouldShowTypingIndicator: Bool {
        !currentlyTypingUsersFiltered(
            currentUserId: InjectedValues[\.chatClient].currentUserId
        ).isEmpty && config.typingEventsEnabled
    }
    
    public var shouldShowOnlineIndicator: Bool {
        !lastActiveMembers.filter { member in
            member.isOnline && member.id != InjectedValues[\.chatClient].currentUserId
        }
        .isEmpty
    }

    public var subtitleText: String {
        if isMuted {
            return L10n.Channel.Item.muted
        } else if shouldShowTypingIndicator {
            return typingIndicatorString(currentUserId: InjectedValues[\.chatClient].currentUserId)
        } else if let lastMessageText = lastMessageText {
            return lastMessageText
        } else {
            return L10n.Channel.Item.emptyMessages
        }
    }

    public var timestampText: String {
        if let lastMessageAt = lastMessageAt {
            return InjectedValues[\.utils].dateFormatter.string(from: lastMessageAt)
        } else {
            return ""
        }
    }
    
    private func textContent(for previewMessage: ChatMessage) -> String {
        if let attachmentPreviewText = attachmentPreviewText(for: previewMessage) {
            return attachmentPreviewText
        }
        if let textContent = previewMessage.textContent, !textContent.isEmpty {
            return textContent
        }
        return previewMessage.adjustedText
    }
    
    /// The message preview text in case it contains attachments.
    /// - Parameter previewMessage: The preview message of the channel.
    /// - Returns: A string representing the message preview text.
    private func attachmentPreviewText(for previewMessage: ChatMessage) -> String? {
        guard let attachment = previewMessage.allAttachments.first else {
            return nil
        }
        let text = previewMessage.textContent ?? previewMessage.text
        switch attachment.type {
        case .audio:
            let defaultAudioText = L10n.Channel.Item.audio
            return "🎧 \(text.isEmpty ? defaultAudioText : text)"
        case .file:
            guard let fileAttachment = previewMessage.fileAttachments.first else {
                return nil
            }
            let title = fileAttachment.payload.title
            return "📄 \(title ?? text)"
        case .image:
            let defaultPhotoText = L10n.Channel.Item.photo
            return "📷 \(text.isEmpty ? defaultPhotoText : text)"
        case .video:
            let defaultVideoText = L10n.Channel.Item.video
            return "📹 \(text.isEmpty ? defaultVideoText : text)"
        case .giphy:
            return "/giphy"
        default:
            return nil
        }
    }
}
