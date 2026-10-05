//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

enum ComposerAttachmentsPage {
    static let openPickerLabel = "Add attachment"
    static let closePickerLabel = "Close attachments"
    static var images: XCUIElementQuery { app.images.matching(identifier: "ComposerImageAttachmentView") }
    static var files: XCUIElementQuery { app.staticTexts.matching(identifier: "ComposerFileAttachmentView") }
    static var removeButtons: XCUIElementQuery { app.buttons.matching(identifier: "DismissButtonOverlay") }

    enum Picker {
        static var view: XCUIElement { app.otherElements["AttachmentPickerView"] }
        static var noAccessPrompt: XCUIElement {
            view.buttons.matching(NSPredicate(format: "label == 'Change in Settings'")).firstMatch
        }

        static var photos: XCUIElementQuery {
            view.buttons.matching(NSPredicate(format: "label == 'Photo'"))
        }
    }
}
