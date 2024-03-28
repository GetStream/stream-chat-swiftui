//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View model for the `AddUsersView`.
class AddUsersViewModel: ObservableObject {

    @Injected(\.chatClient) private var chatClient

    @Published var users = [ChatUser]()
    @Published var searchText = "" {
        didSet {
            searchUsers(term: searchText)
        }
    }

    private var loadedUserIds: [String]
    private var loadingNextUsers = false
    private lazy var userSearch: UserSearch = chatClient.makeUserSearch()

    init(loadedUserIds: [String]) {
        self.loadedUserIds = loadedUserIds
        searchUsers()
    }

    init(loadedUserIds: [String], userSearch: UserSearch) {
        self.loadedUserIds = loadedUserIds
        self.userSearch = userSearch
        searchUsers()
    }

    func onUserAppear(_ user: ChatUser) {
        guard let index = users.firstIndex(where: { element in
            user.id == element.id
        }) else {
            return
        }

        if index < users.count - 10 {
            return
        }

        if !loadingNextUsers {
            loadingNextUsers = true
            Task { @MainActor in
                _ = try? await userSearch.loadNextUsers()
                users = Array(userSearch.state.users)
                loadingNextUsers = false
            }
        }
    }

    private func searchUsers() {
        let filter: Filter<UserListFilterScope> = .notIn(.id, values: loadedUserIds)
        let query = UserListQuery(filter: filter)
        Task { @MainActor in
            try await userSearch.search(query: query)
            users = Array(userSearch.state.users)
        }
    }

    private func searchUsers(term: String) {
        Task { @MainActor in
            try await userSearch.search(term: searchText)
            users = self.userSearch.state.users.filter { user in
                !self.loadedUserIds.contains(user.id)
            }
        }
    }
}
