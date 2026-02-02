//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI
import UIKit

/// Represents the icon to display in a quoted message subtitle.
@MainActor
public struct QuotedMessageAttachmentPreviewIcon {
    @Injected(\.images) private var images

    /// The name identifying the icon type.
    public let name: String

    private init(name: String) {
        self.name = name
    }

    /// Icon for poll attachments.
    public static var poll: Self { .init(name: "poll") }

    /// Icon for voice recording attachments.
    public static var voiceRecording: Self { .init(name: "voiceRecording") }

    /// Icon for photo/image attachments.
    public static var photo: Self { .init(name: "photo") }

    /// Icon for video attachments.
    public static var video: Self { .init(name: "video") }

    /// Icon for document/file attachments.
    public static var document: Self { .init(name: "document") }

    /// Icon for link attachments.
    public static var link: Self { .init(name: "link") }

    /// Icon for audio attachments.
    public static var audio: Self { .init(name: "audio") }

    /// Icon for mixed attachments.
    public static var mixed: Self { .init(name: "mixed") }

    // MARK: - Image Resolution

    public var image: UIImage {
        switch name {
        case "poll":
            return images.attachmentPollIcon
        case "voiceRecording":
            return images.attachmentVoiceIcon
        case "photo":
            return images.attachmentPhotoIcon
        case "video":
            return images.attachmentVideoIcon
        case "link":
            return images.attachmentLinkIcon
        case "document", "audio", "mixed":
            return images.attachmentDocIcon
        default:
            return images.attachmentDocIcon
        }
    }
}
