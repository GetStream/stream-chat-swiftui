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
    
    private var initialReusingState = false
    
    override func setUpWithError() throws {
        initialReusingState = StreamRuntimeCheck._isDatabaseObserverItemReusingEnabled
        StreamRuntimeCheck._isDatabaseObserverItemReusingEnabled = false
    }
    
    override func tearDownWithError() throws {
        StreamRuntimeCheck._isDatabaseObserverItemReusingEnabled = initialReusingState
    }

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
    
    func test_messageCachingUtils_userDisplayInfoWithoutCaching() {
        // Given
        StreamRuntimeCheck._isDatabaseObserverItemReusingEnabled = true
        let utils = MessageCachingUtils()
        let authorId: String = .unique
        let messageId: MessageId = .unique
        let cid: ChannelId = .unique
        let url1 = URL(string: "https://imageurl.com")
        let author1 = ChatUser.mock(id: authorId, name: "Martin", imageURL: url1)
        let message1 = ChatMessage.mock(
            id: messageId,
            cid: cid,
            text: "Test message",
            author: author1
        )
        let url2 = URL(string: "https://anotherimageurl.com")
        let author2 = ChatUser.mock(id: authorId, name: "Toomas", imageURL: url2)
        let message2 = ChatMessage.mock(
            id: messageId,
            cid: cid,
            text: "Test message",
            author: author2
        )
        
        // When
        let authorInfo1 = utils.authorInfo(from: message1)
        let authorInfo2 = utils.authorInfo(from: message2)
        
        // Then
        // Accessing the same message returns updated author information
        XCTAssertEqual("Martin", authorInfo1.name)
        XCTAssertEqual(url1, authorInfo1.imageURL)
        XCTAssertEqual("Toomas", authorInfo2.name)
        XCTAssertEqual(url2, authorInfo2.imageURL)
    }
}

extension UserDisplayInfo: Equatable {
    public static func == (lhs: UserDisplayInfo, rhs: UserDisplayInfo) -> Bool {
        lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.imageURL == rhs.imageURL &&
            lhs.role == rhs.role
    }
}
