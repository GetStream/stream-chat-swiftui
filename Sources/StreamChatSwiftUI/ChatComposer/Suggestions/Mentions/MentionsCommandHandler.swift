//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

/// Handles the mention command and provides suggestions.
public final class MentionsCommandHandler: CommandHandler {
    @Injected(\.utils) private var utils

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
        if let userSearchController {
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
            mentionText = suggestion.mentionText
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

    // MARK: - private

    private func showMentionSuggestions(
        for typingMention: String,
        mentionRange: NSRange
    ) -> Future<SuggestionInfo, Error> {
        let id = id
        return Future { [weak self] promise in
            guard let self else { return }
            nonisolated(unsafe) let unsafePromise = promise
            Task { @MainActor in
                let suggestions = await self.makeSuggestions(for: typingMention)
                unsafePromise(.success(SuggestionInfo(key: id, value: suggestions)))
            }
        }
    }

    @MainActor
    private func makeSuggestions(for typingMention: String) async -> [MentionSuggestion] {
        guard let channel = channelController.channel,
              let currentUserId = channelController.client.currentUserId else {
            return []
        }

        let config = utils.composerConfig.mentionSuggestionsConfig
        let allowedTypes = config.allowedMentionTypes
        let mentionAllAppUsers = config.mentionAllAppUsers || self.mentionAllAppUsers

        // Broadcasts (`@here`, `@channel`) are shown on a bare `@` and filtered
        // by prefix as the user keeps typing, matching the JS SDK behaviour.
        var suggestions = broadcastSuggestions(for: typingMention, allowedTypes: allowedTypes)

        // Roles and groups require a non-empty query to avoid surfacing the
        // entire list on a bare `@`.
        async let roles = (allowedTypes.contains(.role) && !typingMention.isEmpty)
            ? fetchRoles(for: typingMention)
            : []
        async let groups = (allowedTypes.contains(.group) && !typingMention.isEmpty)
            ? fetchGroups(for: typingMention)
            : []
        async let users = allowedTypes.contains(.user)
            ? fetchUsers(
                for: typingMention,
                channel: channel,
                currentUserId: currentUserId,
                mentionAllAppUsers: mentionAllAppUsers
            )
            : []

        suggestions += await roles
        suggestions += await groups
        suggestions += await users
        return suggestions
    }

    private func broadcastSuggestions(
        for typingMention: String,
        allowedTypes: Set<MentionType>
    ) -> [MentionSuggestion] {
        let query = typingMention.lowercased()
        var result: [MentionSuggestion] = []
        if allowedTypes.contains(.channel), matchesBroadcast("channel", query: query) {
            result.append(.channel)
        }
        if allowedTypes.contains(.here), matchesBroadcast("here", query: query) {
            result.append(.here)
        }
        return result
    }

    private func matchesBroadcast(_ keyword: String, query: String) -> Bool {
        query.isEmpty || keyword.hasPrefix(query)
    }

    @MainActor
    private func fetchRoles(for typingMention: String) async -> [MentionSuggestion] {
        await withCheckedContinuation { continuation in
            nonisolated(unsafe) let cont = continuation
            channelController.client.searchRoles(
                query: RoleSearchQuery(query: typingMention)
            ) { result in
                let roles = (try? result.get()) ?? []
                cont.resume(returning: roles.map { MentionSuggestion.role($0) })
            }
        }
    }

    @MainActor
    private func fetchGroups(for typingMention: String) async -> [MentionSuggestion] {
        let controller = channelController.client.userGroupListController()
        return await withCheckedContinuation { continuation in
            nonisolated(unsafe) let cont = continuation
            controller.searchUserGroups(text: typingMention) { result in
                // Keep the ephemeral controller alive until the callback fires.
                withExtendedLifetime(controller) {}
                let groups = (try? result.get()) ?? []
                cont.resume(returning: groups.map { MentionSuggestion.group($0) })
            }
        }
    }

    @MainActor
    private func fetchUsers(
        for typingMention: String,
        channel: ChatChannel,
        currentUserId: UserId,
        mentionAllAppUsers: Bool
    ) async -> [MentionSuggestion] {
        let users: [ChatUser]
        if mentionAllAppUsers {
            users = await searchAllUsers(for: typingMention)
        } else {
            users = searchUsers(
                channel.lastActiveWatchers.map(\.self) + channel.lastActiveMembers.map(\.self),
                by: typingMention,
                excludingId: currentUserId
            )
        }
        return users.map { MentionSuggestion.user($0) }
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

    @MainActor
    private func searchAllUsers(for typingMention: String) async -> [ChatUser] {
        let controller = userSearchController
        let query = queryForMentionSuggestionsSearch(typingMention: typingMention)
        return await withCheckedContinuation { continuation in
            nonisolated(unsafe) let cont = continuation
            controller.search(query: query) { error in
                if error != nil {
                    cont.resume(returning: [])
                } else {
                    cont.resume(returning: controller.userArray)
                }
            }
        }
    }
}

func resolve<Content>(with content: Content) -> Future<Content, Error> {
    Future { promise in
        promise(.success(content))
    }
}
