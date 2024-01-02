//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class MoreChannelActionsViewModel_Tests: StreamChatTestCase {

    @Injected(\.images) var images

    override func setUp() {
        super.setUp()
        let imageLoader = ImageLoader_Mock()
        let utils = Utils(imageLoader: imageLoader)
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }

    func test_moreActionsVM_membersLoaded() {
        // Given
        let memberId: String = .unique
        let viewModel = makeMoreActionsViewModel(
            members: [.mock(id: memberId, isOnline: true)]
        )

        // When
        let members = viewModel.members

        // Then
        XCTAssert(members.count == 1)
        XCTAssert(members[0].id == memberId)
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

    func test_moreActionsVM_imageLoading() {
        // Given
        let memberId: String = .unique
        let member: ChatChannelMember = .mock(id: memberId, isOnline: true)
        let viewModel = makeMoreActionsViewModel(
            members: [member]
        )

        // When
        let firstImage = viewModel.image(for: member)
        let secondImage = viewModel.image(for: member)
        let cachedImage = viewModel.memberAvatars[memberId]

        // Then
        XCTAssert(firstImage == images.userAvatarPlaceholder2)
        XCTAssert(secondImage == ImageLoader_Mock.defaultLoadedImage)
        XCTAssert(cachedImage != nil)
        XCTAssert(cachedImage == secondImage)
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
            for: channel,
            chatClient: chatClient,
            onDismiss: {},
            onError: { _ in }
        )

        let moreActionsVM = MoreChannelActionsViewModel(
            channel: channel,
            channelActions: channelActions
        )

        return moreActionsVM
    }
}
