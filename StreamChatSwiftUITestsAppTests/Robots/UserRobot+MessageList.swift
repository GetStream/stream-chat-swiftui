//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest

// MARK: Actions

extension UserRobot {
    @discardableResult
    func openThreadUsingRepliesButton(
        messageCellIndex: Int = 0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let messageCell = messageCell(withIndex: messageCellIndex, file: file, line: line)
        let threadButton = attributes.threadReplyCountButton(in: messageCell).wait()
        XCTAssertTrue(threadButton.exists, "There is no thread replies button", file: file, line: line)
        threadButton.safeTap()
        ThreadPage.alsoSendInChannelCheckbox.wait()
        return self
    }
}

// MARK: Asserts

extension UserRobot {
    @discardableResult
    func assertMessageTimestampCount(
        _ expectedCount: Int,
        timeout: Double = XCUIElement.waitTimeout,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let timestamps = app.staticTexts.matching(identifier: "MessageDateView")
        let endTime = Date().timeIntervalSince1970 + timeout
        while timestamps.count != expectedCount && Date().timeIntervalSince1970 < endTime {}
        XCTAssertEqual(expectedCount, timestamps.count, "Wrong number of message timestamps", file: file, line: line)
        return self
    }

    @discardableResult
    func assertMessageEditedLabel(
        at messageCellIndex: Int? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let messageCell = messageCell(withIndex: messageCellIndex, file: file, line: line)
        let timestamp = attributes.time(in: messageCell).wait()
        let label = timestamp.waitForText("Edited", mustBeEqual: false).label
        XCTAssertTrue(label.contains("Edited"), "Edited label is not shown, got: \(label)", file: file, line: line)
        return self
    }

    @discardableResult
    func assertComposerGrows(
        whenTypingLines lines: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let composer = MessageListPage.Composer.inputField
        let initialHeight = settledHeight(of: composer.wait())
        typeText((1...lines).map(String.init).joined(separator: "\n"))
        let updatedHeight = settledHeight(of: composer)
        XCTAssertGreaterThan(updatedHeight, initialHeight, "Composer did not grow", file: file, line: line)
        return self
    }

    @discardableResult
    func assertComposerDoesNotGrow(
        afterLines lines: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let composer = MessageListPage.Composer.inputField
        composer.wait()
        typeText((1...lines).map(String.init).joined(separator: "\n"))
        let heightAtLimit = settledHeight(of: composer)
        typeText("\n\(lines + 1)\n\(lines + 2)", obtainKeyboardFocus: false)
        let updatedHeight = settledHeight(of: composer)
        XCTAssertEqual(heightAtLimit, updatedHeight, "Composer grew beyond its limit", file: file, line: line)
        return self
    }

    private func settledHeight(of element: XCUIElement, timeout: Double = XCUIElement.waitTimeout) -> Double {
        var height = element.height
        let endTime = Date().timeIntervalSince1970 + timeout
        while Date().timeIntervalSince1970 < endTime {
            Thread.sleep(forTimeInterval: 0.5)
            let newHeight = element.height
            if newHeight == height { break }
            height = newHeight
        }
        return height
    }
}
