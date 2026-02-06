//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// A view model that provides display data for an edited message.
///
/// This view model has a fixed title of "Edit Message" and always indicates
/// the message is from the current user.
@MainActor
open class EditedMessageViewModel {
    // MARK: - Properties
    
    /// The edited message.
    private let message: ChatMessage

    /// The resolved attachment preview data (lazily computed once).
    private lazy var attachmentPreviewResolver: MessageAttachmentPreviewResolver = {
        MessageAttachmentPreviewResolver(message: message)
    }()

    // MARK: - Init
    
    /// Creates a new edited message view model.
    /// - Parameter message: The message being edited.
    public init(message: ChatMessage) {
        self.message = message
    }
    
    // MARK: - Display Properties
    
    /// The title text displayed at the top.
    open var title: String {
        L10n.Composer.Title.edit
    }
    
    /// Whether the referenced message was sent by the current user.
    /// Always returns `true` for edited messages since you can only edit your own messages.
    open var isSentByCurrentUser: Bool {
        true
    }
    
    /// The subtitle text to display (message preview or attachment description).
    open var subtitle: String {
        // If there's text content, use it.
        if !messageText.isEmpty {
            return messageText
        }

        // Otherwise, use the attachment preview description.
        return attachmentPreviewResolver.previewDescription ?? messageText
    }
    
    /// The icon for the subtitle, if applicable.
    /// Returns nil if no icon should be shown.
    open var subtitleIcon: MessageAttachmentPreviewIcon? {
        attachmentPreviewResolver.previewIcon
    }
    
    /// The thumbnail for the attachment preview, if available.
    open var thumbnail: MessageAttachmentPreviewThumbnail? {
        attachmentPreviewResolver.previewThumbnail
    }

    // MARK: - Private Helpers
    
    private var messageText: String {
        message.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
