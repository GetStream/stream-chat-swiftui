//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Config for customizing the composer.
public struct ComposerConfig {

    public var inputViewMinHeight: CGFloat
    public var inputViewMaxHeight: CGFloat
    public var inputViewCornerRadius: CGFloat
    public var inputFont: UIFont
    public var adjustMessageOnSend: (String) -> (String)
    public var adjustMessageOnRead: (String) -> (String)
    public var attachmentPayloadConverter: (ChatMessage) -> [AnyAttachmentPayload]

    public init(
        inputViewMinHeight: CGFloat = 38,
        inputViewMaxHeight: CGFloat = 76,
        inputViewCornerRadius: CGFloat = 20,
        inputFont: UIFont = UIFont.preferredFont(forTextStyle: .body),
        adjustMessageOnSend: @escaping (String) -> (String) = { $0 },
        adjustMessageOnRead: @escaping (String) -> (String) = { $0 },
        attachmentPayloadConverter: @escaping (ChatMessage) -> [AnyAttachmentPayload] = ComposerConfig.defaultAttachmentPayloadConverter
    ) {
        self.inputViewMinHeight = inputViewMinHeight
        self.inputViewMaxHeight = inputViewMaxHeight
        self.inputViewCornerRadius = inputViewCornerRadius
        self.inputFont = inputFont
        self.adjustMessageOnSend = adjustMessageOnSend
        self.adjustMessageOnRead = adjustMessageOnRead
        self.attachmentPayloadConverter = attachmentPayloadConverter
    }
    
    public static var defaultAttachmentPayloadConverter: (ChatMessage) -> [AnyAttachmentPayload] = { message in
        message.allAttachments.toAnyAttachmentPayload()
    }
}
