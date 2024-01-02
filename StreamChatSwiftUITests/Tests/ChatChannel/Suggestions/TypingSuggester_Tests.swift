//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class TypingSuggester_Tests: XCTestCase {

    func test_typingSuggester_mentionWholeText() {
        // Given
        let options = TypingSuggestionOptions(symbol: "@")
        let typingSuggester = TypingSuggester(options: options)
        let string = "@Martin"
        let caretLocation = 7

        // When
        let suggestion = typingSuggester.typingSuggestion(
            in: string,
            caretLocation: caretLocation
        )

        // Then
        XCTAssert(suggestion?.text == "Martin")
        XCTAssert(suggestion?.locationRange == NSRange(location: 1, length: 6))
    }

    func test_typingSuggester_mentionMiddleOfText() {
        // Given
        let options = TypingSuggestionOptions(symbol: "@")
        let typingSuggester = TypingSuggester(options: options)
        let string = "@Martin"
        let caretLocation = 5

        // When
        let suggestion = typingSuggester.typingSuggestion(
            in: string,
            caretLocation: caretLocation
        )

        // Then
        XCTAssert(suggestion?.text == "Mart")
        XCTAssert(suggestion?.locationRange == NSRange(location: 1, length: 4))
    }

    func test_typingSuggester_mentionDifferentSymbol() {
        // Given
        let options = TypingSuggestionOptions(symbol: "$")
        let typingSuggester = TypingSuggester(options: options)
        let string = "$cash"
        let caretLocation = 3

        // When
        let suggestion = typingSuggester.typingSuggestion(
            in: string,
            caretLocation: caretLocation
        )

        // Then
        XCTAssert(suggestion?.text == "ca")
        XCTAssert(suggestion?.locationRange == NSRange(location: 1, length: 2))
    }

    func test_typingSuggester_notFoundEmptySpace() {
        // Given
        let options = TypingSuggestionOptions(symbol: "@")
        let typingSuggester = TypingSuggester(options: options)
        let string = "@M art"
        let caretLocation = 3

        // When
        let suggestion = typingSuggester.typingSuggestion(
            in: string,
            caretLocation: caretLocation
        )

        // Then
        XCTAssert(suggestion == nil)
    }

    func test_typingSuggester_notFoundNotOnStart() {
        // Given
        let options = TypingSuggestionOptions(symbol: "@")
        let typingSuggester = TypingSuggester(options: options)
        let string = "Hello@User"
        let caretLocation = 7

        // When
        let suggestion = typingSuggester.typingSuggestion(
            in: string,
            caretLocation: caretLocation
        )

        // Then
        XCTAssert(suggestion == nil)
    }

    func test_typingSuggester_minimumNumberOfCharacters() {
        // Given
        let options = TypingSuggestionOptions(
            symbol: "@",
            minimumRequiredCharacters: 5
        )
        let typingSuggester = TypingSuggester(options: options)
        let string = "@Mar"
        let caretLocation = 4

        // When
        let suggestion = typingSuggester.typingSuggestion(
            in: string,
            caretLocation: caretLocation
        )

        // Then
        XCTAssert(suggestion == nil)
    }

    func test_typingSuggester_notOnlyOnStartAllowed() {
        // Given
        let options = TypingSuggestionOptions(symbol: "@")
        let typingSuggester = TypingSuggester(options: options)
        let string = "Hey @Mar"
        let caretLocation = 8

        // When
        let suggestion = typingSuggester.typingSuggestion(
            in: string,
            caretLocation: caretLocation
        )

        // Then
        XCTAssert(suggestion?.text == "Mar")
        XCTAssert(suggestion?.locationRange == NSRange(location: 5, length: 3))
    }
    
    func test_typingSuggester_newLine() {
        // Given
        let options = TypingSuggestionOptions(symbol: "@")
        let typingSuggester = TypingSuggester(options: options)
        let string = "\n@Mar"
        let caretLocation = 5

        // When
        let suggestion = typingSuggester.typingSuggestion(
            in: string,
            caretLocation: caretLocation
        )

        // Then
        XCTAssert(suggestion?.text == "Mar")
        XCTAssert(suggestion?.locationRange == NSRange(location: 2, length: 3))
    }

    func test_typingSuggester_onlyOnStartAllowed() {
        // Given
        let options = TypingSuggestionOptions(
            symbol: "@",
            shouldTriggerOnlyAtStart: true
        )
        let typingSuggester = TypingSuggester(options: options)
        let string = "Hey @Mar"
        let caretLocation = 8

        // When
        let suggestion = typingSuggester.typingSuggestion(
            in: string,
            caretLocation: caretLocation
        )

        // Then
        XCTAssert(suggestion == nil)
    }

    func test_typingSuggester_outOfBounds() {
        // Given
        let options = TypingSuggestionOptions(
            symbol: "@",
            shouldTriggerOnlyAtStart: true
        )
        let typingSuggester = TypingSuggester(options: options)
        let string = "Hey @Mar"
        let caretLocation = 15

        // When
        let suggestion = typingSuggester.typingSuggestion(
            in: string,
            caretLocation: caretLocation
        )

        // Then
        XCTAssert(suggestion == nil)
    }
}
