//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

public struct MentionsSuggester {

    // TODO: read from config
    private var mentionAllAppUsers = false
    
    private let channelController: ChatChannelController
    private let userSearchController: ChatUserSearchController
        
    init(channelController: ChatChannelController) {
        self.channelController = channelController
        userSearchController = channelController.client.userSearchController()
    }
    
    public func showMentionSuggestions(for typingMention: String, mentionRange: NSRange) -> Future<[ChatUser], Never> {
        guard let channel = channelController.channel,
              let currentUserId = channelController.client.currentUserId else {
            return resolve(with: [])
        }

        if mentionAllAppUsers {
            return searchAllUsers(for: typingMention)
        } else {
            let users = searchUsers(
                channel.lastActiveWatchers.map { $0 } + channel.lastActiveMembers.map { $0 },
                by: typingMention,
                excludingId: currentUserId
            )
            return resolve(with: users)
        }
    }
        
    /// searchUsers does an autocomplete search on a list of ChatUser and returns users with `id` or `name` containing the search string
    /// results are returned sorted by their edit distance from the searched string
    /// distance is calculated using the levenshtein algorithm
    /// both search and name strings are normalized (lowercased and by replacing diacritics)
    func searchUsers(_ users: [ChatUser], by searchInput: String, excludingId: String? = nil) -> [ChatUser] {
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
    
    func queryForMentionSuggestionsSearch(typingMention term: String) -> UserListQuery {
        UserListQuery(
            filter: .or([
                .autocomplete(.name, text: term),
                .autocomplete(.id, text: term)
            ]),
            sort: [.init(key: .name, isAscending: true)]
        )
    }
    
    // MARK: - private
    
    private func resolve(with users: [ChatUser]) -> Future<[ChatUser], Never> {
        Future { promise in
            promise(.success(users))
        }
    }
    
    private func searchAllUsers(for typingMention: String) -> Future<[ChatUser], Never> {
        Future { promise in
            let query = queryForMentionSuggestionsSearch(typingMention: typingMention)
            userSearchController.search(query: query) { _ in
                let users = Array(userSearchController.users)
                promise(.success(users))
            }
        }
    }
}
