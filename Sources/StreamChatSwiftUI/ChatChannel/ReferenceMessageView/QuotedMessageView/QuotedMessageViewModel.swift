//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// A view model that provides display data for a quoted message.
@MainActor
open class QuotedMessageViewModel {
    @Injected(\.utils) private var utils

    // MARK: - Properties
    
    /// The quoted message.
    private let message: ChatMessage

    // MARK: - Initialization
    
    /// Creates a new quoted message view model.
    /// - Parameter message: The quoted message to display.
    public init(message: ChatMessage) {
        self.message = message
    }
    
    // MARK: - Display Properties
    
    /// The title text displayed at the top (e.g., "Reply to Emma Chen").
    public var title: String {
        L10n.Composer.Quoted.replyTo(authorName)
    }
    
    /// The author's display name.
    public var authorName: String {
        message.author.name ?? message.author.id
    }
    
    /// Whether the message was sent by the current user.
    public var isSentByCurrentUser: Bool {
        message.isSentByCurrentUser
    }
    
    /// The subtitle text to display (message preview or attachment description).
    public var subtitle: String {
        // If there's text content, use it
        if !messageText.isEmpty {
            return messageText
        }
        
        // Otherwise, describe the attachments
        return attachmentDescription
    }
    
    /// The system icon name for the subtitle, if applicable.
    /// Returns nil if no icon should be shown.
    public var subtitleIconName: String? {
        // Only show icon when there's no text or we're describing attachments
        if !messageText.isEmpty && hasAttachments {
            return attachmentIconName
        }
        
        if messageText.isEmpty {
            return attachmentIconName
        }
        
        return nil
    }
    
    // MARK: - Attachment Preview
    
    /// The URL for the image attachment preview, if available.
    public var imagePreviewURL: URL? {
        if let imageAttachment = message.imageAttachments.first {
            return imageAttachment.imageURL
        }
        if let giphyAttachment = message.giphyAttachments.first {
            return giphyAttachment.previewURL
        }
        if let linkAttachment = message.linkAttachments.first {
            return linkAttachment.previewURL
        }
        return nil
    }
    
    /// The URL for the video thumbnail preview, if available.
    public var videoThumbnailURL: URL? {
        message.videoAttachments.first?.thumbnailURL
    }
    
    /// The file extension for file previews, if available.
    public var fileExtension: String? {
        message.fileAttachments.first?.assetURL.pathExtension.lowercased()
    }
    
    // MARK: - Private Helpers
    
    private var messageText: String {
        message.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var hasAttachments: Bool {
        !message.attachmentCounts.isEmpty
    }
    
    private var attachmentDescription: String {
        // Mixed content
        let totalTypeCount = message.attachmentCounts.count
        if totalTypeCount > 1 {
            return L10n.Composer.Quoted.files(totalTypeCount)
        }

        // Poll
        if let poll = message.poll {
            return poll.name
        }
        
        // Voice recording
        if !message.voiceRecordingAttachments.isEmpty {
            if let duration = message.voiceRecordingAttachments.first?.payload.duration {
                return L10n.Composer.Quoted.voiceMessageWithDuration(formattedDuration(duration))
            }
            return L10n.Composer.Quoted.voiceMessage
        }
        
        // Images
        let imageCount = message.imageAttachments.count + message.giphyAttachments.count
        if imageCount > 0 {
            if imageCount == 1 {
                return L10n.Composer.Quoted.photo
            }
            return L10n.Composer.Quoted.photos(imageCount)
        }
        
        // Videos
        let videoCount = message.videoAttachments.count
        if videoCount > 0 {
            if videoCount == 1 {
                return L10n.Composer.Quoted.video
            }
            return L10n.Composer.Quoted.videos(videoCount)
        }
        
        // Files
        let fileCount = message.fileAttachments.count
        if fileCount > 0 {
            if fileCount == 1 {
                if let fileName = message.fileAttachments.first?.payload.title {
                    return fileName
                }
                return L10n.Composer.Quoted.file
            }
            return L10n.Composer.Quoted.files(fileCount)
        }

        // Audio
        if !message.audioAttachments.isEmpty {
            return L10n.Composer.Quoted.audio
        }
        
        return ""
    }
    
    private var attachmentIconName: String? {
        // Poll
        if message.poll != nil {
            return "chart.bar"
        }
        
        // Voice recording
        if !message.voiceRecordingAttachments.isEmpty {
            return "mic"
        }
        
        // Images
        if !message.imageAttachments.isEmpty || !message.giphyAttachments.isEmpty {
            return "photo"
        }
        
        // Videos
        if !message.videoAttachments.isEmpty {
            return "video"
        }
        
        // Files
        if !message.fileAttachments.isEmpty {
            return "doc"
        }
        
        // Links
        if !message.linkAttachments.isEmpty {
            return "link"
        }
        
        // Audio
        if !message.audioAttachments.isEmpty {
            return "waveform"
        }
        
        return nil
    }
    
    private func formattedDuration(_ duration: TimeInterval) -> String {
        return utils.videoDurationFormatter.format(duration) ?? ""
    }
}
