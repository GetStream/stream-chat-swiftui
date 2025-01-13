//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import UniformTypeIdentifiers
import XCTest

final class ImagePickerView_Tests: StreamChatTestCase {
    func test_openingContentTypes_default() {
        XCTAssertEqual(ImagePickerView().mediaTypes, [UTType.image.identifier, UTType.movie.identifier])
    }
    
    func test_openingContentTypes_allowedLists() {
        chatClient.mockedAppSettings = .mock(imageUploadConfig: .mock(allowedFileExtensions: [".png"]))
        XCTAssertEqual(ImagePickerView().mediaTypes, [UTType.png.identifier])
        
        chatClient.mockedAppSettings = .mock(imageUploadConfig: .mock(allowedMimeTypes: ["image/jpeg", "video/mp4"]))
        XCTAssertEqual(ImagePickerView().mediaTypes, [UTType.jpeg.identifier, UTType.mpeg4Movie.identifier])
    }
}

private extension ImagePickerView {
    init() {
        self.init(sourceType: .camera, onAssetPicked: { _ in })
    }
}
