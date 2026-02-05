//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// A view model that provides display data for a quoted message.
@MainActor
open class QuotedMessageViewModel: ReferenceMessageViewModel {
    // MARK: - Properties
    
    /// The quoted message.
    private let message: ChatMessage

    /// The current logged-in user.
    private let currentUser: CurrentChatUser?

    /// The resolved attachment preview data (lazily computed once).
    private lazy var attachmentPreviewResolver: MessageAttachmentPreviewResolver = {
        MessageAttachmentPreviewResolver(message: message)
    }()

    // MARK: - Init
    
    /// Creates a new quoted message view model.
    /// - Parameter message: The quoted message to display.
    public init(message: ChatMessage) {
        self.message = message
        self.currentUser = InjectedValues[\.chatClient].currentUserController().currentUser
    }
    
    /// Creates a new quoted message view model.
    /// - Parameters:
    ///   - message: The quoted message to display.
    ///   - currentUser: The current logged-in user (used for translations).
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

        // Otherwise, use the attachment preview description.
        return attachmentPreviewResolver.previewDescription ?? ""
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
