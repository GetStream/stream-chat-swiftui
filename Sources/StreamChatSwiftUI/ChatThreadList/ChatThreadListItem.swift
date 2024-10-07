//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the thread list item.
public struct ChatThreadListItem: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils
    @Injected(\.images) private var images
    @Injected(\.chatClient) private var chatClient

    var thread: ChatThread

    public init(
        thread: ChatThread
    ) {
        self.thread = thread
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            threadContainerView
            replyContainerView
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    var threadContainerView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Image(uiImage: images.threadIcon)
                    .customizable()
                    .frame(width: 15, height: 15)
                    .foregroundColor(Color(colors.subtitleText))
                Text(channelName)
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
                avatarURL: latestReplyAuthor?.imageURL,
                size: .init(width: 40, height: 40),
                showOnlineIndicator: latestReplyAuthor?.isOnline ?? false
            )
            VStack(alignment: .leading) {
                Text(latestReplyAuthor?.name ?? "")
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

    var parentMessageText: String {
        var parentMessageText: String
        if thread.parentMessage.isDeleted {
            parentMessageText = L10n.Message.deletedMessagePlaceholder
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

    var channelName: String {
        utils.channelNamer(thread.channel, chatClient.currentUserId) ?? ""
    }
}
