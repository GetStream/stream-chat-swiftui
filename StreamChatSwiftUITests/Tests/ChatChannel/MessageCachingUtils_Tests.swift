//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class MessageCachingUtils_Tests: XCTestCase {
    
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
}
