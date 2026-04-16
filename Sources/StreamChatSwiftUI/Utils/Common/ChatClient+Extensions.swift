//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

extension ChatClient {
    /// The maximum attachment size for the file URL.
    ///
    /// The max attachment size can be set from the Stream's Dashboard App Settings.
    /// Falls back to the value configured in ``ComposerConfig/maxAttachmentSize``.
    ///
    /// - Parameters:
    ///   - fileURL: The file URL of the attachment.
    ///   - fallbackSize: The fallback size when the server doesn't provide one.
    /// - Returns: The maximum allowed size for the attachment in bytes.
    func maxAttachmentSize(for fileURL: URL, fallbackSize: Int64) -> Int64 {
        let attachmentType = AttachmentType(fileExtension: fileURL.pathExtension)
        let maxAttachmentSize: Int64? = switch attachmentType {
        case .image:
            appSettings?.imageUploadConfig.sizeLimitInBytes
        default:
            appSettings?.fileUploadConfig.sizeLimitInBytes
        }
        if let maxAttachmentSize, maxAttachmentSize > 0 {
            return maxAttachmentSize
        } else {
            return fallbackSize
        }
    }
}
