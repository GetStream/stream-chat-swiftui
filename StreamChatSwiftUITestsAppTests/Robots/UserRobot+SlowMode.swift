//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

extension UserRobot {
    @discardableResult
    func assertComposerInputIsDisabled(file: StaticString = #filePath, line: UInt = #line) -> Self {
        MessageListPage.Composer.inputField.wait().safeTap()
        XCTAssertFalse(
            app.keyboards.firstMatch.waitForExistence(timeout: XCUIElement.probeTimeout),
            "Composer input can be focused",
            file: file,
            line: line
        )
        return self
    }

    @discardableResult
    func assertComposerIsDisabledInSlowMode(file: StaticString = #filePath, line: UInt = #line) -> Self {
        assertComposerInputIsDisabled(file: file, line: line)
        let attachmentButton = MessageListPage.Composer.attachmentButton.wait()
        XCTAssertFalse(attachmentButton.isEnabled, "Attachment button is enabled", file: file, line: line)
        return self
    }
}
