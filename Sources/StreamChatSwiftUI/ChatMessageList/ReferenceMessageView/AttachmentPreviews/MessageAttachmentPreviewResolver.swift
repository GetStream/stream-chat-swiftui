//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// Resolves attachment preview data from a message.
@MainActor
public struct MessageAttachmentPreviewResolver {
    @Injected(\.utils) private var utils
    
    /// The kind of attachment.
    private let kind: MessageAttachmentPreviewKind
    
    private let thumbnail: MessageAttachmentPreviewThumbnail?
    
    // MARK: - Initialization
    
    /// Creates an attachment preview resolver from a message.
    /// - Parameters:
    ///   - message: The message to analyze for attachments.
    ///   - translationLanguage: The language to show the poll name in, when it has a translation to it.
    public init(message: ChatMessage, translationLanguage: TranslationLanguage? = nil) {
        self.kind = Self.resolveKind(from: message, translationLanguage: translationLanguage)
        self.thumbnail = Self.resolveThumbnail(from: message)
    }

    /// Creates an attachment preview resolver from the attachments added to the composer.
    init(assets: TotalAddedAssets) {
        let images = assets.mediaAssets.filter { $0.type == .image }
        let videoCount = assets.mediaAssets.count - images.count
        // Custom attachments have no type of their own here, they are described as files.
        let fileCount = assets.fileAssets.count + assets.customAssets.count
        let counts = [images.count, videoCount, fileCount, assets.voiceAssets.count].filter { $0 > 0 }
        if counts.count > 1 {
            kind = .mixed(attachmentsCount: counts.reduce(0, +))
        } else if let voiceRecording = assets.voiceAssets.first {
            kind = .voiceRecording(duration: voiceRecording.duration)
        } else if !images.isEmpty {
            kind = .photo(count: images.count)
        } else if videoCount > 0 {
            kind = .video(count: videoCount)
        } else if fileCount > 0 {
            kind = .file(count: fileCount, fileName: assets.fileAssets.first?.url.lastPathComponent)
        } else {
            kind = .none
        }
        thumbnail = counts == [1] ? images.first.map { .image(url: $0.url) } : nil
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
                
        case .giphy:
            return L10n.Composer.Quoted.giphy
                
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
        case .giphy:
            return .document
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
    
    // MARK: - Preview Thumbnail
    
    /// The thumbnail for the attachment preview, if available.
    /// Returns nil for mixed attachments or when no preview is available.
    public var previewThumbnail: MessageAttachmentPreviewThumbnail? {
        thumbnail
    }
    
    // MARK: - Helpers
    
    private static func resolveThumbnail(from message: ChatMessage) -> MessageAttachmentPreviewThumbnail? {
        let allAttachmentCount = message.attachmentCounts.values.reduce(0, +)
        if allAttachmentCount > 1 {
            return nil
        }

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

        if let videoAttachment = message.videoAttachments.first,
           let thumbnailURL = videoAttachment.thumbnailURL {
            return .video(url: thumbnailURL)
        }

        if let fileAttachment = message.fileAttachments.first {
            return .file(url: fileAttachment.assetURL)
        }

        return nil
    }
    
    private static func resolveKind(
        from message: ChatMessage,
        translationLanguage: TranslationLanguage?
    ) -> MessageAttachmentPreviewKind {
        // Mixed content (multiple attachment types)
        let totalTypeCount = message.attachmentCounts.count
        let totalAttachmentCount = message.attachmentCounts.values.reduce(0, +)
        if totalTypeCount > 1 {
            return .mixed(attachmentsCount: totalAttachmentCount)
        }
        
        // Poll
        if let poll = message.poll {
            return .poll(name: poll.name(in: translationLanguage))
        }
        
        // Voice recording
        if !message.voiceRecordingAttachments.isEmpty {
            let duration = message.voiceRecordingAttachments.first?.payload.duration
            return .voiceRecording(duration: duration)
        }
        
        // Giphy
        if !message.giphyAttachments.isEmpty {
            return .giphy
        }
        
        // Images
        let imageCount = message.imageAttachments.count
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
    
    private func formattedDuration(_ duration: TimeInterval) -> String? {
        utils.videoDurationFormatter.format(duration)
    }
}
