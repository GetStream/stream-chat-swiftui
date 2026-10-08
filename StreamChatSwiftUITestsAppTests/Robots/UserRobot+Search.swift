//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest

// MARK: Actions

extension UserRobot {
    @discardableResult
    func search(_ text: String) -> Self {
        // On older iOS versions the navigation bar search field stays hidden until the list is pulled down.
        if !SearchPage.field.wait(timeout: XCUIElement.probeTimeout).exists {
            ChannelListPage.list.swipeDown()
        }
        SearchPage.field.wait().safeTap()
        SearchPage.field.typeText(text)
        return self
    }

    @discardableResult
    func tapOnSearchResult(at index: Int = 0) -> Self {
        SearchPage.results.waitCount(index + 1).element(boundBy: index).waitForHitPoint().safeTap()
        return self
    }
}

// MARK: Asserts

extension UserRobot {
    @discardableResult
    func assertSearchResultsCount(_ expectedCount: Int, file: StaticString = #filePath, line: UInt = #line) -> Self {
        let actualCount = SearchPage.results.waitCount(expectedCount, exact: true).count
        XCTAssertEqual(expectedCount, actualCount, file: file, line: line)
        return self
    }

    @discardableResult
    func assertChannelInSearchResults(_ name: String, at index: Int = 0, file: StaticString = #filePath, line: UInt = #line) -> Self {
        let result = SearchPage.results.waitCount(index + 1).element(boundBy: index)
        XCTAssertTrue(
            SearchPage.channelName(name, in: result).wait().exists,
            "Channel '\(name)' is not shown in search results",
            file: file,
            line: line
        )
        return self
    }

    @discardableResult
    func assertMessageInSearchResults(_ text: String, at index: Int = 0, file: StaticString = #filePath, line: UInt = #line) -> Self {
        let result = SearchPage.results.waitCount(index + 1).element(boundBy: index)
        XCTAssertTrue(
            SearchPage.messageText(text, in: result).wait().exists,
            "Message '\(text)' is not shown in search results",
            file: file,
            line: line
        )
        return self
    }
}

extension UserRobot {
    /// Counts the channel names, since the swipe action buttons share the channel item identifier.
    @discardableResult
    func assertChannelNamesCount(_ expectedCount: Int, file: StaticString = #filePath, line: UInt = #line) -> Self {
        let names = ChannelListPage.list.staticTexts.matching(identifier: "ChatTitleView")
        XCTAssertEqual(expectedCount, names.waitCount(expectedCount, exact: true).count, file: file, line: line)
        return self
    }
}
