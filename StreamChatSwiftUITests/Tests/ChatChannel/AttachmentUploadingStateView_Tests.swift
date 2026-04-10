//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class AttachmentUploadingStateView_Tests: StreamChatTestCase {

    private let testURL = ChatChannelTestHelpers.testURL
    private let viewSize = CGSize(width: 200, height: 150)

    // MARK: - Uploading Progress

    func test_uploadingProgress_start_snapshot() {
        let view = makeView(state: .uploading(progress: 0))
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_uploadingProgress_half_snapshot() {
        let view = makeView(state: .uploading(progress: 0.5))
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_uploadingProgress_almostDone_snapshot() {
        let view = makeView(state: .uploading(progress: 0.9))
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    // MARK: - Upload Failed

    func test_uploadingFailed_snapshot() {
        let view = makeView(state: .uploadingFailed)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    // MARK: - Uploaded

    func test_uploaded_snapshot() {
        let view = makeView(state: .uploaded)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    // MARK: - Modifier

    func test_withUploadingStateIndicator_uploading_snapshot() {
        let uploadState = makeUploadingState(state: .uploading(progress: 0.6))
        let view = Color.gray
            .frame(width: viewSize.width, height: viewSize.height)
            .withUploadingStateIndicator(for: uploadState, url: testURL)
            .frame(width: viewSize.width, height: viewSize.height)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_withUploadingStateIndicator_failed_snapshot() {
        let uploadState = makeUploadingState(state: .uploadingFailed)
        let view = Color.gray
            .frame(width: viewSize.width, height: viewSize.height)
            .withUploadingStateIndicator(for: uploadState, url: testURL)
            .frame(width: viewSize.width, height: viewSize.height)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_withUploadingStateIndicator_nil_snapshot() {
        let view = Color.gray
            .frame(width: viewSize.width, height: viewSize.height)
            .withUploadingStateIndicator(for: nil, url: testURL)
            .frame(width: viewSize.width, height: viewSize.height)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    // MARK: - Helpers

    private func makeUploadingState(state: LocalAttachmentState) -> AttachmentUploadingState {
        AttachmentUploadingState(
            localFileURL: testURL,
            state: state,
            file: AttachmentFile(type: .png, size: 0, mimeType: "image/png")
        )
    }

    private func makeView(state: LocalAttachmentState) -> some View {
        let uploadState = makeUploadingState(state: state)
        return AttachmentUploadingStateView(uploadState: uploadState, url: testURL)
            .frame(width: viewSize.width, height: viewSize.height)
    }
}
