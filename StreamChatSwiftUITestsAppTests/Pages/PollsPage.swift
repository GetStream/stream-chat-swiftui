//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest

// The SDK's `L10n` resolves to raw keys inside the test runner, so the English copy is used directly.
enum PollsPage {
    static var attachmentPickerPollsButton: XCUIElement { app.buttons["attachmentPickerPolls"] }

    enum Creation {
        static var questionField: XCUIElement {
            app.textFields.matching(NSPredicate(format: "placeholderValue == 'Ask a question'")).firstMatch
        }

        static func optionField(at index: Int) -> XCUIElement {
            app.textFields
                .matching(NSPredicate(format: "placeholderValue == 'Add an option'"))
                .element(boundBy: index)
        }

        static var multipleAnswersSwitch: XCUIElement {
            app.switches.matching(NSPredicate(format: "label BEGINSWITH 'Multiple votes'")).firstMatch.switches.firstMatch
        }

        static var createButton: XCUIElement { app.buttons["Save Poll"] }
    }

    enum Message {
        static let singleVoteSubtitle = "Select one"
        static let multipleVotesSubtitle = "Select one or more"
        static let closedSubtitle = "Vote ended"

        static func header(question: String, subtitle: String, optionsCount: Int) -> XCUIElement {
            let label = "Poll: \(question). \(subtitle). \(optionsCount) options"
            return app.descendants(matching: .any).matching(NSPredicate(format: "label == %@", label)).firstMatch
        }

        static func option(_ text: String) -> XCUIElement {
            app.descendants(matching: .any)
                .matching(NSPredicate(format: "label BEGINSWITH %@", "\(text), "))
                .firstMatch
        }

        static func option(_ text: String, isChecked: Bool) -> XCUIElement {
            let state = isChecked ? "selected" : "not selected"
            return app.descendants(matching: .any)
                .matching(NSPredicate(format: "label BEGINSWITH %@", "\(text), \(state), "))
                .firstMatch
        }

        static func option(_ text: String, voteCount: Int) -> XCUIElement {
            let votes = voteCount == 1 ? "1 vote" : "\(voteCount) votes"
            return app.descendants(matching: .any)
                .matching(NSPredicate(format: "label BEGINSWITH %@ AND label CONTAINS %@", "\(text), ", ", \(votes)"))
                .firstMatch
        }

        static var viewResultsButton: XCUIElement { app.buttons["View Results"] }

        static var endPollButton: XCUIElement { app.buttons["End Poll"] }

        static var endPollConfirmationButton: XCUIElement { app.alerts.buttons["End Poll"] }

        static func viewCommentsButton(count: Int) -> XCUIElement {
            app.buttons[count == 1 ? "View 1 Comment" : "View \(count) Comments"]
        }
    }

    enum Results {
        static var title: XCUIElement { app.staticTexts["Poll Results"] }

        static func voter(_ name: String) -> XCUIElement {
            app.descendants(matching: .any)
                .matching(NSPredicate(format: "label BEGINSWITH %@", "\(name), voted "))
                .firstMatch
        }
    }
}
