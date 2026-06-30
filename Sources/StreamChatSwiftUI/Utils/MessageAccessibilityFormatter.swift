//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// A formatter that builds the VoiceOver labels used across the message list
/// (message bubbles, media attachments and voice recordings).
///
/// It centralizes the pieces that are shared between those labels - the sender
/// name, the sent time and a spoken duration - so that every content type
/// announces them consistently.
@MainActor open class MessageAccessibilityFormatter {
    @Injected(\.utils) private var utils

    private let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .full
        return formatter
    }()

    public init() {}

    // MARK: - Building blocks

    /// The sender prefix announced for the message: a localized "You" for the
    /// current user's messages, otherwise the author's display name.
    open func senderName(for message: ChatMessage) -> String {
        if message.isSentByCurrentUser {
            return L10n.Message.Accessibility.you
        }
        return authorName(for: message)
    }

    /// The author's display name, falling back to the author id.
    open func authorName(for message: ChatMessage) -> String {
        message.author.name ?? message.author.id
    }

    /// The spoken sent time for the message (e.g. "18:45").
    open func sentTime(for message: ChatMessage) -> String {
        utils.dateFormatter.string(from: message.createdAt)
    }

    /// A spoken duration (e.g. "1 minute, 5 seconds"), or `nil` when unavailable.
    open func duration(from seconds: TimeInterval) -> String? {
        durationFormatter.string(from: seconds)
    }

    // MARK: - Attachment labels

    /// The VoiceOver label for a video attachment.
    open func videoLabel(
        for message: ChatMessage,
        metadata: VideoAttachmentAccessibilityMetadata
    ) -> String {
        let time = sentTime(for: message)
        let description: String
        if message.isSentByCurrentUser {
            if let duration = metadata.duration {
                description = metadata.includesTimestamp
                    ? L10n.Message.Accessibility.videoOwnWithDuration(duration, time)
                    : L10n.Message.Accessibility.videoOwnWithDurationWithoutTimestamp(duration)
            } else {
                description = metadata.includesTimestamp
                    ? L10n.Message.Accessibility.videoOwn(time)
                    : L10n.Message.Accessibility.videoOwnWithoutTimestamp
            }
        } else {
            let sender = authorName(for: message)
            if let duration = metadata.duration {
                description = metadata.includesTimestamp
                    ? L10n.Message.Accessibility.videoWithDuration(duration, sender, time)
                    : L10n.Message.Accessibility.videoWithDurationWithoutTimestamp(duration, sender)
            } else {
                description = metadata.includesTimestamp
                    ? L10n.Message.Accessibility.video(sender, time)
                    : L10n.Message.Accessibility.videoWithoutTimestamp(sender)
            }
        }
        return prefixingAttachmentNumber(metadata.attachmentNumber, to: description)
    }

    /// The VoiceOver label for an image attachment.
    open func imageLabel(
        for message: ChatMessage,
        metadata: ImageAttachmentAccessibilityMetadata
    ) -> String {
        let time = sentTime(for: message)
        let description: String
        if message.isSentByCurrentUser {
            description = metadata.includesTimestamp
                ? L10n.Message.Accessibility.imageOwn(time)
                : L10n.Message.Accessibility.imageOwnWithoutTimestamp
        } else {
            let sender = authorName(for: message)
            description = metadata.includesTimestamp
                ? L10n.Message.Accessibility.image(sender, time)
                : L10n.Message.Accessibility.imageWithoutTimestamp(sender)
        }
        return prefixingAttachmentNumber(metadata.attachmentNumber, to: description)
    }

    /// The VoiceOver label for a voice recording attachment.
    open func voiceRecordingLabel(
        for message: ChatMessage,
        metadata: VoiceRecordingAccessibilityMetadata
    ) -> String {
        let time = sentTime(for: message)
        guard let duration = metadata.duration else {
            return message.isSentByCurrentUser
                ? L10n.Message.Accessibility.voiceRecordingOwnWithoutDuration(time)
                : L10n.Message.Accessibility.voiceRecordingWithoutDuration(authorName(for: message), time)
        }
        if message.isSentByCurrentUser {
            return L10n.Message.Accessibility.voiceRecordingOwn(duration, time)
        }
        return L10n.Message.Accessibility.voiceRecording(authorName(for: message), duration, time)
    }

    /// Prepends the spoken attachment number to a label, e.g.
    /// "Attachment 1. Video from …".
    private func prefixingAttachmentNumber(_ number: Int, to label: String) -> String {
        "\(L10n.Message.Attachment.accessibilityLabel(number)). \(label)"
    }
}

// MARK: - Attachment Accessibility Metadata

/// Metadata for building a VoiceOver label for a video attachment.
public struct VideoAttachmentAccessibilityMetadata {
    /// The 1-based position of the attachment within the message.
    public var attachmentNumber: Int
    /// An already-formatted spoken duration (e.g. "1 minute, 5 seconds"), if available.
    public var duration: String?
    /// Whether the sent time should be included. Pass `false` when the message
    /// has a caption that already announces the timestamp.
    public var includesTimestamp: Bool

    public init(
        attachmentNumber: Int,
        duration: String? = nil,
        includesTimestamp: Bool = true
    ) {
        self.attachmentNumber = attachmentNumber
        self.duration = duration
        self.includesTimestamp = includesTimestamp
    }
}

/// Metadata for building a VoiceOver label for an image attachment.
public struct ImageAttachmentAccessibilityMetadata {
    /// The 1-based position of the attachment within the message.
    public var attachmentNumber: Int
    /// Whether the sent time should be included. Pass `false` when the message
    /// has a caption that already announces the timestamp.
    public var includesTimestamp: Bool

    public init(
        attachmentNumber: Int,
        includesTimestamp: Bool = true
    ) {
        self.attachmentNumber = attachmentNumber
        self.includesTimestamp = includesTimestamp
    }
}

/// Metadata for building a VoiceOver label for a voice recording attachment.
public struct VoiceRecordingAccessibilityMetadata {
    /// An already-formatted spoken duration (e.g. "1 minute, 5 seconds"), if available.
    public var duration: String?

    public init(duration: String? = nil) {
        self.duration = duration
    }
}
