//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// A protocol that defines the common interface for message reference view models.
///
/// Both `QuotedMessageViewModel` and `EditedMessageViewModel` conform to this protocol,
/// allowing them to be used interchangeably in views that display message references.
@MainActor
public protocol ReferenceMessageViewModel: AnyObject {
    /// The title text displayed at the top.
    var title: String { get }
    
    /// The subtitle text to display (message preview or attachment description).
    var subtitle: String { get }
    
    /// The icon for the subtitle, if applicable.
    var subtitleIcon: MessageAttachmentPreviewIcon? { get }
    
    /// The thumbnail for the attachment preview, if available.
    var thumbnail: MessageAttachmentPreviewThumbnail? { get }
    
    /// Whether the referenced message was sent by the current user.
    var isSentByCurrentUser: Bool { get }
}
