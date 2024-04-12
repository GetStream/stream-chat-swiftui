//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine
@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class AddUsersViewModel_Tests: StreamChatTestCase {

    private var cancellables = Set<AnyCancellable>()

    @MainActor func test_addUsersViewModel_loadedUsers() {
        // Given
        let generated = ChannelInfoMockUtils.generateMockUsers(count: 10)
        let userSearch = UserSearch_Mock.mock()
        userSearch.setUsers(generated)
        
        let viewModel = AddUsersViewModel(
            loadedUserIds: [],
            userSearch: userSearch
        )

        // When
        let users = viewModel.users

        // Then
        XCTAssertEqual(users.count, 10)
    }

    @MainActor func test_addUsersViewModel_search() {
        // Given
        let generated = ChannelInfoMockUtils.generateMockUsers(count: 12)
        let userSearch = UserSearch_Mock.mock()
        userSearch.setUsers(generated)
        let viewModel = AddUsersViewModel(
            loadedUserIds: [],
            userSearch: userSearch
        )
        let expectation = self.expectation(description: "search")
        expectation.assertForOverFulfill = false
        
        // When
        viewModel.searchText = "Test User 1"
        viewModel.$users.drop(while: { users in
            users.count != 3
        }).sink { users in
            // Then
            XCTAssert(users.count == 3)
            expectation.fulfill()
        }
        .store(in: &cancellables)

        waitForExpectations(timeout: defaultTimeout)
    }

    @MainActor func test_addUsersViewModel_onUserAppear() async throws {
        // Given
        var users = ChannelInfoMockUtils.generateMockUsers(count: 20)
        let userSearch = UserSearch_Mock.mock()
        userSearch.setUsers(users)
        let viewModel = AddUsersViewModel(
            loadedUserIds: [],
            userSearch: userSearch
        )

        // When
        users.append(contentsOf: ChannelInfoMockUtils.generateMockUsers(count: 20))
        userSearch.setUsers(users)
        viewModel.onUserAppear(users[5])
        let initial = viewModel.users
        viewModel.onUserAppear(users[15])
        try await Task.sleep(nanoseconds: 1_000_000)
        let afterLoad = viewModel.users

        // Then
        XCTAssert(initial.count == 20)
        XCTAssert(afterLoad.count == 40)
    }
}
