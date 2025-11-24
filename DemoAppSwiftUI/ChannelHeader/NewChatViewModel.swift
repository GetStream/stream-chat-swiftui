//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

class NewChatViewModel: ObservableObject, ChatUserSearchControllerDelegate {
    @Injected(\.chatClient) var chatClient

    @Published var searchText: String = "" {
        didSet {
            operation?.cancel()
            state = .loading

            // Reset the flag when user starts typing
            if !searchText.isEmpty {
                isShowingSearchResults = false
            }

            // Update info label text
            if !searchText.isEmpty {
                infoLabelText = "Matches for \"\(searchText)\""
            } else {
                infoLabelText = "On the platform"
            }

            operation = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                let term = self.searchText.isEmpty ? nil : self.searchText
                self.searchController.search(term: term) { [weak self] error in
                    guard let self = self else { return }
                    if error != nil {
                        self.state = .error
                    } else {
                        // Update state based on results
                        DispatchQueue.main.async {
                            self.chatUsers = self.searchController.userArray
                            // If there's search text, show search results even if users are selected
                            if !self.searchText.isEmpty {
                                self.update(for: self.chatUsers.isEmpty ? .noUsers : .searching)
                            } else if !self.selectedUsers.isEmpty && !self.isShowingSearchResults {
                                self.update(for: .selected)
                            } else {
                                self.update(for: self.chatUsers.isEmpty ? .noUsers : .searching)
                            }
                        }
                    }
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(throttleTime), execute: operation!)
        }
    }

    @Published var chatUsers = [ChatUser]()
    @Published var state: NewChatState = .initial
    @Published var infoLabelText = "On the platform"
    @Published var selectedUsers = [ChatUser]() {
        didSet {
            if !selectedUsers.isEmpty {
                update(for: .selected)
                do {
                    let selectedUserIds = Set(selectedUsers.map(\.id))
                    channelController = try chatClient.channelController(
                        createDirectMessageChannelWith: selectedUserIds,
                        name: nil,
                        imageURL: nil,
                        extraData: [:]
                    )
                } catch {
                    state = .error
                }
            } else {
                update(for: .searching)
            }
        }
    }

    private var loadingNextUsers: Bool = false
    private var hasPerformedInitialSearch = false
    private var isShowingSearchResults = false
    var channelController: ChatChannelController?

    private lazy var searchController: ChatUserSearchController = chatClient.userSearchController()
    private let lastSeenDateFormatter = DateUtils.timeAgo
    private var operation: DispatchWorkItem?
    private let throttleTime = 1000

    init() {
        searchController.delegate = self
    }

    func loadInitialUsers() {
        guard !hasPerformedInitialSearch else { return }
        hasPerformedInitialSearch = true

        state = .loading
        searchController.search(term: nil) { [weak self] _ in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.chatUsers = self.searchController.userArray
                // If there's search text, show search results even if users are selected
                if !self.searchText.isEmpty {
                    self.update(for: self.chatUsers.isEmpty ? .noUsers : .searching)
                } else if !self.selectedUsers.isEmpty {
                    self.update(for: .selected)
                } else {
                    self.update(for: self.chatUsers.isEmpty ? .noUsers : .searching)
                }
            }
        }
    }

    func userTapped(_ user: ChatUser) {
        guard !selectedUsers.contains(user) else {
            return
        }

        selectedUsers.append(user)
        searchText = ""
        isShowingSearchResults = false
    }

    func showSearchResults() {
        // Trigger search to show all users when "Add user" button is clicked
        if searchText.isEmpty {
            isShowingSearchResults = true
            // Force a search to show all users
            state = .loading
            searchController.search(term: nil) { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.chatUsers = self.searchController.userArray
                    // Always show search results when button is clicked, even if users are selected
                    self.update(for: self.chatUsers.isEmpty ? .noUsers : .searching)
                }
            }
        }
    }

    func onlineInfo(for user: ChatUser) -> String {
        if user.isOnline {
            return "Online"
        } else if let lastActiveAt = user.lastActiveAt,
                  let timeAgo = lastSeenDateFormatter(lastActiveAt) {
            return "Last seen: \(timeAgo)"
        } else {
            return "Never seen"
        }
    }

    func isSelected(user: ChatUser) -> Bool {
        selectedUsers.contains(user)
    }

    func onChatUserAppear(_ user: ChatUser) {
        guard let index = chatUsers.firstIndex(where: { element in
            user.id == element.id
        }) else {
            return
        }

        // Load more when near bottom
        if index >= chatUsers.count - 10 && !loadingNextUsers {
            loadingNextUsers = true
            searchController.loadNextUsers { [weak self] _ in
                guard let self = self else { return }
                self.chatUsers = self.searchController.userArray
                self.loadingNextUsers = false
            }
        }
    }

    private func update(for newState: NewChatState) {
        state = newState
    }

    // MARK: - ChatUserSearchControllerDelegate

    func controller(
        _ controller: ChatUserSearchController,
        didChangeUsers changes: [ListChange<ChatUser>]
    ) {
        chatUsers = controller.userArray
        // Update state when users change
        // If there's search text or we're showing search results, show search results even if users are selected
        if !searchText.isEmpty || isShowingSearchResults {
            update(for: chatUsers.isEmpty ? .noUsers : .searching)
        } else if !selectedUsers.isEmpty {
            update(for: .selected)
        } else {
            update(for: chatUsers.isEmpty ? .noUsers : .searching)
        }
    }
}

enum NewChatState {
    case initial
    case searching
    case loading
    case noUsers
    case selected
    case error
}
