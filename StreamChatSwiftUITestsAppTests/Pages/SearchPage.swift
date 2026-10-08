//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest

enum SearchPage {
    static var field: XCUIElement { app.searchFields.firstMatch }

    static var results: XCUIElementQuery {
        app.buttons.matching(identifier: "SearchResultItem")
    }

    static func channelName(_ name: String, in result: XCUIElement) -> XCUIElement {
        result.staticTexts.matching(NSPredicate(format: "identifier == 'ChatTitleView' AND label == %@", name)).firstMatch
    }

    static func messageText(_ text: String, in result: XCUIElement) -> XCUIElement {
        result.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
    }
}
