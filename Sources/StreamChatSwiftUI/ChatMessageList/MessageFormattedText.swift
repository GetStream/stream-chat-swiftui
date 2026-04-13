//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// The rendered form of ``ChatMessage/text``, ready to be handed to `Text(_:)`.
///
/// `ChatMessage.text` is the raw authored string as sent by the user. Before
/// the message list displays it, ``MessageViewModel`` applies a number of
/// presentation concerns on top of that raw string:
///
/// - **Translation resolution** — if the channel membership has a translation
///   language and the user has not asked to see the original, the translated
///   text replaces the raw string (see ``MessageViewModel/textContent``).
/// - **Markdown formatting** (iOS 15+, when
///   ``MessageListConfig/markdownSupportEnabled`` is on) — bold, italic,
///   strikethrough, lists, headers, quotes, code, etc.
/// - **Mention detection** (iOS 15+, when
///   ``MessageListConfig/localLinkDetectionEnabled`` is on) — every `@username`
///   that matches a ``ChatMessage/mentionedUsers`` entry becomes a tappable
///   `getstream://mention/...` link.
/// - **Link detection** (iOS 15+, when
///   ``MessageListConfig/localLinkDetectionEnabled`` is on) — URLs in the body
///   become tappable links via `NSDataDetector`.
/// - **Link styling** — attributes returned by
///   ``MessageDisplayOptions/messageLinkDisplayResolver`` (foreground color,
///   underline, …) are merged into every detected link range.
/// - **Base styling** — the message's default foreground color (incoming vs
///   outgoing) and body font are baked into the base attribute container.
///
/// The SDK supports iOS 14, where `AttributedString` is unavailable, so
/// `MessageFormattedText` keeps a plain-string fallback (``string``) alongside
/// the iOS-15-only ``attributedString`` payload. Consumers render with a
/// single `if let` on ``attributedString`` and fall through to ``string``
/// otherwise.
public struct MessageFormattedText: Equatable, @unchecked Sendable {
    private let attributed: Any?

    /// Plain-string fallback. Always populated — on iOS 15+ it is derived
    /// from the attributed string's characters so downstream consumers
    /// (accessibility, previews, fallback rendering) can always read a
    /// meaningful `String`.
    public let string: String

    /// Plain-text initializer (iOS 14 compatible). The resulting value has
    /// no attributed payload: ``attributedString`` is `nil`.
    public init(_ plainString: String) {
        string = plainString
        attributed = nil
    }

    /// Attributed-string initializer (iOS 15+).
    ///
    /// - Parameters:
    ///   - attributedString: The formatted payload (markdown, links, mentions,
    ///     base styling) produced by ``MessageViewModel``.
    ///   - string: The raw plain text, typically ``ChatMessage/text`` (or the
    ///     translated equivalent). Kept separately from the attributed
    ///     payload so consumers that need the original — accessibility
    ///     labels, previews, search, iOS 14 fallback — see the authored
    ///     string rather than one derived from the attributed characters
    ///     (which drops markdown syntax and rewrites mentions).
    @available(iOS 15.0, *)
    public init(_ attributedString: AttributedString, string: String) {
        self.string = string
        attributed = attributedString
    }

    /// The attributed-string payload, or `nil` when only a plain string was
    /// supplied (or on iOS 14). Consumers use `if let` to pick the formatted
    /// render path and fall through to ``string`` otherwise.
    @available(iOS 15.0, *)
    public var attributedString: AttributedString? {
        attributed as? AttributedString
    }

    public static func == (lhs: MessageFormattedText, rhs: MessageFormattedText) -> Bool {
        guard lhs.string == rhs.string else { return false }
        if #available(iOS 15.0, *) {
            return lhs.attributedString == rhs.attributedString
        }
        return true
    }
}
