//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the thread list item.
public struct ChatThreadListItem: View {
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient

    var thread: ChatThread

    public init(
        thread: ChatThread
    ) {
        self.thread = thread
    }

    public var body: some View {
        ChatThreadListItemContentView(
            channelNameText: channelNameText,
            parentMessageText: parentMessageText,
            unreadRepliesCount: unreadRepliesCount,
            replyAuthorName: latestReplyAuthor?.name ?? "",
            replyAuthorUrl: latestReplyAuthor?.imageURL,
            replyAuthorIsOnline: latestReplyAuthor?.isOnline ?? false,
            replyMessageText: replyMessageText,
            replyTimestampText: replyTimestampText
        )
    }

    var parentMessageText: String {
        var parentMessageText: String
        if thread.parentMessage.isDeleted {
            parentMessageText = L10n.Message.deletedMessagePlaceholder
        } else if let threadTitle = thread.title {
            parentMessageText = threadTitle
        } else {
            let formatter = MessagePreviewFormatter()
            parentMessageText =  formatter.formatContent(for: thread.parentMessage)
        }
        return L10n.Thread.Item.repliedTo(parentMessageText.trimmed)
    }

    var replyMessageText: String {
        guard let latestReply = thread.latestReplies.last else {
            return ""
        }

        if latestReply.isDeleted {
            return L10n.Message.deletedMessagePlaceholder
        }

        let formatter = MessagePreviewFormatter()
        return formatter.format(latestReply)
    }

    var replyTimestampText: String {
        utils.dateFormatter.string(
            from: thread.latestReplies.last?.createdAt ?? .distantPast
        )
    }

    var unreadRepliesCount: Int {
        let currentUserRead = thread.reads.first(
            where: { $0.user.id == chatClient.currentUserId }
        )
        return currentUserRead?.unreadMessagesCount ?? 0
    }

    var latestReplyAuthor: ChatUser? {
        thread.latestReplies.last?.author
    }

    var channelNameText: String {
        utils.channelNamer(thread.channel, chatClient.currentUserId) ?? ""
    }
}

struct ChatThreadListItemContentView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils
    @Injected(\.images) private var images
    @Injected(\.chatClient) private var chatClient

    var channelNameText: String
    var parentMessageText: String
    var unreadRepliesCount: Int
    var replyAuthorName: String
    var replyAuthorUrl: URL?
    var replyAuthorIsOnline: Bool
    var replyMessageText: String
    var replyTimestampText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            threadContainerView
            replyContainerView
        }
        .padding(.all, 8)
    }

    var threadContainerView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Image(uiImage: images.threadIcon)
                    .customizable()
                    .frame(width: 15, height: 15)
                    .foregroundColor(Color(colors.subtitleText))
                Text(channelNameText)
                    .lineLimit(1)
                    .foregroundColor(Color(colors.text))
                    .font(fonts.subheadlineBold)
            }
            HStack(alignment: .bottom) {
                SubtitleText(text: parentMessageText)
                Spacer()
                if unreadRepliesCount != 0 {
                    UnreadIndicatorView(
                        unreadCount: unreadRepliesCount
                    )
                }
            }
        }
    }

    var replyContainerView: some View {
        HStack(spacing: 8) {
            MessageAvatarView(
                avatarURL: replyAuthorUrl,
                size: .init(width: 40, height: 40),
                showOnlineIndicator: replyAuthorIsOnline
            )
            VStack(alignment: .leading) {
                Text(replyAuthorName)
                    .lineLimit(1)
                    .foregroundColor(Color(colors.text))
                    .font(fonts.subheadlineBold)
                HStack {
                    SubtitleText(text: replyMessageText)
                    Spacer()
                    SubtitleText(text: replyTimestampText)
                }
            }
        }
    }
}
