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

    // MARK: - Voice recording label

    /// The VoiceOver label for a voice recording attachment.
    open func voiceRecordingLabel(for message: ChatMessage, duration: String?) -> String {
        let time = sentTime(for: message)
        let durationText = duration ?? ""
        if message.isSentByCurrentUser {
            return L10n.Message.Accessibility.voiceRecordingOwn(durationText, time)
        }
        return L10n.Message.Accessibility.voiceRecording(authorName(for: message), durationText, time)
    }
}
