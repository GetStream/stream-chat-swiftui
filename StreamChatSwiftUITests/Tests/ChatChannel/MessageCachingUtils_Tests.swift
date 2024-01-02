//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class MessageCachingUtils_Tests: StreamChatTestCase {

    let author = ChatUser.mock(
        id: "test",
        name: "Test",
        imageURL: URL(string: "https://test.com")!
    )
    lazy var message = ChatMessage.mock(
        id: .unique,
        cid: .unique,
        text: "Test",
        author: author,
        quotedMessage: .mock(
            id: .unique,
            cid: .unique,
            text: "Quoted",
            author: author
        )
    )

    func test_messageCachingUtils_authorId() {
        // Given
        let utils = MessageCachingUtils()

        // When
        let authorIdInitial = utils.authorId(for: message)
        let authorIdCached = utils.authorId(for: message)

        // Then
        XCTAssert(authorIdInitial == "test")
        XCTAssert(authorIdInitial == authorIdCached)
    }

    func test_messageCachingUtils_authorName() {
        // Given
        let utils = MessageCachingUtils()

        // When
        let authorNameInitial = utils.authorName(for: message)
        let authorNameCached = utils.authorName(for: message)

        // Then
        XCTAssert(authorNameInitial == "Test")
        XCTAssert(authorNameInitial == authorNameCached)
    }

    func test_messageCachingUtils_imageURL() {
        // Given
        let utils = MessageCachingUtils()

        // When
        let authorURLInitial = utils.authorImageURL(for: message)
        let authorURLCached = utils.authorImageURL(for: message)

        // Then
        XCTAssert(authorURLInitial?.absoluteString == "https://test.com")
        XCTAssert(authorURLInitial == authorURLCached)
    }

    func test_messageCachingUtils_quotedMessageAvailable() {
        // Given
        let utils = MessageCachingUtils()

        // When
        let quotedMessageInitial = utils.quotedMessage(for: message)
        let quotedMessageCached = utils.quotedMessage(for: message)

        // Then
        XCTAssert(quotedMessageInitial == quotedMessageCached)
    }

    func test_messageCachingUtils_quotedMessageNotAvailable() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: .unique,
            author: .mock(id: .unique)
        )
        let utils = MessageCachingUtils()

        // When
        let quotedMessageInitial = utils.quotedMessage(for: message)
        let quotedMessageCached = utils.quotedMessage(for: message)

        // Then
        XCTAssert(quotedMessageInitial == nil)
        XCTAssert(quotedMessageCached == nil)
    }

    func test_messageCachingUtils_recreatingCache() {
        // Given
        let utils = MessageCachingUtils()

        // When
        let authorIdInitial = utils.authorId(for: message)
        utils.clearCache()
        let authorIdAfterClear = utils.authorId(for: message)

        // Then
        XCTAssert(authorIdInitial == "test")
        XCTAssert(authorIdInitial == authorIdAfterClear)
    }

    func test_messageCachingUtils_userDisplayInfo() {
        // Given
        let id: String = .unique
        let url = URL(string: "https://imageurl.com")
        let author = ChatUser.mock(id: id, name: "Martin", imageURL: url)
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Test message",
            author: author
        )
        let utils = MessageCachingUtils()

        // When
        let authorInfo = utils.authorInfo(from: message)
        let userDisplayInfo = message.authorDisplayInfo

        // Then
        XCTAssert(authorInfo == userDisplayInfo)
        XCTAssert(userDisplayInfo.id == id)
        XCTAssert(userDisplayInfo.name == author.name)
        XCTAssert(userDisplayInfo.imageURL == url)
    }

    func test_messageCachingUtils_userDisplayInfoIdExisting() {
        // Given
        let id: String = .unique
        let url = URL(string: "https://imageurl.com")
        let author = ChatUser.mock(id: id, name: "Martin", imageURL: url)
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Test message",
            author: author
        )
        let utils = MessageCachingUtils()

        // When
        let authorInfo = utils.authorInfo(from: message)
        let userDisplayInfo = utils.userDisplayInfo(with: id)

        // Then
        XCTAssert(userDisplayInfo != nil)
        XCTAssert(authorInfo == userDisplayInfo)
        XCTAssert(userDisplayInfo!.id == id)
        XCTAssert(userDisplayInfo!.name == author.name)
        XCTAssert(userDisplayInfo!.imageURL == url)
    }

    func test_messageCachingUtils_userDisplayInfoIdNonExisting() {
        let utils = MessageCachingUtils()

        // When
        let userDisplayInfo = utils.userDisplayInfo(with: "some id")

        // Then
        XCTAssert(userDisplayInfo == nil)
    }
}

extension UserDisplayInfo: Equatable {
    public static func == (lhs: UserDisplayInfo, rhs: UserDisplayInfo) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.imageURL == rhs.imageURL
    }
}
