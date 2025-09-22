//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

class MessageAttachmentsConverter_Tests: StreamChatTestCase {
    private var converter: MessageAttachmentsConverter!
    private var mockImageData: Data!
    private var mockImageURL: URL!
    private var mockFileURL: URL!
    private var mockVideoURL: URL!
    
    override func setUp() {
        super.setUp()
        converter = MessageAttachmentsConverter()
        
        // Create mock image data
        mockImageData = createMockImageData()
        
        // Create temporary URLs for testing
        mockImageURL = createTemporaryFileURL(extension: "png")
        mockFileURL = createTemporaryFileURL(extension: "pdf")
        mockVideoURL = createTemporaryFileURL(extension: "mp4")
        
        // Write mock data to files
        try? mockImageData.write(to: mockImageURL)
        try? "Mock PDF content".data(using: .utf8)?.write(to: mockFileURL)
        try? "Mock video content".data(using: .utf8)?.write(to: mockVideoURL)
    }
    
    override func tearDown() {
        // Clean up temporary files
        try? FileManager.default.removeItem(at: mockImageURL)
        try? FileManager.default.removeItem(at: mockFileURL)
        try? FileManager.default.removeItem(at: mockVideoURL)
        
        converter = nil
        mockImageData = nil
        mockImageURL = nil
        mockFileURL = nil
        mockVideoURL = nil
        
        super.tearDown()
    }
    
    // MARK: - Public Interface Tests
    
    func test_attachmentsToAssets_emptyAttachments() {
        // Given
        let attachments: [AnyChatMessageAttachment] = []
        let expectation = XCTestExpectation(description: "Empty attachments conversion completion")
        var result: ComposerAssets?
        
        // When
        converter.attachmentsToAssets(attachments) { composerAssets in
            result = composerAssets
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.fileAssets.isEmpty ?? false)
        XCTAssertTrue(result?.mediaAssets.isEmpty ?? false)
        XCTAssertTrue(result?.voiceAssets.isEmpty ?? false)
        XCTAssertTrue(result?.customAssets.isEmpty ?? false)
    }
    
    func test_attachmentsToAssets_mixedLocalAndRemoteAttachments() {
        // Given
        let attachments = [
            createFileAttachmentWithLocalURL(),
            createFileAttachmentWithoutLocalURL(),
            createImageAttachmentWithLocalURL(),
            createImageAttachmentWithoutLocalURL()
        ]
        let expectation = XCTestExpectation(description: "Mixed attachments conversion completion")
        var result: ComposerAssets?
        
        // When
        converter.attachmentsToAssets(attachments) { composerAssets in
            result = composerAssets
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.fileAssets.count, 2)
        XCTAssertEqual(result?.mediaAssets.count, 2)
        
        // Verify both local and remote URLs are handled
        let fileURLs = result?.fileAssets.map(\.url)
        XCTAssertTrue(fileURLs?.contains(mockFileURL) ?? false)
        XCTAssertTrue(fileURLs?.contains(URL(string: "https://example.com/file.pdf")!) ?? false)
        
        // Verify image assets
        let imageAssets = result?.mediaAssets.filter { $0.type == .image }
        XCTAssertEqual(imageAssets?.count, 2)
    }

    func test_attachmentsToAssets_withCorruptedLocalFile() {
        // Given
        let corruptedURL = createTemporaryFileURL(extension: "png")
        try? "corrupted data".data(using: .utf8)?.write(to: corruptedURL)
        let attachment = createImageAttachmentWithSpecificLocalURL(corruptedURL)
        let expectation = XCTestExpectation(description: "Corrupted image conversion completion")
        var result: ComposerAssets?
        
        // When
        converter.attachmentsToAssets([attachment]) { composerAssets in
            result = composerAssets
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        // Should fall back to remote URL loading since local file is corrupted
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.mediaAssets.count, 1)
        XCTAssertEqual(result?.mediaAssets.first?.type, .image)
        
        // Clean up
        try? FileManager.default.removeItem(at: corruptedURL)
    }
    
    func test_attachmentsToAssets_fileAttachmentWithLocalURL() {
        // Given
        let attachments = [createFileAttachmentWithLocalURL()]
        let expectation = XCTestExpectation(description: "File attachment conversion completion")
        var result: ComposerAssets?
        
        // When
        converter.attachmentsToAssets(attachments) { composerAssets in
            result = composerAssets
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.fileAssets.count, 1)
        XCTAssertEqual(result?.fileAssets.first?.url, mockFileURL)
        XCTAssertNil(result?.fileAssets.first?.payload) // Should not include payload when using local URL
    }
    
    func test_attachmentsToAssets_fileAttachmentWithoutLocalURL() {
        // Given
        let attachments = [createFileAttachmentWithoutLocalURL()]
        let expectation = XCTestExpectation(description: "File attachment conversion completion")
        var result: ComposerAssets?
        
        // When
        converter.attachmentsToAssets(attachments) { composerAssets in
            result = composerAssets
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.fileAssets.count, 1)
        XCTAssertEqual(result?.fileAssets.first?.url, URL(string: "https://example.com/file.pdf"))
        XCTAssertNotNil(result?.fileAssets.first?.payload)
    }
    
    func test_attachmentsToAssets_videoAttachmentWithLocalURL() {
        // Given
        let attachments = [createVideoAttachmentWithLocalURL()]
        let expectation = XCTestExpectation(description: "Video attachment conversion completion")
        var result: ComposerAssets?
        
        // When
        converter.attachmentsToAssets(attachments) { composerAssets in
            result = composerAssets
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.mediaAssets.count, 1)
        let videoAsset = result?.mediaAssets.first
        XCTAssertEqual(videoAsset?.url, mockVideoURL)
        XCTAssertEqual(videoAsset?.type, .video)
        XCTAssertNotNil(videoAsset?.image) // Should have thumbnail
        XCTAssertNil(videoAsset?.payload) // Should not include payload when using local URL
    }
    
    func test_attachmentsToAssets_videoAttachmentWithoutLocalURL() {
        // Given
        let attachments = [createVideoAttachmentWithoutLocalURL()]
        let expectation = XCTestExpectation(description: "Video attachment conversion completion")
        var result: ComposerAssets?
        
        // When
        converter.attachmentsToAssets(attachments) { composerAssets in
            result = composerAssets
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.mediaAssets.count, 1)
        let videoAsset = result?.mediaAssets.first
        XCTAssertEqual(videoAsset?.url, URL(string: "https://example.com/video.mp4"))
        XCTAssertEqual(videoAsset?.type, .video)
        XCTAssertNotNil(videoAsset?.image) // Should have thumbnail
        XCTAssertNotNil(videoAsset?.payload)
    }
    
    func test_attachmentsToAssets_imageAttachmentWithLocalURL() {
        // Given
        let attachments = [createImageAttachmentWithLocalURL()]
        let expectation = XCTestExpectation(description: "Image attachment conversion completion")
        var result: ComposerAssets?
        
        // When
        converter.attachmentsToAssets(attachments) { composerAssets in
            result = composerAssets
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.mediaAssets.count, 1)
        let imageAsset = result?.mediaAssets.first
        XCTAssertEqual(imageAsset?.url, mockImageURL)
        XCTAssertEqual(imageAsset?.type, .image)
        XCTAssertNotNil(imageAsset?.image)
        XCTAssertNil(imageAsset?.payload) // Should not include payload when using local URL
    }
    
    func test_attachmentsToAssets_imageAttachmentWithoutLocalURL() {
        // Given
        let attachments = [createImageAttachmentWithoutLocalURL()]
        let expectation = XCTestExpectation(description: "Image attachment conversion completion")
        var result: ComposerAssets?
        
        // When
        converter.attachmentsToAssets(attachments) { composerAssets in
            result = composerAssets
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.mediaAssets.count, 1)
        let imageAsset = result?.mediaAssets.first
        XCTAssertEqual(imageAsset?.url, URL(string: "https://example.com/image.png"))
        XCTAssertEqual(imageAsset?.type, .image)
        XCTAssertNotNil(imageAsset?.image)
        XCTAssertNotNil(imageAsset?.payload)
    }
    
    // MARK: - Helper Methods
    
    private func createMockImageData() -> Data {
        // Create a simple 1x1 PNG image data
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.red.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image.pngData()!
    }
    
    private func createTemporaryFileURL(extension ext: String) -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        return tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension(ext)
    }
    
    private func createFileAttachmentWithLocalURL() -> AnyChatMessageAttachment {
        let attachmentFile = AttachmentFile(type: .pdf, size: 1024, mimeType: "application/pdf")
        let uploadingState = AttachmentUploadingState(
            localFileURL: mockFileURL,
            state: .pendingUpload,
            file: attachmentFile
        )
        
        return ChatMessageFileAttachment(
            id: .unique,
            type: .file,
            payload: FileAttachmentPayload(
                title: "Test PDF",
                assetRemoteURL: URL(string: "https://example.com/file.pdf")!,
                file: attachmentFile,
                extraData: ["test": "value"]
            ),
            downloadingState: nil,
            uploadingState: uploadingState
        ).asAnyAttachment
    }
    
    private func createFileAttachmentWithoutLocalURL() -> AnyChatMessageAttachment {
        let attachmentFile = AttachmentFile(type: .pdf, size: 1024, mimeType: "application/pdf")
        
        return ChatMessageFileAttachment(
            id: .unique,
            type: .file,
            payload: FileAttachmentPayload(
                title: "Test PDF",
                assetRemoteURL: URL(string: "https://example.com/file.pdf")!,
                file: attachmentFile,
                extraData: ["test": "value"]
            ),
            downloadingState: nil,
            uploadingState: nil
        ).asAnyAttachment
    }
    
    private func createVideoAttachmentWithLocalURL() -> AnyChatMessageAttachment {
        let attachmentFile = AttachmentFile(type: .mp4, size: 2048, mimeType: "video/mp4")
        let uploadingState = AttachmentUploadingState(
            localFileURL: mockVideoURL,
            state: .pendingUpload,
            file: attachmentFile
        )
        
        return ChatMessageVideoAttachment(
            id: .unique,
            type: .video,
            payload: VideoAttachmentPayload(
                title: "Test Video",
                videoRemoteURL: URL(string: "https://example.com/video.mp4")!,
                thumbnailURL: TestImages.yoda.url,
                file: attachmentFile,
                extraData: ["test": "value"]
            ),
            downloadingState: nil,
            uploadingState: uploadingState
        ).asAnyAttachment
    }
    
    private func createVideoAttachmentWithoutLocalURL() -> AnyChatMessageAttachment {
        let attachmentFile = AttachmentFile(type: .mp4, size: 2048, mimeType: "video/mp4")
        
        return ChatMessageVideoAttachment(
            id: .unique,
            type: .video,
            payload: VideoAttachmentPayload(
                title: "Test Video",
                videoRemoteURL: URL(string: "https://example.com/video.mp4")!,
                thumbnailURL: TestImages.yoda.url,
                file: attachmentFile,
                extraData: ["test": "value"]
            ),
            downloadingState: nil,
            uploadingState: nil
        ).asAnyAttachment
    }
    
    private func createImageAttachmentWithLocalURL() -> AnyChatMessageAttachment {
        let attachmentFile = AttachmentFile(type: .png, size: 512, mimeType: "image/png")
        let uploadingState = AttachmentUploadingState(
            localFileURL: mockImageURL,
            state: .pendingUpload,
            file: attachmentFile
        )
        
        return ChatMessageImageAttachment(
            id: .unique,
            type: .image,
            payload: ImageAttachmentPayload(
                title: "Test Image",
                imageRemoteURL: URL(string: "https://example.com/image.png")!,
                extraData: ["test": "value"]
            ),
            downloadingState: nil,
            uploadingState: uploadingState
        ).asAnyAttachment
    }
    
    private func createImageAttachmentWithSpecificLocalURL(_ url: URL) -> AnyChatMessageAttachment {
        let attachmentFile = AttachmentFile(type: .png, size: 512, mimeType: "image/png")
        let uploadingState = AttachmentUploadingState(
            localFileURL: url,
            state: .pendingUpload,
            file: attachmentFile
        )
        
        return ChatMessageImageAttachment(
            id: .unique,
            type: .image,
            payload: ImageAttachmentPayload(
                title: "Test Image",
                imageRemoteURL: URL(string: "https://example.com/image.png")!,
                extraData: ["test": "value"]
            ),
            downloadingState: nil,
            uploadingState: uploadingState
        ).asAnyAttachment
    }
    
    private func createImageAttachmentWithoutLocalURL() -> AnyChatMessageAttachment {
        let attachmentFile = AttachmentFile(type: .png, size: 512, mimeType: "image/png")
        
        return ChatMessageImageAttachment(
            id: .unique,
            type: .image,
            payload: ImageAttachmentPayload(
                title: "Test Image",
                imageRemoteURL: URL(string: "https://example.com/image.png")!,
                extraData: ["test": "value"]
            ),
            downloadingState: nil,
            uploadingState: nil
        ).asAnyAttachment
    }
}
