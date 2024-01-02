//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest
import StreamChat

enum ChannelListPage {

    static var userAvatar: XCUIElement {
        return app.buttons["LogoutButton"]
    }

    static var cells: XCUIElementQuery {
        app.buttons.matching(NSPredicate(format: "identifier LIKE 'ChatChannelSwipeableListItem'"))
    }

    static var list: XCUIElement {
        app.otherElements["ChatChannelListView"].scrollViews.firstMatch
    }

    static func channel(withName: String) -> XCUIElement {
        app.staticTexts.matching(NSPredicate(
            format: "identifier LIKE 'ChatTitleView' AND label LIKE '\(withName)'")).firstMatch
    }

    enum Search {
        static var field: XCUIElement { app.textFields["SearchBar"] }
        static var image: XCUIElement { app.images["SearchBar"] }
    }

    enum Attributes {
        static func name(in cell: XCUIElement) -> XCUIElement {
            cell.staticTexts["ChatTitleView"]
        }

        static func lastMessageTime(in cell: XCUIElement) -> XCUIElement {
            cell.staticTexts["timestampView"]
        }

        static func lastMessage(in cell: XCUIElement) -> XCUIElement {
            cell.staticTexts["subtitleView"]
        }

        static func avatar(in cell: XCUIElement) -> XCUIElement {
            cell.images["ChannelAvatarView"].firstMatch
        }

        static func readCount(in cell: XCUIElement) -> XCUIElement {
            cell.staticTexts["UnreadIndicatorView"]
        }

        static func statusCheckmark(for status: MessageDeliveryStatus?, in cell: XCUIElement) -> XCUIElement {
            return cell.images["readIndicatorCheckmark"]
        }
    }

}
