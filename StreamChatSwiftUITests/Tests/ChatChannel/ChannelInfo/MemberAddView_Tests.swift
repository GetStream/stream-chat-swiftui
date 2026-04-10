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

@MainActor class MemberAddView_Tests: StreamChatTestCase {
    func test_memberAddView_snapshot() {
        // Given
        let searchController = ChatUserSearchController_Mock.mock(client: chatClient)
        let users = ChannelInfoMockUtils.generateMockUsers(count: 20)
        searchController.users_mock = users
        let viewModel = MemberAddViewModel(
            loadedUserIds: [],
            searchController: searchController
        )

        // When
        let view = MemberAddView(factory: DefaultTestViewFactory.shared, viewModel: viewModel, onConfirm: { _ in })
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }

    func test_memberAddView_selectedUsersSnapshot() {
        // Given
        let searchController = ChatUserSearchController_Mock.mock(client: chatClient)
        let users = ChannelInfoMockUtils.generateMockUsers(count: 10)
        searchController.users_mock = users
        let viewModel = MemberAddViewModel(
            loadedUserIds: [],
            searchController: searchController
        )
        viewModel.toggleUser(users[1])
        viewModel.toggleUser(users[3])

        // When
        let view = MemberAddView(factory: DefaultTestViewFactory.shared, viewModel: viewModel, onConfirm: { _ in })
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }

    func test_memberAddView_alreadyMemberSnapshot() {
        // Given
        let searchController = ChatUserSearchController_Mock.mock(client: chatClient)
        let users = ChannelInfoMockUtils.generateMockUsers(count: 10)
        searchController.users_mock = users
        let alreadyMemberIds = Array(users.prefix(3)).map(\.id)
        let viewModel = MemberAddViewModel(
            loadedUserIds: alreadyMemberIds,
            searchController: searchController
        )

        // When
        let view = MemberAddView(factory: DefaultTestViewFactory.shared, viewModel: viewModel, onConfirm: { _ in })
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }
}
