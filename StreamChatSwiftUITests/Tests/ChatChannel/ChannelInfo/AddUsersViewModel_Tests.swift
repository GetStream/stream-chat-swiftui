//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import Combine
@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class AddUsersViewModel_Tests: StreamChatTestCase {

    private var cancellables = Set<AnyCancellable>()

    func test_addUsersViewModel_loadedUsers() {
        // Given
        let searchController = ChatUserSearchController_Mock.mock(client: chatClient)
        searchController.users_mock = ChannelInfoMockUtils.generateMockUsers(count: 10)
        let viewModel = AddUsersViewModel(
            loadedUserIds: [],
            searchController: searchController
        )

        // When
        let users = viewModel.users

        // Then
        XCTAssert(users.count == 10)
    }

    func test_addUsersViewModel_search() {
        // Given
        let searchController = ChatUserSearchController_Mock.mock(client: chatClient)
        searchController.users_mock = ChannelInfoMockUtils.generateMockUsers(count: 12)
        let viewModel = AddUsersViewModel(
            loadedUserIds: [],
            searchController: searchController
        )
        let expectation = self.expectation(description: "search")

        // When
        viewModel.searchText = "Test User 1"
        viewModel.$users.sink { users in
            // Then
            XCTAssert(users.count == 3)
            expectation.fulfill()
        }
        .store(in: &cancellables)

        waitForExpectations(timeout: defaultTimeout)
    }

    func test_addUsersViewModel_onUserAppear() {
        // Given
        let searchController = ChatUserSearchController_Mock.mock(client: chatClient)
        var users = ChannelInfoMockUtils.generateMockUsers(count: 20)
        searchController.users_mock = users
        let viewModel = AddUsersViewModel(
            loadedUserIds: [],
            searchController: searchController
        )

        // When
        users.append(contentsOf: ChannelInfoMockUtils.generateMockUsers(count: 20))
        searchController.users_mock = users
        viewModel.onUserAppear(users[5])
        let initial = viewModel.users
        viewModel.onUserAppear(users[15])
        let afterLoad = viewModel.users

        // Then
        XCTAssert(initial.count == 20)
        XCTAssert(afterLoad.count == 40)
    }
}
