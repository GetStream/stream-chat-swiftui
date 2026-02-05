//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// A view model that provides display data for an edited message.
///
/// This view model is simpler than `QuotedMessageViewModel` since the title
/// is always "Edit Message" and doesn't depend on the message author.
@MainActor
open class EditedMessageViewModel {
    @Injected(\.utils) private var utils

    // MARK: - Properties
    
    /// The edited message.
    private let message: ChatMessage

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
    
    /// The title text displayed at the top.
    open var title: String {
        L10n.Composer.Title.edit
    }
    
    /// The subtitle text to display, by default it is the original message text.
    open var subtitle: String {
        // If there's text content, use it.
        if !messageText.isEmpty {
            return messageText
        }

        if !message.attachmentCounts.isEmpty {
            let totalAttachmentCount = message.attachmentCounts.values.reduce(0, +)
            return L10n.Composer.Quoted.files(totalAttachmentCount)
        }

        return ""
    }
    
    /// The icon for the subtitle, if it has any attachment.
    open var subtitleIcon: EditedMessageAttachmentPreviewIcon? {
        // If message has a link, return link icon
        if !message.linkAttachments.isEmpty {
            return .link
        }
        
        // If message has any attachment, return file icon
        if !message.attachmentCounts.isEmpty {
            return .file
        }
        
        return nil
    }

    // MARK: - Private Helpers
    
    private var messageText: String {
        return message.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
