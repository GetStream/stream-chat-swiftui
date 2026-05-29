//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// The view model for the channel list item view.
///
/// It contains the default presentation logic for the channel list item data.
/// Subclass and override the `open` properties to customize what the channel
/// list item displays.
@MainActor open class ChatChannelListItemViewModel {
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient

    /// The channel represented by this item.
    public let channel: ChatChannel

    /// The display name of the channel.
    ///
    /// The default implementation returns the channel name passed to the
    /// initializer. Subclasses can override this to provide a custom display
    /// name (for example, derived from custom channel data) and may call
    /// `super.channelName` to fall back to the initializer value.
    open var channelName: String { providedChannelName }

    public init(channel: ChatChannel, channelName: String) {
        self.channel = channel
        providedChannelName = channelName
    }

    // MARK: - Title row

    /// The formatted timestamp of the last message in the channel.
    open var timestampText: String {
        if let lastMessageAt = channel.lastMessageAt {
            return utils.messageTimestampFormatter.format(lastMessageAt)
        }
        return ""
    }

    /// The number of unread messages in the channel.
    open var unreadCount: Int {
        channel.unreadCount.messages
    }

    /// A boolean value indicating whether the channel has any unread content.
    open var hasUnread: Bool {
        channel.unreadCount != .noUnread
    }

    /// A boolean value indicating whether the muted icon should be rendered
    /// inline next to the channel name.
    open var shouldShowInlineMutedIcon: Bool {
        isMuted && mutedLayoutStyle == .afterChannelName
    }

    /// A boolean value indicating whether the muted icon should be rendered
    /// in the trailing bottom corner of the item.
    open var shouldShowMutedTrailingIcon: Bool {
        isMuted && mutedLayoutStyle == .bottomRightCorner
    }

    // MARK: - Read indicator

    /// A boolean value indicating whether the read events indicator should be shown.
    open var shouldShowReadEvents: Bool {
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
    open var readUsers: [ChatUser] {
        channel.readUsers(
            currentUserId: chatClient.currentUserId,
            message: previewMessage
        )
    }

    /// A boolean value indicating whether the read indicator should
    /// show the delivered state.
    open var shouldShowDelivered: Bool {
        previewMessage?.deliveryStatus(for: channel) == .delivered
    }

    /// The local message state of the preview message.
    public var previewMessageLocalState: LocalMessageState? {
        previewMessage?.localState
    }

    // MARK: - Preview

    /// The preview variant to render for the channel list item.
    ///
    /// Pass it to ``ChannelItemPreviewView``. The default
    /// implementation picks the first applicable variant in this order of
    /// precedence: failed-to-send, typing, draft, deleted, then a regular
    /// message.
    open var preview: ChannelItemPreview {
        if lastMessageFailedToSend {
            return .failedToSend()
        }
        if shouldShowTypingIndicator {
            return .typing(channel: channel)
        }
        if isDraftMessagesEnabled, let draftText = draftMessageText {
            return .draft(text: draftText)
        }
        if isPreviewMessageDeleted {
            return .deleted(isSentByCurrentUser: isPreviewMessageSentByCurrentUser)
        }
        return .message(
            .init(
                text: messagePreviewText,
                authorName: messagePreviewAuthorName,
                attachmentIcon: previewAttachmentIconImage
            )
        )
    }

    /// The text shown in the regular message preview variant.
    ///
    /// When ``messagePreviewAuthorName`` is non-`nil` the view already
    /// renders that author label as a prefix, so this returns just the
    /// formatted content of the preview message to avoid duplicating the
    /// author name. When ``messagePreviewAuthorName`` is `nil` (direct
    /// message channels with two members, poll previews, empty channels)
    /// the formatter is allowed to include its own author prefix where it
    /// makes sense, or falls back to the empty channel placeholder.
    open var messagePreviewText: String {
        guard let previewMessage else { return L10n.Channel.Item.emptyMessages }
        if messagePreviewAuthorName != nil {
            return utils.messagePreviewFormatter.formatContent(for: previewMessage, in: channel)
        }
        return utils.messagePreviewFormatter.format(previewMessage, in: channel)
    }

    /// The formatted text of the pending draft message in the channel, or
    /// `nil` when no draft exists. Used by ``preview`` to render the `.draft`
    /// variant.
    open var draftMessageText: String? {
        guard let draftMessage = channel.draftMessage else { return nil }
        return utils.messagePreviewFormatter.formatContent(for: ChatMessage(draftMessage), in: channel)
    }

    /// The author prefix shown before the message preview text. Returns
    /// `"You"` when the current user sent the latest message, the author's
    /// display name in group channels, and `nil` for direct message channels
    /// with two members and for poll previews.
    open var messagePreviewAuthorName: String? {
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

    /// The leading attachment glyph for the latest message's first
    /// attachment, or `nil` when the message has no attachments to preview.
    open var previewAttachmentIconImage: UIImage? {
        guard let message = previewMessage else { return nil }
        let resolver = MessageAttachmentPreviewResolver(message: message)
        guard let previewIcon = resolver.previewIcon else { return nil }
        return utils.messageAttachmentPreviewIconProvider.image(for: previewIcon)
    }

    // MARK: - Private

    private let providedChannelName: String

    private var isMuted: Bool {
        channel.isMuted
    }

    private var mutedLayoutStyle: ChannelItemMutedLayoutStyle {
        utils.channelListConfig.channelItemMutedStyle
    }

    private var previewMessage: ChatMessage? {
        channel.latestMessages.first(where: { $0.type != .ephemeral })
    }

    private var lastMessageFailedToSend: Bool {
        previewMessage?.localState == .sendingFailed
    }

    private var shouldShowTypingIndicator: Bool {
        !channel.currentlyTypingUsersFiltered(
            currentUserId: chatClient.currentUserId
        ).isEmpty && channel.config.typingEventsEnabled
    }

    private var isDraftMessagesEnabled: Bool {
        utils.messageListConfig.draftMessagesEnabled
    }

    private var isPreviewMessageDeleted: Bool {
        previewMessage?.isDeleted == true
    }

    private var isPreviewMessageSentByCurrentUser: Bool {
        previewMessage?.isSentByCurrentUser == true
    }
}
