//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class DateUtils_Tests: XCTestCase {

    func test_timeAgoNow() throws {
        // Given
        let expected = "last seen just one second ago"

        // When
        let timeAgo = DateUtils.timeAgo(relativeTo: Date())

        // Then
        XCTAssert(timeAgo == expected)
    }

    func test_timeAgoFuture() throws {
        // Given
        let date = Calendar.current.date(byAdding: .second, value: 60, to: Date())!

        // When
        let timeAgo = DateUtils.timeAgo(relativeTo: date)

        // Then
        XCTAssert(timeAgo == nil)
    }

    func test_timeAgo1MinuteAgo() throws {
        // Given
        let date = Calendar.current.date(byAdding: .second, value: -60, to: Date())!
        let expected = "last seen one minute ago"

        // When
        let timeAgo = DateUtils.timeAgo(relativeTo: date)

        // Then
        XCTAssert(timeAgo == expected)
    }

    func test_timeAgo59SecondsAgo() throws {
        // Given
        let date = Calendar.current.date(byAdding: .second, value: -59, to: Date())!
        let expected = "last seen 59 seconds ago"

        // When
        let timeAgo = DateUtils.timeAgo(relativeTo: date)

        // Then
        XCTAssert(timeAgo == expected)
    }

    func test_timeAgo42SecondsAgo() throws {
        // Given
        let date = Calendar.current.date(byAdding: .second, value: -42, to: Date())!
        let expected = "last seen 42 seconds ago"

        // When
        let timeAgo = DateUtils.timeAgo(relativeTo: date)

        // Then
        XCTAssert(timeAgo == expected)
    }

    func test_timeAgo42MinutesAgo() throws {
        // Given
        let date = Calendar.current.date(byAdding: .minute, value: -42, to: Date())!
        let expected = "last seen 42 minutes ago"

        // When
        let timeAgo = DateUtils.timeAgo(relativeTo: date)

        // Then
        XCTAssert(timeAgo == expected)
    }

    func test_timeAgo42DaysAgo() throws {
        // Given
        let date = Calendar.current.date(byAdding: .day, value: -42, to: Date())!
        let expected = "last seen one month ago"

        // When
        let timeAgo = DateUtils.timeAgo(relativeTo: date)

        // Then
        XCTAssert(timeAgo == expected)
    }

    func test_timeAgo42WeeksAgo() throws {
        // Given
        let date = Calendar.current.date(byAdding: .day, value: -42 * 7, to: Date())!
        let expected = "last seen 9 months ago"

        // When
        let timeAgo = DateUtils.timeAgo(relativeTo: date)

        // Then
        XCTAssert(timeAgo == expected)
    }

    func test_timeAgo4HoursAgo() {
        // Given
        let date = Calendar.current.date(byAdding: .hour, value: -4, to: Date())!
        let expected = "last seen 4 hours ago"

        // When
        let timeAgo = DateUtils.timeAgo(relativeTo: date)

        // Then
        XCTAssert(timeAgo == expected)
    }

    func test_timeAgo5DaysAgo() throws {
        // Given
        let date = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let expected = "last seen 5 days ago"

        // When
        let timeAgo = DateUtils.timeAgo(relativeTo: date)

        // Then
        XCTAssert(timeAgo == expected)
    }

    func test_timeAgo3WeeksAgo() throws {
        // Given
        let date = Calendar.current.date(byAdding: .day, value: -3 * 7, to: Date())!
        let expected = "last seen 3 weeks ago"

        // When
        let timeAgo = DateUtils.timeAgo(relativeTo: date)

        // Then
        XCTAssert(timeAgo == expected)
    }
}
