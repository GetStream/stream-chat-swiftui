//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest

// MARK: Actions

extension UserRobot {
    @discardableResult
    func markMessageAsUnread(_ text: String) -> Self {
        let messageCell = MessageListPage.cells
            .containing(NSPredicate(format: "identifier == 'MessageTextView' AND label == %@", text))
            .firstMatch
            .wait()
        MessageListPage.Attributes.messageBubble(in: messageCell).press(forDuration: 1)
        UnreadMessagesPage.markUnreadAction.wait().safeTap()
        return self
    }

    @discardableResult
    func tapOnJumpToUnreadButton() -> Self {
        UnreadMessagesPage.jumpToUnreadButton.wait().safeTap()
        return self
    }

    @discardableResult
    func dismissUnreadIndicator() -> Self {
        UnreadMessagesPage.jumpToUnreadDismissButton.wait().safeTap()
        return self
    }
}

// MARK: Asserts

extension UserRobot {
    /// Message cells are matched by text since their accessibility order depends on the iOS version.
    @discardableResult
    func assertMessageIsShown(_ text: String, file: StaticString = #filePath, line: UInt = #line) -> Self {
        let cell = MessageListPage.cells
            .containing(NSPredicate(format: "identifier == 'MessageTextView' AND label == %@", text))
            .firstMatch
        XCTAssertTrue(cell.wait(timeout: XCUIElement.longWaitTimeout).exists, "Message '\(text)' is not shown", file: file, line: line)
        return self
    }

    @discardableResult
    func assertUnreadSeparator(file: StaticString = #filePath, line: UInt = #line) -> Self {
        let separator = UnreadMessagesPage.unreadSeparator.wait(timeout: XCUIElement.longWaitTimeout)
        XCTAssertTrue(separator.exists, "Unread separator is not shown", file: file, line: line)
        XCTAssertTrue(separator.waitForHitPoint().isHittable, "Unread separator is not on screen", file: file, line: line)
        return self
    }

    @discardableResult
    func assertJumpToUnreadButton(
        unreadCount: Int? = nil,
        isDisplayed: Bool = true,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let button = UnreadMessagesPage.jumpToUnreadButton
        guard isDisplayed else {
            XCTAssertFalse(button.waitForDisappearance().exists, "Jump to unread button is shown", file: file, line: line)
            return self
        }
        XCTAssertTrue(button.wait(timeout: XCUIElement.longWaitTimeout).exists, "Jump to unread button is not shown", file: file, line: line)
        if let unreadCount {
            let expectedText = "\(unreadCount) unread"
            _ = button.waitForText(expectedText, mustBeEqual: false)
            XCTAssertTrue(button.label.contains(expectedText), "'\(button.label)' has no '\(expectedText)'", file: file, line: line)
        }
        return self
    }

    @discardableResult
    func assertChannelUnreadCount(
        _ count: Int,
        channelCellIndex: Int = 0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let cell = ChannelListPage.cells.waitCount(channelCellIndex + 1).element(boundBy: channelCellIndex)
        let unreadCount = UnreadMessagesPage.channelUnreadCount(in: cell)
        if count > 0 {
            XCTAssertEqual("\(count)", unreadCount.wait().waitForText("\(count)").label, file: file, line: line)
        } else {
            XCTAssertFalse(unreadCount.waitForDisappearance().exists, "Unread count is shown", file: file, line: line)
        }
        return self
    }
}
