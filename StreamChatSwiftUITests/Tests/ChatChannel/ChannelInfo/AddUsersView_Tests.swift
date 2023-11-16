//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class AddUsersView_Tests: StreamChatTestCase {

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
        let view = AddUsersView(viewModel: viewModel, onUserTap: { _ in })
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}
