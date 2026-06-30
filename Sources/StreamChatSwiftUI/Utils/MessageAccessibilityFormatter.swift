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
    /// - Parameters:
    ///   - message: The message the attachment belongs to.
    ///   - attachmentNumber: The 1-based position of the attachment within the
    ///     message, announced so users can tell multiple attachments apart.
    ///   - duration: An already-formatted spoken duration, if available.
    ///   - includesTimestamp: Whether the sent time should be announced. Pass
    ///     `false` when the message has a caption that already announces it.
    open func videoLabel(
        for message: ChatMessage,
        attachmentNumber: Int,
        duration: String?,
        includesTimestamp: Bool
    ) -> String {
        let time = sentTime(for: message)
        let description: String
        if message.isSentByCurrentUser {
            if let duration {
                description = includesTimestamp
                    ? L10n.Message.Accessibility.videoOwnWithDuration(duration, time)
                    : L10n.Message.Accessibility.videoOwnWithDurationWithoutTimestamp(duration)
            } else {
                description = includesTimestamp
                    ? L10n.Message.Accessibility.videoOwn(time)
                    : L10n.Message.Accessibility.videoOwnWithoutTimestamp
            }
        } else {
            let sender = authorName(for: message)
            if let duration {
                description = includesTimestamp
                    ? L10n.Message.Accessibility.videoWithDuration(duration, sender, time)
                    : L10n.Message.Accessibility.videoWithDurationWithoutTimestamp(duration, sender)
            } else {
                description = includesTimestamp
                    ? L10n.Message.Accessibility.video(sender, time)
                    : L10n.Message.Accessibility.videoWithoutTimestamp(sender)
            }
        }
        return prefixingAttachmentNumber(attachmentNumber, to: description)
    }

    /// The VoiceOver label for an image attachment.
    /// - Parameters:
    ///   - message: The message the attachment belongs to.
    ///   - attachmentNumber: The 1-based position of the attachment within the
    ///     message, announced so users can tell multiple attachments apart.
    ///   - includesTimestamp: Whether the sent time should be announced. Pass
    ///     `false` when the message has a caption that already announces it.
    open func imageLabel(
        for message: ChatMessage,
        attachmentNumber: Int,
        includesTimestamp: Bool
    ) -> String {
        let time = sentTime(for: message)
        let description: String
        if message.isSentByCurrentUser {
            description = includesTimestamp
                ? L10n.Message.Accessibility.imageOwn(time)
                : L10n.Message.Accessibility.imageOwnWithoutTimestamp
        } else {
            let sender = authorName(for: message)
            description = includesTimestamp
                ? L10n.Message.Accessibility.image(sender, time)
                : L10n.Message.Accessibility.imageWithoutTimestamp(sender)
        }
        return prefixingAttachmentNumber(attachmentNumber, to: description)
    }

    /// Prepends the spoken attachment number to a label, e.g.
    /// "Attachment 1. Video from …".
    private func prefixingAttachmentNumber(_ number: Int, to label: String) -> String {
        "\(L10n.Message.Attachment.accessibilityLabel(number)). \(label)"
    }

    /// The VoiceOver label for a voice recording attachment.
    open func voiceRecordingLabel(for message: ChatMessage, duration: String?) -> String {
        let time = sentTime(for: message)
        guard let duration else {
            return message.isSentByCurrentUser
                ? L10n.Message.Accessibility.voiceRecordingOwnWithoutDuration(time)
                : L10n.Message.Accessibility.voiceRecordingWithoutDuration(authorName(for: message), time)
        }
        if message.isSentByCurrentUser {
            return L10n.Message.Accessibility.voiceRecordingOwn(duration, time)
        }
        return L10n.Message.Accessibility.voiceRecording(authorName(for: message), duration, time)
    }
}
