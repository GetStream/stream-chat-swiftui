//
// Copyright © 2026 Stream.io Inc. All rights reserved.
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
    public var maxGalleryAssetsCount: Int?
    public var adjustMessageOnSend: (String) -> (String)
    public var adjustMessageOnRead: (String) -> (String)

    public init(
        isVoiceRecordingEnabled: Bool = false,
        inputViewMinHeight: CGFloat = 40,
        inputViewMaxHeight: CGFloat = 120,
        inputViewCornerRadius: CGFloat = 20,
        inputFont: UIFont = UIFont.preferredFont(forTextStyle: .body),
        gallerySupportedTypes: GallerySupportedTypes = .imagesAndVideo,
        maxGalleryAssetsCount: Int? = nil,
        adjustMessageOnSend: @escaping (String) -> (String) = { $0 },
        adjustMessageOnRead: @escaping (String) -> (String) = { $0 }
    ) {
        self.inputViewMinHeight = inputViewMinHeight
        self.inputViewMaxHeight = inputViewMaxHeight
        self.inputViewCornerRadius = inputViewCornerRadius
        self.inputFont = inputFont
        self.adjustMessageOnSend = adjustMessageOnSend
        self.adjustMessageOnRead = adjustMessageOnRead
        self.gallerySupportedTypes = gallerySupportedTypes
        self.maxGalleryAssetsCount = maxGalleryAssetsCount
        self.isVoiceRecordingEnabled = isVoiceRecordingEnabled
    }
}

public enum GallerySupportedTypes {
    case imagesAndVideo
    case images
    case videos
}
