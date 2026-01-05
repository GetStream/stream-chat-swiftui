//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import UniformTypeIdentifiers
import XCTest

final class FilePickerView_Tests: StreamChatTestCase {
    func test_openingContentTypes_default() {
        let picker = FilePickerView(fileURLs: .constant([]))
        XCTAssertEqual(picker.openingContentTypes, [UTType.item])
    }
    
    func test_openingContentTypes_allowedLists() {
        chatClient.mockedAppSettings = .mock(fileUploadConfig: .mock(allowedFileExtensions: [".pdf"]))
        XCTAssertEqual(FilePickerView(fileURLs: .constant([])).openingContentTypes, [UTType.pdf])
        
        chatClient.mockedAppSettings = .mock(fileUploadConfig: .mock(allowedMimeTypes: ["audio/mp3"]))
        XCTAssertEqual(FilePickerView(fileURLs: .constant([])).openingContentTypes, [UTType.mp3])
    }
}
