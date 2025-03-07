//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the channel list item.
public struct ChatChannelListItem<Factory: ViewFactory>: View {

    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils
    @Injected(\.images) private var images
    @Injected(\.chatClient) private var chatClient

    var factory: Factory
    var channel: ChatChannel
    var channelName: String
    var injectedChannelInfo: InjectedChannelInfo?
    var avatar: UIImage
    var onlineIndicatorShown: Bool
    var disabled = false
    var onItemTap: (ChatChannel) -> Void

    public init(
        factory: Factory = DefaultViewFactory.shared,
        channel: ChatChannel,
        channelName: String,
        injectedChannelInfo: InjectedChannelInfo? = nil,
        avatar: UIImage,
        onlineIndicatorShown: Bool,
        disabled: Bool = false,
        onItemTap: @escaping (ChatChannel) -> Void
    ) {
        self.factory = factory
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
                factory.makeChannelAvatarView(
                    for: channel,
                    with: .init(showOnlineIndicator: onlineIndicatorShown)
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
            if utils.messageListConfig.draftMessagesEnabled, let draftText = channel.draftMessageText {
                HStack(spacing: 2) {
                    Text("\(L10n.Message.Preview.draft):")
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

/// Options for setting up the channel avatar view.
public struct ChannelAvatarViewOptions {
    /// Whether the online indicator should be shown.
    public var showOnlineIndicator: Bool
    /// Size of the avatar.
    public var size: CGSize = .defaultAvatarSize
    /// Optional avatar image. If not provided, it will be loaded by the channel header loader.
    public var avatar: UIImage?
}

/// View for the avatar used in channels (includes online indicator overlay).
public struct ChannelAvatarView: View {
    @Injected(\.utils) private var utils
    let avatar: UIImage?
    let showOnlineIndicator: Bool
    let size: CGSize

    @State private var channelAvatar = UIImage()
    let channel: ChatChannel?

    @available(
        *,
        deprecated,
        renamed: "init(channel:showOnlineIndicator:size:)",
        message: "Use automatically refreshing avatar initializer."
    )
    public init(
        avatar: UIImage,
        showOnlineIndicator: Bool,
        size: CGSize = .defaultAvatarSize
    ) {
        self.avatar = avatar
        channel = nil
        self.showOnlineIndicator = showOnlineIndicator
        self.size = size
    }
    
    public init(
        channel: ChatChannel,
        showOnlineIndicator: Bool,
        avatar: UIImage? = nil,
        size: CGSize = .defaultAvatarSize
    ) {
        self.avatar = avatar
        self.channel = channel
        self.showOnlineIndicator = showOnlineIndicator
        self.size = size
    }

    public var body: some View {
        LazyView(
            AvatarView(avatar: image, size: size)
                .overlay(
                    showOnlineIndicator ?
                        TopRightView {
                            OnlineIndicatorView(indicatorSize: size.width * 0.3)
                        }
                        .offset(x: 3, y: -1)
                        : nil
                )
                .onLoad {
                    reloadAvatar()
                }
                .onReceive(channelHeaderLoader.channelAvatarChanged(channel?.cid)) { _ in
                    reloadAvatar()
                }
        )
        .accessibilityIdentifier("ChannelAvatarView")
    }
    
    private var channelHeaderLoader: ChannelHeaderLoader { utils.channelHeaderLoader }
    
    private var image: UIImage {
        avatar ?? channelAvatar
    }
    
    private func reloadAvatar() {
        guard let channel, avatar == nil else { return }
        channelAvatar = utils.channelHeaderLoader.image(for: channel)
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
    
    public init(
        subtitle: String? = nil,
        unreadCount: Int,
        timestamp: String? = nil,
        lastMessageAt: Date? = nil,
        latestMessages: [ChatMessage]? = nil
    ) {
        self.subtitle = subtitle
        self.unreadCount = unreadCount
        self.timestamp = timestamp
        self.lastMessageAt = lastMessageAt
        self.latestMessages = latestMessages
    }
}

extension ChatChannel {

    public var previewMessageText: String? {
        guard let previewMessage else { return nil }
        let messageFormatter = InjectedValues[\.utils].messagePreviewFormatter
        return messageFormatter.format(previewMessage)
    }

    public var draftMessageText: String? {
        guard let draftMessage = draftMessage else { return nil }
        let messageFormatter = InjectedValues[\.utils].messagePreviewFormatter
        return messageFormatter.formatContent(for: ChatMessage(draftMessage))
    }

    public var lastMessageText: String? {
        guard let latestMessage = latestMessages.first else { return nil }
        let messageFormatter = InjectedValues[\.utils].messagePreviewFormatter
        return messageFormatter.format(latestMessage)
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
        } else if let previewMessageText {
            return previewMessageText
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
}
