//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import XCTest

final class ChatThreadListItemView_Tests: StreamChatTestCase {
    var mockThread: ChatThread!

    var mockYoda = ChatUser.mock(id: .unique, name: "Yoda", imageURL: nil)
    var currentUser: ChatUser!

    override func setUp() {
        super.setUp()

        let circleImage = UIImage.circleImage
        streamChat?.utils.channelHeaderLoader.placeholder1 = circleImage
        streamChat?.utils.channelHeaderLoader.placeholder2 = circleImage
        streamChat?.utils.channelHeaderLoader.placeholder3 = circleImage
        streamChat?.utils.channelHeaderLoader.placeholder4 = circleImage

        currentUser = ChatUser.mock(id: StreamChatTestCase.currentUserId, name: "Vader", imageURL: nil)

        mockThread = .mock(
            parentMessage: .mock(text: "Parent Message", author: mockYoda),
            channel: .mock(cid: .unique, name: "Star Wars Channel"),
            createdBy: currentUser,
            replyCount: 3,
            participantCount: 2,
            threadParticipants: [
                .mock(user: mockYoda),
                .mock(user: currentUser)
            ],
            lastMessageAt: .unique,
            createdAt: .unique,
            updatedAt: .unique,
            title: nil,
            latestReplies: [
                .mock(text: "First Message", author: mockYoda),
                .mock(text: "Second Message", author: currentUser),
                .mock(text: "Third Message", author: mockYoda)
            ],
            reads: [],
            extraData: [:]
        )
    }

    func test_threadListItem_default() throws {
        let view = ChatThreadListItem(thread: mockThread)
            .frame(width: defaultScreenSize.width)

        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_threadListItem_withUnreads() throws {
        let thread = mockThread
            .with(reads: [.mock(user: currentUser, lastReadAt: .unique, unreadMessagesCount: 4)])
        
        let view = ChatThreadListItem(thread: thread)
            .frame(width: defaultScreenSize.width)
        
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_threadListItem_withTitle() throws {
        let thread = mockThread
            .with(title: "Thread title")

        let view = ChatThreadListItem(thread: thread)
            .frame(width: defaultScreenSize.width)

        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_threadListItem_withParentMessageDeleted() throws {
        let thread = mockThread
            .with(parentMessage: .mock(text: "Parent Message", deletedAt: .unique))

        let view = ChatThreadListItem(thread: thread)
            .frame(width: defaultScreenSize.width)

        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_threadListItem_withLastReplyDeleted() throws {
        let thread = mockThread
            .with(latestReplies: [
                .mock(text: "First Message", author: mockYoda),
                .mock(text: "Second Message", author: currentUser),
                .mock(text: "Third Message", author: mockYoda, deletedAt: .unique)
            ])

        let view = ChatThreadListItem(thread: thread)
            .frame(width: defaultScreenSize.width)

        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_threadListItem_whenAttachments() throws {
        let thread = mockThread
            .with(
                parentMessage: .mock(text: "", attachments: [.dummy(type: .giphy)]),
                latestReplies: [
                    .mock(text: "", author: mockYoda, attachments: [.dummy(type: .audio)])
                ]
            )

        let view = ChatThreadListItem(thread: thread)
            .frame(width: defaultScreenSize.width)

        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_threadListItem_whenAttachmentIsPoll() throws {
        let thread = mockThread
            .with(
                parentMessage: .mock(text: "", poll: .mock(name: "Who is better?")),
                latestReplies: [
                    .mock(text: "", author: mockYoda, poll: .mock(name: "Who is worse?"))
                ]
            )

        let view = ChatThreadListItem(thread: thread)
            .frame(width: defaultScreenSize.width)

        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}

extension ChatThreadListItem {
    init(thread: ChatThread) {
        self.init(viewModel: ChatThreadListItemViewModel(thread: thread))
    }
}
