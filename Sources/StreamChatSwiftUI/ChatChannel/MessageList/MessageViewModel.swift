//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat

/// The view model that contains the logic for displaying a message in the message list view.
open class MessageViewModel: ObservableObject {
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient

    public private(set) var message: ChatMessage
    public private(set) var channel: ChatChannel?
    private(set) var originalTextTranslationsStore: MessageOriginalTranslationsStore
    private var cancellables = Set<AnyCancellable>()

    public init(
        message: ChatMessage,
        channel: ChatChannel?,
        originalTextTranslationsStore: MessageOriginalTranslationsStore
    ) {
        self.message = message
        self.channel = channel
        self.originalTextTranslationsStore = originalTextTranslationsStore
        self.originalTextTranslationsStore.$originalTextMessageIds.sink(
            receiveValue: { [weak self] _ in
                self?.objectWillChange.send()
            }
        )
        .store(in: &cancellables)
    }

    // MARK: - Inputs

    public func showOriginalText() {
        originalTextTranslationsStore.showOriginalText(for: message.id)
    }

    public func hideOriginalText() {
        originalTextTranslationsStore.hideOriginalText(for: message.id)
    }

    // MARK: - Outputs

    public var originalTextShown: Bool {
        originalTextTranslationsStore.shouldShowOriginalText(for: message.id)
    }

    public var systemMessageShown: Bool {
        message.type == .system || (message.type == .error && message.isBounced == false)
    }

    public var reactionsShown: Bool {
        !message.reactionScores.isEmpty
            && !message.isDeleted
            && channel?.config.reactionsEnabled == true
    }

    public var failureIndicatorShown: Bool {
        ((message.localState == .sendingFailed || message.isBounced) && !message.text.isEmpty)
    }

    open var authorAndDateShown: Bool {
        guard let channel = channel else { return false }
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

    public var isRightAligned: Bool {
        message.isRightAligned
    }

    public var userDisplayInfo: UserDisplayInfo? {
        guard let channel = channel else { return nil }
        guard messageListConfig.messageDisplayOptions.showAvatars(for: channel) else { return nil }
        return message.authorDisplayInfo
    }

    open var isSwipeToQuoteReplyPossible: Bool {
        message.isInteractionEnabled && channel?.config.repliesEnabled == true
    }

    open var textContent: String {
        if !originalTextShown, let translatedText = translatedText {
            return translatedText
        }

        return message.adjustedText
    }

    public var translatedText: String? {
        if let language = channel?.membership?.language,
           let translatedText = message.textContent(for: language) {
            return translatedText
        }

        return nil
    }

    public var translatedLanguageText: String? {
        guard let localizedName = channel?.membership?.language?.localizedName else {
            return nil
        }
        
        return L10n.Message.translatedTo(localizedName)
    }

    public var originalTranslationButtonText: String {
        originalTextShown ? L10n.Message.showTranslation : L10n.Message.showOriginal
    }

    // MARK: - Helpers

    private var messageListConfig: MessageListConfig {
        utils.messageListConfig
    }
}

/// A singleton store that keeps track of which messages have their original text shown.
public class MessageOriginalTranslationsStore: ObservableObject {
    private init() {}

    public static let shared = MessageOriginalTranslationsStore()

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
}
