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
    private lazy var attachmentPreviewContent: MessageAttachmentPreviewContent = {
        MessageAttachmentPreviewContent(message: message)
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

        // Otherwise, use the attachment content description.
        return attachmentPreviewContent.previewDescription
    }
    
    /// The icon for the subtitle, if applicable.
    /// Returns nil if no icon should be shown.
    open var subtitleIcon: MessageAttachmentPreviewIcon? {
        attachmentPreviewContent.previewIcon
    }
    
    // MARK: - Attachment Preview
    
    /// The URL for the attachment preview (image, video thumbnail, link, or file).
    open var previewURL: URL? {
        attachmentPreviewContent.previewURL
    }

    // MARK: - Private Helpers
    
    private var messageText: String {
        message.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
