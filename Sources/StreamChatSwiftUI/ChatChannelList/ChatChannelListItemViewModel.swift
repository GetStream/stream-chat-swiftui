//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// The view model for the channel list item view.
///
/// It contains the default presentation logic for the channel list item data.
@MainActor public final class ChatChannelListItemViewModel {
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient

    /// The channel represented by this item.
    public let channel: ChatChannel

    /// The display name of the channel.
    public let channelName: String

    public init(channel: ChatChannel, channelName: String) {
        self.channel = channel
        self.channelName = channelName
    }

    // MARK: - Title row

    /// The formatted timestamp of the last message in the channel.
    public var timestampText: String {
        if let lastMessageAt = channel.lastMessageAt {
            return utils.messageTimestampFormatter.format(lastMessageAt)
        }
        return ""
    }

    /// The number of unread messages in the channel.
    public var unreadCount: Int {
        channel.unreadCount.messages
    }

    /// A boolean value indicating whether the channel has any unread content.
    public var hasUnread: Bool {
        channel.unreadCount != .noUnread
    }

    /// A boolean value indicating whether the channel is muted.
    public var isMuted: Bool {
        channel.isMuted
    }

    /// The configured layout style for the muted icon.
    public var mutedLayoutStyle: ChannelItemMutedLayoutStyle {
        utils.channelListConfig.channelItemMutedStyle
    }

    /// A boolean value indicating whether the muted icon should be rendered
    /// inline next to the channel name.
    public var shouldShowInlineMutedIcon: Bool {
        isMuted && mutedLayoutStyle == .afterChannelName
    }

    /// A boolean value indicating whether the muted icon should be rendered
    /// in the trailing bottom corner of the item.
    public var shouldShowMutedTrailingIcon: Bool {
        isMuted && mutedLayoutStyle == .bottomRightCorner
    }

    // MARK: - Read indicator

    /// A boolean value indicating whether the read events indicator should be shown.
    public var shouldShowReadEvents: Bool {
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

    /// The users that have read the preview message.
    public var readUsers: [ChatUser] {
        channel.readUsers(
            currentUserId: chatClient.currentUserId,
            message: previewMessage
        )
    }

    /// A boolean value indicating whether the read indicator should
    /// show the delivered state.
    public var showDelivered: Bool {
        previewMessage?.deliveryStatus(for: channel) == .delivered
    }

    /// The local message state of the preview message.
    public var previewMessageLocalState: LocalMessageState? {
        previewMessage?.localState
    }

    // MARK: - Subtitle row

    /// A boolean value indicating whether the last message failed to send.
    public var lastMessageFailedToSend: Bool {
        previewMessage?.localState == .sendingFailed
    }

    /// A boolean value indicating whether a typing indicator should be shown
    /// in the subtitle area.
    public var shouldShowTypingIndicator: Bool {
        !channel.currentlyTypingUsersFiltered(
            currentUserId: chatClient.currentUserId
        ).isEmpty && channel.config.typingEventsEnabled
    }

    /// The formatted typing indicator text for the channel.
    ///
    /// Derived from the channel's currently-typing users; can be passed to
    /// ``SubtitleTypingIndicatorView`` to avoid recomputing it inside the view.
    public var typingIndicatorText: String {
        channel.typingIndicatorString(currentUserId: chatClient.currentUserId)
    }

    /// A boolean value indicating whether the draft messages feature is enabled.
    public var isDraftMessagesEnabled: Bool {
        utils.messageListConfig.draftMessagesEnabled
    }

    /// The formatted draft message text, when there is a draft for this channel.
    public var draftMessageText: String? {
        guard let draftMessage = channel.draftMessage else { return nil }
        return utils.messagePreviewFormatter.formatContent(for: ChatMessage(draftMessage), in: channel)
    }

    /// A boolean value indicating whether the preview message is deleted.
    public var isPreviewMessageDeleted: Bool {
        previewMessage?.isDeleted == true
    }

    /// A boolean value indicating whether the preview message was sent by the
    /// current user.
    public var isPreviewMessageSentByCurrentUser: Bool {
        previewMessage?.isSentByCurrentUser == true
    }

    /// The author name to display before the subtitle content, when applicable.
    ///
    /// Returns `nil` for direct message channels with two members, polls, or
    /// when there is no preview message.
    public var subtitleAuthorName: String? {
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

    /// The formatted subtitle text for the channel item.
    ///
    /// Used as the fallback when no other subtitle variant applies, and as the
    /// typing indicator string when typing is active.
    public var subtitleText: String {
        if shouldShowTypingIndicator {
            return channel.typingIndicatorString(currentUserId: chatClient.currentUserId)
        }
        if let previewMessage {
            return utils.messagePreviewFormatter.format(previewMessage, in: channel)
        }
        return L10n.Channel.Item.emptyMessages
    }

    /// The preview message content text without any author name prefix.
    public var previewContentText: String {
        guard let previewMessage else { return "" }
        return utils.messagePreviewFormatter.formatContent(for: previewMessage, in: channel)
    }

    /// The icon image for the preview message attachment, when present.
    public var previewAttachmentIconImage: UIImage? {
        guard let message = previewMessage else { return nil }
        let resolver = MessageAttachmentPreviewResolver(message: message)
        guard let previewIcon = resolver.previewIcon else { return nil }
        return utils.messageAttachmentPreviewIconProvider.image(for: previewIcon)
    }

    /// The subtitle variant to render for the channel list item.
    ///
    /// Combines the granular subtitle flags above into a single value that
    /// can be passed to ``ChatChannelListItemSubtitleView``. The order of
    /// precedence is: failed-to-send, typing, draft, deleted, author preview,
    /// attachment preview, then plain text fallback.
    public var subtitle: ChatChannelListItemSubtitle {
        if lastMessageFailedToSend {
            return .failedToSend()
        }
        if shouldShowTypingIndicator {
            return .typing(text: typingIndicatorText)
        }
        if isDraftMessagesEnabled, let draftText = draftMessageText {
            return .draft(text: draftText)
        }
        if isPreviewMessageDeleted {
            return .deleted(isSentByCurrentUser: isPreviewMessageSentByCurrentUser)
        }
        if let authorName = subtitleAuthorName {
            return .authorPreview(
                authorName: authorName,
                contentText: previewContentText,
                attachmentIcon: previewAttachmentIconImage
            )
        }
        if let attachmentIcon = previewAttachmentIconImage {
            return .attachmentPreview(text: subtitleText, attachmentIcon: attachmentIcon)
        }
        return .plain(text: subtitleText)
    }

    // MARK: - Private

    private var previewMessage: ChatMessage? {
        channel.latestMessages.first(where: { $0.type != .ephemeral })
    }
}
