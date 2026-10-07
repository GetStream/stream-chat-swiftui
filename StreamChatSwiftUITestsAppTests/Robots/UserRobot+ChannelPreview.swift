//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest

extension UserRobot {
    /// Waits for the channel preview to contain (or stop containing) the text.
    @discardableResult
    func assertChannelPreview(
        contains text: String,
        _ contains: Bool = true,
        at cellIndex: Int = 0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let cell = ChannelListPage.cells.element(boundBy: cellIndex)
        let endTime = Date().addingTimeInterval(XCUIElement.waitTimeout)
        var previewText = ChannelListPage.Attributes.lastMessageText(in: cell)
        while previewText.contains(text) != contains && Date() < endTime {
            previewText = ChannelListPage.Attributes.lastMessageText(in: cell)
        }
        XCTAssertEqual(
            previewText.contains(text),
            contains,
            "Unexpected channel preview: '\(previewText)'",
            file: file,
            line: line
        )
        return self
    }

    @discardableResult
    func assertTypingIndicatorInChannelPreview(
        isShown: Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        assertChannelPreview(contains: "typing", isShown, file: file, line: line)
    }
}

extension UserRobot {
    @discardableResult
    func assertSystemMessage(_ text: String, file: StaticString = #filePath, line: UInt = #line) -> Self {
        let systemMessage = app.staticTexts.matching(identifier: "SystemMessageView").firstMatch
        let actualText = systemMessage.wait().waitForText(text, mustBeEqual: false).text
        XCTAssertTrue(actualText.contains(text), "'\(actualText)' does not contain '\(text)'", file: file, line: line)
        return self
    }
}
