//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

@MainActor class MoreChannelActionsViewModel_Tests: StreamChatTestCase {
    @Injected(\.images) var images

    func test_moreActionsVM_membersLoaded() throws {
        // Given
        let currentUserId = try XCTUnwrap(streamChat?.chatClient.currentUserId)
        let memberId: String = .unique
        let viewModel = makeMoreActionsViewModel(
            members: [
                .mock(id: memberId, isOnline: true),
                .mock(id: currentUserId, isOnline: true)
            ]
        )

        // When
        let members = viewModel.members

        // Then
        XCTAssert(members.count == 2)
        XCTAssert(members.map(\.id) == [memberId, currentUserId])
    }

    func test_moreActionsVM_chatHeaderInfo() {
        // Given
        let viewModel = makeMoreActionsViewModel()

        // When
        let title = viewModel.chatName
        let subtitle = viewModel.subtitleText

        // Then
        XCTAssert(title == "test")
        XCTAssert(subtitle == "Online")
    }

    // MARK: - private

    private func makeMoreActionsViewModel(
        members: [ChatChannelMember] = []
    ) -> MoreChannelActionsViewModel {
        var channelMembers = [ChatChannelMember]()
        if !members.isEmpty {
            channelMembers = members
        } else {
            channelMembers = [.mock(id: .unique, isOnline: true)]
        }
        let channel = ChatChannel.mockDMChannel(
            name: "test",
            lastActiveMembers: channelMembers
        )

        let channelActions = ChannelAction.defaultActions(
            for: SupportedMoreChannelActionsOptions(
                channel: channel,
                onDismiss: {},
                onError: { _ in }
            )
        )

        let moreActionsVM = MoreChannelActionsViewModel(
            channel: channel,
            channelActions: channelActions
        )

        return moreActionsVM
    }
}
