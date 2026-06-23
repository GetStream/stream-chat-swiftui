//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

public extension ChatMessage {
    /// A boolean value that checks if actions are available on the message (e.g. `edit`, `delete`, `resend`, etc.).
    var isInteractionEnabled: Bool {
        guard
            type != .ephemeral, type != .system,
            isDeleted == false
        else { return false }

        return localState == nil || isLastActionFailed
    }

    /// A boolean value that checks if the last action (`send`, `edit` or `delete`) on the message failed.
    var isLastActionFailed: Bool {
        guard isDeleted == false else {
            return false
        }

        if isBounced {
            return true
        }

        switch localState {
        case .sendingFailed, .syncingFailed, .deletingFailed:
            return true
        default:
            return false
        }
    }

    /// A boolean value that checks if the message is the root of a thread.
    var isRootOfThread: Bool {
        replyCount > 0
    }

    /// A boolean value that checks if the message is part of a thread.
    var isPartOfThread: Bool {
        parentMessageId != nil
    }

    /// The text which should be shown in a text view inside the message bubble.
    @MainActor var textContent: String? {
        guard type != .ephemeral else {
            return nil
        }

        return isDeleted ? L10n.Message.deletedMessagePlaceholder : adjustedText
    }
    
    func textContent(for translationLanguage: TranslationLanguage?) -> String? {
        guard let translationLanguage else { return nil }
        guard !isSentByCurrentUser, !isDeleted else { return nil }
        return translatedText(for: translationLanguage)
    }

    /// A boolean value that checks if the message is visible for current user only.
    var isOnlyVisibleForCurrentUser: Bool {
        guard isSentByCurrentUser else {
            return false
        }

        return isDeleted || type == .ephemeral
    }

    /// Returns last active thread participant.
    var lastActiveThreadParticipant: ChatUser? {
        func sortingCriteriaDate(_ user: ChatUser) -> Date {
            user.lastActiveAt ?? user.userUpdatedAt
        }

        return threadParticipants
            .sorted(by: { sortingCriteriaDate($0) > sortingCriteriaDate($1) })
            .first
    }

    /// A boolean value that says if the message is deleted.
    var isDeleted: Bool {
        deletedAt != nil
    }

    /// A boolean value that determines whether the text message should be rendered as large emojis
    ///
    /// By default, any string which comprises of ONLY emojis of length 3 or less is displayed as large emoji
    ///
    /// Note that for messages sent with attachments, large emojis aren's rendered
    @MainActor var shouldRenderAsJumbomoji: Bool {
        guard let textContent, !textContent.isEmpty else { return false }
        return textContent.count <= 3 && textContent.containsOnlyEmoji
    }

    @MainActor var adjustedText: String {
        InjectedValues[\.utils].composerConfig.adjustMessageOnRead(text)
    }
    
    @MainActor var isRightAligned: Bool {
        let config = InjectedValues[\.utils].messageListConfig
        let messageListAlignment = config.messageListAlignment
        if messageListAlignment == .leftAligned {
            return false
        }
        return isSentByCurrentUser
    }
}

@available(iOS 15, *)
extension ChatMessage {
    /// Returns the message text as a styled `AttributedString` with markdown, mentions, and links applied.
    ///
    /// Behavior is controlled by `MessageListConfig.markdownSupportEnabled`, `MessageListConfig.localLinkDetectionEnabled`,
    /// and `MessageDisplayOptions.messageLinkDisplayResolver`.
    @MainActor public func attributedTextContent(
        layoutDirection: LayoutDirection,
        translationLanguage: TranslationLanguage?
    ) -> AttributedString {
        @Injected(\.utils) var utils
        @Injected(\.colors) var colors
        @Injected(\.fonts) var fonts

        let text: String
        if let translationLanguage, let translatedText = textContent(for: translationLanguage) {
            text = translatedText
        } else {
            text = textContent ?? ""
        }

        let foregroundColor: Color = isSentByCurrentUser
            ? Color(colors.chatTextOutgoing)
            : Color(colors.chatTextIncoming)

        // Markdown
        let attributes = AttributeContainer()
            .foregroundColor(foregroundColor)
            .font(fonts.body)
        var attributedString: AttributedString
        if utils.messageListConfig.markdownSupportEnabled {
            attributedString = utils.markdownFormatter.format(
                text,
                attributes: attributes,
                layoutDirection: layoutDirection
            )
        } else {
            attributedString = AttributedString(text, attributes: attributes)
        }

        // Links and mentions
        if utils.messageListConfig.localLinkDetectionEnabled {
            for user in mentionedUsers {
                addMentionLink(for: user.name ?? user.id, mentionId: user.id, in: &attributedString)
            }
            for role in mentionedRoles {
                addMentionLink(for: role, mentionId: role, in: &attributedString)
            }
            for group in mentionedGroups {
                addMentionLink(for: group.name, mentionId: group.id, in: &attributedString)
            }
            if mentionedHere {
                addMentionLink(for: "here", mentionId: "here", in: &attributedString)
            }
            if mentionedChannel {
                addMentionLink(for: "channel", mentionId: "channel", in: &attributedString)
            }
            for link in utils.linkDetector.links(in: String(attributedString.characters)) {
                if let attributedStringRange = Range(link.range, in: attributedString) {
                    attributedString[attributedStringRange].link = link.url
                }
            }
        }

        // Link styling
        var linkAttributes = utils.messageListConfig.messageDisplayOptions.messageLinkDisplayResolver(self)
        if !linkAttributes.isEmpty {
            var linkAttributeContainer = AttributeContainer()
            if let uiColor = linkAttributes[.foregroundColor] as? UIColor {
                linkAttributeContainer = linkAttributeContainer.foregroundColor(Color(uiColor: uiColor))
                linkAttributes.removeValue(forKey: .foregroundColor)
            }
            linkAttributeContainer.merge(AttributeContainer(linkAttributes))
            for (value, range) in attributedString.runs[\.link] {
                guard value != nil else { continue }
                attributedString[range].mergeAttributes(linkAttributeContainer)
            }
        }

        return attributedString
    }

    /// Adds a mention link to all occurrences of `@<mentionText>` in the attributed string.
    ///
    /// - Parameters:
    ///   - mentionText: The text following the `@` symbol (e.g. a user name, role or group).
    ///   - mentionId: The identifier used to build the mention link.
    ///   - attributedString: The attributed string to update.
    @MainActor private func addMentionLink(
        for mentionText: String,
        mentionId: String,
        in attributedString: inout AttributedString
    ) {
        let mention = "@\(mentionText)"
        let ranges = attributedString.ranges(of: mention, options: [.caseInsensitive])
        guard !ranges.isEmpty,
              let encodedMessageId = messageId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let encodedMentionId = mentionId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "getstream://mention/\(encodedMessageId)/\(encodedMentionId)")
        else { return }
        for range in ranges {
            attributedString[range].link = url
        }
    }
}

extension TranslationLanguage {
    var localizedName: String? {
        Locale.current.localizedString(forLanguageCode: languageCode)
    }
}
