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

    public var isOriginalTextShown: Bool {
        originalTextMessageIds.contains(message.id)
    }

    open var isSwipeToQuoteReplyPossible: Bool {
        message.isInteractionEnabled && channel?.config.repliesEnabled == true
    }

    open var textContent: String {
        if !isOriginalTextShown, let translatedText = translatedText {
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

    // MARK: - Helpers

    private var messageListConfig: MessageListConfig {
        utils.messageListConfig
    }
}
