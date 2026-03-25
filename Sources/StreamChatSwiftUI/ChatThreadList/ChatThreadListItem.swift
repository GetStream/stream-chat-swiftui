//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the thread list item.
public struct ChatThreadListItem<Factory: ViewFactory>: View {
    var factory: Factory
    var viewModel: ChatThreadListItemViewModel

    public init(
        factory: Factory = DefaultViewFactory.shared,
        viewModel: ChatThreadListItemViewModel
    ) {
        self.factory = factory
        self.viewModel = viewModel
    }

    public var body: some View {
        ChatThreadListItemContentView(
            factory: factory,
            channelNameText: viewModel.channelNameText,
            parentMessageAuthorName: viewModel.parentMessageAuthorName,
            parentMessageContentText: viewModel.parentMessageContentText,
            unreadRepliesCount: viewModel.unreadRepliesCount,
            parentAuthor: viewModel.parentMessageAuthor,
            replyCountText: viewModel.replyCountText,
            replyTimestampText: viewModel.latestReplyTimestampText,
            participantUsers: viewModel.participantUsers,
            draftText: viewModel.draftReplyText
        )
    }
}

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

/// The layout of the thread list item view.
struct ChatThreadListItemContentView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    var factory: Factory
    var channelNameText: String
    var parentMessageAuthorName: String?
    var parentMessageContentText: String
    var unreadRepliesCount: Int
    let parentAuthor: ChatUser?
    var replyCountText: String
    var replyTimestampText: String
    var participantUsers: [ChatUser]
    var draftText: String?

    init(
        factory: Factory = DefaultViewFactory.shared,
        channelNameText: String,
        parentMessageAuthorName: String?,
        parentMessageContentText: String,
        unreadRepliesCount: Int,
        parentAuthor: ChatUser?,
        replyCountText: String,
        replyTimestampText: String,
        participantUsers: [ChatUser],
        draftText: String? = nil
    ) {
        self.factory = factory
        self.channelNameText = channelNameText
        self.parentMessageAuthorName = parentMessageAuthorName
        self.parentMessageContentText = parentMessageContentText
        self.unreadRepliesCount = unreadRepliesCount
        self.parentAuthor = parentAuthor
        self.replyCountText = replyCountText
        self.replyTimestampText = replyTimestampText
        self.participantUsers = participantUsers
        self.draftText = draftText
    }

    var body: some View {
        HStack(alignment: .top, spacing: tokens.spacingMd) {
            parentAuthorAvatarView
            VStack(alignment: .leading, spacing: tokens.spacingXxs) {
                titleRow
                messageTextRow
                repliesRow
            }
        }
        .padding(.all, tokens.spacingMd)
    }

    var parentAuthorAvatarView: some View {
        Group {
            if let parentAuthor {
                factory.makeUserAvatarView(
                    options: .init(
                        user: parentAuthor,
                        size: AvatarSize.extraLarge,
                        showsIndicator: parentAuthor.isOnline
                    )
                )
            } else {
                UserAvatar(url: nil, initials: "", size: AvatarSize.extraLarge, indicator: .none)
            }
        }
    }

    var titleRow: some View {
        HStack {
            Text(channelNameText)
                .font(fonts.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)
                .foregroundColor(Color(colors.textTertiary))
                .accessibilityIdentifier("ThreadMessageTitle")

            Spacer()
            if unreadRepliesCount > 0 {
                BadgeNotificationView(count: unreadRepliesCount)
            }
        }
    }

    @ViewBuilder
    var messageTextRow: some View {
        if let draftText {
            HStack(spacing: tokens.spacingXxxs) {
                draftPrefixView
                messageTitle(text: draftText)
            }
        } else if let authorName = parentMessageAuthorName {
            HStack(spacing: tokens.spacingXxs) {
                Text("\(authorName):")
                    .font(fonts.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(colors.textSecondary))
                messageTitle(text: parentMessageContentText)
            }
            .lineLimit(1)
        } else {
            messageTitle(text: parentMessageContentText)
        }
    }

    var repliesRow: some View {
        HStack(spacing: tokens.spacingXs) {
            participantAvatarsView
            Text(replyCountText)
                .font(fonts.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color(colors.textLink))
            SubtitleText(text: replyTimestampText, color: Color(colors.textTertiary))
        }
        .offset(y: tokens.spacingXxxs)
    }

    var participantAvatarsView: some View {
        let avatarSize = AvatarSize.small
        let overlap: CGFloat = avatarSize / 3
        let borderWidth: CGFloat = 2

        return HStack(spacing: -(overlap + borderWidth * 2)) {
            ForEach(Array(participantUsers.prefix(3).enumerated()), id: \.offset) { index, user in
                factory.makeUserAvatarView(
                    options: UserAvatarViewOptions(
                        user: user,
                        size: avatarSize,
                        showsIndicator: false,
                        showsBorder: false
                    )
                )
                .padding(borderWidth)
                .background(Circle().fill(colors.borderCoreOnDark.toColor))
                .zIndex(Double(index))
            }
        }
    }

    var draftPrefixView: some View {
        Text("\(L10n.Message.Preview.draft):")
            .font(fonts.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(Color(colors.accentPrimary))
    }
    
    func messageTitle(text: String) -> some View {
        Text(text)
            .lineLimit(1)
            .font(fonts.body)
            .foregroundColor(colors.textPrimary.toColor)
    }
}
