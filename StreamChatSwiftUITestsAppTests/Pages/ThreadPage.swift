//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest

class ThreadPage: MessageListPage {
    static var alsoSendInChannelCheckbox: XCUIElement { app.buttons["SendInChannelView"] }
    static var repliesCountLabel: XCUIElement { app.staticTexts["textLabel"] }
}
