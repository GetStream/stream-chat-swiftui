//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI
import UIKit

/// Represents the icon to display in a reference message subtitle.
/// Used by both quoted messages and edited messages.
public struct MessageAttachmentPreviewIcon: Equatable, Sendable {
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
}
