//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

public final class MediaAttachment: Identifiable, Equatable, Sendable {
    public let url: URL
    public let type: MediaAttachmentType
    public let uploadingState: AttachmentUploadingState?
    public let originalWidth: Double?
    public let originalHeight: Double?
    let videoAttachment: ChatMessageVideoAttachment?

    public init(
        url: URL,
        type: MediaAttachmentType,
        uploadingState: AttachmentUploadingState? = nil,
        originalWidth: Double? = nil,
        originalHeight: Double? = nil,
        videoAttachment: ChatMessageVideoAttachment? = nil
    ) {
        self.url = url
        self.type = type
        self.uploadingState = uploadingState
        self.originalWidth = originalWidth
        self.originalHeight = originalHeight
        self.videoAttachment = videoAttachment
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
            let imageResize: ImageResize? = resize ? ImageResize(preferredSize) : nil
            utils.mediaLoader.loadImage(
                url: url,
                options: ImageLoadOptions(resize: imageResize)
            ) { result in
                completion(result.map(\.image))
            }
        } else if type == .video {
            guard let videoAttachment else {
                log.warning("Missing videoAttachment for .video MediaAttachment, skipping thumbnail generation")
                completion(.failure(ClientError("Missing videoAttachment for .video MediaAttachment")))
                return
            }
            utils.mediaLoader.loadVideoPreview(
                with: videoAttachment
            ) { result in
                completion(result.map(\.image))
            }
        }
    }

    public static func == (lhs: MediaAttachment, rhs: MediaAttachment) -> Bool {
        lhs.url == rhs.url
            && lhs.type == rhs.type
            && lhs.uploadingState == rhs.uploadingState
            && lhs.originalWidth == rhs.originalWidth
            && lhs.originalHeight == rhs.originalHeight
            && lhs.videoAttachment?.id == rhs.videoAttachment?.id
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
            originalHeight: attachment.originalHeight,
            videoAttachment: attachment
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
