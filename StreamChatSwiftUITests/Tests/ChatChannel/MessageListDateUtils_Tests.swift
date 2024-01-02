//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class MessageListDateUtils_Tests: StreamChatTestCase {

    let testMessage = ChatMessage.mock(
        id: .unique,
        cid: .unique,
        text: "Test message 1",
        author: .mock(id: .unique),
        createdAt: Date(timeIntervalSince1970: 10000)
    )
    let testMessageSameDay = ChatMessage.mock(
        id: .unique,
        cid: .unique,
        text: "Test message 2",
        author: .mock(id: .unique),
        createdAt: Date(timeIntervalSince1970: 120)
    )
    let testMessageOtherDay = ChatMessage.mock(
        id: .unique,
        cid: .unique,
        text: "Test message 3",
        author: .mock(id: .unique),
        createdAt: Date(timeIntervalSince1970: -100_000)
    )

    private lazy var messages = LazyCachedMapCollection(source: [testMessage], map: { $0 })
    private lazy var messagesSameDay = LazyCachedMapCollection(source: [testMessage, testMessageSameDay], map: { $0 })
    private lazy var messagesDifferentDay = LazyCachedMapCollection(source: [testMessage, testMessageOtherDay], map: { $0 })

    func test_indexForMessageDate_messageListConfig() {
        // Given
        let messageListConfig = MessageListConfig(dateIndicatorPlacement: .messageList)
        let messageListDateUtils = MessageListDateUtils(messageListConfig: messageListConfig)

        // When
        let index = messageListDateUtils.indexForMessageDate(message: testMessage, in: messages)

        // Then
        XCTAssert(index == 0)
    }

    func test_indexForMessageDate_overlayConfig() {
        // Given
        let messageListConfig = MessageListConfig(dateIndicatorPlacement: .overlay)
        let messageListDateUtils = MessageListDateUtils(messageListConfig: messageListConfig)

        // When
        let index = messageListDateUtils.indexForMessageDate(message: testMessage, in: messages)

        // Then
        XCTAssert(index == nil)
    }

    func test_indexForMessage_overlayConfig() {
        // Given
        let messageListConfig = MessageListConfig(dateIndicatorPlacement: .overlay)
        let messageListDateUtils = MessageListDateUtils(messageListConfig: messageListConfig)

        // When
        let index = messageListDateUtils.index(for: testMessage, in: messages)

        // Then
        XCTAssert(index == 0)
    }

    func test_showMessageDate_nilIndex() {
        // Given
        let messageListConfig = MessageListConfig(dateIndicatorPlacement: .overlay)
        let messageListDateUtils = MessageListDateUtils(messageListConfig: messageListConfig)

        // When
        let date = messageListDateUtils.showMessageDate(for: nil, in: messages)

        // Then
        XCTAssert(date == nil)
    }

    func test_showMessageDate_singleMessage() {
        // Given
        let messageListConfig = MessageListConfig(dateIndicatorPlacement: .overlay)
        let messageListDateUtils = MessageListDateUtils(messageListConfig: messageListConfig)

        // When
        let date = messageListDateUtils.showMessageDate(for: 0, in: messages)

        // Then
        XCTAssert(date != nil)
    }

    func test_showMessageDate_sameDay() {
        // Given
        let messageListConfig = MessageListConfig(dateIndicatorPlacement: .overlay)
        let messageListDateUtils = MessageListDateUtils(messageListConfig: messageListConfig)

        // When
        let dateFirst = messageListDateUtils.showMessageDate(for: 0, in: messagesSameDay)
        let dateSecond = messageListDateUtils.showMessageDate(for: 1, in: messagesSameDay)

        // Then
        XCTAssert(dateFirst == nil)
        XCTAssert(dateSecond != nil)
    }

    func test_showMessageDate_differentDay() {
        // Given
        let messageListConfig = MessageListConfig(dateIndicatorPlacement: .overlay)
        let messageListDateUtils = MessageListDateUtils(messageListConfig: messageListConfig)

        // When
        let dateFirst = messageListDateUtils.showMessageDate(for: 0, in: messagesDifferentDay)
        let dateSecond = messageListDateUtils.showMessageDate(for: 1, in: messagesDifferentDay)

        // Then
        XCTAssert(dateFirst != nil)
        XCTAssert(dateSecond != nil)
    }
}
