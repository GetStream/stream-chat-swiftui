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
            parentMessageAttachmentIcon: viewModel.parentMessageAttachmentIcon,
            unreadRepliesCount: viewModel.unreadRepliesCount,
            parentAuthor: viewModel.parentMessageAuthor,
            replyCountText: viewModel.replyCountText,
            replyTimestampText: viewModel.latestReplyTimestampText,
            participantUsers: viewModel.participantUsers,
            draftText: viewModel.draftReplyText
        )
    }
}

/// The layout of the thread list item view.
struct ChatThreadListItemContentView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens
    @ScaledMetric(relativeTo: .body) private var iconScale: CGFloat = 1

    var factory: Factory
    var channelNameText: String
    var parentMessageAuthorName: String?
    var parentMessageContentText: String
    var parentMessageAttachmentIcon: UIImage?
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
        parentMessageAttachmentIcon: UIImage? = nil,
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
        self.parentMessageAttachmentIcon = parentMessageAttachmentIcon
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
                attachmentIconView
                messageTitle(text: parentMessageContentText)
            }
            .lineLimit(1)
        } else {
            HStack(spacing: tokens.spacingXxs) {
                attachmentIconView
                messageTitle(text: parentMessageContentText)
            }
            .lineLimit(1)
        }
    }

    @ViewBuilder
    var attachmentIconView: some View {
        if let parentMessageAttachmentIcon {
            Image(uiImage: parentMessageAttachmentIcon)
                .customizable()
                .frame(width: tokens.iconSizeSm * iconScale, height: tokens.iconSizeSm * iconScale)
                .foregroundColor(colors.textPrimary.toColor)
                .accessibilityHidden(true)
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
                .background(Circle().fill(colors.borderCoreOnAccent.toColor))
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
