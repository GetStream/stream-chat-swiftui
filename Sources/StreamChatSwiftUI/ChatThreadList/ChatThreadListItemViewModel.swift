//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// The view model for the thread list item view.
///
/// It contains the default presentation logic for the thread list item data.
@MainActor public final class ChatThreadListItemViewModel {
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient

    private let thread: ChatThread

    public init(thread: ChatThread) {
        self.thread = thread
    }

    /// The formatted thread parent message text.
    public var parentMessageText: String {
        var parentMessageText: String
        if thread.parentMessage.isDeleted {
            parentMessageText = L10n.Message.deletedMessagePlaceholder
        } else if let threadTitle = thread.title {
            parentMessageText = threadTitle
        } else {
            let formatter = utils.messagePreviewFormatter
            parentMessageText = formatter.formatContent(for: thread.parentMessage, in: thread.channel)
        }
        return L10n.Thread.Item.repliedTo(parentMessageText.trimmed)
    }

    /// The parent message formatted for display, including author prefix for group channels.
    public var parentMessagePreviewText: String {
        if thread.parentMessage.isDeleted {
            return L10n.Message.deletedMessagePlaceholder
        }
        if let threadTitle = thread.title {
            return threadTitle
        }
        let formatter = utils.messagePreviewFormatter
        return formatter.format(thread.parentMessage, in: thread.channel)
    }

    /// The content text of the parent message without the author name prefix.
    public var parentMessageContentText: String {
        if thread.parentMessage.isDeleted {
            return L10n.Message.deletedMessagePlaceholder
        }
        if let threadTitle = thread.title {
            return threadTitle
        }
        let formatter = utils.messagePreviewFormatter
        return formatter.formatContent(for: thread.parentMessage, in: thread.channel)
    }

    /// For group channels, the author name to display before the message content.
    /// Returns `nil` for direct message channels so no prefix is shown.
    public var parentMessageAuthorName: String? {
        guard !(thread.channel.isDirectMessageChannel && thread.channel.memberCount == 2) else {
            return nil
        }
        if thread.parentMessage.isSentByCurrentUser {
            return L10n.Channel.Item.you
        }
        return thread.parentMessage.author.name ?? thread.parentMessage.author.id
    }

    /// The formatted latest reply text.
    public var latestReplyMessageText: String {
        guard let latestReply = thread.latestReplies.last else {
            return ""
        }

        if latestReply.isDeleted {
            return L10n.Message.deletedMessagePlaceholder
        }

        let formatter = utils.messagePreviewFormatter
        return formatter.format(latestReply, in: thread.channel)
    }

    /// The formatted latest reply timestamp.
    public var latestReplyTimestampText: String {
        utils.messageTimestampFormatter.format(
            thread.latestReplies.last?.createdAt ?? .distantPast
        )
    }

    /// The formatted draft reply text.
    public var draftReplyText: String? {
        guard utils.messageListConfig.draftMessagesEnabled else { return nil }
        guard let draftMessage = thread.parentMessage.draftReply else { return nil }
        let messageFormatter = utils.messagePreviewFormatter
        return messageFormatter.formatContent(for: ChatMessage(draftMessage), in: thread.channel)
    }

    /// The number of unread replies.
    public var unreadRepliesCount: Int {
        let currentUserRead = thread.reads.first(
            where: { $0.user.id == chatClient.currentUserId }
        )
        return currentUserRead?.unreadMessagesCount ?? 0
    }

    /// The formatted latest reply author name text.
    public var latestReplyAuthorNameText: String {
        latestReplyAuthor?.name ?? ""
    }

    /// A boolean value indicating if the latest reply author is online.
    public var isLatestReplyAuthorOnline: Bool {
        latestReplyAuthor?.isOnline ?? false
    }

    /// The latest reply author's image url.
    public var latestReplyAuthorImageURL: URL? {
        latestReplyAuthor?.imageURL
    }

    /// The latest reply author's user ID.
    public var latestReplyAuthorId: String {
        latestReplyAuthor?.id ?? ""
    }

    /// The formatted channel name text.
    public var channelNameText: String {
        utils.channelNameFormatter.format(
            channel: thread.channel,
            forCurrentUserId: chatClient.currentUserId
        ) ?? ""
    }

    /// The author of the parent message.
    public var parentMessageAuthor: ChatUser {
        thread.parentMessage.author
    }

    /// The formatted reply count text (e.g. "1 reply" or "4 replies").
    public var replyCountText: String {
        let count = thread.replyCount
        let suffix = count == 1 ? L10n.Thread.Item.reply : L10n.Thread.Item.replies
        return "\(count) \(suffix)"
    }

    /// The first three thread participant users for the avatar row.
    public var participantUsers: [ChatUser] {
        Array(thread.threadParticipants.prefix(3).map(\.user))
    }

    var latestReplyAuthor: ChatUser? {
        thread.latestReplies.last?.author
    }
}
