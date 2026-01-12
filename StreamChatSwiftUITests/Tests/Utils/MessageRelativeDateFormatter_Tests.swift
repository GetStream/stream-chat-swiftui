//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

final class MessageRelativeDateFormatter_Tests: StreamChatTestCase {
    private var formatter: MessageRelativeDateFormatter!
    
    override func setUp() {
        super.setUp()
        formatter = MessageRelativeDateFormatter()
        formatter.locale = Locale(identifier: "en_UK")
        formatter.todayFormatter.locale = Locale(identifier: "en_UK")
        formatter.yesterdayFormatter.locale = Locale(identifier: "en_UK")
    }
    
    override func tearDown() {
        super.tearDown()
        formatter = nil
    }
    
    func test_showingTimeOnly() throws {
        let date = try XCTUnwrap(Calendar.current.date(bySettingHour: 1, minute: 2, second: 3, of: Date()))
        let result = formatter.string(from: date)
        let expected = formatter.todayFormatter.string(from: date)
        XCTAssertEqual(expected, result)
        XCTAssertEqual("01:02", result)
    }
    
    func test_showingYesterday() throws {
        let date = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -1, to: Date()))
        let result = formatter.string(from: date)
        let expected = formatter.yesterdayFormatter.string(from: date)
        XCTAssertEqual(expected, result)
        XCTAssertEqual("Yesterday", result)
    }
    
    func test_showingWeekday() throws {
        let date = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -6, to: Date()))
        let result = formatter.string(from: date)
        let expected = formatter.weekdayFormatter.string(from: date)
        XCTAssertEqual(expected, result)
    }
    
    func test_showingShortDate() throws {
        let components = DateComponents(
            timeZone: TimeZone(secondsFromGMT: 0),
            year: 2025,
            month: 1,
            day: 15,
            hour: 3,
            minute: 4,
            second: 5
        )
        let date = try XCTUnwrap(Calendar.current.date(from: components))
        let result = formatter.string(from: date)
        XCTAssertEqual("15/01/2025", result)
    }
}
