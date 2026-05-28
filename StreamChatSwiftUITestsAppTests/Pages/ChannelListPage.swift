//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import XCTest

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
            cell.staticTexts["messagePreviewView"]
        }

        static func lastMessageText(in cell: XCUIElement) -> String {
            let previewElements = cell.staticTexts.matching(identifier: "messagePreviewView")
            _ = previewElements.firstMatch.wait()
            var combinedText = ""
            for i in 0..<previewElements.count {
                let element = previewElements.element(boundBy: i)
                if element.exists {
                    combinedText += element.label
                }
            }
            return combinedText
                .components(separatedBy: .whitespaces)
                .filter { !$0.isEmpty }
                .joined(separator: " ")
        }

        static func avatar(in cell: XCUIElement) -> XCUIElement {
            cell.images["ChannelAvatar"].firstMatch
        }

        static func statusCheckmark(
            for status: StreamChatTestMockServer.MessageDeliveryStatus?,
            in cell: XCUIElement
        ) -> XCUIElement {
            return cell.images["readIndicatorCheckmark"]
        }
    }
}
