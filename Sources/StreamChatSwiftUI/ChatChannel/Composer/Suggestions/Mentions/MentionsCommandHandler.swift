//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

/// Handles the mention command and provides suggestions.
public struct MentionsCommandHandler: CommandHandler {
    
    @Injected(\.chatClient) var chatClient

    public let id: String
    public var displayInfo: CommandDisplayInfo?

    private let mentionAllAppUsers: Bool
    private let typingSuggester: TypingSuggester

    private let chat: Chat
    private let userSearch: UserSearch

    public init(
        chat: Chat,
        userSearch: UserSearch? = nil,
        commandSymbol: String,
        mentionAllAppUsers: Bool,
        id: String = "mentions"
    ) {
        self.id = id
        self.chat = chat
        self.mentionAllAppUsers = mentionAllAppUsers
        typingSuggester = TypingSuggester(options: .init(symbol: commandSymbol))
        if let userSearch {
            self.userSearch = userSearch
        } else {
            self.userSearch = InjectedValues[\.chatClient].makeUserSearch()
        }
    }

    public func canHandleCommand(in text: String, caretLocation: Int) -> ComposerCommand? {
        if let suggestion = typingSuggester.typingSuggestion(
            in: text,
            caretLocation: caretLocation
        ) {
            return ComposerCommand(
                id: id,
                typingSuggestion: suggestion,
                displayInfo: nil
            )
        } else {
            return nil
        }
    }

    public func handleCommand(
        for text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        command: Binding<ComposerCommand?>,
        extraData: [String: Any]
    ) {
        guard let chatUser = extraData["chatUser"] as? ChatUser,
              let typingSuggestionValue = command.wrappedValue?.typingSuggestion else {
            return
        }

        let mentionText = chatUser.mentionText
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
    ) async throws -> SuggestionInfo {
        try await showMentionSuggestions(
            for: command.typingSuggestion.text,
            mentionRange: command.typingSuggestion.locationRange
        )
    }

    // MARK: - private

    private func showMentionSuggestions(
        for typingMention: String,
        mentionRange: NSRange
    ) async throws -> SuggestionInfo {
        guard let channel = await chat.state.channel,
              let currentUserId = chatClient.currentUserId else {
            throw StreamChatError.missingData
        }

        if mentionAllAppUsers {
            return try await searchAllUsers(for: typingMention)
        } else {
            let users = searchUsers(
                channel.lastActiveWatchers.map { $0 } + channel.lastActiveMembers.map { $0 },
                by: typingMention,
                excludingId: currentUserId
            )
            let suggestionInfo = SuggestionInfo(key: id, value: users)
            return suggestionInfo
        }
    }

    /// searchUsers does an autocomplete search on a list of ChatUser and returns users with `id` or `name` containing the search string
    /// results are returned sorted by their edit distance from the searched string
    /// distance is calculated using the levenshtein algorithm
    /// both search and name strings are normalized (lowercased and by replacing diacritics)
    private func searchUsers(_ users: [ChatUser], by searchInput: String, excludingId: String? = nil) -> [ChatUser] {
        let normalize: (String) -> String = {
            $0.lowercased().folding(options: .diacriticInsensitive, locale: .current)
        }

        let searchInput = normalize(searchInput)

        let matchingUsers = users.filter { $0.id != excludingId }
            .filter { searchInput == "" || $0.id.contains(searchInput) || (normalize($0.name ?? "").contains(searchInput)) }

        let distance: (ChatUser) -> Int = {
            min($0.id.levenshtein(searchInput), $0.name?.levenshtein(searchInput) ?? 1000)
        }

        return Array(Set(matchingUsers)).sorted {
            /// a tie breaker is needed here to avoid results from flickering
            let dist = distance($0) - distance($1)
            if dist == 0 {
                return $0.id < $1.id
            }
            return dist < 0
        }
    }

    private func queryForMentionSuggestionsSearch(typingMention term: String) -> UserListQuery {
        UserListQuery(
            filter: .or([
                .autocomplete(.name, text: term),
                .autocomplete(.id, text: term)
            ]),
            sort: [.init(key: .name, isAscending: true)]
        )
    }

    private func searchAllUsers(for typingMention: String) async throws -> SuggestionInfo {
        let query = queryForMentionSuggestionsSearch(typingMention: typingMention)
        try await userSearch.search(query: query)
        let users = await userSearch.state.users
        let suggestionInfo = SuggestionInfo(key: id, value: users)
        return suggestionInfo
    }
}
