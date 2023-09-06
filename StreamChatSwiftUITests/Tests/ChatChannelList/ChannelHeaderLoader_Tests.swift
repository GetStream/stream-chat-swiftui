//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class ChannelHeaderLoader_Tests: StreamChatTestCase {

    @Injected(\.images) var images

    private let testURL = URL(string: "https://example.com")!

    override func setUp() {
        super.setUp()
        let imageLoader = ImageLoader_Mock()
        let utils = Utils(imageLoader: imageLoader)
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }

    func test_channelHeaderLoader_channelImageURL() {
        // Given
        let channel = ChatChannel.mockDMChannel(imageURL: testURL)

        // Then
        loadImagesAndAssert(
            for: channel,
            expectedInitialImage: images.userAvatarPlaceholder4,
            expectedLoadedImage: ImageLoader_Mock.defaultLoadedImage
        )
    }

    func test_channelHeaderLoader_directMessageChannel_otherMember() {
        // Given
        let channel = ChatChannel.mockDMChannel(
            lastActiveMembers: [.mock(id: .unique, imageURL: testURL)]
        )

        // Then
        loadImagesAndAssert(
            for: channel,
            expectedInitialImage: images.userAvatarPlaceholder3,
            expectedLoadedImage: ImageLoader_Mock.defaultLoadedImage
        )
    }

    func test_channelHeaderLoader_directMessageChannel_placeholder() {
        // Given
        let channel = ChatChannel.mockDMChannel(
            lastActiveMembers: [.mock(id: .unique)]
        )

        // Then
        loadImagesAndAssert(
            for: channel,
            expectedInitialImage: images.userAvatarPlaceholder4,
            expectedLoadedImage: images.userAvatarPlaceholder4
        )
    }

    func test_channelHeaderLoader_group_activeMembersEmpty() {
        // Given
        let channel = ChatChannel.mockNonDMChannel()

        // Then
        loadImagesAndAssert(
            for: channel,
            expectedInitialImage: images.userAvatarPlaceholder4,
            expectedLoadedImage: images.userAvatarPlaceholder4
        )
    }

    func test_channelHeaderLoader_group_activeMembersEmptyURLs() {
        // Given
        let channel = ChatChannel.mockNonDMChannel(
            lastActiveMembers: [.mock(id: .unique)]
        )

        // Then
        loadImagesAndAssert(
            for: channel,
            expectedInitialImage: images.userAvatarPlaceholder3,
            expectedLoadedImage: images.userAvatarPlaceholder3
        )
    }

    func test_channelHeaderLoader_group_activeMembersURLs() {
        // Given
        let channel = ChatChannel.mockNonDMChannel(
            lastActiveMembers: [.mock(id: .unique, imageURL: testURL)]
        )

        // Then
        loadImagesAndAssert(
            for: channel,
            expectedInitialImage: images.userAvatarPlaceholder4,
            expectedLoadedImage: nil
        )
    }

    // MARK: - private

    private func loadImagesAndAssert(
        for channel: ChatChannel,
        expectedInitialImage: UIImage,
        expectedLoadedImage: UIImage?
    ) {
        // Given
        let channelHeaderLoader = ChannelHeaderLoader()
        let expectation = self.expectation(description: "loadingImage")

        // When
        let firstImage = channelHeaderLoader.image(for: channel)
        var secondImage: UIImage!

        // Simulate image loaded and view re-draw invoked.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            secondImage = channelHeaderLoader.image(for: channel)
            expectation.fulfill()
        }

        waitForExpectations(timeout: defaultTimeout, handler: nil)

        // Then
        XCTAssert(firstImage == expectedInitialImage)
        if expectedLoadedImage != nil {
            XCTAssert(secondImage == expectedLoadedImage)
        } else {
            XCTAssert(firstImage != secondImage)
        }
    }
}
