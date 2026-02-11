//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A view that displays an attachment preview icon in a message.
public struct MessageAttachmentPreviewIconView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    /// The image representing the icon.
    public let iconImage: UIImage

    /// Creates a new attachment preview icon view.
    /// - Parameters:
    ///   - iconImage: The icon type to display.
    public init(
        iconImage: UIImage
    ) {
        self.iconImage = iconImage
    }

    public var body: some View {
        Image(uiImage: iconImage)
            .renderingMode(.template)
            .resizable()
            .foregroundColor(Color(colors.textPrimary))
            .aspectRatio(contentMode: .fit)
            .frame(
                width: tokens.iconSizeXs,
                height: tokens.iconSizeXs
            )
            .accessibilityHidden(true)
    }
}

@MainActor
public protocol MessageAttachmentPreviewIconProvider {
    func image(for icon: MessageAttachmentPreviewIcon) -> UIImage
}

@MainActor
public struct DefaultMessageAttachmentPreviewIconProvider: MessageAttachmentPreviewIconProvider {
    @Injected(\.images) var images

    public func image(for icon: MessageAttachmentPreviewIcon) -> UIImage {
        switch icon {
        case .poll:
            return images.attachmentPollIcon
        case .voiceRecording:
            return images.attachmentVoiceIcon
        case .photo:
            return images.attachmentPhotoIcon
        case .video:
            return images.attachmentVideoIcon
        case .link:
            return images.attachmentLinkIcon
        case .document, .audio, .mixed:
            return images.attachmentDocIcon
        default:
            return images.attachmentDocIcon
        }
    }
}
