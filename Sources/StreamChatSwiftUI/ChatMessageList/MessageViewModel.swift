//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat

/// The view model that contains the logic for displaying a message in the message list view.
@MainActor open class MessageViewModel: ObservableObject {
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient

    @Published public internal(set) var message: ChatMessage
    @Published public internal(set) var channel: ChatChannel
    @Published public var usesScrollView: Bool = false
    public let isInThread: Bool
    private var cancellables = Set<AnyCancellable>()

    public init(
        message: ChatMessage,
        channel: ChatChannel,
        isInThread: Bool = false
    ) {
        self.message = message
        self.channel = channel
        self.isInThread = isInThread
        utils.originalTranslationsStore.$originalTextMessageIds.sink(
            receiveValue: { [weak self] _ in
                self?.objectWillChange.send()
            }
        )
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
