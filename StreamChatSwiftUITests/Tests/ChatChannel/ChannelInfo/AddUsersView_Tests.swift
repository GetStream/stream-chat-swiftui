//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class AddUsersView_Tests: StreamChatTestCase {
    func test_addUsersView_snapshot() {
        // Given
        let searchController = ChatUserSearchController_Mock.mock(client: chatClient)
        let users = ChannelInfoMockUtils.generateMockUsers(count: 20)
        searchController.users_mock = users
        let viewModel = AddUsersViewModel(
            loadedUserIds: [],
            searchController: searchController
        )

        // When
        let view = AddUsersView(viewModel: viewModel, onConfirm: { _ in })
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_addUsersView_selectedUsersSnapshot() {
        // Given
        let searchController = ChatUserSearchController_Mock.mock(client: chatClient)
        let users = ChannelInfoMockUtils.generateMockUsers(count: 10)
        searchController.users_mock = users
        let viewModel = AddUsersViewModel(
            loadedUserIds: [],
            searchController: searchController
        )
        viewModel.toggleUser(users[1])
        viewModel.toggleUser(users[3])

        // When
        let view = AddUsersView(viewModel: viewModel, onConfirm: { _ in })
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_addUsersView_alreadyMemberSnapshot() {
        // Given
        let searchController = ChatUserSearchController_Mock.mock(client: chatClient)
        let users = ChannelInfoMockUtils.generateMockUsers(count: 10)
        searchController.users_mock = users
        let alreadyMemberIds = Array(users.prefix(3)).map(\.id)
        let viewModel = AddUsersViewModel(
            loadedUserIds: alreadyMemberIds,
            searchController: searchController
        )

        // When
        let view = AddUsersView(viewModel: viewModel, onConfirm: { _ in })
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}
