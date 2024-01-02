//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class URLUtils_Tests: XCTestCase {
    func test_secureSchemeURL_withMissingScheme() {
        // Given
        let initialURLString = "google.com"
        let initialURL = URL(string: initialURLString)

        // When
        let secureSchemeURL = initialURL?.secureURL

        // Then
        if let finalURL = secureSchemeURL {
            XCTAssertEqual(finalURL.scheme, "https")
        } else {
            XCTFail()
        }
    }

    func test_secureSchemeURL_withUnsecureScheme() {
        // Given
        let initialURLString = "http://www.google.com"
        let initialURL = URL(string: initialURLString)

        // When
        let secureSchemeURL = initialURL?.secureURL

        // Then
        if let finalURL = secureSchemeURL {
            XCTAssertEqual(finalURL.scheme, "https")
        } else {
            XCTFail()
        }
    }

    func test_secureSchemeURL_withSecureScheme() {
        // Given
        let initialURLString = "https://www.google.com"
        let initialURL = URL(string: initialURLString)

        // When
        let secureSchemeURL = initialURL?.secureURL

        // Then
        if let finalURL = secureSchemeURL {
            XCTAssertEqual(finalURL.scheme, "https")
        } else {
            XCTFail()
        }
    }
}
