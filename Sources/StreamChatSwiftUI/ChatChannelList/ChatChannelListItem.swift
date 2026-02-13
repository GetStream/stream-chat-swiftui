//
// Copyright © 2026 Stream.io Inc. All rights reserved.
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
    @Injected(\.tokens) private var tokens

    var factory: Factory
    var channel: ChatChannel
    var channelName: String
    var injectedChannelInfo: InjectedChannelInfo?
    var disabled = false
    var onItemTap: (ChatChannel) -> Void

    public init(
        factory: Factory = DefaultViewFactory.shared,
        channel: ChatChannel,
        channelName: String,
        injectedChannelInfo: InjectedChannelInfo? = nil,
        disabled: Bool = false,
        onItemTap: @escaping (ChatChannel) -> Void
    ) {
        self.factory = factory
        self.channel = channel
        self.channelName = channelName
        self.injectedChannelInfo = injectedChannelInfo
        self.disabled = disabled
        self.onItemTap = onItemTap
    }

    public var body: some View {
        Button {
            onItemTap(channel)
        } label: {
            HStack(spacing: tokens.spacingMd) {
                factory.makeChannelAvatarView(
                    options: ChannelAvatarViewOptions(
                        channel: channel,
                        size: AvatarSize.large
                    )
                )

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        HStack(spacing: 6) {
                            ChatTitleView(name: channelName)
                            if channel.isMuted, mutedLayoutStyle == .afterChannelName {
                                mutedIcon
                                    .frame(maxHeight: 14)
                                    .padding(.bottom, -2)
                            }
                        }

                        Spacer()
                        
                        HStack(spacing: 4) {
                            SubtitleText(
                                text: injectedChannelInfo?.timestamp ?? channel.timestampText,
                                color: Color(colors.textTertiary)
                            )
                            .accessibilityIdentifier("timestampView")
                        }
                        
                        if injectedChannelInfo == nil && channel.unreadCount != .noUnread {
                            UnreadIndicatorView(
                                unreadCount: channel.unreadCount.messages
                            )
                        }
                    }

                    HStack(spacing: tokens.spacingXxs) {
                        if shouldShowReadEvents {
                            MessageReadIndicatorView(
                                readUsers: channel.readUsers(
                                    currentUserId: chatClient.currentUserId,
                                    message: channel.previewMessage
                                ),
                                showReadCount: false,
                                showDelivered: channel.previewMessage?.deliveryStatus(for: channel) == .delivered
                            )
                        }
                        
                        subtitleView

                        Spacer()
                        
                        if channel.isMuted, mutedLayoutStyle == .topBottomCorner {
                            mutedIcon
                        }
                    }
                }
            }
            .padding(.all, tokens.spacingMd)
        }
        .foregroundColor(.black)
        .disabled(disabled)
        .id("\(channel.id)-base")
    }

    private var mutedLayoutStyle: ChannelItemMutedLayoutStyle {
        utils.channelListConfig.channelItemMutedStyle
    }

    private var subtitleView: some View {
        HStack(spacing: 4) {
            if channel.isMuted, mutedLayoutStyle == .default {
                mutedIcon
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
            } else if let authorName = subtitleAuthorName {
                (Text(authorName).fontWeight(.semibold).foregroundColor(Color(colors.textTertiary))
                    + Text(": " + String(subtitleText.dropFirst(authorName.count + 2))))
                    .lineLimit(1)
                    .font(fonts.subheadline)
                    .foregroundColor(Color(colors.textSecondary))
            } else {
                SubtitleText(text: subtitleText)
            }
            Spacer()
        }
        .accessibilityIdentifier("subtitleView")
    }

    private var subtitleAuthorName: String? {
        guard let previewMessage = channel.previewMessage,
              previewMessage.poll == nil else {
            return nil
        }
        let authorName = previewMessage.author.name ?? previewMessage.author.id
        let prefix = "\(authorName): "
        guard subtitleText.hasPrefix(prefix) else {
            return nil
        }
        return authorName
    }

    private var subtitleText: String {
        if let injectedSubtitle = injectedChannelInfo?.subtitle {
            return injectedSubtitle
        }
        if mutedLayoutStyle != .default {
            return channelSubtitleText
        }
        return channel.subtitleText
    }

    private var channelSubtitleText: String {
        if channel.shouldShowTypingIndicator {
            channel.typingIndicatorString(currentUserId: chatClient.currentUserId)
        } else if let previewMessageText = channel.previewMessageText {
            previewMessageText
        } else {
            L10n.Channel.Item.emptyMessages
        }
    }

    private var mutedIcon: some View {
        Image(uiImage: images.muted)
            .customizable()
            .frame(maxHeight: 12)
            .foregroundColor(Color(colors.subtitleText))
    }

    private var shouldShowReadEvents: Bool {
        if let message = channel.previewMessage,
           message.isSentByCurrentUser {
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
            .foregroundColor(Color(colors.badgeTextOnAccent))
            .frame(width: unreadCount < 10 ? 18 : nil, height: 18)
            .padding(.horizontal, unreadCount < 10 ? 0 : 6)
            .background(Color(colors.badgeBackgroundPrimary))
            .cornerRadius(9)
            .accessibilityIdentifier("UnreadIndicatorView")
    }
}

public struct InjectedChannelInfo: Sendable {
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
    @MainActor public var previewMessageText: String? {
        guard let previewMessage else { return nil }
        let messageFormatter = InjectedValues[\.utils].messagePreviewFormatter
        return messageFormatter.format(previewMessage, in: self)
    }

    @MainActor public var draftMessageText: String? {
        guard let draftMessage else { return nil }
        let messageFormatter = InjectedValues[\.utils].messagePreviewFormatter
        return messageFormatter.formatContent(for: ChatMessage(draftMessage), in: self)
    }

    @MainActor public var lastMessageText: String? {
        guard let latestMessage = latestMessages.first else { return nil }
        let messageFormatter = InjectedValues[\.utils].messagePreviewFormatter
        return messageFormatter.format(latestMessage, in: self)
    }

    @MainActor public var shouldShowTypingIndicator: Bool {
        !currentlyTypingUsersFiltered(
            currentUserId: InjectedValues[\.chatClient].currentUserId
        ).isEmpty && config.typingEventsEnabled
    }

    @MainActor public var subtitleText: String {
        if isMuted {
            L10n.Channel.Item.muted
        } else if shouldShowTypingIndicator {
            typingIndicatorString(currentUserId: InjectedValues[\.chatClient].currentUserId)
        } else if let previewMessageText {
            previewMessageText
        } else {
            L10n.Channel.Item.emptyMessages
        }
    }

    @MainActor public var timestampText: String {
        if let lastMessageAt {
            let utils = InjectedValues[\.utils]
            let formatter = utils.messageTimestampFormatter
            return formatter.format(lastMessageAt)
        } else {
            return ""
        }
    }
}

/// The style for the muted icon in the channel list item.
public final class ChannelItemMutedLayoutStyle: Hashable, Sendable {
    let identifier: String

    init(_ identifier: String) {
        self.identifier = identifier
    }

    /// The default style shows the muted icon and the text "channel is muted" as the subtitle text.
    public static let `default`: ChannelItemMutedLayoutStyle = .init("default")

    /// This style shows the muted icon at the top right corner of the channel item.
    /// The subtitle text shows the last message preview text.
    public static let topBottomCorner: ChannelItemMutedLayoutStyle = .init("topBottomCorner")

    /// This style shows the muted icon after the channel name.
    /// The subtitle text shows the last message preview text.
    public static let afterChannelName: ChannelItemMutedLayoutStyle = .init("afterChannelName")
    
    public static func == (lhs: ChannelItemMutedLayoutStyle, rhs: ChannelItemMutedLayoutStyle) -> Bool {
        lhs.identifier == rhs.identifier
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
