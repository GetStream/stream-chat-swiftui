//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest

// MARK: Actions

extension UserRobot {
    @discardableResult
    func openThreadList() -> Self {
        ThreadListPage.openButton.wait().safeTap()
        return self
    }

    @discardableResult
    func openThreadFromThreadList(parentMessageText: String) -> Self {
        ThreadListPage.parentMessage(parentMessageText).wait().waitForHitPoint().safeTap()
        return self
    }
}

// MARK: Asserts

extension UserRobot {
    @discardableResult
    func assertThreadListIsEmpty(file: StaticString = #filePath, line: UInt = #line) -> Self {
        XCTAssertTrue(ThreadListPage.emptyView.wait().exists, "Thread list is not empty", file: file, line: line)
        return self
    }

    @discardableResult
    func assertThreadInThreadList(
        parentMessageText: String,
        replies: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        XCTAssertTrue(
            ThreadListPage.parentMessage(parentMessageText).wait().exists,
            "Thread with '\(parentMessageText)' is not shown",
            file: file,
            line: line
        )
        XCTAssertTrue(
            ThreadListPage.repliesCountLabel(replies).wait().exists,
            "Replies count \(replies) is not shown",
            file: file,
            line: line
        )
        return self
    }

    @discardableResult
    func assertThreadUnreadCountInThreadList(
        _ count: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let badge = ThreadListPage.unreadBadge
        if count == 0 {
            XCTAssertFalse(badge.waitForDisappearance().exists, "Unread badge is shown", file: file, line: line)
        } else {
            let actualText = badge.wait().waitForText("\(count)").text
            XCTAssertEqual("\(count)", actualText, file: file, line: line)
        }
        return self
    }
}

extension UserRobot {
    /// Looks the message up by its text, since the thread also lists the parent message.
    @discardableResult
    func assertThreadMessage(_ text: String, file: StaticString = #filePath, line: UInt = #line) -> Self {
        assertThreadIsOpen(file: file, line: line)
        let message = app.staticTexts
            .matching(NSPredicate(format: "identifier == 'MessageTextView' AND label == %@", text))
            .firstMatch
        XCTAssertTrue(message.wait().exists, "Message '\(text)' is not shown in the thread", file: file, line: line)
        return self
    }
}
