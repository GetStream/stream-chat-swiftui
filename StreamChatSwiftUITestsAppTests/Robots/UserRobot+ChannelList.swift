//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

extension UserRobot {
    /// Waits for the channel at the given position in the channel list to have the name.
    /// Titles are matched instead of cells because swipe actions share the cell identifier.
    @discardableResult
    func assertChannelName(
        _ name: String,
        at cellIndex: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let titles = app.staticTexts.matching(identifier: "ChatTitleView")
        let title = titles.waitCount(cellIndex + 1).element(boundBy: cellIndex)
        let actualName = title.wait().waitForText(name).text
        XCTAssertEqual(name, actualName, "Unexpected channel at position #\(cellIndex)", file: file, line: line)
        return self
    }
}
