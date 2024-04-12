//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChatSwiftUI
import XCTest

class String_Extensions_Tests: XCTestCase {

    func test_onlyEmoji() {
        XCTAssertTrue("🍺".isSingleEmoji)
    }

    func test_stringWithEmoji() {
        XCTAssertFalse("Cold one 🍺".isSingleEmoji)
    }

    func test_multipleEmoji() {
        XCTAssertFalse("😄😆".isSingleEmoji)
    }

    func test_skinToneEmoji() {
        XCTAssertTrue("👋🏽".isSingleEmoji)
    }

    func test_multiScalarCharacterEmoji() {
        XCTAssertTrue("1️⃣".isSingleEmoji) // 3 UnicodeScalars
        XCTAssertTrue("👨‍👩‍👧‍👦".isSingleEmoji) // 7 UnicodeScalars
    }

    func test_containsEmoji() {
        let string = "Hello 👋🏽"
        XCTAssertTrue(string.containsEmoji)
        XCTAssertFalse(string.containsOnlyEmoji)
    }

    func test_containsOnlyEmoji() {
        XCTAssertTrue("💯😆☺️".containsOnlyEmoji)
        XCTAssertFalse("Number one 1️⃣".containsOnlyEmoji)
    }

    func test_nonEmojiScalar() {
        XCTAssertFalse("3".containsEmoji)
        XCTAssertFalse("#".containsEmoji)
    }

    func testLevenshtein() throws {
        XCTAssertEqual("".levenshtein(""), "".levenshtein(""))
        XCTAssertEqual("".levenshtein(""), 0)
        XCTAssertEqual("a".levenshtein(""), 1)
        XCTAssertEqual("".levenshtein("a"), 1)
        XCTAssertEqual("tommaso".levenshtein("ToMmAsO"), 4)
    }

    func testValidURL() {
        XCTAssert("https://example.com".isURL == true)
    }

    func testInvalidURLs() {
        XCTAssert("https:/example".isURL == false)
        XCTAssert("example".isURL == false)
        XCTAssert("invalid_url".isURL == false)
    }
    
    func testRangesOfString() {
        let mention = "@Martin"
        let string = "Hey \(mention), how are you?"
        let result = string
            .ranges(of: mention, options: [.caseInsensitive])
            .map { NSRange($0, in: string) }
            .first
        XCTAssertEqual(result, NSRange(location: 4, length: 7))
    }
    
    func testRangesOfStringNotFound() {
        let string = "Hey @Martin, how are you?"
        let mention = "@Alexey"
        let result = string
            .ranges(of: mention, options: [.caseInsensitive])
            .map { NSRange($0, in: string) }
            .first
        XCTAssertEqual(result, nil)
    }
}
