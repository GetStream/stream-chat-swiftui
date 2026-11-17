//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

extension ScheduledMessage {
    /// A Boolean value indicating whether the message waits for its attachments to upload before it is scheduled.
    var isUploadingAttachments: Bool {
        status == .preparingToSchedule && message.allAttachments.contains { attachment in
            switch attachment.uploadingState?.state {
            case .pendingUpload, .uploading:
                true
            default:
                false
            }
        }
    }

    /// A Boolean value indicating whether the message can't be changed right now, because it is being sent or its
    /// attachments are uploading.
    var isInProgress: Bool {
        status == .sending || isUploadingAttachments
    }

    /// The text of the message, or a description of its attachments when it has no text, prefixed when it is a
    /// thread reply or quotes a message.
    @MainActor var previewText: String {
        let text = message.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let content = text.isEmpty
            ? MessageAttachmentPreviewResolver(message: message).previewDescription ?? ""
            : text
        if message.parentMessageId != nil {
            return L10n.ScheduledMessages.Item.threadReply(content)
        }
        if let author = message.quotedMessage?.author {
            return L10n.ScheduledMessages.Item.replyTo(author.name ?? author.id, content)
        }
        return content
    }

    /// The names of the files attached to the message.
    var attachmentNames: [String] {
        message.fileAttachments.compactMap(\.payload.title)
            + message.imageAttachments.compactMap(\.payload.title)
            + message.videoAttachments.compactMap(\.payload.title)
    }

    /// The name of the channel: formatted from the channel when it is known, otherwise the name stored with the
    /// scheduled message.
    @MainActor func channelName(in channel: ChatChannel?, currentUserId: UserId?) -> String {
        let utils = InjectedValues[\.utils]
        if let channel, let name = utils.channelNameFormatter.format(channel: channel, forCurrentUserId: currentUserId) {
            return name
        }
        return self.channel.name ?? self.channel.id
    }
}
