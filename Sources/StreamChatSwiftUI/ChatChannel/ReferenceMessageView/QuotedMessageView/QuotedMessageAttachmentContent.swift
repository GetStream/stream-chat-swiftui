//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// Represents the resolved attachment content for a quoted message.
/// This provides a single source of truth for determining both the description and icon.
@MainActor
struct QuotedMessageAttachmentContent {
    @Injected(\.utils) private var utils

    /// The kind of attachment content.
    let kind: Kind

    /// The different kinds of attachment content that can be displayed.
    enum Kind: Equatable {
        /// Multiple different attachment types.
        case mixed(typeCount: Int)
        /// A poll attachment.
        case poll(name: String)
        /// A voice recording attachment.
        case voiceRecording(duration: TimeInterval?)
        /// One or more photo attachments.
        case photo(count: Int)
        /// One or more video attachments.
        case video(count: Int)
        /// One or more file attachments.
        case file(count: Int, fileName: String?)
        /// A link attachment.
        case link
        /// An audio attachment.
        case audio
        /// No attachments.
        case none
    }

    // MARK: - Initialization

    private init(kind: Kind) {
        self.kind = kind
    }

    /// Resolves the attachment content from a message.
    /// - Parameter message: The message to analyze.
    /// - Returns: The resolved attachment content.
    static func resolve(from message: ChatMessage) -> QuotedMessageAttachmentContent {
        let kind = resolveKind(from: message)
        return QuotedMessageAttachmentContent(kind: kind)
    }

    private static func resolveKind(from message: ChatMessage) -> Kind {
        // Mixed content (multiple attachment types)
        let totalTypeCount = message.attachmentCounts.count
        let totalAttachmentCount = message.attachmentCounts.values.reduce(0, +)
        if totalTypeCount > 1 {
            return .mixed(typeCount: totalAttachmentCount)
        }

        // Poll
        if let poll = message.poll {
            return .poll(name: poll.name)
        }

        // Voice recording
        if !message.voiceRecordingAttachments.isEmpty {
            let duration = message.voiceRecordingAttachments.first?.payload.duration
            return .voiceRecording(duration: duration)
        }

        // Images (including giphys)
        let imageCount = message.imageAttachments.count + message.giphyAttachments.count
        if imageCount > 0 {
            return .photo(count: imageCount)
        }

        // Videos
        let videoCount = message.videoAttachments.count
        if videoCount > 0 {
            return .video(count: videoCount)
        }

        // Files
        let fileCount = message.fileAttachments.count
        if fileCount > 0 {
            let fileName = message.fileAttachments.first?.payload.title
            return .file(count: fileCount, fileName: fileName)
        }

        // Links
        if !message.linkAttachments.isEmpty {
            return .link
        }

        // Audio
        if !message.audioAttachments.isEmpty {
            return .audio
        }

        return .none
    }
}
