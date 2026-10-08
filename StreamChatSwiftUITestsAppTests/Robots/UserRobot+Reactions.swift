//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest

// MARK: Actions

extension UserRobot {
    @discardableResult
    func toggleReactionUsingExtendedPicker(type: ReactionType, messageCellIndex: Int = 0) -> Self {
        openContextMenu(messageCellIndex: messageCellIndex)
        MessageListPage.Reactions.moreReactionsButton.wait().safeTap()
        MessageListPage.Reactions.extendedPickerReaction(type).wait().safeTap()
        MessageListPage.Reactions.extendedPicker.waitForDisappearance()
        return self
    }

    @discardableResult
    func tapOnMessageReactions(at messageCellIndex: Int? = nil) -> Self {
        let messageCell = messageCell(withIndex: messageCellIndex)
        attributes.reactionButton(in: messageCell).wait().safeTap()
        return self
    }
}

// MARK: Asserts

extension UserRobot {
    @discardableResult
    func assertReaction(
        type: ReactionType,
        isPresent: Bool,
        at messageCellIndex: Int? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let messageCell = messageCell(withIndex: messageCellIndex, file: file, line: line)
        let reaction = attributes.reaction(type, in: messageCell)
        _ = isPresent ? reaction.wait() : reaction.waitForDisappearance()
        let errMessage = isPresent ? "Reaction \(type) is not shown" : "Reaction \(type) is shown"
        XCTAssertEqual(isPresent, reaction.exists, errMessage, file: file, line: line)
        return self
    }

    @discardableResult
    func assertReactionAuthor(
        _ authorName: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let author = MessageListPage.Reactions.author(authorName).wait()
        XCTAssertTrue(author.exists, "Reaction author \(authorName) is not shown", file: file, line: line)
        return self
    }
}

extension MessageListPage.Reactions {
    static var moreReactionsButton: XCUIElement { app.buttons["moreReactions"].firstMatch }

    static var extendedPicker: XCUIElement { app.descendants(matching: .any)["MoreReactionsView"].firstMatch }

    static func extendedPickerReaction(_ type: ReactionType) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label == %@", type.emoji)).firstMatch
    }

    static func author(_ name: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "identifier == 'ReactionAuthorView' AND label CONTAINS %@", name)).firstMatch
    }
}

extension MessageListPage.Attributes {
    static func reaction(_ type: ReactionType, in messageCell: XCUIElement) -> XCUIElement {
        reactionButton(in: messageCell).descendants(matching: .any)["reaction-\(type.rawValue)"].firstMatch
    }
}

private extension ReactionType {
    var emoji: String {
        switch self {
        case .love: return "❤️"
        case .lol: return "😂"
        case .wow: return "😮"
        case .sad: return "👎"
        case .like: return "👍"
        }
    }
}
