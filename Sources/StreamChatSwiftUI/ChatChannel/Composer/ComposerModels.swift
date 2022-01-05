//
// Copyright © 2022 Stream.io Inc. All rights reserved.
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
public struct AddedAsset: Identifiable {
    public let image: UIImage
    public let id: String
    public let url: URL
    public let type: AssetType
    public var extraData: [String: Any] = [:]
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
