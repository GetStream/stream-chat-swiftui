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

    // MARK: - Download / Share Button

    func test_downloadShareAttachmentView_notDownloaded_snapshot() {
        let attachment = createFileAttachment(downloadingState: nil, uploadingState: nil)
        let size = CGSize(width: 44, height: 44)
        let view = DownloadShareAttachmentView(attachment: attachment, onShare: { _ in })
            .frame(width: size.width, height: size.height)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles, size: size)
    }

    func test_downloadShareAttachmentView_downloading_snapshot() {
        let downloadingState = AttachmentDownloadingState(
            localFileURL: nil,
            state: .downloading(progress: 0.5),
            file: nil
        )
        let attachment = createFileAttachment(downloadingState: downloadingState, uploadingState: nil)
        let size = CGSize(width: 44, height: 44)
        let view = DownloadShareAttachmentView(attachment: attachment, onShare: { _ in })
            .frame(width: size.width, height: size.height)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles, size: size)
    }

    func test_downloadShareAttachmentView_downloaded_snapshot() {
        let downloadingState = AttachmentDownloadingState(
            localFileURL: ChatChannelTestHelpers.testURL,
            state: .downloaded,
            file: nil
        )
        let attachment = createFileAttachment(downloadingState: downloadingState, uploadingState: nil)
        let size = CGSize(width: 44, height: 44)
        let view = DownloadShareAttachmentView(attachment: attachment, onShare: { _ in })
            .frame(width: size.width, height: size.height)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles, size: size)
    }

    // MARK: - Download / Share View Model

    func test_downloadShareViewModel_notDownloaded() {
        let attachment = createFileAttachment(downloadingState: nil, uploadingState: nil)
        let viewModel = DownloadShareAttachmentView.ViewModel(attachment: attachment)
        XCTAssertTrue(viewModel.downloadButtonShown)
        XCTAssertFalse(viewModel.isDownloading)
        XCTAssertNil(viewModel.downloadProgress)
        XCTAssertNil(viewModel.localFileURL)
    }

    func test_downloadShareViewModel_downloading() {
        let downloadingState = AttachmentDownloadingState(
            localFileURL: nil,
            state: .downloading(progress: 0.4),
            file: nil
        )
        let attachment = createFileAttachment(downloadingState: downloadingState, uploadingState: nil)
        let viewModel = DownloadShareAttachmentView.ViewModel(attachment: attachment)
        XCTAssertTrue(viewModel.isDownloading)
        XCTAssertEqual(viewModel.downloadProgress, 0.4)
        XCTAssertNil(viewModel.localFileURL)
    }

    func test_downloadShareViewModel_downloaded() {
        let downloadingState = AttachmentDownloadingState(
            localFileURL: ChatChannelTestHelpers.testURL,
            state: .downloaded,
            file: nil
        )
        let attachment = createFileAttachment(downloadingState: downloadingState, uploadingState: nil)
        let viewModel = DownloadShareAttachmentView.ViewModel(attachment: attachment)
        XCTAssertFalse(viewModel.isDownloading)
        XCTAssertEqual(viewModel.localFileURL, ChatChannelTestHelpers.testURL)
    }

    func test_downloadShareViewModel_downloadedFileMissing() {
        let downloadingState = AttachmentDownloadingState(
            localFileURL: FileManager.default.temporaryDirectory.appendingPathComponent("missing-attachment.pdf"),
            state: .downloaded,
            file: nil
        )
        let attachment = createFileAttachment(downloadingState: downloadingState, uploadingState: nil)
        let viewModel = DownloadShareAttachmentView.ViewModel(attachment: attachment)
        XCTAssertNil(viewModel.localFileURL)
    }

    func test_downloadShareViewModel_uploadInProgress() {
        let uploadingState = AttachmentUploadingState(
            localFileURL: ChatChannelTestHelpers.testURL,
            state: .uploading(progress: 0.5),
            file: AttachmentFile(type: .pdf, size: 1024, mimeType: "application/pdf")
        )
        let attachment = createFileAttachment(downloadingState: nil, uploadingState: uploadingState)
        let viewModel = DownloadShareAttachmentView.ViewModel(attachment: attachment)
        XCTAssertFalse(viewModel.downloadButtonShown)
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
