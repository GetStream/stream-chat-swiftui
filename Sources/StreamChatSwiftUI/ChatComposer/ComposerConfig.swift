//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

/// Config for customizing the composer.
public final class ComposerConfig {
    public var isVoiceRecordingEnabled: Bool

    /// When enabled, releasing a hold-to-record gesture sends the voice message
    /// immediately. When disabled (default), the recording is added to the
    /// composer's attachment preview so the user can review before sending.
    public var isVoiceRecordingAutoSendEnabled: Bool

    public var inputViewMinHeight: CGFloat
    public var inputViewMaxHeight: CGFloat
    public var inputViewCornerRadius: CGFloat
    public var inputFont: UIFont
    public var gallerySupportedTypes: GallerySupportedTypes
    public var maxGalleryAssetsCount: Int?
    public var adjustMessageOnSend: (String) -> (String)
    public var adjustMessageOnRead: (String) -> (String)

    /// The fallback maximum attachment size in bytes when the server does not provide one.
    /// The default value is 100 MB.
    public var maxAttachmentSize: Int64

    /// Shared configuration for @mention suggestions (provider, roles, search scope).
    public var mentionSuggestionsConfig: MentionSuggestionsConfig

    public init(
        isVoiceRecordingEnabled: Bool = true,
        isVoiceRecordingAutoSendEnabled: Bool = false,
        inputViewMinHeight: CGFloat = 40,
        inputViewMaxHeight: CGFloat = 120,
        inputViewCornerRadius: CGFloat = 20,
        inputFont: UIFont = UIFont.preferredFont(forTextStyle: .body),
        gallerySupportedTypes: GallerySupportedTypes = .imagesAndVideo,
        maxGalleryAssetsCount: Int? = nil,
        adjustMessageOnSend: @escaping (String) -> (String) = { $0 },
        adjustMessageOnRead: @escaping (String) -> (String) = { $0 },
        maxAttachmentSize: Int64 = 100 * 1024 * 1024,
        mentionSuggestionsConfig: MentionSuggestionsConfig = MentionSuggestionsConfig()
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
        self.isVoiceRecordingAutoSendEnabled = isVoiceRecordingAutoSendEnabled
        self.maxAttachmentSize = maxAttachmentSize
        self.mentionSuggestionsConfig = mentionSuggestionsConfig
    }
}

public enum GallerySupportedTypes {
    case imagesAndVideo
    case images
    case videos
}
