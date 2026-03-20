//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
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
                        size: AvatarSize.extraLarge
                    )
                )

                VStack(alignment: .leading, spacing: tokens.spacingXxs) {
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
                        
                        HStack(spacing: tokens.spacingXs) {
                            SubtitleText(
                                text: injectedChannelInfo?.timestamp ?? channel.timestampText,
                                color: Color(colors.textTertiary)
                            )
                            .accessibilityIdentifier("timestampView")

                            if lastMessageFailedToSend {
                                Image(uiImage: images.messageListErrorIndicator)
                                    .customizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(Color(colors.badgeBackgroundError))
                                    .accessibilityHidden(true)
                            }
                        }
                        
                        if injectedChannelInfo == nil && channel.unreadCount != .noUnread {
                            BadgeNotificationView(
                                count: channel.unreadCount.messages
                            )
                        }
                    }

                    HStack(spacing: tokens.spacingXxxs) {
                        if shouldShowReadEvents {
                            MessageReadIndicatorView(
                                readUsers: channel.readUsers(
                                    currentUserId: chatClient.currentUserId,
                                    message: channel.previewMessage
                                ),
                                showDelivered: channel.previewMessage?.deliveryStatus(for: channel) == .delivered
                            )
                        }
                        
                        subtitleView

                        Spacer()
                        
                        if channel.isMuted, mutedLayoutStyle == .bottomRightCorner {
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
            if lastMessageFailedToSend {
                Text(L10n.Channel.Item.messageFailedToSend)
                    .font(fonts.subheadline)
                    .foregroundColor(Color(colors.accentError))
                    .lineLimit(1)
            } else if channel.shouldShowTypingIndicator {
                factory.makeSubtitleTypingIndicatorView(
                    options: SubtitleTypingIndicatorViewOptions(channel: channel)
                )
            } else if utils.messageListConfig.draftMessagesEnabled, let draftText = channel.draftMessageText {
                HStack(spacing: 2) {
                    Text("\(L10n.Message.Preview.draft): ")
                        .font(fonts.subheadline).fontWeight(.semibold)
                        .foregroundColor(Color(colors.accentPrimary))
                    SubtitleText(text: draftText)
                }
            } else if let authorName = subtitleAuthorName {
                let contentString = channel.previewMessage.map {
                    utils.messagePreviewFormatter.formatContent(for: $0, in: channel)
                } ?? subtitleText
                HStack(spacing: tokens.spacingXxs) {
                    Text("\(authorName):")
                        .font(fonts.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(colors.textTertiary))
                    attachmentIconView
                    Text(contentString)
                }
                .lineLimit(1)
                .font(fonts.subheadline)
                .foregroundColor(Color(colors.textSecondary))
            } else if previewAttachmentIconImage != nil {
                HStack(spacing: tokens.spacingXxs) {
                    attachmentIconView
                    Text(subtitleText)
                }
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

    private var previewAttachmentIconImage: UIImage? {
        guard let previewMessage = channel.previewMessage else { return nil }
        let resolver = MessageAttachmentPreviewResolver(message: previewMessage)
        guard let previewIcon = resolver.previewIcon else { return nil }
        return utils.messageAttachmentPreviewIconProvider.image(for: previewIcon)
    }

    @ViewBuilder
    private var attachmentIconView: some View {
        if let iconImage = previewAttachmentIconImage {
            Image(uiImage: iconImage)
                .customizable()
                .frame(maxHeight: 14)
                .accessibilityHidden(true)
        }
    }

    private var subtitleAuthorName: String? {
        guard let previewMessage = channel.previewMessage,
              previewMessage.poll == nil,
              injectedChannelInfo?.subtitle == nil,
              !(channel.isDirectMessageChannel && channel.memberCount == 2) else {
            return nil
        }
        if previewMessage.isSentByCurrentUser {
            return L10n.Channel.Item.you
        }
        return previewMessage.author.name ?? previewMessage.author.id
    }

    private var subtitleText: String {
        if let injectedSubtitle = injectedChannelInfo?.subtitle {
            return injectedSubtitle
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

    private var lastMessageFailedToSend: Bool {
        channel.previewMessage?.localState == .sendingFailed
    }

    private var shouldShowReadEvents: Bool {
        if channel.shouldShowTypingIndicator || lastMessageFailedToSend {
            return false
        }
        if utils.messageListConfig.draftMessagesEnabled && channel.draftMessageText != nil {
            return false
        }
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

public final class InjectedChannelInfo: Sendable {
    public let subtitle: String?
    public let unreadCount: Int
    public let timestamp: String?
    public let lastMessageAt: Date?
    public let latestMessages: [ChatMessage]?
    
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
        if shouldShowTypingIndicator {
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

    /// This style shows the muted icon at the bottom right corner of the channel item.
    /// The subtitle text shows the last message preview text.
    public static let bottomRightCorner: ChannelItemMutedLayoutStyle = .init("bottomRightCorner")

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
