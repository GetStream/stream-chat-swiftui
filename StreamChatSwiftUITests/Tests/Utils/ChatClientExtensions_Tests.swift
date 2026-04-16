//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

final class ChatClientExtensions_Tests: StreamChatTestCase {
    private let defaultFallback: Int64 = 100 * 1024 * 1024

    func test_maxAttachmentSize_file() {
        // Given
        let expectedValue: Int64 = 512
        chatClient.mockedAppSettings = .mock(fileUploadConfig: .mock(
            sizeLimitInBytes: expectedValue
        ))
        
        // When
        let size = chatClient.maxAttachmentSize(for: .localYodaQuote, fallbackSize: defaultFallback)
        
        // Then
        XCTAssertEqual(size, expectedValue)
    }
    
    func test_maxAttachmentSize_image() {
        // Given
        let expectedValue: Int64 = 256
        chatClient.mockedAppSettings = .mock(imageUploadConfig: .mock(
            sizeLimitInBytes: expectedValue
        ))
        
        // When
        let size = chatClient.maxAttachmentSize(for: .localYodaImage, fallbackSize: defaultFallback)
        
        // Then
        XCTAssertEqual(size, expectedValue)
    }

    func test_maxAttachmentSize_returnsFallback_whenAppSettingsNil() {
        // Given — appSettings is nil by default on the mock
        let fallback: Int64 = 50 * 1024 * 1024

        // When
        let size = chatClient.maxAttachmentSize(for: .localYodaImage, fallbackSize: fallback)

        // Then
        XCTAssertEqual(size, fallback)
    }

    func test_maxAttachmentSize_returnsFallback_whenServerLimitIsZero() {
        // Given
        chatClient.mockedAppSettings = .mock(imageUploadConfig: .mock(
            sizeLimitInBytes: 0
        ))
        let fallback: Int64 = 75 * 1024 * 1024

        // When
        let size = chatClient.maxAttachmentSize(for: .localYodaImage, fallbackSize: fallback)

        // Then
        XCTAssertEqual(size, fallback)
    }

    func test_maxAttachmentSize_returnsFallback_whenServerLimitIsNegative() {
        // Given
        chatClient.mockedAppSettings = .mock(fileUploadConfig: .mock(
            sizeLimitInBytes: -1
        ))
        let fallback: Int64 = 25 * 1024 * 1024

        // When
        let size = chatClient.maxAttachmentSize(for: .localYodaQuote, fallbackSize: fallback)

        // Then
        XCTAssertEqual(size, fallback)
    }
}
