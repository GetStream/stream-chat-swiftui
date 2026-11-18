//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A row of the scheduled messages list: when the message is sent, its channel, a preview of its content and,
/// when there is one, why it failed or that it is being sent.
///
/// Part of the design system, where it is the `Chat / Mobile / Scheduled Message List Item` component.
public struct ScheduledMessageListItem<Factory: ViewFactory>: View {
    @Injected(\.chatClient) private var chatClient
    @Injected(\.utils) private var utils

    private let factory: Factory
    private let scheduledMessage: ScheduledMessage
    private let channel: ChatChannel?

    /// Creates the row.
    /// - Parameters:
    ///   - factory: The view factory used for creating the avatar of the channel.
    ///   - scheduledMessage: The scheduled message of the row.
    ///   - channel: The channel of the scheduled message, when it is known. It gives a direct message channel the
    ///   name and avatar of the other member. Without it, the row shows the name and image stored with the scheduled message.
    public init(
        factory: Factory = DefaultViewFactory.shared,
        scheduledMessage: ScheduledMessage,
        channel: ChatChannel?
    ) {
        self.factory = factory
        self.scheduledMessage = scheduledMessage
        self.channel = channel
    }

    public var body: some View {
        let channelName = scheduledMessage.channelName(in: channel, currentUserId: chatClient.currentUserId)
        ScheduledMessageListItemContentView(
            sendAtText: L10n.ScheduledMessages.Item.sendAt(
                utils.scheduledMessagesConfig.dateFormatter.formatAbsolute(scheduledMessage.scheduledAt)
            ),
            channelName: channelName,
            previewIcon: MessageAttachmentPreviewResolver(message: scheduledMessage.message).previewIcon
                .map(utils.messageAttachmentPreviewIconProvider.image(for:)),
            previewText: scheduledMessage.previewText,
            status: status
        ) {
            if let channel {
                factory.makeChannelAvatarView(
                    options: ChannelAvatarViewOptions(
                        channel: channel,
                        size: AvatarSize.extraLarge,
                        showsIndicator: false
                    )
                )
            } else {
                UserAvatar(
                    url: scheduledMessage.channel.imageURL,
                    initials: channelName.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined(),
                    size: AvatarSize.extraLarge,
                    indicator: .none
                )
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("ScheduledMessageListItem")
    }

    private var status: ScheduledMessageListItemStatus? {
        if scheduledMessage.status == .failed {
            .failed(utils.scheduledMessagesConfig.failureFormatter.format(scheduledMessage.failure))
        } else if scheduledMessage.status == .sending {
            .inProgress(L10n.ScheduledMessages.Item.sending)
        } else if scheduledMessage.isUploadingAttachments {
            .inProgress(L10n.ScheduledMessages.Item.uploading)
        } else if scheduledMessage.quotesDeletedMessage {
            .failed(L10n.ScheduledMessages.Item.quoteDeleted)
        } else {
            nil
        }
    }
}

enum ScheduledMessageListItemStatus: Equatable {
    case failed(String)
    case inProgress(String)
}
