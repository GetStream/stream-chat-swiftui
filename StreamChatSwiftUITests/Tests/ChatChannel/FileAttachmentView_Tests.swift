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
    // MARK: - Upload States

    func test_fileAttachmentView_uploadingProgress_snapshot() {
        let uploadingState = AttachmentUploadingState(
            localFileURL: ChatChannelTestHelpers.testURL,
            state: .uploading(progress: 0.5),
            file: AttachmentFile(type: .pdf, size: 1024, mimeType: "application/pdf")
        )
        let attachment = createFileAttachment(downloadingState: nil, uploadingState: uploadingState)
        let view = FileAttachmentView(
            attachment: attachment,
            width: 300,
            isFirst: true
        )
        .applyDefaultSize()
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_fileAttachmentView_uploadingFailed_snapshot() {
        let uploadingState = AttachmentUploadingState(
            localFileURL: ChatChannelTestHelpers.testURL,
            state: .uploadingFailed,
            file: AttachmentFile(type: .pdf, size: 1024, mimeType: "application/pdf")
        )
        let attachment = createFileAttachment(downloadingState: nil, uploadingState: uploadingState)
        let view = FileAttachmentView(
            attachment: attachment,
            width: 300,
            isFirst: true
        )
        .applyDefaultSize()
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_fileAttachmentView_uploaded_snapshot() {
        let uploadingState = AttachmentUploadingState(
            localFileURL: ChatChannelTestHelpers.testURL,
            state: .uploaded,
            file: AttachmentFile(type: .pdf, size: 1024, mimeType: "application/pdf")
        )
        let attachment = createFileAttachment(downloadingState: nil, uploadingState: uploadingState)
        let view = FileAttachmentView(
            attachment: attachment,
            width: 300,
            isFirst: true
        )
        .applyDefaultSize()
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
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
