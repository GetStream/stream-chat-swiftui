//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI
import UIKit

/// Represents the icon to display in an edited message subtitle.
@MainActor
public struct EditedMessageAttachmentPreviewIcon {
    @Injected(\.images) private var images

    /// The name identifying the icon type.
    public let name: String

    private init(name: String) {
        self.name = name
    }

    /// Icon for link attachments.
    public static var link: Self { .init(name: "link") }

    /// Icon for file/document attachments (used for all non-link attachments).
    public static var file: Self { .init(name: "file") }

    // MARK: - Image Resolution

    public var image: UIImage {
        switch name {
        case "link":
            return images.attachmentLinkIcon
        case "file":
            return images.attachmentDocIcon
        default:
            return images.attachmentDocIcon
        }
    }
}
