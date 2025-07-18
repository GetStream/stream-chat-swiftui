//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Config for customizing the composer.
public struct ComposerConfig {
    public var isVoiceRecordingEnabled: Bool
    public var inputViewMinHeight: CGFloat
    public var inputViewMaxHeight: CGFloat
    public var inputViewCornerRadius: CGFloat
    public var inputFont: UIFont
    public var gallerySupportedTypes: GallerySupportedTypes
    public var inputPaddingsConfig: PaddingsConfig
    public var adjustMessageOnSend: (String) -> (String)
    public var adjustMessageOnRead: (String) -> (String)

    @available(
        *,
        deprecated,
        message: """
        Override the MessageComposerViewModel.inputAttachmentsAsPayloads() in order to convert the message attachments to payloads.
        """
    )
    public var attachmentPayloadConverter: (ChatMessage) -> [AnyAttachmentPayload]

    public init(
        isVoiceRecordingEnabled: Bool = false,
        inputViewMinHeight: CGFloat = 38,
        inputViewMaxHeight: CGFloat = 76,
        inputViewCornerRadius: CGFloat = 20,
        inputFont: UIFont = UIFont.preferredFont(forTextStyle: .body),
        gallerySupportedTypes: GallerySupportedTypes = .imagesAndVideo,
        inputPaddingsConfig: PaddingsConfig = .composerInput,
        adjustMessageOnSend: @escaping (String) -> (String) = { $0 },
        adjustMessageOnRead: @escaping (String) -> (String) = { $0 },
        attachmentPayloadConverter: @escaping (ChatMessage) -> [AnyAttachmentPayload]
            = ComposerConfig.defaultAttachmentPayloadConverter
    ) {
        self.inputViewMinHeight = inputViewMinHeight
        self.inputViewMaxHeight = inputViewMaxHeight
        self.inputViewCornerRadius = inputViewCornerRadius
        self.inputFont = inputFont
        self.adjustMessageOnSend = adjustMessageOnSend
        self.adjustMessageOnRead = adjustMessageOnRead
        self.attachmentPayloadConverter = attachmentPayloadConverter
        self.gallerySupportedTypes = gallerySupportedTypes
        self.inputPaddingsConfig = inputPaddingsConfig
        self.isVoiceRecordingEnabled = isVoiceRecordingEnabled
    }
    
    public static var defaultAttachmentPayloadConverter: (ChatMessage) -> [AnyAttachmentPayload] = { _ in
        /// This now returns empty array by default since attachmentPayloadConverter has been deprecated.
        []
    }
}

public enum GallerySupportedTypes {
    case imagesAndVideo
    case images
    case videos
}

public struct PaddingsConfig {
    public let top: CGFloat
    public let bottom: CGFloat
    public let leading: CGFloat
    public let trailing: CGFloat
    
    public var horizontal: CGFloat {
        leading + trailing
    }
    
    public var vertical: CGFloat {
        top + bottom
    }
    
    public init(top: CGFloat, bottom: CGFloat, leading: CGFloat, trailing: CGFloat) {
        self.top = top
        self.bottom = bottom
        self.leading = leading
        self.trailing = trailing
    }
}

extension PaddingsConfig {
    public static let composerInput = PaddingsConfig(
        top: 4,
        bottom: 4,
        leading: 8,
        trailing: 0
    )
}
