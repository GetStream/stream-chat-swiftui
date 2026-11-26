//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A row of the scheduled messages list: when the message is sent, its channel, a preview of its content and,
/// when there is one, why it failed or that it is being sent.
///
/// Part of the design system, where it is the `Chat / Mobile / Scheduled Message List Item` component.
public struct ScheduledMessageListItem: View {
    @Injected(\.chatClient) private var chatClient
    @Injected(\.utils) private var utils

    private let scheduledMessage: ScheduledMessage

    /// Creates the row.
    /// - Parameter scheduledMessage: The scheduled message of the row.
    public init(scheduledMessage: ScheduledMessage) {
        self.scheduledMessage = scheduledMessage
    }

    public var body: some View {
        let channel = scheduledMessage.channel
        ScheduledMessageListItemContentView(
            sendAtText: L10n.ScheduledMessages.Item.sendAt(
                utils.scheduledMessagesConfig.dateFormatter.formatAbsolute(scheduledMessage.scheduledAt)
            ),
            channelName: scheduledMessage.channelName(currentUserId: chatClient.currentUserId),
            previewIcon: MessageAttachmentPreviewResolver(message: scheduledMessage.message).previewIcon
                .map(utils.messageAttachmentPreviewIconProvider.image(for:)),
            previewText: scheduledMessage.previewText,
            status: status
        ) {
            ChannelAvatar(
                url: channel.imageURL,
                size: AvatarSize.extraLarge,
                stackedPlaceholders: channel.members
                    .filter { $0.id != chatClient.currentUserId }
                    .map { ($0.imageURL, UserAvatar.initials(from: $0.name ?? "")) },
                memberCount: channel.memberCount,
                directMessageChannel: channel.isDirectMessageChannel
            )
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

enum ScheduledMessageListItemStatus {
    case failed(String)
    case inProgress(String)
}
