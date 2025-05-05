//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat

/// The view model that contains the logic for displaying a message in the message list view.
open class MessageViewModel: ObservableObject {
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient

    public private(set) var message: ChatMessage
    public private(set) var channel: ChatChannel?
    public private(set) var originalTextMessageIds: Set<MessageId>

    public init(
        message: ChatMessage,
        channel: ChatChannel?,
        originalTextMessageIds: Set<MessageId> = []
    ) {
        self.message = message
        self.channel = channel
        self.originalTextMessageIds = originalTextMessageIds
    }

    public var originalTextShown: Bool {
        originalTextMessageIds.contains(message.id)
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
