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
            parentMessageText: viewModel.parentMessageText,
            unreadRepliesCount: viewModel.unreadRepliesCount,
            replyAuthorId: viewModel.latestReplyAuthorId,
            replyAuthorName: viewModel.latestReplyAuthorNameText,
            replyAuthorUrl: viewModel.latestReplyAuthorImageURL,
            replyAuthorIsOnline: viewModel.isLatestReplyAuthorOnline,
            replyMessageText: viewModel.latestReplyMessageText,
            replyTimestampText: viewModel.latestReplyTimestampText,
            draftText: viewModel.draftReplyText
        )
    }
}

/// The view model for the thread list item view.
///
/// It contains the default presentation logic for the thread list item data.
public struct ChatThreadListItemViewModel {
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
            let formatter = InjectedValues[\.utils].messagePreviewFormatter
            parentMessageText = formatter.formatContent(for: thread.parentMessage, in: thread.channel)
        }
        return L10n.Thread.Item.repliedTo(parentMessageText.trimmed)
    }

    /// The formatted latest reply text.
    public var latestReplyMessageText: String {
        guard let latestReply = thread.latestReplies.last else {
            return ""
        }

        if latestReply.isDeleted {
            return L10n.Message.deletedMessagePlaceholder
        }

        let formatter = InjectedValues[\.utils].messagePreviewFormatter
        return formatter.format(latestReply, in: thread.channel)
    }

    /// The formatted latest reply timestamp.
    public var latestReplyTimestampText: String {
        utils.dateFormatter.string(
            from: thread.latestReplies.last?.createdAt ?? .distantPast
        )
    }

    /// The formatted draft reply text.
    public var draftReplyText: String? {
        guard utils.messageListConfig.draftMessagesEnabled else { return nil }
        guard let draftMessage = thread.parentMessage.draftReply else { return nil }
        let messageFormatter = InjectedValues[\.utils].messagePreviewFormatter
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
        utils.channelNamer(thread.channel, chatClient.currentUserId) ?? ""
    }

    private var latestReplyAuthor: ChatUser? {
        thread.latestReplies.last?.author
    }
}

/// The layout of the thread list item view.
struct ChatThreadListItemContentView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils
    @Injected(\.images) private var images
    @Injected(\.chatClient) private var chatClient

    var factory: Factory
    var channelNameText: String
    var parentMessageText: String
    var unreadRepliesCount: Int
    var replyAuthorId: String
    var replyAuthorName: String
    var replyAuthorUrl: URL?
    var replyAuthorIsOnline: Bool
    var replyMessageText: String
    var replyTimestampText: String
    var draftText: String?

    init(
        factory: Factory = DefaultViewFactory.shared,
        channelNameText: String,
        parentMessageText: String,
        unreadRepliesCount: Int,
        replyAuthorId: String,
        replyAuthorName: String,
        replyAuthorUrl: URL?,
        replyAuthorIsOnline: Bool,
        replyMessageText: String,
        replyTimestampText: String,
        draftText: String? = nil
    ) {
        self.factory = factory
        self.channelNameText = channelNameText
        self.parentMessageText = parentMessageText
        self.unreadRepliesCount = unreadRepliesCount
        self.replyAuthorId = replyAuthorId
        self.replyAuthorName = replyAuthorName
        self.replyAuthorUrl = replyAuthorUrl
        self.replyAuthorIsOnline = replyAuthorIsOnline
        self.replyMessageText = replyMessageText
        self.replyTimestampText = replyTimestampText
        self.draftText = draftText
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            threadContainerView
            replyContainerView
        }
        .padding(.all, 8)
    }

    var threadContainerView: some View {
        VStack(alignment: .leading, spacing: 0) {
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
                HStack {
                    if unreadRepliesCount != 0 {
                        UnreadIndicatorView(
                            unreadCount: unreadRepliesCount
                        )
                    }
                }
                .frame(minHeight: 18)
            }
        }
    }

    var replyContainerView: some View {
        HStack(spacing: 8) {
            let displayInfo = UserDisplayInfo(
                id: replyAuthorId,
                name: replyAuthorName,
                imageURL: replyAuthorUrl,
                size: .init(width: 40, height: 40)
            )
            factory.makeMessageAvatarView(for: displayInfo)
            VStack(alignment: .leading) {
                Text(replyAuthorName)
                    .lineLimit(1)
                    .foregroundColor(Color(colors.text))
                    .font(fonts.subheadlineBold)
                HStack {
                    if let draftText {
                        HStack(spacing: 2) {
                            draftPrefixView
                            SubtitleText(text: draftText)
                        }
                    } else {
                        SubtitleText(text: replyMessageText)
                    }
                    Spacer()
                    SubtitleText(text: replyTimestampText)
                }
            }
        }
    }

    var draftPrefixView: some View {
        Text("\(L10n.Message.Preview.draft):")
            .font(fonts.caption1).bold()
            .foregroundColor(Color(colors.highlightedAccentBackground))
    }
}
