//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest
import StreamChat

enum ChannelListPage {
        
    static var cells: XCUIElementQuery {
        app.buttons.matching(NSPredicate(format: "identifier LIKE 'ChatChannelSwipeableListItem'"))
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

        static func unreadCount(in cell: XCUIElement) -> XCUIElement {
            cell.staticTexts["UnreadIndicatorView"]
        }
    }

}
