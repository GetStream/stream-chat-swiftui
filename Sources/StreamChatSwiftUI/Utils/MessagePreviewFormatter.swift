//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A formatter that converts a message to a text preview representation.
/// By default it is used to show message previews in the Channel List and Thread List.
struct MessagePreviewFormatter {
    @Injected(\.chatClient) var chatClient

    init() {}

    /// Formats the message including the author's name.
    func format(_ previewMessage: ChatMessage) -> String {
        if let poll = previewMessage.poll {
            return formatPoll(poll)
        }
        return "\(previewMessage.author.name ?? previewMessage.author.id): \(formatContent(for: previewMessage))"
    }
    
    /// Formats only the content of the message without the author's name.
    func formatContent(for previewMessage: ChatMessage) -> String {
        if let attachmentPreviewText = formatAttachmentContent(for: previewMessage) {
            return attachmentPreviewText
        }
        if let textContent = previewMessage.textContent, !textContent.isEmpty {
            return textContent
        }
        return previewMessage.adjustedText
    }

    /// Formats only the attachment content of the message in case it contains attachments.
    func formatAttachmentContent(for previewMessage: ChatMessage) -> String? {
        if let poll = previewMessage.poll {
            return "📊 \(poll.name)"
        }
        guard let attachment = previewMessage.allAttachments.first, !previewMessage.isDeleted else {
            return nil
        }
        let text = previewMessage.textContent ?? previewMessage.text
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
        return components.joined(separator: " ")
    }
}
