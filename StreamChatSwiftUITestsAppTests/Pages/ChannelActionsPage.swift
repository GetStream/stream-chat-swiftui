//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest

enum ChannelActionsPage {
    static var emptyChannelsView: XCUIElement {
        app.descendants(matching: .any).matching(identifier: "EmptyChannelsView").firstMatch
    }

    static func mutedIcon(in cell: XCUIElement) -> XCUIElement {
        cell.images["ChannelItemMutedIcon"]
    }

    enum SwipeActions {
        static var more: XCUIElement { app.buttons["More"].firstMatch }
        static var mute: XCUIElement { app.buttons["Mute"].firstMatch }
        static var unmute: XCUIElement {
            app.buttons["Volume High"].firstMatch
        }
    }

    enum MuteAlert {
        static var mute: XCUIElement { app.alerts.buttons["Mute"] }
        static var unmute: XCUIElement { app.alerts.buttons["Unmute"] }
    }

    enum Sheet {
        static var viewInfo: XCUIElement { app.buttons["View info"] }
        static var muteChannel: XCUIElement { app.buttons["Mute Channel"] }
        static var deleteGroup: XCUIElement { app.buttons["Delete conversation"] }
        static var confirmDelete: XCUIElement { app.alerts.buttons["Delete"] }
    }

    enum ChannelInfo {
        static var title: XCUIElement { app.staticTexts["Group Info"] }
        static var pinnedMessagesOption: XCUIElement { app.buttons["Pinned Messages"] }
        static var leaveGroup: XCUIElement { app.buttons["Leave group"] }
        static var confirmLeave: XCUIElement { app.alerts.buttons["Leave group"] }

        static func channelName(_ name: String) -> XCUIElement {
            app.staticTexts[name]
        }
    }
}
