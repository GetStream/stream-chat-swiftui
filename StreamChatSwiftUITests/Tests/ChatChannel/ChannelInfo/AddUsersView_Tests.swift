//
// Copyright © 2024 Stream.io Inc. All rights reserved.
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
        let users = ChannelInfoMockUtils.generateMockUsers(count: 20)
        let userSearch = UserSearch_Mock.mock()
        userSearch.setUsers(users)
        let viewModel = AddUsersViewModel(
            loadedUserIds: [],
            userSearch: userSearch
        )

        // When
        let view = AddUsersView(viewModel: viewModel, onUserTap: { _ in })
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}
