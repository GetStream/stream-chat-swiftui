//
// Copyright Β© 2022 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChatSwiftUI
import XCTest

class String_Extensions_Tests: XCTestCase {
    
    func test_onlyEmoji() {
        XCTAssertTrue("πΊ".isSingleEmoji)
    }
    
    func test_stringWithEmoji() {
        XCTAssertFalse("Cold one πΊ".isSingleEmoji)
    }
    
    func test_multipleEmoji() {
        XCTAssertFalse("ππ".isSingleEmoji)
    }
    
    func test_skinToneEmoji() {
        XCTAssertTrue("ππ½".isSingleEmoji)
    }
    
    func test_multiScalarCharacterEmoji() {
        XCTAssertTrue("1οΈβ£".isSingleEmoji) // 3 UnicodeScalars
        XCTAssertTrue("π¨βπ©βπ§βπ¦".isSingleEmoji) // 7 UnicodeScalars
    }
    
    func test_containsEmoji() {
        let string = "Hello ππ½"
        XCTAssertTrue(string.containsEmoji)
        XCTAssertFalse(string.containsOnlyEmoji)
    }
    
    func test_containsOnlyEmoji() {
        XCTAssertTrue("π―πβΊοΈ".containsOnlyEmoji)
        XCTAssertFalse("Number one 1οΈβ£".containsOnlyEmoji)
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
}
