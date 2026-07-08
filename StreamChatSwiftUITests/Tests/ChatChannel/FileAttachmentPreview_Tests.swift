//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

class FileAttachmentPreview_Tests: StreamChatTestCase {
    func test_fileAttachmentPreview_downloaded_usesLocalFileURL() {
        let downloadingState = AttachmentDownloadingState(
            localFileURL: ChatChannelTestHelpers.testURL,
            state: .downloaded,
            file: nil
        )
        let attachment = createFileAttachment(downloadingState: downloadingState)
        let view = FileAttachmentPreview(attachment: attachment)
        XCTAssertEqual(view.url, ChatChannelTestHelpers.testURL)
    }

    func test_fileAttachmentPreview_downloadedFileMissing_usesRemoteURL() {
        let downloadingState = AttachmentDownloadingState(
            localFileURL: FileManager.default.temporaryDirectory.appendingPathComponent("missing-attachment.pdf"),
            state: .downloaded,
            file: nil
        )
        let attachment = createFileAttachment(downloadingState: downloadingState)
        let view = FileAttachmentPreview(attachment: attachment)
        XCTAssertEqual(view.url, attachment.assetURL)
    }

    func test_fileAttachmentPreview_downloading_usesRemoteURL() {
        let downloadingState = AttachmentDownloadingState(
            localFileURL: ChatChannelTestHelpers.testURL,
            state: .downloading(progress: 0.5),
            file: nil
        )
        let attachment = createFileAttachment(downloadingState: downloadingState)
        let view = FileAttachmentPreview(attachment: attachment)
        XCTAssertEqual(view.url, attachment.assetURL)
    }

    func test_fileAttachmentPreview_notDownloaded_usesRemoteURL() {
        let attachment = createFileAttachment(downloadingState: nil)
        let view = FileAttachmentPreview(attachment: attachment)
        XCTAssertEqual(view.url, attachment.assetURL)
    }

    // MARK: - Helper Methods

    private func createFileAttachment(
        downloadingState: AttachmentDownloadingState?
    ) -> ChatMessageFileAttachment {
        ChatMessageFileAttachment(
            id: .unique,
            type: .file,
            payload: FileAttachmentPayload(
                title: "test.pdf",
                assetRemoteURL: URL(string: "https://example.com/test.pdf")!,
                file: AttachmentFile(type: .pdf, size: 1024, mimeType: "application/pdf"),
                extraData: nil
            ),
            downloadingState: downloadingState,
            uploadingState: nil
        )
    }
}
