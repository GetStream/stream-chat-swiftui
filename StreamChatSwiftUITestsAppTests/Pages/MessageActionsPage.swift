//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest

extension MessageListPage.ContextMenu.Element {
    static var block: XCUIElement { app.otherElements["messageAction-block_user_action"].images.firstMatch }
    static var unblock: XCUIElement { app.otherElements["messageAction-unblock_user_action"].images.firstMatch }
}

extension MessageListPage.Composer {
    static var pasteButton: XCUIElement { app.menuItems.matching(NSPredicate(format: "label LIKE 'Paste'")).firstMatch }
}

// The test runner cannot resolve the SDK's localized strings (`L10n` returns the keys), so the
// English UI strings are used directly.
extension MessageListPage {
    enum ConfirmationAlert {
        static var alert: XCUIElement { app.alerts.firstMatch }
        static var flagButton: XCUIElement { alert.buttons["Flag Message"] }
        static var okButton: XCUIElement { alert.buttons.matching(NSPredicate(format: "label ==[c] %@", "OK")).firstMatch }
    }

    enum Annotations {
        static func pinnedLabel(in messageCell: XCUIElement) -> XCUIElement {
            messageCell.descendants(matching: .any)["MessagePinDetailsView"].firstMatch
        }

        static func reminderLabel(in messageCell: XCUIElement) -> XCUIElement {
            messageCell.descendants(matching: .any)["ReminderAnnotation"].firstMatch
        }

        static var pinnedByYou: String { "Pinned by you" }

        static func pinnedBy(_ name: String) -> String { "Pinned by \(name)" }

        static var reminderSet: String { "Reminder set" }
    }

    static func cell(withText text: String) -> XCUIElement {
        cells.containing(NSPredicate(format: "identifier == 'MessageTextView' AND label == %@", text)).firstMatch
    }

    /// Dismisses the message actions overlay by tapping outside of the message and its actions.
    static func dismissMessageActions() {
        // A corner is used because message bubbles are inset from the screen edges, so no message length reaches it.
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: 0.15)).tap()
        ContextMenu.actionsView.element.waitForDisappearance()
    }
}

extension ChannelListPage {
    static var channelNames: XCUIElementQuery {
        app.staticTexts.matching(identifier: "ChatTitleView")
    }
}

enum ChannelInfoPage {
    static var pinnedMessagesOption: XCUIElement {
        app.buttons["Pinned Messages"].firstMatch
    }
}

enum PinnedMessagesPage {
    static var title: XCUIElement {
        app.navigationBars.staticTexts["Pinned Messages"].firstMatch
    }

    static var messages: XCUIElementQuery {
        app.otherElements.matching(identifier: "PinnedMessageView")
    }

    static func message(withText text: String) -> XCUIElement {
        messages.containing(NSPredicate(format: "label == %@", text)).firstMatch
    }

    static var emptyTitle: XCUIElement {
        app.staticTexts["No pinned messages"].firstMatch
    }
}
