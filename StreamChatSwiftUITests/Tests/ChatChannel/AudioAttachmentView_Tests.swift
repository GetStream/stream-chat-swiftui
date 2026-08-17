//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor
final class AudioAttachmentView_Tests: StreamChatTestCase {
    private let audioURL = URL(string: "https://example.com/sample.mp3")!
    private let file = AttachmentFile(type: .mp3, size: 4_000_000, mimeType: "audio/mpeg")

    func test_audioAttachmentView_default_snapshot() {
        let view = AudioAttachmentView(
            handler: AudioSessionHandler(),
            attachment: makeAttachment(),
            message: makeMessage(),
            isSentByCurrentUser: true
        )
        .frame(width: 256, height: 64)

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles, size: CGSize(width: 256, height: 64))
    }

    func test_audioAttachmentView_playing_snapshot() {
        let handler = AudioSessionHandler()
        handler.isPlaying = true
        handler.context = AudioPlaybackContext(
            assetLocation: audioURL,
            duration: 8,
            currentTime: 3,
            state: .playing,
            rate: .normal,
            isSeeking: false
        )

        let view = AudioAttachmentView(
            handler: handler,
            attachment: makeAttachment(),
            message: makeMessage(),
            isSentByCurrentUser: true
        )
        .frame(width: 256, height: 64)

        AssertSnapshot(view, variants: [.defaultLight], size: CGSize(width: 256, height: 64))
    }

    func test_audioAttachmentView_uploading_snapshot() {
        let uploadingState = AttachmentUploadingState(
            localFileURL: ChatChannelTestHelpers.testURL,
            state: .uploading(progress: 0.6),
            file: file
        )
        let view = AudioAttachmentView(
            handler: AudioSessionHandler(),
            attachment: makeAttachment(uploadingState: uploadingState),
            message: makeMessage(),
            isSentByCurrentUser: true
        )
        .frame(width: 256, height: 64)

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles, size: CGSize(width: 256, height: 64))
    }

    func test_audioAttachmentView_uploadingFailed_snapshot() {
        let uploadingState = AttachmentUploadingState(
            localFileURL: ChatChannelTestHelpers.testURL,
            state: .uploadingFailed,
            file: file
        )
        let view = AudioAttachmentView(
            handler: AudioSessionHandler(),
            attachment: makeAttachment(uploadingState: uploadingState),
            message: makeMessage(),
            isSentByCurrentUser: true
        )
        .frame(width: 256, height: 80)

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles, size: CGSize(width: 256, height: 80))
    }

    func test_audioAttachmentPayload_readsDurationFromExtraData() {
        let payload = AudioAttachmentPayload(
            title: "Sample.mp3",
            audioRemoteURL: audioURL,
            file: file,
            extraData: ["duration": .number(8)]
        )

        XCTAssertEqual(payload.duration, 8)
    }

    func test_audioAttachmentPayload_durationMissingFromExtraData() {
        let payload = AudioAttachmentPayload(
            title: "Sample.mp3",
            audioRemoteURL: audioURL,
            file: file,
            extraData: nil
        )

        XCTAssertNil(payload.duration)
    }

    func test_audioAttachmentView_readsDurationFromRawPayloadAfterRoundTrip() {
        let attachment = makeAttachment()
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            attachments: [attachment.asAnyAttachment]
        )

        XCTAssertEqual(
            AudioAttachmentView.duration(fromRawPayload: message.attachment(with: attachment.id)?.payload),
            8
        )
    }

    func test_audioAttachmentsContainer_snapshot() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.audioAttachments
        )
        let view = MessageAttachmentsView(
            factory: DefaultViewFactory.shared,
            message: message,
            width: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .frame(width: defaultScreenSize.width, height: 80)

        AssertSnapshot(
            view,
            variants: .onlyUserInterfaceStyles,
            size: CGSize(width: defaultScreenSize.width, height: 80)
        )
    }

    // MARK: - Helpers

    private func makeAttachment(
        uploadingState: AttachmentUploadingState? = nil
    ) -> ChatMessageAudioAttachment {
        ChatMessageAudioAttachment(
            id: .unique,
            type: .audio,
            payload: AudioAttachmentPayload(
                title: "Sample.mp3",
                audioRemoteURL: audioURL,
                file: file,
                extraData: ["duration": .number(8)]
            ),
            downloadingState: nil,
            uploadingState: uploadingState
        )
    }

    private func makeMessage() -> ChatMessage {
        ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique)
        )
    }
}
