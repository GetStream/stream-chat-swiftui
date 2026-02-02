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

    /// The resolved attachment content (lazily computed once).
    private lazy var attachmentContent: QuotedMessageAttachmentContent = {
        QuotedMessageAttachmentContent.resolve(from: message)
    }()

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
        // If there's text content, use it.
        if !messageText.isEmpty {
            return messageText
        }
        
        // Otherwise, describe the attachments.
        switch attachmentContent.kind {
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

        case .link:
            return L10n.Composer.Quoted.file

        case .audio:
            return L10n.Composer.Quoted.audio

        case .none:
            return ""
        }
    }
    
    /// The icon for the subtitle, if applicable.
    /// Returns nil if no icon should be shown.
    public var subtitleIcon: QuotedMessageAttachmentPreviewIcon? {
        switch attachmentContent.kind {
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

    private func formattedDuration(_ duration: TimeInterval) -> String? {
        utils.videoDurationFormatter.format(duration)
    }
}
