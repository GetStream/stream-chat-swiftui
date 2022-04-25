//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

class AddUsersViewModel: ObservableObject {
    
    @Injected(\.chatClient) private var chatClient
    
    @Published var users = [ChatUser]()
    @Published var searchText = "" {
        didSet {
            searchUsers(term: searchText)
        }
    }
    
    private var loadedUserIds: [String]
    
    init(loadedUserIds: [String]) {
        self.loadedUserIds = loadedUserIds
        searchUsers()
    }
    
    private lazy var searchController: ChatUserSearchController = chatClient.userSearchController()
    
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
