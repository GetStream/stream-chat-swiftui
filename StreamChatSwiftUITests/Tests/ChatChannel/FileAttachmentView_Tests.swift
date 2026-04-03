//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class FileAttachmentView_Tests: StreamChatTestCase {
    func test_fileAttachmentView_downloadingState() {
        // Given
        let downloadingState = AttachmentDownloadingState(
            localFileURL: nil,
            state: .downloading(progress: 0.5),
            file: nil
        )
        let attachment = createFileAttachment(downloadingState: downloadingState, uploadingState: nil)

        // When
        let view = FileAttachmentView(
            attachment: attachment,
            width: 300,
            isFirst: true
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_fileAttachmentView_downloadedState() {
        // Given
        let downloadingState = AttachmentDownloadingState(
            localFileURL: URL(string: "file:///tmp/test.pdf")!,
            state: .downloaded,
            file: nil
        )
        let attachment = createFileAttachment(downloadingState: downloadingState, uploadingState: nil)

        // When
        let view = FileAttachmentView(
            attachment: attachment,
            width: 300,
            isFirst: true
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_fileAttachmentView_downloadDisabled() {
        // Given
        let attachment = createFileAttachment(downloadingState: nil, uploadingState: nil)

        // When
        let view = FileAttachmentView(
            attachment: attachment,
            width: 300,
            isFirst: true
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    // MARK: - Helper Methods
    
    private func createFileAttachment(
        downloadingState: AttachmentDownloadingState?,
        uploadingState: AttachmentUploadingState?
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
            uploadingState: uploadingState
        )
    }
}
