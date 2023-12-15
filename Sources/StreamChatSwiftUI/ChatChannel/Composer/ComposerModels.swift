//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Enum describing the attachment picker's state.
public enum AttachmentPickerState {
    case files
    case photos
    case camera
    case custom
}

/// Struct representing an asset added to the composer.
public struct AddedAsset: Identifiable, Equatable {
    
    public static func == (lhs: AddedAsset, rhs: AddedAsset) -> Bool {
        lhs.id == rhs.id
    }
    
    public let image: UIImage
    public let id: String
    public let url: URL
    public let type: AssetType
    public var extraData: [String: RawJSON] = [:]
    
    public init(
        image: UIImage,
        id: String,
        url: URL,
        type: AssetType,
        extraData: [String: RawJSON] = [:]
    ) {
        self.image = image
        self.id = id
        self.url = url
        self.type = type
        self.extraData = extraData
    }
}

extension AddedAsset {
    func toAttachmentPayload() throws -> AnyAttachmentPayload {
        try AnyAttachmentPayload(
            localFileURL: url,
            attachmentType: type == .video ? .video : .image,
            extraData: extraData
        )
    }
}

/// Type of asset added to the composer.
public enum AssetType {
    case image
    case video
}

public struct CustomAttachment: Identifiable, Equatable {
    
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

public struct AddedVoiceRecording: Identifiable, Equatable {
    public var id: String {
        url.absoluteString
    }
    
    public let url: URL
    public let duration: TimeInterval
    public let waveform: [Float]
}
