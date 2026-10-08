//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest

enum ThreadListPage {
    static var openButton: XCUIElement { app.buttons["ThreadListButton"] }

    static var emptyView: XCUIElement {
        app.staticTexts.matching(identifier: "EmptyThreadsView").firstMatch
    }

    static func parentMessage(_ text: String) -> XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label == %@", text)).firstMatch
    }

    static func repliesCountLabel(_ replies: Int) -> XCUIElement {
        let suffix = replies == 1 ? "reply" : "replies"
        return app.staticTexts["\(replies) \(suffix)"]
    }

    static var unreadBadge: XCUIElement {
        app.descendants(matching: .any).matching(identifier: "BadgeNotificationView").firstMatch
    }
}
