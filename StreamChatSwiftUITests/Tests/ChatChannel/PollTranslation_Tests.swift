//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

final class PollTranslation_Tests: XCTestCase {
    func test_pollName_inLanguage() {
        let poll = Poll.mock(
            name: "What's for lunch?",
            nameTranslations: [.spanish: "¿Qué hay de almuerzo?"],
            originalLanguage: .english
        )

        XCTAssertEqual(poll.name(in: .spanish), "¿Qué hay de almuerzo?")
        XCTAssertEqual(poll.name(in: .french), "What's for lunch?")
        XCTAssertEqual(poll.name(in: nil), "What's for lunch?")
    }

    func test_pollOptionText_inLanguage() {
        let option = PollOption(text: "Soup", translations: [.spanish: "Sopa"], originalLanguage: .english)

        XCTAssertEqual(option.text(in: .spanish), "Sopa")
        XCTAssertEqual(option.text(in: .english), "Soup")
        XCTAssertEqual(option.text(in: nil), "Soup")
    }

    func test_pollVoteAnswerText_inLanguage() {
        let vote = PollVote.mock(
            isAnswer: true,
            answerText: "Fish, please",
            answerTextTranslations: [.spanish: "Pescado, por favor"],
            originalLanguage: .english
        )

        XCTAssertEqual(vote.answerText(in: .spanish), "Pescado, por favor")
        XCTAssertEqual(vote.answerText(in: .french), "Fish, please")
        XCTAssertEqual(vote.answerText(in: nil), "Fish, please")
    }
}
