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
                            channelName: viewModel.channelName,
                            shouldShowInlineMutedIcon: viewModel.shouldShowInlineMutedIcon
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
                        ChatChannelListItemSubtitleView(subtitle: viewModel.subtitle)
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

/// The title view used in the channel list item.
///
/// Renders the channel name and, when `shouldShowInlineMutedIcon` is `true`,
/// an inline muted icon after the name.
public struct ChatChannelListItemTitleView: View {
    /// The channel display name.
    public let channelName: String
    /// Whether the muted icon should be shown inline next to the channel name.
    public let shouldShowInlineMutedIcon: Bool

    public init(
        channelName: String,
        shouldShowInlineMutedIcon: Bool
    ) {
        self.channelName = channelName
        self.shouldShowInlineMutedIcon = shouldShowInlineMutedIcon
    }

    public var body: some View {
        HStack(spacing: 6) {
            ChatTitleView(name: channelName)
            if shouldShowInlineMutedIcon {
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
            .accessibilityLabel(Text(L10n.Channel.Item.muted))
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

// MARK: - Subtitle variants

/// Failed-to-send subtitle variant for the channel list item: an error icon
/// followed by the "message failed to send" label.
public struct ChatChannelListItemFailedToSendView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    public init() {}

    public var body: some View {
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
    }
}

/// Draft subtitle variant for the channel list item: a "Draft:" prefix
/// followed by the draft message text.
public struct ChatChannelListItemDraftPreviewView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    /// The formatted draft message text.
    public let draftMessageText: String

    public init(draftMessageText: String) {
        self.draftMessageText = draftMessageText
    }

    public var body: some View {
        HStack(spacing: 2) {
            LabelWithColon(text: L10n.Message.Preview.draft, weight: .semibold, trailingSpace: true)
                .font(fonts.subheadline)
                .foregroundColor(Color(colors.accentPrimary))
            SubtitleText(text: draftMessageText)
        }
    }
}

/// Deleted-preview subtitle variant for the channel list item: an optional
/// "You:" prefix when the deleted message was sent by the current user,
/// followed by a "nosign" icon and the deleted placeholder text.
public struct ChatChannelListItemDeletedPreviewView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    /// Whether the deleted preview message was sent by the current user.
    public let isPreviewMessageSentByCurrentUser: Bool

    public init(isPreviewMessageSentByCurrentUser: Bool) {
        self.isPreviewMessageSentByCurrentUser = isPreviewMessageSentByCurrentUser
    }

    public var body: some View {
        HStack(spacing: tokens.spacingXxs) {
            if isPreviewMessageSentByCurrentUser {
                LabelWithColon(text: L10n.Channel.Item.you, weight: .semibold)
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
    }
}

/// Author-prefixed subtitle variant for the channel list item: "Author:"
/// followed by an optional attachment icon and the preview content text.
public struct ChatChannelListItemAuthorPreviewView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    /// The author name shown before the preview content.
    public let subtitleAuthorName: String
    /// The preview message content text.
    public let previewContentText: String
    /// The icon image for the preview message attachment, when present.
    public let previewAttachmentIconImage: UIImage?

    public init(
        subtitleAuthorName: String,
        previewContentText: String,
        previewAttachmentIconImage: UIImage?
    ) {
        self.subtitleAuthorName = subtitleAuthorName
        self.previewContentText = previewContentText
        self.previewAttachmentIconImage = previewAttachmentIconImage
    }

    public var body: some View {
        HStack(spacing: tokens.spacingXxs) {
            LabelWithColon(text: subtitleAuthorName, weight: .semibold)
                .font(fonts.subheadline)
                .foregroundColor(Color(colors.textTertiary))
            ChatChannelListItemAttachmentIcon(image: previewAttachmentIconImage)
            Text(previewContentText)
        }
        .lineLimit(1)
        .font(fonts.subheadline)
        .foregroundColor(Color(colors.textSecondary))
    }
}

/// Attachment-only subtitle variant for the channel list item: an attachment
/// icon followed by the preview text (used when there is no author prefix
/// to show).
public struct ChatChannelListItemAttachmentPreviewView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    /// The formatted subtitle text shown next to the attachment icon.
    public let subtitleText: String
    /// The icon image for the preview message attachment, when present.
    public let previewAttachmentIconImage: UIImage?

    public init(
        subtitleText: String,
        previewAttachmentIconImage: UIImage?
    ) {
        self.subtitleText = subtitleText
        self.previewAttachmentIconImage = previewAttachmentIconImage
    }

    public var body: some View {
        HStack(spacing: tokens.spacingXxs) {
            ChatChannelListItemAttachmentIcon(image: previewAttachmentIconImage)
            Text(subtitleText)
        }
        .lineLimit(1)
        .font(fonts.subheadline)
        .foregroundColor(Color(colors.textSecondary))
    }
}

/// The attachment icon used by the channel list item preview variants that
/// display an attachment glyph before the text.
public struct ChatChannelListItemAttachmentIcon: View {
    @Injected(\.tokens) private var tokens

    /// The image to render as the attachment icon. Renders nothing when `nil`.
    public let image: UIImage?

    public init(image: UIImage?) {
        self.image = image
    }

    @ViewBuilder
    public var body: some View {
        if let image {
            Image(uiImage: image)
                .customizable()
                .frame(width: tokens.iconSizeSm, height: tokens.iconSizeSm)
                .accessibilityHidden(true)
        }
    }
}

/// A label followed by a colon (and optional trailing space). Used as the
/// author / draft / "You" prefix inside the subtitle variants.
private struct LabelWithColon: View {
    let text: String
    let weight: Font.Weight
    let trailingSpace: Bool

    init(text: String, weight: Font.Weight = .regular, trailingSpace: Bool = false) {
        self.text = text
        self.weight = weight
        self.trailingSpace = trailingSpace
    }

    var body: some View {
        HStack(spacing: 0) {
            Text(text).fontWeight(weight)
            Text(verbatim: trailingSpace ? ": " : ":").fontWeight(weight)
        }
    }
}
