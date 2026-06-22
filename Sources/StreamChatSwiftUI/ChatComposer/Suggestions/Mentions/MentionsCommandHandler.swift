//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

/// Handles the mention command and provides suggestions.
public final class MentionsCommandHandler: CommandHandler {
    public let id: String
    public var displayInfo: CommandDisplayInfo?

    private let typingSuggester: TypingSuggester

    private let channelController: ChatChannelController
    private let provider: MentionSuggestionsProvider

    /// Creates a new mentions command handler.
    ///
    /// - Parameters:
    ///   - channelController: The controller of the channel the suggestions are provided for.
    ///   - userSearchController: Deprecated and unused. User search is now performed through the
    ///     ``MentionSuggestionsProvider``. The parameter is kept for source compatibility.
    ///   - commandSymbol: The symbol that triggers the command (e.g. `@`).
    ///   - mentionAllAppUsers: Whether user suggestions are searched across all app users.
    ///   - id: The identifier of the command.
    @available(*, deprecated, message: "Use init(channelController:commandSymbol:provider:id:) instead. The userSearchController parameter is no longer used.")
    public convenience init(
        channelController: ChatChannelController,
        userSearchController: ChatUserSearchController? = nil,
        commandSymbol: String,
        mentionAllAppUsers: Bool,
        id: String = "mentions"
    ) {
        self.init(
            channelController: channelController,
            commandSymbol: commandSymbol,
            provider: DefaultMentionSuggestionsProvider(
                client: channelController.client,
                mentionAllAppUsers: mentionAllAppUsers
            ),
            id: id
        )
    }

    /// Creates a new mentions command handler.
    ///
    /// - Parameters:
    ///   - channelController: The controller of the channel the suggestions are provided for.
    ///   - commandSymbol: The symbol that triggers the command (e.g. `@`).
    ///   - provider: The provider used to compute the suggestions. When `nil`, the
    ///     ``DefaultMentionSuggestionsProvider`` is used.
    ///   - id: The identifier of the command.
    public init(
        channelController: ChatChannelController,
        commandSymbol: String,
        provider: MentionSuggestionsProvider? = nil,
        id: String = "mentions"
    ) {
        self.id = id
        self.channelController = channelController
        self.provider = provider ?? DefaultMentionSuggestionsProvider(client: channelController.client)
        typingSuggester = TypingSuggester(options: .init(symbol: commandSymbol))
    }

    public func canHandleCommand(in text: String, caretLocation: Int) -> ComposerCommand? {
        if let suggestion = typingSuggester.typingSuggestion(
            in: text,
            caretLocation: caretLocation
        ) {
            ComposerCommand(
                id: id,
                typingSuggestion: suggestion,
                displayInfo: nil
            )
        } else {
            nil
        }
    }

    public func handleCommand(
        for text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        command: Binding<ComposerCommand?>,
        extraData: [String: Any]
    ) {
        guard let typingSuggestionValue = command.wrappedValue?.typingSuggestion else {
            return
        }

        let mentionText: String
        if let suggestion = extraData["mentionSuggestion"] as? MentionSuggestion {
            mentionText = self.mentionText(for: suggestion)
        } else if let chatUser = extraData["chatUser"] as? ChatUser {
            mentionText = chatUser.mentionText
        } else {
            return
        }

        let newText = (text.wrappedValue as NSString).replacingCharacters(
            in: typingSuggestionValue.locationRange,
            with: mentionText
        )
        text.wrappedValue = newText

        let newCaretLocation =
            selectedRangeLocation.wrappedValue + (mentionText.count - typingSuggestionValue.text.count)
        selectedRangeLocation.wrappedValue = newCaretLocation
        command.wrappedValue = nil
    }

    public func commandHandler(for command: ComposerCommand) -> CommandHandler? {
        command.id == id ? self : nil
    }

    public func showSuggestions(
        for command: ComposerCommand
    ) -> Future<SuggestionInfo, Error> {
        showMentionSuggestions(
            for: command.typingSuggestion.text,
            mentionRange: command.typingSuggestion.locationRange
        )
    }

    func mentionText(for suggestion: MentionSuggestion) -> String {
        switch suggestion.kind {
        case let userSuggestion as MentionSuggestion.User:
            return userSuggestion.user.mentionText
        case is MentionSuggestion.Here:
            return L10n.Composer.Suggestions.Mentions.Here.text
        case is MentionSuggestion.Channel:
            return L10n.Composer.Suggestions.Mentions.Channel.text
        case let roleSuggestion as MentionSuggestion.Role:
            return roleSuggestion.role.name
        case let groupSuggestion as MentionSuggestion.Group:
            return groupSuggestion.group.name
        default:
            return suggestion.id
        }
    }

    // MARK: - private

    private func showMentionSuggestions(
        for typingMention: String,
        mentionRange: NSRange
    ) -> Future<SuggestionInfo, Error> {
        let id = id
        return Future { [weak self] promise in
            guard let self else {
                promise(.success(SuggestionInfo(key: id, value: [MentionSuggestion]())))
                return
            }
            nonisolated(unsafe) let unsafePromise = promise
            Task { @MainActor in
                let suggestions = await self.makeSuggestions(for: typingMention)
                unsafePromise(.success(SuggestionInfo(key: id, value: suggestions)))
            }
        }
    }

    @MainActor
    private func makeSuggestions(for typingMention: String) async -> [MentionSuggestion] {
        guard let channel = channelController.channel else {
            return []
        }
        let request = MentionSuggestionsRequest(text: typingMention, channel: channel)
        return (try? await provider.mentionSuggestions(for: request)) ?? []
    }
}

func resolve<Content>(with content: Content) -> Future<Content, Error> {
    Future { promise in
        promise(.success(content))
    }
}
