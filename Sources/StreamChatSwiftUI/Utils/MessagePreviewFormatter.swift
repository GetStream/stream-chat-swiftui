//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A formatter that converts a message to a text preview representation.
/// By default it is used to show message previews in the Channel List and Thread List.
open class MessagePreviewFormatter {
    @Injected(\.chatClient) var chatClient

    public init() {}

    /// Formats the message including the author's name.
    open func format(_ previewMessage: ChatMessage, in channel: ChatChannel) -> String {
        if let poll = previewMessage.poll {
            return formatPoll(poll)
        }
        return "\(previewMessage.author.name ?? previewMessage.author.id): \(formatContent(for: previewMessage, in: channel))"
    }
    
    /// Formats only the content of the message without the author's name.
    open func formatContent(for previewMessage: ChatMessage, in channel: ChatChannel) -> String {
        if let attachmentPreviewText = formatAttachmentContent(for: previewMessage, in: channel) {
            return attachmentPreviewText
        }
        if let textContent = previewMessage.textContent(for: channel.membership?.language), !textContent.isEmpty {
            return textContent
        }
        return previewMessage.adjustedText
    }

    /// Formats only the attachment content of the message in case it contains attachments.
    open func formatAttachmentContent(for previewMessage: ChatMessage, in channel: ChatChannel) -> String? {
        if let poll = previewMessage.poll {
            return "📊 \(poll.name)"
        }
        guard let attachment = previewMessage.allAttachments.first, !previewMessage.isDeleted else {
            return nil
        }
        let text = previewMessage.textContent(for: channel.membership?.language) ?? previewMessage.text
        switch attachment.type {
        case .audio:
            let defaultAudioText = L10n.Channel.Item.audio
            return "🎧 \(text.isEmpty ? defaultAudioText : text)"
        case .file:
            guard let fileAttachment = previewMessage.fileAttachments.first else {
                return nil
            }
            let title = fileAttachment.payload.title
            return "📄 \(title ?? text)"
        case .image:
            let defaultPhotoText = L10n.Channel.Item.photo
            return "📷 \(text.isEmpty ? defaultPhotoText : text)"
        case .video:
            let defaultVideoText = L10n.Channel.Item.video
            return "📹 \(text.isEmpty ? defaultVideoText : text)"
        case .giphy:
            return "/giphy"
        case .voiceRecording:
            let defaultVoiceMessageText = L10n.Channel.Item.voiceMessage
            return "🎧 \(text.isEmpty ? defaultVoiceMessageText : text)"
        default:
            return nil
        }
    }

    /// Formats the poll, including the author's name.
    private func formatPoll(_ poll: Poll) -> String {
        var components = ["📊"]
        if let latestVoter = poll.latestVotes.first?.user {
            if latestVoter.id == chatClient.currentUserId {
                components.append(L10n.Channel.Item.pollYouVoted)
            } else {
                components.append(L10n.Channel.Item.pollSomeoneVoted(latestVoter.name ?? latestVoter.id))
            }
        } else if let creator = poll.createdBy {
            if creator.id == chatClient.currentUserId {
                components.append(L10n.Channel.Item.pollYouCreated)
            } else {
                components.append(L10n.Channel.Item.pollSomeoneCreated(creator.name ?? creator.id))
            }
        }
        if !poll.name.isEmpty {
            components.append(poll.name)
        }
        return components.joined(separator: " ")
    }
}
