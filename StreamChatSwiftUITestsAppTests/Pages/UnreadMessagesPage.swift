//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest

enum UnreadMessagesPage {
    static var unreadSeparator: XCUIElement { app.staticTexts["NewMessagesDivider"] }

    static var jumpToUnreadButton: XCUIElement { app.buttons["JumpToUnreadButton"] }

    static var jumpToUnreadDismissButton: XCUIElement { app.buttons["JumpToUnreadDismissButton"] }

    static var markUnreadAction: XCUIElement {
        app.otherElements["messageAction-mark_unread_action"].images.firstMatch
    }

    static func channelUnreadCount(in cell: XCUIElement) -> XCUIElement {
        cell.staticTexts["BadgeNotificationView"]
    }
}
