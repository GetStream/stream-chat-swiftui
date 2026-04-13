//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

/// The view model that contains the logic for displaying a message in the message list view.
@MainActor open class MessageViewModel: ObservableObject {
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    @Published public internal(set) var message: ChatMessage
    @Published public internal(set) var channel: ChatChannel
    @Published public var usesScrollView: Bool = false
    public let isInThread: Bool
    private var cancellables = Set<AnyCancellable>()
    private lazy var linkDetector = TextLinkDetector()

    public init(
        message: ChatMessage,
        channel: ChatChannel,
        isInThread: Bool = false
    ) {
        self.message = message
        self.channel = channel
        self.isInThread = isInThread
        utils.originalTranslationsStore.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
        .store(in: &cancellables)
    }

    // MARK: - Inputs

    /// Show the original text of the message.
    public func showOriginalText() {
        utils.originalTranslationsStore.showOriginalText(for: message.id)
    }

    /// Hide the original text of the message to show the translated text.
    public func hideOriginalText() {
        utils.originalTranslationsStore.hideOriginalText(for: message.id)
    }

    // MARK: - Outputs

    public var originalTextShown: Bool {
        utils.originalTranslationsStore.shouldShowOriginalText(for: message.id)
    }

    public var systemMessageShown: Bool {
        message.type == .system || (message.type == .error && message.isBounced == false)
    }

    public var reactionsShown: Bool {
        !message.reactionScores.isEmpty
            && !message.isDeleted
            && channel.config.reactionsEnabled == true
    }

    public var topReactionsShown: Bool {
        messageListConfig.messageDisplayOptions.reactionsPlacement != .bottom && reactionsShown
    }

    public var bottomReactionsShown: Bool {
        messageListConfig.messageDisplayOptions.reactionsPlacement != .top && reactionsShown
    }

    public var failureIndicatorShown: Bool {
        message.isLastActionFailed && !message.text.isEmpty
    }

    open var authorAndDateShown: Bool {
        return !message.isRightAligned
            && channel.memberCount > 2
            && messageListConfig.messageDisplayOptions.showAuthorName
    }

    open var messageDateShown: Bool {
        messageListConfig.messageDisplayOptions.showMessageDate
    }

    public var isPinned: Bool {
        message.isPinned
    }

    public var pinnedByText: String {
        if message.pinDetails?.pinnedBy.id == chatClient.currentUserId {
            return L10n.Message.Cell.pinnedByYou
        }
        let name = message.pinDetails?.pinnedBy.name ?? L10n.Message.Cell.unknownPin
        return "\(L10n.Message.Cell.pinnedBy) \(name)"
    }

    public var isRightAligned: Bool {
        message.isRightAligned
    }

    public var messageAuthor: ChatUser? {
        guard messageListConfig.messageDisplayOptions.showAvatars(for: channel, incoming: !isRightAligned) else { return nil }
        return message.author
    }

    public func isHighlighted(messageId: String?) -> Bool {
        messageListConfig.highlightMessageWhenJumping && messageId == message.messageId
    }

    public var isDoubleTapOverlayEnabled: Bool {
        messageListConfig.doubleTapOverlayEnabled
    }

    open var isSwipeToQuoteReplyPossible: Bool {
        message.isInteractionEnabled && channel.config.quotesEnabled == true
    }

    open var textContent: String {
        if !originalTextShown, let translatedText {
            return translatedText
        }

        return message.adjustedText
    }

    /// The ready-to-render text content for this message.
    ///
    /// On iOS 15+ the returned value carries markdown, link, and mention
    /// attributes resolved against the current ``Utils/messageListConfig``.
    /// On iOS 14 only the plain-string fallback is populated.
    /// - Parameter layoutDirection: The layout direction used when formatting
    ///   markdown (RTL locales need this to flip emphasis markers correctly).
    open func messageFormattedText(layoutDirection: LayoutDirection = .leftToRight) -> MessageFormattedText {
        let text = textContent
        if #available(iOS 15.0, *) {
            return MessageFormattedText(
                makeAttributedString(layoutDirection: layoutDirection),
                string: text
            )
        } else {
            return MessageFormattedText(text)
        }
    }

    public var translatedText: String? {
        if let language = channel.membership?.language,
           let translatedText = message.textContent(for: language) {
            return translatedText
        }

        return nil
    }

    public var translatedLanguageText: String? {
        guard let localizedName = channel.membership?.language?.localizedName else {
            return nil
        }
        
        return L10n.Message.translatedTo(localizedName)
    }

    public var annotationsShown: Bool {
        isPinned
            || sentInChannelShown
            || repliedToThreadShown
            || hasReminder
            || translatedText != nil
    }

    public var threadRepliesShown: Bool {
        !isInThread && message.replyCount > 0
    }

    public var sentInChannelShown: Bool {
        isInThread && message.showReplyInChannel && message.parentMessageId != nil
    }

    public var repliedToThreadShown: Bool {
        !isInThread && message.showReplyInChannel && message.parentMessageId != nil
    }

    /// Whether the message has an active reminder set.
    public var hasReminder: Bool {
        channel.config.messageRemindersEnabled && message.reminder != nil
    }

    /// Formatted text describing when the reminder fires (e.g. "in 1 hour").
    public var reminderTimeText: String? {
        guard channel.config.messageRemindersEnabled else { return nil }
        guard let remindAt = message.reminder?.remindAt else { return nil }
        return utils.messageRemindersFormatter.format(remindAt)
    }

    // MARK: - Helpers

    private var messageListConfig: MessageListConfig {
        utils.messageListConfig
    }

    // MARK: - Text Content Building

    private var messageTextColor: Color {
        message.isSentByCurrentUser
            ? Color(colors.chatTextOutgoing)
            : Color(colors.chatTextIncoming)
    }

    @available(iOS 15.0, *)
    private func makeAttributedString(layoutDirection: LayoutDirection) -> AttributedString {
        let text = textContent
        let baseAttributes = AttributeContainer()
            .foregroundColor(messageTextColor)
            .font(fonts.body)

        var attributedString: AttributedString
        if messageListConfig.markdownSupportEnabled {
            attributedString = utils.markdownFormatter.format(
                text,
                attributes: baseAttributes,
                layoutDirection: layoutDirection
            )
        } else {
            attributedString = AttributedString(text, attributes: baseAttributes)
        }

        if messageListConfig.localLinkDetectionEnabled {
            applyMentions(to: &attributedString)
            applyLinks(to: &attributedString)
        }

        applyLinkStyleOverrides(to: &attributedString)
        return attributedString
    }

    @available(iOS 15.0, *)
    private func applyMentions(to attributedString: inout AttributedString) {
        let messageId = message.messageId
        for user in message.mentionedUsers {
            let mention = "@\(user.name ?? user.id)"
            let ranges = attributedString.ranges(of: mention, options: [.caseInsensitive])
            for range in ranges {
                if let encodedId = messageId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
                   let url = URL(string: "getstream://mention/\(encodedId)/\(user.id)") {
                    attributedString[range].link = url
                }
            }
        }
    }

    @available(iOS 15.0, *)
    private func applyLinks(to attributedString: inout AttributedString) {
        for link in linkDetector.links(in: String(attributedString.characters)) {
            if let attributedStringRange = Range(link.range, in: attributedString) {
                attributedString[attributedStringRange].link = link.url
            }
        }
    }

    @available(iOS 15.0, *)
    private func applyLinkStyleOverrides(to attributedString: inout AttributedString) {
        var linkAttributes = messageListConfig.messageDisplayOptions.messageLinkDisplayResolver(message)
        guard !linkAttributes.isEmpty else { return }

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
}

/// A singleton store that keeps track of which messages have their original text shown.
///
/// **Note:** This is not thread-safe, it should only be used on the main thread.
public class MessageOriginalTranslationsStore: ObservableObject {
    init() {}

    @Published var originalTextMessageIds: Set<MessageId> = []

    public func shouldShowOriginalText(for messageId: MessageId) -> Bool {
        originalTextMessageIds.contains(messageId)
    }

    public func showOriginalText(for messageId: MessageId) {
        originalTextMessageIds.insert(messageId)
    }

    public func hideOriginalText(for messageId: MessageId) {
        originalTextMessageIds.remove(messageId)
    }

    public func clear() {
        originalTextMessageIds.removeAll()
    }
}
