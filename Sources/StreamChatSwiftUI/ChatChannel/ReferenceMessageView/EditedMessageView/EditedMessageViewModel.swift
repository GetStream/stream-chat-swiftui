//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// A view model that provides display data for an edited message.
///
/// This view model shares the same subtitle and icon logic as `QuotedMessageViewModel`,
/// but the title is always "Edit Message" instead of "Reply to [Author]".
@MainActor
open class EditedMessageViewModel {
    @Injected(\.utils) private var utils

    // MARK: - Properties
    
    /// The edited message.
    private let message: ChatMessage

    /// The resolved attachment content (lazily computed once).
    public lazy var attachmentPreviewContent: MessageAttachmentPreviewContent = {
        MessageAttachmentPreviewContent.resolve(from: message)
    }()

    // MARK: - Init
    
    /// Creates a new edited message view model.
    /// - Parameters:
    ///   - message: The message being edited.
    public init(
        message: ChatMessage
    ) {
        self.message = message
    }
    
    // MARK: - Display Properties
    
    /// The title text displayed at the top (always "Edit Message").
    open var title: String {
        L10n.Composer.Title.edit
    }
    
    /// The subtitle text to display (message preview or attachment description).
    open var subtitle: String {
        // If there's text content, use it.
        if !messageText.isEmpty {
            return messageText
        }

        // Otherwise, use the attachment content subtitle.
        return attachmentPreviewContent.subtitle
    }
    
    /// The icon for the subtitle, if applicable.
    /// Returns nil if no icon should be shown.
    open var subtitleIcon: MessageAttachmentPreviewIcon? {
        attachmentPreviewContent.subtitleIcon
    }
    
    // MARK: - Attachment Preview
    
    /// The URL for the image attachment preview, if available.
    open var imagePreviewURL: URL? {
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
    open var videoThumbnailURL: URL? {
        message.videoAttachments.first?.thumbnailURL
    }
    
    /// The file extension for file previews, if available.
    open var fileExtension: String? {
        message.fileAttachments.first?.assetURL.pathExtension.lowercased()
    }

    // MARK: - Private Helpers
    
    private var messageText: String {
        message.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
