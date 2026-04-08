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
    var isSelected: Bool
    var disabled = false
    var onItemTap: (ChatChannel) -> Void

    public init(
        factory: Factory = DefaultViewFactory.shared,
        channel: ChatChannel,
        channelName: String,
        isSelected: Bool = false,
        disabled: Bool = false,
        onItemTap: @escaping (ChatChannel) -> Void
    ) {
        self.factory = factory
        self.channel = channel
        self.channelName = channelName
        self.isSelected = isSelected
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
                        
                        SubtitleText(
                            text: timestampText,
                            color: Color(colors.textTertiary)
                        )
                        .accessibilityIdentifier("timestampView")
                        
                        if !isSelected && channel.unreadCount != .noUnread {
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
                                    message: previewMessage
                                ),
                                showDelivered: previewMessage?.deliveryStatus(for: channel) == .delivered,
                                localState: previewMessage?.localState
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

    private var previewMessage: ChatMessage? {
        channel.latestMessages.first(where: { $0.type != .ephemeral })
    }

    private var shouldShowTypingIndicator: Bool {
        !channel.currentlyTypingUsersFiltered(
            currentUserId: chatClient.currentUserId
        ).isEmpty && channel.config.typingEventsEnabled
    }

    private var draftMessageText: String? {
        guard let draftMessage = channel.draftMessage else { return nil }
        return utils.messagePreviewFormatter.formatContent(for: ChatMessage(draftMessage), in: channel)
    }

    private var timestampText: String {
        if let lastMessageAt = channel.lastMessageAt {
            return utils.messageTimestampFormatter.format(lastMessageAt)
        }
        return ""
    }

    private var subtitleView: some View {
        HStack(spacing: 4) {
            if lastMessageFailedToSend {
                HStack(spacing: tokens.spacingXxs) {
                    Image(uiImage: images.messageListErrorIndicator)
                        .customizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(Color(colors.badgeBackgroundError))
                        .accessibilityHidden(true)
                    Text(L10n.Channel.Item.messageFailedToSend)
                }
                .font(fonts.subheadline)
                .foregroundColor(Color(colors.accentError))
                .lineLimit(1)
            } else if shouldShowTypingIndicator {
                factory.makeSubtitleTypingIndicatorView(
                    options: SubtitleTypingIndicatorViewOptions(channel: channel)
                )
            } else if utils.messageListConfig.draftMessagesEnabled, let draftText = draftMessageText {
                HStack(spacing: 2) {
                    Text("\(L10n.Message.Preview.draft): ")
                        .font(fonts.subheadline).fontWeight(.semibold)
                        .foregroundColor(Color(colors.accentPrimary))
                    SubtitleText(text: draftText)
                }
            } else if previewMessage?.isDeleted == true {
                HStack(spacing: tokens.spacingXxs) {
                    if previewMessage?.isSentByCurrentUser == true {
                        Text("\(L10n.Channel.Item.you):")
                            .font(fonts.subheadline)
                            .fontWeight(.semibold)
                    }
                    Image(systemName: "nosign")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .accessibilityHidden(true)
                    Text(L10n.Message.deletedMessagePlaceholder)
                }
                .lineLimit(1)
                .font(fonts.subheadline)
                .foregroundColor(Color(colors.textTertiary))
            } else if let authorName = subtitleAuthorName {
                let contentString = previewMessage.map {
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
        guard let message = previewMessage else { return nil }
        let resolver = MessageAttachmentPreviewResolver(message: message)
        guard let previewIcon = resolver.previewIcon else { return nil }
        return utils.messageAttachmentPreviewIconProvider.image(for: previewIcon)
    }

    @ViewBuilder
    private var attachmentIconView: some View {
        if let iconImage = previewAttachmentIconImage {
            Image(uiImage: iconImage)
                .customizable()
                .frame(height: 14)
                .accessibilityHidden(true)
        }
    }

    private var subtitleAuthorName: String? {
        guard let previewMessage,
              previewMessage.poll == nil,
              !(channel.isDirectMessageChannel && channel.memberCount == 2) else {
            return nil
        }
        if previewMessage.isSentByCurrentUser {
            return L10n.Channel.Item.you
        }
        return previewMessage.author.name ?? previewMessage.author.id
    }

    private var subtitleText: String {
        if shouldShowTypingIndicator {
            return channel.typingIndicatorString(currentUserId: chatClient.currentUserId)
        }
        if let previewMessage {
            return utils.messagePreviewFormatter.format(previewMessage, in: channel)
        }
        return L10n.Channel.Item.emptyMessages
    }

    private var mutedIcon: some View {
        Image(uiImage: images.muted)
            .customizable()
            .frame(height: tokens.iconSizeMd)
            .foregroundColor(Color(colors.textTertiary))
    }

    private var lastMessageFailedToSend: Bool {
        previewMessage?.localState == .sendingFailed
    }

    private var shouldShowReadEvents: Bool {
        if shouldShowTypingIndicator || lastMessageFailedToSend {
            return false
        }
        if utils.messageListConfig.draftMessagesEnabled && draftMessageText != nil {
            return false
        }
        if let message = previewMessage,
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
