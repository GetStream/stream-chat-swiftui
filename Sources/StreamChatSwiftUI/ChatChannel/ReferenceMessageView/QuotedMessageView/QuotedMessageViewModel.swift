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

    /// The current logged-in user.
    private let currentUser: CurrentChatUser?

    /// The resolved attachment content (lazily computed once).
    public lazy var attachmentPreviewContent: MessageAttachmentPreviewContent = {
        MessageAttachmentPreviewContent.resolve(from: message)
    }()

    // MARK: - Init
    
    /// Creates a new quoted message view model.
    /// - Parameter message: The quoted message to display.
    ///
    public init(
        message: ChatMessage,
        currentUser: CurrentChatUser?
    ) {
        self.message = message
        self.currentUser = currentUser
    }
    
    // MARK: - Display Properties
    
    /// The title text displayed at the top (e.g., "Reply to Emma Chen").
    open var title: String {
        L10n.Composer.Quoted.replyTo(authorName)
    }
    
    /// The author's display name.
    open var authorName: String {
        message.author.name ?? message.author.id
    }
    
    /// Whether the message was sent by the current user.
    open var isSentByCurrentUser: Bool {
        message.isSentByCurrentUser
    }
    
    /// The message ID for scroll navigation.
    open var messageId: String {
        message.messageId
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
        if message.isDeleted {
            return L10n.Message.deletedMessagePlaceholder
        }

        if let language = currentUser?.language,
           let translatedText = message.translatedText(for: language) {
            return translatedText
        }

        return message.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
