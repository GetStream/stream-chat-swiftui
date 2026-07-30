//
// Copyright © 2026 Stream.io Inc. All rights reserved.
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

        streamChat?.utils.messageListConfig = .init(draftMessagesEnabled: true)

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

        AssertSnapshot(view, variants: [.defaultLight, .defaultDark], size: defaultScreenSize)
    }

    func test_threadListItem_withUnreads() throws {
        let thread = mockThread
            .with(reads: [.mock(user: currentUser, lastReadAt: .unique, unreadMessagesCount: 4)])
        
        let view = ChatThreadListItem(thread: thread)
            .frame(width: defaultScreenSize.width)
        
        AssertSnapshot(view, variants: [.defaultLight, .defaultDark], size: defaultScreenSize)
    }

    func test_threadListItem_withTitle() throws {
        let thread = mockThread
            .with(title: "Thread title")

        let view = ChatThreadListItem(thread: thread)
            .frame(width: defaultScreenSize.width)

        AssertSnapshot(view, variants: [.defaultLight, .defaultDark], size: defaultScreenSize)
    }

    func test_threadListItem_withParentMessageDeleted() throws {
        let thread = mockThread
            .with(parentMessage: .mock(text: "Parent Message", author: mockYoda, deletedAt: .unique))

        let view = ChatThreadListItem(thread: thread)
            .frame(width: defaultScreenSize.width)

        AssertSnapshot(view, variants: [.defaultLight, .defaultDark], size: defaultScreenSize)
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

        AssertSnapshot(view, variants: [.defaultLight, .defaultDark], size: defaultScreenSize)
    }

    func test_threadListItem_whenAttachments() throws {
        let thread = mockThread
            .with(
                parentMessage: .mock(text: "", author: mockYoda, attachments: [.dummy(type: .giphy)]),
                latestReplies: [
                    .mock(text: "", author: mockYoda, attachments: [.dummy(type: .audio)])
                ]
            )

        let view = ChatThreadListItem(thread: thread)
            .frame(width: defaultScreenSize.width)

        AssertSnapshot(view, variants: [.defaultLight, .defaultDark], size: defaultScreenSize)
    }

    func test_threadListItem_whenAttachmentIsPoll() throws {
        let thread = mockThread
            .with(
                parentMessage: .mock(text: "", author: mockYoda, poll: .mock(name: "Who is better?")),
                latestReplies: [
                    .mock(text: "", author: mockYoda, poll: .mock(name: "Who is worse?"))
                ]
            )

        let view = ChatThreadListItem(thread: thread)
            .frame(width: defaultScreenSize.width)

        AssertSnapshot(view, variants: [.defaultLight, .defaultDark], size: defaultScreenSize)
    }

    func test_threadListItem_whenParentMessageIsImageOnly() throws {
        let thread = mockThread
            .with(parentMessage: .mock(text: "", author: mockYoda, attachments: [try imageAttachment()]))

        let view = ChatThreadListItem(thread: thread)
            .frame(width: defaultScreenSize.width)

        AssertSnapshot(view, variants: [.defaultLight, .defaultDark], size: defaultScreenSize)
    }

    func test_threadListItem_whenParentMessageIsVideoOnly() throws {
        let thread = mockThread
            .with(parentMessage: .mock(text: "", author: mockYoda, attachments: [try videoAttachment()]))

        let view = ChatThreadListItem(thread: thread)
            .frame(width: defaultScreenSize.width)

        AssertSnapshot(view, variants: [.defaultLight, .defaultDark], size: defaultScreenSize)
    }

    func test_threadListItem_whenParentMessageIsFileWithoutTitle() throws {
        let thread = mockThread
            .with(parentMessage: .mock(text: "", author: mockYoda, attachments: [try fileAttachment(title: nil)]))

        let view = ChatThreadListItem(thread: thread)
            .frame(width: defaultScreenSize.width)

        AssertSnapshot(view, variants: [.defaultLight, .defaultDark], size: defaultScreenSize)
    }

    func test_threadListItem_whenThreadTitleIsBlankAndParentMessageIsImageOnly() throws {
        let thread = mockThread
            .with(parentMessage: .mock(text: "", author: mockYoda, attachments: [try imageAttachment()]))
            .with(title: "")

        let view = ChatThreadListItem(thread: thread)
            .frame(width: defaultScreenSize.width)

        AssertSnapshot(view, variants: [.defaultLight, .defaultDark], size: defaultScreenSize)
    }

    func test_threadListItemViewModel_whenThreadTitleIsBlank_usesParentMessagePreview() throws {
        let thread = mockThread
            .with(parentMessage: .mock(text: "", author: mockYoda, attachments: [try imageAttachment()]))
            .with(title: "   ")

        let viewModel = ChatThreadListItemViewModel(thread: thread)

        XCTAssertEqual(viewModel.parentMessageContentText, L10n.Channel.Item.photo)
        XCTAssertNotNil(viewModel.parentMessageAttachmentIcon)
    }

    func test_threadListItemViewModel_whenThreadTitleIsSet_hasNoAttachmentIcon() throws {
        let thread = mockThread
            .with(parentMessage: .mock(text: "", author: mockYoda, attachments: [try imageAttachment()]))
            .with(title: "Thread title")

        let viewModel = ChatThreadListItemViewModel(thread: thread)

        XCTAssertEqual(viewModel.parentMessageContentText, "Thread title")
        XCTAssertNil(viewModel.parentMessageAttachmentIcon)
    }

    func test_threadListItemViewModel_whenParentMessageIsDeleted_hasNoAttachmentIcon() throws {
        let thread = mockThread
            .with(parentMessage: .mock(
                text: "",
                author: mockYoda,
                deletedAt: .unique,
                attachments: [try imageAttachment()]
            ))

        let viewModel = ChatThreadListItemViewModel(thread: thread)

        XCTAssertNil(viewModel.parentMessageAttachmentIcon)
    }

    func test_threadListItem_whenDraftMessage() {
        let thread = mockThread
            .with(parentMessage: .mock(text: "Parent", draftReply: .mock(text: "Draft message")))

        let view = ChatThreadListItem(thread: thread)
            .frame(width: defaultScreenSize.width)

        AssertSnapshot(view, variants: [.defaultLight, .defaultDark], size: defaultScreenSize)
    }

    func test_threadListItem_whenDraftMessageHasAttachment() throws {
        let message = try DraftMessage.mock(text: "Draft message", attachments: [.dummy(payload: JSONEncoder().encode(
            ImageAttachmentPayload(
                title: "Test",
                imageRemoteURL: .localYodaImage,
                file: .init(url: ChatChannelTestHelpers.testFileURL)
            )
        ))])
        let thread = mockThread
            .with(parentMessage: .mock(
                text: "Parent",
                draftReply: message
            ))

        let view = ChatThreadListItem(thread: thread)
            .frame(width: defaultScreenSize.width)

        AssertSnapshot(view, variants: [.defaultLight, .defaultDark], size: defaultScreenSize)
    }

    // MARK: - Helpers

    private func imageAttachment() throws -> AnyChatMessageAttachment {
        .dummy(
            type: .image,
            payload: try JSONEncoder().encode(ImageAttachmentPayload(
                title: "Test",
                imageRemoteURL: .localYodaImage,
                file: .init(type: .png, size: 123, mimeType: nil)
            ))
        )
    }

    private func videoAttachment() throws -> AnyChatMessageAttachment {
        .dummy(
            type: .video,
            payload: try JSONEncoder().encode(VideoAttachmentPayload(
                title: "Test",
                videoRemoteURL: .localYodaImage,
                file: .init(type: .mp4, size: 123, mimeType: nil),
                extraData: nil
            ))
        )
    }

    private func fileAttachment(title: String?) throws -> AnyChatMessageAttachment {
        .dummy(
            type: .file,
            payload: try JSONEncoder().encode(FileAttachmentPayload(
                title: title,
                assetRemoteURL: .localYodaImage,
                file: .init(type: .pdf, size: 123, mimeType: nil),
                extraData: nil
            ))
        )
    }
}

extension ChatThreadListItem where Factory == DefaultViewFactory {
    init(thread: ChatThread) {
        self.init(viewModel: ChatThreadListItemViewModel(thread: thread))
    }
}
