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
                        ChannelItemTitleView(
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
                        ChannelItemPreviewView(viewModel.preview)
                        Spacer()
                        if viewModel.shouldShowMutedTrailingIcon {
                            ChannelItemMutedIcon()
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
public struct ChannelItemTitleView: View {
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
                ChannelItemMutedIcon()
                    .frame(maxHeight: 14)
                    .padding(.bottom, -2)
            }
        }
    }
}

/// The muted icon used by the channel list item.
public struct ChannelItemMutedIcon: View {
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
    public static let bottomRightCorner: ChannelItemMutedLayoutStyle = .init("bottomRightCorner")

    /// This style shows the muted icon after the channel name.
    public static let afterChannelName: ChannelItemMutedLayoutStyle = .init("afterChannelName")

    public static func == (lhs: ChannelItemMutedLayoutStyle, rhs: ChannelItemMutedLayoutStyle) -> Bool {
        lhs.identifier == rhs.identifier
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
