//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

extension ChatClient {
    /// The maximum attachment size for the file URL.
    ///
    /// The max attachment size can be set from the Stream's Dashboard App Settings.
    ///
    /// - Parameter fileURL: The file URL of the attachment.
    /// - Returns: The maximum allowed size for the attachment in bytes.
    func maxAttachmentSize(for fileURL: URL) -> Int64 {
        let attachmentType = AttachmentType(fileExtension: fileURL.pathExtension)
        let maxAttachmentSize: Int64?
        switch attachmentType {
        case .image:
            maxAttachmentSize = appSettings?.imageUploadConfig.sizeLimitInBytes
        default:
            maxAttachmentSize = appSettings?.fileUploadConfig.sizeLimitInBytes
        }
        if let maxAttachmentSize, maxAttachmentSize > 0 {
            return maxAttachmentSize
        } else {
            return config.maxAttachmentSize
        }
    }
}
