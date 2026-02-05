//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// Represents the resolved attachment content for a message preview.
@MainActor
public struct MessageAttachmentPreviewContent {
    @Injected(\.utils) private var utils

    /// The kind of attachment content.
    public let kind: Kind
    
    /// The URL for the attachment preview (image, video thumbnail, link preview, or file).
    public let previewURL: URL?

    /// The different kinds of attachment content that can be displayed.
    public enum Kind: Equatable {
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

    /// Creates an attachment preview content from a message.
    /// - Parameter message: The message to analyze for attachments.
    public init(message: ChatMessage) {
        self.kind = Self.resolveKind(from: message)
        self.previewURL = Self.resolvePreviewURL(from: message)
    }

    // MARK: - Preview Description

    /// Returns the description text for the attachment preview.
    /// - Returns: A localized string describing the attachment, or empty string if none.
    public var previewDescription: String {
        switch kind {
        case .mixed(let typeCount):
            return L10n.Composer.Quoted.files(typeCount)

        case .poll(let name):
            return name

        case .voiceRecording(let duration):
            if let duration, let formatted = formattedDuration(duration) {
                return L10n.Composer.Quoted.voiceMessageWithDuration(formatted)
            }
            return L10n.Composer.Quoted.voiceMessage

        case .photo(let count):
            return count == 1 ? L10n.Composer.Quoted.photo : L10n.Composer.Quoted.photos(count)

        case .video(let count):
            return count == 1 ? L10n.Composer.Quoted.video : L10n.Composer.Quoted.videos(count)

        case .file(let count, let fileName):
            if count == 1 {
                return fileName ?? L10n.Composer.Quoted.file
            }
            return L10n.Composer.Quoted.files(count)

        case .audio:
            return L10n.Composer.Quoted.audio

        case .none, .link:
            return ""
        }
    }

    // MARK: - Preview Icon

    /// Returns the icon for the attachment preview.
    /// - Returns: The appropriate icon, or nil if no icon should be shown.
    public var previewIcon: MessageAttachmentPreviewIcon? {
        switch kind {
        case .mixed:
            return .mixed
        case .poll:
            return .poll
        case .voiceRecording:
            return .voiceRecording
        case .photo:
            return .photo
        case .video:
            return .video
        case .file:
            return .document
        case .link:
            return .link
        case .audio:
            return .audio
        case .none:
            return nil
        }
    }

    // MARK: - Private Helpers

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
    
    private static func resolvePreviewURL(from message: ChatMessage) -> URL? {
        if let imageAttachment = message.imageAttachments.first {
            return imageAttachment.imageURL
        }

        if let giphyAttachment = message.giphyAttachments.first {
            return giphyAttachment.previewURL
        }

        if let videoAttachment = message.videoAttachments.first {
            return videoAttachment.thumbnailURL
        }

        if let linkAttachment = message.linkAttachments.first {
            return linkAttachment.previewURL
        }

        if let fileAttachment = message.fileAttachments.first {
            return fileAttachment.assetURL
        }

        return nil
    }

    private func formattedDuration(_ duration: TimeInterval) -> String? {
        utils.videoDurationFormatter.format(duration)
    }
}
