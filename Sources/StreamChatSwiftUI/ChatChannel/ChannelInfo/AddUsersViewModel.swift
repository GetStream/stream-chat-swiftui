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
    private lazy var searchController: ChatUserSearchController = chatClient.userSearchController()

    init(loadedUserIds: [String]) {
        self.loadedUserIds = loadedUserIds
        searchUsers()
    }

    init(loadedUserIds: [String], searchController: ChatUserSearchController) {
        self.loadedUserIds = loadedUserIds
        self.searchController = searchController
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
            searchController.loadNextUsers { [weak self] _ in
                guard let self = self else { return }
                self.users = self.searchController.userArray
                self.loadingNextUsers = false
            }
        }
    }

    private func searchUsers() {
        let filter: Filter<UserListFilterScope> = .notIn(.id, values: loadedUserIds)
        let query = UserListQuery(filter: filter)
        searchController.search(query: query) { [weak self] error in
            guard let self = self, error == nil else { return }
            self.users = self.searchController.userArray
        }
    }

    private func searchUsers(term: String) {
        searchController.search(term: searchText) { [weak self] error in
            guard let self = self, error == nil else { return }
            self.users = self.searchController.userArray.filter { user in
                !self.loadedUserIds.contains(user.id)
            }
        }
    }
}
