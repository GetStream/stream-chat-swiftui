//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// Resolves attachment preview data from a message.
///
/// This struct analyzes a message's attachments and provides the necessary data
/// for displaying attachment previews in reference message views.
@MainActor
public struct MessageAttachmentPreviewResolver {
    @Injected(\.utils) private var utils
    
    /// The kind of attachment.
    public let kind: MessageAttachmentPreviewKind
    
    /// The thumbnail for the attachment preview, if available.
    /// Returns nil for mixed attachments or when no preview is available.
    public let thumbnail: MessageAttachmentPreviewThumbnail?
    
    // MARK: - Initialization
    
    /// Creates an attachment preview resolver from a message.
    /// - Parameter message: The message to analyze for attachments.
    public init(message: ChatMessage) {
        self.kind = Self.resolveKind(from: message)
        self.thumbnail = Self.resolveThumbnail(from: message, kind: self.kind)
    }
    
    // MARK: - Preview Description
    
    /// Returns the description text for the attachment preview.
    /// - Returns: A localized string describing the attachment, or nil if none.
    public var previewDescription: String? {
        switch kind {
        case .mixed(let attachmentsCount):
            return L10n.Composer.Quoted.files(attachmentsCount)
                
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
            return nil
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
    
    private static func resolveKind(from message: ChatMessage) -> MessageAttachmentPreviewKind {
        // Mixed content (multiple attachment types)
        let totalTypeCount = message.attachmentCounts.count
        let totalAttachmentCount = message.attachmentCounts.values.reduce(0, +)
        if totalTypeCount > 1 {
            return .mixed(attachmentsCount: totalAttachmentCount)
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
    
    private static func resolveThumbnail(
        from message: ChatMessage,
        kind: MessageAttachmentPreviewKind
    ) -> MessageAttachmentPreviewThumbnail? {
        // No thumbnail for mixed attachments
        if case .mixed = kind {
            return nil
        }
        
        // Image attachments (includes images, giphys, and link previews)
        if let imageAttachment = message.imageAttachments.first {
            return .image(url: imageAttachment.imageURL)
        }
        if let giphyAttachment = message.giphyAttachments.first {
            return .image(url: giphyAttachment.previewURL)
        }
        if let linkAttachment = message.linkAttachments.first,
           let previewURL = linkAttachment.previewURL {
            return .image(url: previewURL)
        }
        
        // Video attachments
        if let videoAttachment = message.videoAttachments.first,
           let thumbnailURL = videoAttachment.thumbnailURL {
            return .video(url: thumbnailURL)
        }
        
        // File attachments
        if let fileAttachment = message.fileAttachments.first {
            return .file(url: fileAttachment.assetURL)
        }
        
        return nil
    }
    
    private func formattedDuration(_ duration: TimeInterval) -> String? {
        utils.videoDurationFormatter.format(duration)
    }
}
