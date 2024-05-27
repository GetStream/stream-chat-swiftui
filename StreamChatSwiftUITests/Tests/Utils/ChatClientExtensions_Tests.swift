//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

final class ChatClientExtensions_Tests: StreamChatTestCase {
    func test_maxAttachmentSize_file() {
        // Given
        let expectedValue: Int64 = 512
        chatClient.mockedAppSettings = .mock(fileUploadConfig: .mock(
            sizeLimitInBytes: expectedValue
        ))
        
        // When
        let size = chatClient.maxAttachmentSize(for: .localYodaQuote)
        
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
        let size = chatClient.maxAttachmentSize(for: .localYodaImage)
        
        // Then
        XCTAssertEqual(size, expectedValue)
    }
}
