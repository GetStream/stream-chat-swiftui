//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

extension UserRobot {
    @discardableResult
    func tapOnShuffleGiphyButton(messageCellIndex: Int = 0) -> Self {
        let messageCell = messageCell(withIndex: messageCellIndex)
        MessageListPage.Attributes.giphyShuffleButton(in: messageCell).wait().safeTap()
        return self
    }

    @discardableResult
    func tapOnCancelGiphyButton(messageCellIndex: Int = 0) -> Self {
        let messageCell = messageCell(withIndex: messageCellIndex)
        MessageListPage.Attributes.giphyCancelButton(in: messageCell).wait().safeTap()
        return self
    }

    @discardableResult
    func assertGiphyButtons(
        areDisplayed: Bool,
        at messageCellIndex: Int? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let cell = messageCell(withIndex: messageCellIndex, file: file, line: line)
        let sendButton = attributes.giphySendButton(in: cell)
        if areDisplayed {
            XCTAssertTrue(sendButton.wait().exists, "Giphy send button is not displayed", file: file, line: line)
            XCTAssertTrue(attributes.giphyShuffleButton(in: cell).exists, "Giphy shuffle button is not displayed", file: file, line: line)
            XCTAssertTrue(attributes.giphyCancelButton(in: cell).exists, "Giphy cancel button is not displayed", file: file, line: line)
        } else {
            XCTAssertFalse(sendButton.waitForDisappearance().exists, "Giphy send button is displayed", file: file, line: line)
            XCTAssertFalse(attributes.giphyShuffleButton(in: cell).exists, "Giphy shuffle button is displayed", file: file, line: line)
            XCTAssertFalse(attributes.giphyCancelButton(in: cell).exists, "Giphy cancel button is displayed", file: file, line: line)
        }
        return self
    }

    @discardableResult
    func assertEphemeralGiphyImage(
        at messageCellIndex: Int? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let cell = messageCell(withIndex: messageCellIndex, file: file, line: line).wait()
        let image = cell.images.matching(NSPredicate(format: "identifier == 'GiphyAttachmentView' AND label BEGINSWITH 'Giphy'")).firstMatch
        XCTAssertTrue(image.wait().exists, "Giphy image does not exist", file: file, line: line)
        return self
    }

    /// The thread lists the parent message first on iOS 27 and last on iOS 18,
    /// so the giphy reply is looked up by its content rather than by its position.
    @discardableResult
    func assertGiphyImageInThread(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let giphyImage = cells
            .containing(.image, identifier: "GiphyAttachmentView")
            .images
            .matching(NSPredicate(format: "identifier == 'GiphyAttachmentView' AND label BEGINSWITH 'Giphy'"))
            .firstMatch
        XCTAssertTrue(giphyImage.wait().exists, "Giphy image does not exist", file: file, line: line)
        return self
    }
}
