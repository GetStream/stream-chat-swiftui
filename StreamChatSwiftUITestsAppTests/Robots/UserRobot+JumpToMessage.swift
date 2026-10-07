//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest

// MARK: Actions

extension UserRobot {
    /// The cell of the message with the given text. The text of a quoted message has another identifier, so it does not match.
    func messageCell(withText text: String) -> XCUIElement {
        MessageListPage.cells.containing(messageTextPredicate(text)).firstMatch
    }

    @discardableResult
    func copyMessageId(_ text: String) -> Self {
        openContextMenu(forMessageWithText: text)
        MessageListPage.ContextMenu.copyMessageId.element.wait().safeTap()
        return self
    }

    /// Opens the channel from the channel list's swipe actions, at the message id that was copied before.
    @discardableResult
    func openChannelWithCopiedMessageId(channelCellIndex: Int = 0) -> Self {
        swipeChannel(channelCellIndex: channelCellIndex)
        tapOnMoreSwipeAction()
        ChannelActionsPage.Sheet.showChannelWithMessageId.wait().safeTap()

        let textField = ChannelActionsPage.ShowChannelWithMessageId.textField.wait()
        let pasteButton = MessageListPage.Composer.pasteButton
        for _ in 0..<5 {
            textField.tap()
            if pasteButton.wait(timeout: XCUIElement.probeTimeout).exists { break }
        }
        pasteButton.safeTap()
        ChannelActionsPage.ShowChannelWithMessageId.showChannelButton.wait().safeTap()
        return self
    }

    @discardableResult
    func tapOnRepliedToThreadButton(inMessageWithText text: String) -> Self {
        messageCell(withText: text)
            .buttons
            .matching(NSPredicate(format: "label CONTAINS 'Replied to a thread'"))
            .firstMatch
            .wait()
            // Only the trailing "View" title is tappable, the button frame also covers the annotation title.
            .coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5))
            .tap()
        return self
    }

    @discardableResult
    func scrollMessageListDown(untilMessageIsVisible text: String, maxSwipes: Int = 20) -> Self {
        let cell = messageCell(withText: text)
        for _ in 0..<maxSwipes {
            if cell.exists && cell.isHittable { break }
            MessageListPage.list.swipeUp()
        }
        return self
    }

    @discardableResult
    func scrollMessageListUp(untilMessageIsVisible text: String, maxSwipes: Int = 20) -> Self {
        let cell = messageCell(withText: text)
        for _ in 0..<maxSwipes {
            if cell.exists && cell.isHittable { break }
            MessageListPage.list.swipeDown()
        }
        return self
    }

    private func messageTextPredicate(_ text: String) -> NSPredicate {
        NSPredicate(format: "identifier == 'MessageTextView' AND label == %@", text)
    }
}

// MARK: Asserts

extension UserRobot {
    @discardableResult
    func assertMessageIsVisible(
        withText text: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let cell = messageCell(withText: text).wait()
        XCTAssertTrue(cell.exists, "Message '\(text)' is not loaded", file: file, line: line)
        XCTAssertTrue(cell.waitForHitPoint().isHittable, "Message '\(text)' is not visible", file: file, line: line)
        return self
    }

    /// Unlike `assertMessageIsVisible`, it accepts a message partly covered by the navigation bar after a jump.
    @discardableResult
    func assertMessageIsOnScreen(
        withText text: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let cells = MessageListPage.cells.containing(messageTextPredicate(text))
        XCTAssertTrue(cells.firstMatch.wait().exists, "Message '\(text)' is not loaded", file: file, line: line)
        // The previous screen's list can stay in the tree after navigating, so look for any match that is visible.
        let window = app.windows.firstMatch.frame
        let visibleTop = app.navigationBars.firstMatch.exists ? app.navigationBars.firstMatch.frame.maxY : window.minY
        let endTime = Date().addingTimeInterval(XCUIElement.waitTimeout)
        var isOnScreen = false
        repeat {
            isOnScreen = cells.allElementsBoundByIndex.contains { cell in
                cell.exists && cell.frame.intersects(window) && cell.frame.maxY > visibleTop
            }
            if !isOnScreen { Thread.sleep(forTimeInterval: 0.2) }
        } while !isOnScreen && Date() < endTime
        XCTAssertTrue(isOnScreen, "Message '\(text)' is not on screen", file: file, line: line)
        return self
    }

    @discardableResult
    func assertMessageIsNotLoaded(
        withText text: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        XCTAssertFalse(messageCell(withText: text).exists, "Message '\(text)' is loaded", file: file, line: line)
        return self
    }

    /// The jump highlight lasts well under a second, so the tree is polled without waiting for the app to idle.
}
