//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

extension UserRobot {
    @discardableResult
    func assertLinkPreviewInMessageList(
        at messageCellIndex: Int? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let messageCell = messageCell(withIndex: messageCellIndex, file: file, line: line)
        XCTAssertTrue(attributes.text(in: messageCell).wait().isHittable, "Message text is not visible", file: file, line: line)
        return assertLinkPreview(at: messageCellIndex, file: file, line: line)
    }

    @discardableResult
    func assertLinkOpensSafari(
        at messageCellIndex: Int? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let messageCell = messageCell(withIndex: messageCellIndex, file: file, line: line)
        let text = attributes.text(in: messageCell).wait()
        let link = text.links.firstMatch
        if link.exists {
            link.tap()
        } else {
            // On iOS 18 SwiftUI does not expose links inside `Text` as separate elements,
            // so the link at the end of the single-line message is tapped by its position.
            text.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.5)).tap()
        }

        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        defer { safari.terminate() }
        XCTAssertTrue(
            safari.wait(for: .runningForeground, timeout: XCUIElement.waitTimeout),
            "Safari did not open",
            file: file,
            line: line
        )
        return self
    }
}
