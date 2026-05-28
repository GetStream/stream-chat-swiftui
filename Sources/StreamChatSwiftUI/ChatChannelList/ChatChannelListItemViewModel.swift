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

    private let providedChannelName: String

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

    /// A boolean value indicating whether the channel is muted.
    open var isMuted: Bool {
        channel.isMuted
    }

    /// The configured layout style for the muted icon.
    open var mutedLayoutStyle: ChannelItemMutedLayoutStyle {
        utils.channelListConfig.channelItemMutedStyle
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
    open var showDelivered: Bool {
        previewMessage?.deliveryStatus(for: channel) == .delivered
    }

    /// The local message state of the preview message.
    open var previewMessageLocalState: LocalMessageState? {
        previewMessage?.localState
    }

    // MARK: - Message preview

    /// A boolean value indicating whether the last message failed to send.
    open var lastMessageFailedToSend: Bool {
        previewMessage?.localState == .sendingFailed
    }

    /// A boolean value indicating whether a typing indicator should be shown
    /// in the message preview area.
    open var shouldShowTypingIndicator: Bool {
        !channel.currentlyTypingUsersFiltered(
            currentUserId: chatClient.currentUserId
        ).isEmpty && channel.config.typingEventsEnabled
    }

    /// The formatted typing indicator text for the channel.
    ///
    /// Derived from the channel's currently-typing users; can be passed to
    /// ``SubtitleTypingIndicatorView`` to avoid recomputing it inside the view.
    open var typingIndicatorText: String {
        channel.typingIndicatorString(currentUserId: chatClient.currentUserId)
    }

    /// A boolean value indicating whether the draft messages feature is enabled.
    open var isDraftMessagesEnabled: Bool {
        utils.messageListConfig.draftMessagesEnabled
    }

    /// The formatted draft message text, when there is a draft for this channel.
    open var draftMessageText: String? {
        guard let draftMessage = channel.draftMessage else { return nil }
        return utils.messagePreviewFormatter.formatContent(for: ChatMessage(draftMessage), in: channel)
    }

    /// A boolean value indicating whether the preview message is deleted.
    open var isPreviewMessageDeleted: Bool {
        previewMessage?.isDeleted == true
    }

    /// A boolean value indicating whether the preview message was sent by the
    /// current user.
    open var isPreviewMessageSentByCurrentUser: Bool {
        previewMessage?.isSentByCurrentUser == true
    }

    /// The author name to display before the message preview content, when applicable.
    ///
    /// Returns `nil` for direct message channels with two members, polls, or
    /// when there is no preview message.
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

    /// The formatted message preview text for the channel item.
    ///
    /// Used as the fallback when no other message preview variant applies, and
    /// as the typing indicator string when typing is active.
    open var messagePreviewText: String {
        if shouldShowTypingIndicator {
            return channel.typingIndicatorString(currentUserId: chatClient.currentUserId)
        }
        if let previewMessage {
            return utils.messagePreviewFormatter.format(previewMessage, in: channel)
        }
        return L10n.Channel.Item.emptyMessages
    }

    /// The preview message content text without any author name prefix.
    open var previewContentText: String {
        guard let previewMessage else { return "" }
        return utils.messagePreviewFormatter.formatContent(for: previewMessage, in: channel)
    }

    /// The icon image for the preview message attachment, when present.
    open var previewAttachmentIconImage: UIImage? {
        guard let message = previewMessage else { return nil }
        let resolver = MessageAttachmentPreviewResolver(message: message)
        guard let previewIcon = resolver.previewIcon else { return nil }
        return utils.messageAttachmentPreviewIconProvider.image(for: previewIcon)
    }

    /// The message preview variant to render for the channel list item.
    ///
    /// Combines the granular message preview flags above into a single value
    /// that can be passed to ``ChatChannelListItemMessagePreviewView``. The
    /// order of precedence is: failed-to-send, typing, draft, deleted, author
    /// preview, attachment preview, then plain text fallback.
    open var messagePreview: ChatChannelListItemMessagePreview {
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
        if let authorName = messagePreviewAuthorName {
            return .authorPreview(
                authorName: authorName,
                contentText: previewContentText,
                attachmentIcon: previewAttachmentIconImage
            )
        }
        if let attachmentIcon = previewAttachmentIconImage {
            return .attachmentPreview(text: messagePreviewText, attachmentIcon: attachmentIcon)
        }
        return .plain(text: messagePreviewText)
    }

    // MARK: - Private

    private var previewMessage: ChatMessage? {
        channel.latestMessages.first(where: { $0.type != .ephemeral })
    }
}
