//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation

/// Represents the kind of attachment content that can be displayed in a message preview.
public enum MessageAttachmentPreviewKind: Equatable {
    /// Multiple different attachment types.
    case mixed(attachmentsCount: Int)
    /// A poll attachment.
    case poll(name: String)
    /// A voice recording attachment.
    case voiceRecording(duration: TimeInterval?)
    /// One or more photo attachments.
    case photo(count: Int)
    /// One or more video attachments.
    case video(count: Int)
    /// One or more file attachments.
    case file(count: Int, fileName: String?)
    /// A link attachment.
    case link
    /// An audio attachment.
    case audio
    /// No attachments.
    case none
}
