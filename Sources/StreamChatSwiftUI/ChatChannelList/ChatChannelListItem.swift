//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the channel list item.
public struct ChatChannelListItem<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    var factory: Factory
    var viewModel: ChatChannelListItemViewModel
    var isSelected: Bool
    var disabled = false
    var onItemTap: (ChatChannel) -> Void

    public init(
        factory: Factory = DefaultViewFactory.shared,
        channel: ChatChannel,
        channelName: String,
        isSelected: Bool = false,
        disabled: Bool = false,
        onItemTap: @escaping (ChatChannel) -> Void
    ) {
        self.init(
            factory: factory,
            viewModel: ChatChannelListItemViewModel(
                channel: channel,
                channelName: channelName
            ),
            isSelected: isSelected,
            disabled: disabled,
            onItemTap: onItemTap
        )
    }

    public init(
        factory: Factory = DefaultViewFactory.shared,
        viewModel: ChatChannelListItemViewModel,
        isSelected: Bool = false,
        disabled: Bool = false,
        onItemTap: @escaping (ChatChannel) -> Void
    ) {
        self.factory = factory
        self.viewModel = viewModel
        self.isSelected = isSelected
        self.disabled = disabled
        self.onItemTap = onItemTap
    }

    public var body: some View {
        Button {
            onItemTap(viewModel.channel)
        } label: {
            HStack(spacing: tokens.spacingMd) {
                factory.makeChannelAvatarView(
                    options: ChannelAvatarViewOptions(
                        channel: viewModel.channel,
                        size: AvatarSize.extraLarge
                    )
                )

                VStack(alignment: .leading, spacing: tokens.spacingXxs) {
                    HStack {
                        ChatChannelListItemTitleView(
                            name: viewModel.channelName,
                            isMuted: viewModel.isMuted,
                            mutedLayoutStyle: viewModel.mutedLayoutStyle
                        )

                        Spacer()

                        SubtitleText(
                            text: viewModel.timestampText,
                            color: Color(colors.textTertiary)
                        )
                        .accessibilityIdentifier("timestampView")

                        if !isSelected && viewModel.hasUnread {
                            BadgeNotificationView(
                                count: viewModel.unreadCount
                            )
                        }
                    }

                    HStack(spacing: tokens.spacingXxxs) {
                        if viewModel.shouldShowReadEvents {
                            MessageReadIndicatorView(
                                readUsers: viewModel.readUsers,
                                showDelivered: viewModel.showDelivered,
                                localState: viewModel.previewMessageLocalState
                            )
                        }
                        ChatChannelListItemSubtitleView(
                            factory: factory,
                            channel: viewModel.channel,
                            isLastMessageFailedToSend: viewModel.lastMessageFailedToSend,
                            isShowingTypingIndicator: viewModel.shouldShowTypingIndicator,
                            isDraftMessagesEnabled: viewModel.isDraftMessagesEnabled,
                            draftMessageText: viewModel.draftMessageText,
                            isPreviewMessageDeleted: viewModel.isPreviewMessageDeleted,
                            isPreviewMessageSentByCurrentUser: viewModel.isPreviewMessageSentByCurrentUser,
                            subtitleAuthorName: viewModel.subtitleAuthorName,
                            subtitleText: viewModel.subtitleText,
                            previewContentText: viewModel.previewContentText,
                            previewAttachmentIconImage: viewModel.previewAttachmentIconImage
                        )
                        Spacer()
                        if viewModel.shouldShowMutedTrailingIcon {
                            ChatChannelListItemMutedIcon()
                        }
                    }
                }
            }
            .padding(.all, tokens.spacingMd)
        }
        .foregroundColor(.black)
        .disabled(disabled)
        .id("\(viewModel.channel.id)-base")
    }
}

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

    // MARK: - Private

    private var previewMessage: ChatMessage? {
        channel.latestMessages.first(where: { $0.type != .ephemeral })
    }
}

/// The title view used in the channel list item.
///
/// Renders the channel name and, depending on `mutedLayoutStyle`, an inline
/// muted icon after the name.
public struct ChatChannelListItemTitleView: View {
    /// The channel display name.
    public let name: String
    /// Whether the channel is muted.
    public let isMuted: Bool
    /// The layout style that determines where the muted icon is rendered.
    public let mutedLayoutStyle: ChannelItemMutedLayoutStyle

    public init(
        name: String,
        isMuted: Bool = false,
        mutedLayoutStyle: ChannelItemMutedLayoutStyle = .bottomRightCorner
    ) {
        self.name = name
        self.isMuted = isMuted
        self.mutedLayoutStyle = mutedLayoutStyle
    }

    public var body: some View {
        HStack(spacing: 6) {
            ChatTitleView(name: name)
            if isMuted, mutedLayoutStyle == .afterChannelName {
                ChatChannelListItemMutedIcon()
                    .frame(maxHeight: 14)
                    .padding(.bottom, -2)
            }
        }
    }
}

/// The muted icon used by the channel list item.
public struct ChatChannelListItemMutedIcon: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    public init() {}

    public var body: some View {
        Image(uiImage: images.muted)
            .customizable()
            .frame(height: tokens.iconSizeMd)
            .foregroundColor(Color(colors.textTertiary))
    }
}

/// The subtitle view used by the channel list item.
///
/// Renders one of the channel preview variants based on the provided primitive
/// flags. The variants, evaluated in order, are: failed-to-send, typing,
/// draft, deleted, author-prefixed preview, attachment-only preview, and
/// plain subtitle text.
///
/// The view is generic over `Factory` because the typing variant is rendered
/// via `factory.makeSubtitleTypingIndicatorView(options:)`.
public struct ChatChannelListItemSubtitleView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    /// The factory used to build the typing indicator view.
    public let factory: Factory
    /// The channel used as input to the typing indicator options.
    public let channel: ChatChannel
    /// Whether the last message failed to send.
    public let isLastMessageFailedToSend: Bool
    /// Whether the typing indicator should be shown.
    public let isShowingTypingIndicator: Bool
    /// Whether the draft messages feature is enabled.
    public let isDraftMessagesEnabled: Bool
    /// The formatted draft message text, when present.
    public let draftMessageText: String?
    /// Whether the preview message is deleted.
    public let isPreviewMessageDeleted: Bool
    /// Whether the preview message was sent by the current user.
    public let isPreviewMessageSentByCurrentUser: Bool
    /// The author name to show before the subtitle content, when applicable.
    public let subtitleAuthorName: String?
    /// The formatted subtitle text (preview, typing string, or empty placeholder).
    public let subtitleText: String
    /// The preview message content text without any author name prefix.
    public let previewContentText: String
    /// The icon image for the preview message attachment, when present.
    public let previewAttachmentIconImage: UIImage?

    public init(
        factory: Factory = DefaultViewFactory.shared,
        channel: ChatChannel,
        isLastMessageFailedToSend: Bool,
        isShowingTypingIndicator: Bool,
        isDraftMessagesEnabled: Bool,
        draftMessageText: String?,
        isPreviewMessageDeleted: Bool,
        isPreviewMessageSentByCurrentUser: Bool,
        subtitleAuthorName: String?,
        subtitleText: String,
        previewContentText: String,
        previewAttachmentIconImage: UIImage?
    ) {
        self.factory = factory
        self.channel = channel
        self.isLastMessageFailedToSend = isLastMessageFailedToSend
        self.isShowingTypingIndicator = isShowingTypingIndicator
        self.isDraftMessagesEnabled = isDraftMessagesEnabled
        self.draftMessageText = draftMessageText
        self.isPreviewMessageDeleted = isPreviewMessageDeleted
        self.isPreviewMessageSentByCurrentUser = isPreviewMessageSentByCurrentUser
        self.subtitleAuthorName = subtitleAuthorName
        self.subtitleText = subtitleText
        self.previewContentText = previewContentText
        self.previewAttachmentIconImage = previewAttachmentIconImage
    }

    public var body: some View {
        HStack(spacing: 4) {
            if isLastMessageFailedToSend {
                HStack(spacing: tokens.spacingXxs) {
                    Image(uiImage: images.messageListErrorIndicator)
                        .customizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(Color(colors.badgeBackgroundError))
                        .accessibilityHidden(true)
                    Text(L10n.Channel.Item.messageFailedToSend)
                }
                .font(fonts.subheadline)
                .foregroundColor(Color(colors.accentError))
                .lineLimit(1)
            } else if isShowingTypingIndicator {
                factory.makeSubtitleTypingIndicatorView(
                    options: SubtitleTypingIndicatorViewOptions(channel: channel)
                )
            } else if isDraftMessagesEnabled, let draftText = draftMessageText {
                HStack(spacing: 2) {
                    labelWithColon(L10n.Message.Preview.draft, weight: .semibold, trailingSpace: true)
                        .font(fonts.subheadline)
                        .foregroundColor(Color(colors.accentPrimary))
                    SubtitleText(text: draftText)
                }
            } else if isPreviewMessageDeleted {
                HStack(spacing: tokens.spacingXxs) {
                    if isPreviewMessageSentByCurrentUser {
                        labelWithColon(L10n.Channel.Item.you, weight: .semibold)
                            .font(fonts.subheadline)
                    }
                    Image(systemName: "nosign")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .accessibilityHidden(true)
                    Text(L10n.Message.deletedMessagePlaceholder)
                }
                .lineLimit(1)
                .font(fonts.subheadline)
                .foregroundColor(Color(colors.textTertiary))
            } else if let authorName = subtitleAuthorName {
                HStack(spacing: tokens.spacingXxs) {
                    labelWithColon(authorName, weight: .semibold)
                        .font(fonts.subheadline)
                        .foregroundColor(Color(colors.textTertiary))
                    attachmentIconView
                    Text(previewContentText)
                }
                .lineLimit(1)
                .font(fonts.subheadline)
                .foregroundColor(Color(colors.textSecondary))
            } else if previewAttachmentIconImage != nil {
                HStack(spacing: tokens.spacingXxs) {
                    attachmentIconView
                    Text(subtitleText)
                }
                .lineLimit(1)
                .font(fonts.subheadline)
                .foregroundColor(Color(colors.textSecondary))
            } else {
                SubtitleText(text: subtitleText)
            }
        }
        .accessibilityIdentifier("subtitleView")
    }

    @ViewBuilder
    private var attachmentIconView: some View {
        if let iconImage = previewAttachmentIconImage {
            Image(uiImage: iconImage)
                .customizable()
                .frame(width: tokens.iconSizeSm, height: tokens.iconSizeSm)
                .accessibilityHidden(true)
        }
    }

    private func labelWithColon(
        _ text: String,
        weight: Font.Weight = .regular,
        trailingSpace: Bool = false
    ) -> some View {
        HStack(spacing: 0) {
            Text(text).fontWeight(weight)
            Text(verbatim: trailingSpace ? ": " : ":").fontWeight(weight)
        }
    }
}

/// The style for the muted icon in the channel list item.
public final class ChannelItemMutedLayoutStyle: Hashable, Sendable {
    let identifier: String

    init(_ identifier: String) {
        self.identifier = identifier
    }

    /// This style shows the muted icon at the bottom right corner of the channel item.
    /// The subtitle text shows the last message preview text.
    public static let bottomRightCorner: ChannelItemMutedLayoutStyle = .init("bottomRightCorner")

    /// This style shows the muted icon after the channel name.
    /// The subtitle text shows the last message preview text.
    public static let afterChannelName: ChannelItemMutedLayoutStyle = .init("afterChannelName")

    public static func == (lhs: ChannelItemMutedLayoutStyle, rhs: ChannelItemMutedLayoutStyle) -> Bool {
        lhs.identifier == rhs.identifier
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
