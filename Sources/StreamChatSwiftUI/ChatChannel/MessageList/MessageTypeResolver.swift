//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// Resolves the message type, based on the message.
public protocol MessageTypeResolving {
    /// Checks whether the message is deleted.
    /// - Parameter message: the message being checked.
    /// - Returns: bool, whether the condition is satisfied.
    func isDeleted(message: ChatMessage) -> Bool

    /// Checks whether the message has image attachment.
    /// - Parameter message: the message being checked.
    /// - Returns: bool, whether the condition is satisfied.
    func hasImageAttachment(message: ChatMessage) -> Bool

    /// Checks whether the message has giphy attachment.
    /// - Parameter message: the message being checked.
    /// - Returns: bool, whether the condition is satisfied.
    func hasGiphyAttachment(message: ChatMessage) -> Bool

    /// Checks whether the message has video attachment.
    /// - Parameter message: the message being checked.
    /// - Returns: bool, whether the condition is satisfied.
    func hasVideoAttachment(message: ChatMessage) -> Bool

    /// Checks whether the message has link attachment.
    /// - Parameter message: the message being checked.
    /// - Returns: bool, whether the condition is satisfied.
    func hasLinkAttachment(message: ChatMessage) -> Bool

    /// Checks whether the message has file attachment.
    /// - Parameter message: the message being checked.
    /// - Returns: bool, whether the condition is satisfied.
    func hasFileAttachment(message: ChatMessage) -> Bool

    /// Checks whether the message has custom attachment.
    /// - Parameter message: the message being checked.
    /// - Returns: bool, whether the condition is satisfied.
    func hasCustomAttachment(message: ChatMessage) -> Bool
}

/// Default methods implementation of the `MessageTypeResolving` protocol.
extension MessageTypeResolving {
    public func isDeleted(message: ChatMessage) -> Bool {
        message.isDeleted
    }

    public func hasImageAttachment(message: ChatMessage) -> Bool {
        !message.imageAttachments.isEmpty
    }

    public func hasGiphyAttachment(message: ChatMessage) -> Bool {
        !message.giphyAttachments.isEmpty
    }

    public func hasVideoAttachment(message: ChatMessage) -> Bool {
        !message.videoAttachments.isEmpty
    }

    public func hasLinkAttachment(message: ChatMessage) -> Bool {
        message.allAttachments.contains(where: { attachment in
            attachment.type == .linkPreview
        })
    }

    public func hasFileAttachment(message: ChatMessage) -> Bool {
        !message.fileAttachments.isEmpty
    }

    public func hasCustomAttachment(message: ChatMessage) -> Bool {
        false
    }
}

/// Default class implementation of the `MessageTypeResolving` protocol.
public class MessageTypeResolver: MessageTypeResolving {
    public init() {
        // Public init.
    }
}
