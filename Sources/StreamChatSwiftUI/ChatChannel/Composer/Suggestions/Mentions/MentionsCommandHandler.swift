//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

/// Handles the mention command and provides suggestions.
public struct MentionsCommandHandler: CommandHandler {

    public let id: String
    public var displayInfo: CommandDisplayInfo?

    private let mentionAllAppUsers: Bool
    private let typingSuggester: TypingSuggester

    private let channelController: ChatChannelController
    private let userSearchController: ChatUserSearchController

    public init(
        channelController: ChatChannelController,
        userSearchController: ChatUserSearchController? = nil,
        commandSymbol: String,
        mentionAllAppUsers: Bool,
        id: String = "mentions"
    ) {
        self.id = id
        self.channelController = channelController
        self.mentionAllAppUsers = mentionAllAppUsers
        typingSuggester = TypingSuggester(options: .init(symbol: commandSymbol))
        if let userSearchController = userSearchController {
            self.userSearchController = userSearchController
        } else {
            self.userSearchController = channelController.client.userSearchController()
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
    ) -> Future<SuggestionInfo, Error> {
        showMentionSuggestions(
            for: command.typingSuggestion.text,
            mentionRange: command.typingSuggestion.locationRange
        )
    }

    // MARK: - private

    private func showMentionSuggestions(
        for typingMention: String,
        mentionRange: NSRange
    ) -> Future<SuggestionInfo, Error> {
        guard let channel = channelController.channel,
              let currentUserId = channelController.client.currentUserId else {
            return StreamChatError.missingData.asFailedPromise()
        }

        if mentionAllAppUsers {
            return searchAllUsers(for: typingMention)
        } else {
            let users = searchUsers(
                channel.lastActiveWatchers.map { $0 } + channel.lastActiveMembers.map { $0 },
                by: typingMention,
                excludingId: currentUserId
            )
            let suggestionInfo = SuggestionInfo(key: id, value: users)
            return resolve(with: suggestionInfo)
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

    private func searchAllUsers(for typingMention: String) -> Future<SuggestionInfo, Error> {
        Future { promise in
            let query = queryForMentionSuggestionsSearch(typingMention: typingMention)
            userSearchController.search(query: query) { error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                let users = userSearchController.userArray
                let suggestionInfo = SuggestionInfo(key: id, value: users)
                promise(.success(suggestionInfo))
            }
        }
    }
}

func resolve<Content>(with content: Content) -> Future<Content, Error> {
    Future { promise in
        promise(.success(content))
    }
}
