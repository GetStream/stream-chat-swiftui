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
    open var showDelivered: Bool {
        previewMessage?.deliveryStatus(for: channel) == .delivered
    }

    /// The local message state of the preview message.
    open var previewMessageLocalState: LocalMessageState? {
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
            return .typing(text: typingIndicatorText)
        }
        if isDraftMessagesEnabled, let draftText = draftMessageText {
            return .draft(text: draftText)
        }
        if isPreviewMessageDeleted {
            return .deleted(isSentByCurrentUser: isPreviewMessageSentByCurrentUser)
        }
        let authorName = messagePreviewAuthorName
        return .message(
            .init(
                text: authorName == nil ? messagePreviewText : previewContentText,
                authorName: authorName,
                attachmentIcon: previewAttachmentIconImage
            )
        )
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

    private var typingIndicatorText: String {
        channel.typingIndicatorString(currentUserId: chatClient.currentUserId)
    }

    private var isDraftMessagesEnabled: Bool {
        utils.messageListConfig.draftMessagesEnabled
    }

    private var draftMessageText: String? {
        guard let draftMessage = channel.draftMessage else { return nil }
        return utils.messagePreviewFormatter.formatContent(for: ChatMessage(draftMessage), in: channel)
    }

    private var isPreviewMessageDeleted: Bool {
        previewMessage?.isDeleted == true
    }

    private var isPreviewMessageSentByCurrentUser: Bool {
        previewMessage?.isSentByCurrentUser == true
    }

    private var messagePreviewAuthorName: String? {
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

    private var messagePreviewText: String {
        if shouldShowTypingIndicator {
            return typingIndicatorText
        }
        if let previewMessage {
            return utils.messagePreviewFormatter.format(previewMessage, in: channel)
        }
        return L10n.Channel.Item.emptyMessages
    }

    private var previewContentText: String {
        guard let previewMessage else { return "" }
        return utils.messagePreviewFormatter.formatContent(for: previewMessage, in: channel)
    }

    private var previewAttachmentIconImage: UIImage? {
        guard let message = previewMessage else { return nil }
        let resolver = MessageAttachmentPreviewResolver(message: message)
        guard let previewIcon = resolver.previewIcon else { return nil }
        return utils.messageAttachmentPreviewIconProvider.image(for: previewIcon)
    }
}
