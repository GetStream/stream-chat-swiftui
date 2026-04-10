//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

@MainActor class MemberAddViewModel_Tests: StreamChatTestCase {
    private var cancellables = Set<AnyCancellable>()

    func test_memberAddViewModel_loadedUsers() {
        // Given
        let searchController = ChatUserSearchController_Mock.mock(client: chatClient)
        searchController.users_mock = ChannelInfoMockUtils.generateMockUsers(count: 10)
        let viewModel = MemberAddViewModel(
            loadedUserIds: [],
            searchController: searchController
        )

        // When
        let users = viewModel.users

        // Then
        XCTAssert(users.count == 10)
    }

    func test_memberAddViewModel_search() {
        // Given
        let searchController = ChatUserSearchController_Mock.mock(client: chatClient)
        searchController.users_mock = ChannelInfoMockUtils.generateMockUsers(count: 12)
        let viewModel = MemberAddViewModel(
            loadedUserIds: [],
            searchController: searchController
        )
        let expectation = expectation(description: "search")
        
        viewModel.$users
            .dropFirst()
            .first()
            .sink { users in
                XCTAssertEqual(users.count, 3)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.searchText = "Test User 1"

        waitForExpectations(timeout: defaultTimeout)
    }

    func test_memberAddViewModel_onUserAppear() {
        // Given
        let searchController = ChatUserSearchController_Mock.mock(client: chatClient)
        var users = ChannelInfoMockUtils.generateMockUsers(count: 20)
        searchController.users_mock = users
        let viewModel = MemberAddViewModel(
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

    func test_memberAddViewModel_toggleUser_selectsUser() {
        // Given
        let searchController = ChatUserSearchController_Mock.mock(client: chatClient)
        let users = ChannelInfoMockUtils.generateMockUsers(count: 5)
        searchController.users_mock = users
        let viewModel = MemberAddViewModel(loadedUserIds: [], searchController: searchController)
        let user = viewModel.users[0]

        // When
        viewModel.toggleUser(user)

        // Then
        XCTAssertTrue(viewModel.isSelected(user))
    }

    func test_memberAddViewModel_toggleUser_deselectsUser() {
        // Given
        let searchController = ChatUserSearchController_Mock.mock(client: chatClient)
        let users = ChannelInfoMockUtils.generateMockUsers(count: 5)
        searchController.users_mock = users
        let viewModel = MemberAddViewModel(loadedUserIds: [], searchController: searchController)
        let user = viewModel.users[0]

        // When
        viewModel.toggleUser(user)
        viewModel.toggleUser(user)

        // Then
        XCTAssertFalse(viewModel.isSelected(user))
    }

    func test_memberAddViewModel_isAlreadyMember_trueForLoadedUser() {
        // Given
        let users = ChannelInfoMockUtils.generateMockUsers(count: 5)
        let loadedUserIds = users.map(\.id)
        let searchController = ChatUserSearchController_Mock.mock(client: chatClient)
        searchController.users_mock = users
        let viewModel = MemberAddViewModel(loadedUserIds: loadedUserIds, searchController: searchController)

        // Then
        XCTAssertTrue(viewModel.isAlreadyMember(users[0]))
        XCTAssertTrue(viewModel.isAlreadyMember(users[4]))
    }

    func test_memberAddViewModel_isAlreadyMember_falseForNewUser() {
        // Given
        let users = ChannelInfoMockUtils.generateMockUsers(count: 5)
        let searchController = ChatUserSearchController_Mock.mock(client: chatClient)
        searchController.users_mock = users
        let viewModel = MemberAddViewModel(loadedUserIds: [], searchController: searchController)

        // Then
        XCTAssertFalse(viewModel.isAlreadyMember(users[0]))
    }

    func test_memberAddViewModel_selectedUsers_returnsSelectedSubset() {
        // Given
        let searchController = ChatUserSearchController_Mock.mock(client: chatClient)
        let users = ChannelInfoMockUtils.generateMockUsers(count: 5)
        searchController.users_mock = users
        let viewModel = MemberAddViewModel(loadedUserIds: [], searchController: searchController)

        // When
        viewModel.toggleUser(viewModel.users[0])
        viewModel.toggleUser(viewModel.users[2])

        // Then
        XCTAssertEqual(viewModel.selectedUsers.count, 2)
        XCTAssertTrue(viewModel.selectedUsers.contains { $0.id == viewModel.users[0].id })
        XCTAssertTrue(viewModel.selectedUsers.contains { $0.id == viewModel.users[2].id })
        XCTAssertFalse(viewModel.selectedUsers.contains { $0.id == viewModel.users[1].id })
    }
}
