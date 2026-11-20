//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

extension ScheduledMessage {
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

    var isChannelDeleted: Bool {
        if case let .serverFailedPublishing(failure) = failure {
            failure.reason == .channelDeleted
        } else {
            false
        }
    }

    // The server refuses to send a message which quotes a deleted message. The quoted message is only known when it is
    // stored locally.
    var quotesDeletedMessage: Bool {
        message.quotedMessage?.deletedAt != nil
    }

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

    var attachmentNames: [String] {
        message.fileAttachments.compactMap(\.payload.title)
            + message.imageAttachments.compactMap(\.payload.title)
            + message.videoAttachments.compactMap(\.payload.title)
    }

    // Names the channel as `DefaultChatChannelNamer` does.
    @MainActor func channelName(currentUserId: UserId?) -> String {
        if let name = channel.name, !name.isEmpty {
            return name
        }
        guard channel.isDirectMessageChannel else { return channel.id }
        let names = channel.members.filter { $0.id != currentUserId }.compactMap(\.name).sorted()
        guard !names.isEmpty else {
            return channel.members.first { $0.id == currentUserId }.map { $0.name ?? $0.id } ?? ""
        }
        let otherCount = max(names.count, channel.memberCount - 1)
        if otherCount == 2, names.count == 2 {
            return "\(names[0]) \(L10n.Channel.Name.and) \(names[1])"
        }
        let shownNames = names.prefix(2).joined(separator: ", ")
        return otherCount > 2 ? "\(shownNames) \(L10n.Channel.Name.andXMore(otherCount - 2))" : shownNames
    }
}

extension ScheduledMessageChannel {
    var isDirectMessageChannel: Bool {
        cid.id.hasPrefix("!members")
    }
}
