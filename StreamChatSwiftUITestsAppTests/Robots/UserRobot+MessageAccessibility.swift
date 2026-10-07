//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest

// The message bubble's accessibility label reads "<sender>, <text>, <sent time>[, <status>]",
// where the status is "sent", "delivered" or "read". The checkmark image has the same
// identifier for every status, so the label is what tells them apart.
extension UserRobot {
    @discardableResult
    func assertMessageDeliveryStatusAnnouncement(
        _ deliveryStatus: StreamChatTestMockServer.MessageDeliveryStatus,
        at messageCellIndex: Int? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let expectedSuffix = ", \(deliveryStatus.rawValue)"
        let label = waitForMessageBubbleLabel(at: messageCellIndex, file: file, line: line) { $0.hasSuffix(expectedSuffix) }
        XCTAssertTrue(label.hasSuffix(expectedSuffix), "'\(label)' does not end with '\(expectedSuffix)'", file: file, line: line)
        return self
    }

    @discardableResult
    func assertMessageAuthor(
        _ author: String,
        at messageCellIndex: Int? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let expectedPrefix = "\(author), "
        let label = waitForMessageBubbleLabel(at: messageCellIndex, file: file, line: line) { $0.hasPrefix(expectedPrefix) }
        XCTAssertTrue(label.hasPrefix(expectedPrefix), "'\(label)' does not start with '\(expectedPrefix)'", file: file, line: line)
        return self
    }

    private func waitForMessageBubbleLabel(
        at messageCellIndex: Int?,
        timeout: TimeInterval = 10,
        file: StaticString,
        line: UInt,
        until condition: (String) -> Bool
    ) -> String {
        let messageCell = messageCell(withIndex: messageCellIndex, file: file, line: line)
        let bubble = MessageListPage.messageView(for: messageCell).wait()
        let endTime = Date().addingTimeInterval(timeout)
        while !condition(bubble.label) && Date() < endTime {
            Thread.sleep(forTimeInterval: 0.5)
        }
        return bubble.label
    }
}
