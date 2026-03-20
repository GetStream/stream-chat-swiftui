//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public final class MediaAttachment: Identifiable, Equatable, Sendable {
    public let url: URL
    public let type: MediaAttachmentType
    public let uploadingState: AttachmentUploadingState?
    public let originalWidth: Double?
    public let originalHeight: Double?

    public init(
        url: URL,
        type: MediaAttachmentType,
        uploadingState: AttachmentUploadingState? = nil,
        originalWidth: Double? = nil,
        originalHeight: Double? = nil
    ) {
        self.url = url
        self.type = type
        self.uploadingState = uploadingState
        self.originalWidth = originalWidth
        self.originalHeight = originalHeight
    }

    public var id: String {
        url.absoluteString
    }

    @MainActor func generateThumbnail(
        resize: Bool,
        preferredSize: CGSize,
        completion: @escaping @MainActor (Result<UIImage, Error>) -> Void
    ) {
        let utils = InjectedValues[\.utils]
        if type == .image {
            utils.imageLoader.loadImage(
                url: url,
                imageCDN: utils.imageCDN,
                resize: resize,
                preferredSize: preferredSize,
                completion: completion
            )
        } else if type == .video {
            utils.videoPreviewLoader.loadPreviewForVideo(
                at: url,
                completion: completion
            )
        }
    }

    public static func == (lhs: MediaAttachment, rhs: MediaAttachment) -> Bool {
        lhs.url == rhs.url
            && lhs.type == rhs.type
            && lhs.uploadingState == rhs.uploadingState
            && lhs.originalWidth == rhs.originalWidth
            && lhs.originalHeight == rhs.originalHeight
    }
}

extension MediaAttachment {
    convenience init(from attachment: ChatMessageImageAttachment) {
        let url: URL
        if let state = attachment.uploadingState {
            url = state.localFileURL
        } else {
            url = attachment.imageURL
        }
        self.init(
            url: url,
            type: .image,
            uploadingState: attachment.uploadingState,
            originalWidth: attachment.originalWidth,
            originalHeight: attachment.originalHeight
        )
    }

    convenience init(from attachment: ChatMessageVideoAttachment) {
        let url: URL
        if let state = attachment.uploadingState {
            url = state.localFileURL
        } else {
            url = attachment.videoURL
        }
        self.init(
            url: url,
            type: .video,
            uploadingState: attachment.uploadingState,
            originalWidth: attachment.originalWidth,
            originalHeight: attachment.originalHeight
        )
    }

    /// Image and video attachments in the same order as ``ChatMessage/allAttachments``.
    static func galleryOrdered(from message: ChatMessage) -> [MediaAttachment] {
        message.allAttachments.compactMap { attachment -> MediaAttachment? in
            if let image = attachment.attachment(payloadType: ImageAttachmentPayload.self) {
                return MediaAttachment(from: image)
            }
            if let video = attachment.attachment(payloadType: VideoAttachmentPayload.self) {
                return MediaAttachment(from: video)
            }
            return nil
        }
    }
}

public final class MediaAttachmentType: RawRepresentable, Sendable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let image = MediaAttachmentType(rawValue: "image")
    public static let video = MediaAttachmentType(rawValue: "video")
}

extension ChatMessage {
    var alignmentInBubble: HorizontalAlignment {
        .leading
    }
}

/// Options for the gallery view.
public final class MediaViewsOptions: Sendable {
    /// The index of the selected media item.
    public let selectedIndex: Int

    public init(selectedIndex: Int) {
        self.selectedIndex = selectedIndex
    }
}
