//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import AVFoundation
import StreamChat
import SwiftUI

/// Enum describing the attachment picker's state.
public enum AttachmentPickerState {
    case files
    case photos
    case camera
    case polls
    case custom
}

/// Struct representing an asset added to the composer.
public struct AddedAsset: Identifiable, Equatable, Sendable {
    public static func == (lhs: AddedAsset, rhs: AddedAsset) -> Bool {
        lhs.id == rhs.id
    }
    
    public let image: UIImage
    public let id: String
    public let url: URL
    public let type: AssetType
    public var extraData: [String: RawJSON] = [:]

    /// The payload of the attachment, in case the attachment has been uploaded to server already.
    /// This is mostly used when editing an existing message that contains attachments.
    public var payload: AttachmentPayload?

    public init(
        image: UIImage,
        id: String,
        url: URL,
        type: AssetType,
        extraData: [String: RawJSON] = [:],
        payload: AttachmentPayload? = nil
    ) {
        self.image = image
        self.id = id
        self.url = url
        self.type = type
        self.extraData = extraData
        self.payload = payload
    }
}

extension AddedAsset {
    func toAttachmentPayload() throws -> AnyAttachmentPayload {
        if let payload = self.payload {
            return AnyAttachmentPayload(payload: payload)
        }
        return try AnyAttachmentPayload(
            localFileURL: url,
            attachmentType: type == .video ? .video : .image,
            extraData: extraData
        )
    }
}

extension AnyChatMessageAttachment {
    func toAddedAsset() -> AddedAsset? {
        if let imageAttachment = attachment(payloadType: ImageAttachmentPayload.self),
           let imageData = try? Data(contentsOf: imageAttachment.imageURL),
           let image = UIImage(data: imageData) {
            return AddedAsset(
                image: image,
                id: imageAttachment.id.rawValue,
                url: imageAttachment.imageURL,
                type: .image,
                extraData: imageAttachment.extraData ?? [:],
                payload: imageAttachment.payload
            )
        } else if let videoAttachment = attachment(payloadType: VideoAttachmentPayload.self),
                  let thumbnail = imageThumbnail(for: videoAttachment.payload) {
            return AddedAsset(
                image: thumbnail,
                id: videoAttachment.id.rawValue,
                url: videoAttachment.videoURL,
                type: .video,
                extraData: videoAttachment.extraData ?? [:],
                payload: videoAttachment.payload
            )
        }
        return nil
    }

    private func imageThumbnail(for videoAttachmentPayload: VideoAttachmentPayload) -> UIImage? {
        if let thumbnailURL = videoAttachmentPayload.thumbnailURL, let data = try? Data(contentsOf: thumbnailURL) {
            return UIImage(data: data)
        }
        let asset = AVURLAsset(url: videoAttachmentPayload.videoURL, options: nil)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        guard let cgImage = try? imageGenerator.copyCGImage(
            at: CMTimeMake(value: 0, timescale: 1),
            actualTime: nil
        ) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}

/// Type of asset added to the composer.
public enum AssetType: Sendable {
    case image
    case video
}

public struct CustomAttachment: Identifiable, Equatable, Sendable {
    public static func == (lhs: CustomAttachment, rhs: CustomAttachment) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id: String
    public let content: AnyAttachmentPayload
    
    public init(id: String, content: AnyAttachmentPayload) {
        self.id = id
        self.content = content
    }
}

/// Represents an added voice recording.
public struct AddedVoiceRecording: Identifiable, Equatable, Sendable {
    public var id: String {
        url.absoluteString
    }
    
    /// The URL of the recording.
    public let url: URL
    /// The duration of the recording.
    public let duration: TimeInterval
    /// The waveform of the recording.
    public let waveform: [Float]
    
    public init(url: URL, duration: TimeInterval, waveform: [Float]) {
        self.url = url
        self.duration = duration
        self.waveform = waveform
    }
}

extension AnyChatMessageAttachment {
    func toAddedVoiceRecording() -> AddedVoiceRecording? {
        guard let voiceAttachment = attachment(payloadType: VoiceRecordingAttachmentPayload.self) else { return nil }
        guard let duration = voiceAttachment.duration else { return nil }
        guard let waveform = voiceAttachment.waveformData else { return nil }
        return AddedVoiceRecording(
            url: voiceAttachment.voiceRecordingURL,
            duration: duration,
            waveform: waveform
        )
    }
}
