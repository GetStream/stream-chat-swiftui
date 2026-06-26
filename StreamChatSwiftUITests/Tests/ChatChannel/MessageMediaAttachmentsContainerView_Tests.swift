//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

@MainActor final class MessageMediaAttachmentsContainerView_Tests: StreamChatTestCase {
    private let testURL = URL(string: "https://getstream.io/video.mp4")!

    // MARK: - Image

    func test_mediaAccessibilityLabel_imageFromOtherUser_usesRichLabelWithAttachmentNumber() {
        let message = makeMessage(
            author: .mock(id: "yoda", name: "Yoda"),
            isSentByCurrentUser: false
        )
        let view = makeView(for: message)
        let item = MediaAttachment(url: testURL, type: .image)

        XCTAssertEqual(
            view.mediaAccessibilityLabel(for: item, index: 2),
            attachmentPrefixed(3, L10n.Message.Accessibility.image("Yoda", expectedTime(for: message)))
        )
    }

    func test_mediaAccessibilityLabel_ownImage_usesRichLabelWithAttachmentNumber() {
        let message = makeMessage(
            author: .mock(id: Self.currentUserId, name: "Me"),
            isSentByCurrentUser: true
        )
        let view = makeView(for: message)
        let item = MediaAttachment(url: testURL, type: .image)

        XCTAssertEqual(
            view.mediaAccessibilityLabel(for: item, index: 0),
            attachmentPrefixed(1, L10n.Message.Accessibility.imageOwn(expectedTime(for: message)))
        )
    }

    func test_mediaAccessibilityLabel_imageWithCaption_omitsTimestamp() {
        let message = makeMessage(
            author: .mock(id: "yoda", name: "Yoda"),
            isSentByCurrentUser: false,
            text: "Look at this"
        )
        let view = makeView(for: message)
        let item = MediaAttachment(url: testURL, type: .image)

        XCTAssertEqual(
            view.mediaAccessibilityLabel(for: item, index: 0),
            attachmentPrefixed(1, L10n.Message.Accessibility.imageWithoutTimestamp("Yoda"))
        )
    }

    // MARK: - Video from another user

    func test_mediaAccessibilityLabel_videoFromOtherUser_withoutDuration() {
        let message = makeMessage(
            author: .mock(id: "yoda", name: "Yoda"),
            isSentByCurrentUser: false
        )
        let view = makeView(for: message)
        let item = makeVideoAttachment(duration: nil)

        XCTAssertEqual(
            view.mediaAccessibilityLabel(for: item, index: 0),
            attachmentPrefixed(1, L10n.Message.Accessibility.video("Yoda", expectedTime(for: message)))
        )
    }

    func test_mediaAccessibilityLabel_videoFromOtherUser_withDuration() throws {
        let message = makeMessage(
            author: .mock(id: "yoda", name: "Yoda"),
            isSentByCurrentUser: false
        )
        let view = makeView(for: message)
        let item = makeVideoAttachment(duration: 83)
        let durationText = try XCTUnwrap(view.videoDurationText(for: item))

        XCTAssertEqual(
            view.mediaAccessibilityLabel(for: item, index: 0),
            attachmentPrefixed(1, L10n.Message.Accessibility.videoWithDuration(durationText, "Yoda", expectedTime(for: message)))
        )
    }

    func test_mediaAccessibilityLabel_videoFromOtherUser_fallsBackToAuthorIdWhenNameMissing() {
        let message = makeMessage(
            author: .mock(id: "yoda", name: nil),
            isSentByCurrentUser: false
        )
        let view = makeView(for: message)
        let item = makeVideoAttachment(duration: nil)

        XCTAssertEqual(
            view.mediaAccessibilityLabel(for: item, index: 0),
            attachmentPrefixed(1, L10n.Message.Accessibility.video("yoda", expectedTime(for: message)))
        )
    }

    // MARK: - Video from the current user

    func test_mediaAccessibilityLabel_ownVideo_withoutDuration() {
        let message = makeMessage(
            author: .mock(id: Self.currentUserId, name: "Me"),
            isSentByCurrentUser: true
        )
        let view = makeView(for: message)
        let item = makeVideoAttachment(duration: nil)

        XCTAssertEqual(
            view.mediaAccessibilityLabel(for: item, index: 0),
            attachmentPrefixed(1, L10n.Message.Accessibility.videoOwn(expectedTime(for: message)))
        )
    }

    func test_mediaAccessibilityLabel_ownVideo_withDuration() throws {
        let message = makeMessage(
            author: .mock(id: Self.currentUserId, name: "Me"),
            isSentByCurrentUser: true
        )
        let view = makeView(for: message)
        let item = makeVideoAttachment(duration: 83)
        let durationText = try XCTUnwrap(view.videoDurationText(for: item))

        XCTAssertEqual(
            view.mediaAccessibilityLabel(for: item, index: 0),
            attachmentPrefixed(1, L10n.Message.Accessibility.videoOwnWithDuration(durationText, expectedTime(for: message)))
        )
    }

    // MARK: - Video with a caption omits the timestamp

    func test_mediaAccessibilityLabel_videoFromOtherUserWithCaption_omitsTimestamp() {
        let message = makeMessage(
            author: .mock(id: "yoda", name: "Yoda"),
            isSentByCurrentUser: false,
            text: "Look at this"
        )
        let view = makeView(for: message)
        let item = makeVideoAttachment(duration: nil)

        XCTAssertEqual(
            view.mediaAccessibilityLabel(for: item, index: 0),
            attachmentPrefixed(1, L10n.Message.Accessibility.videoWithoutTimestamp("Yoda"))
        )
    }

    func test_mediaAccessibilityLabel_videoFromOtherUserWithCaptionAndDuration_omitsTimestamp() throws {
        let message = makeMessage(
            author: .mock(id: "yoda", name: "Yoda"),
            isSentByCurrentUser: false,
            text: "Look at this"
        )
        let view = makeView(for: message)
        let item = makeVideoAttachment(duration: 83)
        let durationText = try XCTUnwrap(view.videoDurationText(for: item))

        XCTAssertEqual(
            view.mediaAccessibilityLabel(for: item, index: 0),
            attachmentPrefixed(1, L10n.Message.Accessibility.videoWithDurationWithoutTimestamp(durationText, "Yoda"))
        )
    }

    func test_mediaAccessibilityLabel_ownVideoWithCaption_omitsTimestamp() {
        let message = makeMessage(
            author: .mock(id: Self.currentUserId, name: "Me"),
            isSentByCurrentUser: true,
            text: "Look at this"
        )
        let view = makeView(for: message)
        let item = makeVideoAttachment(duration: nil)

        XCTAssertEqual(
            view.mediaAccessibilityLabel(for: item, index: 0),
            attachmentPrefixed(1, L10n.Message.Accessibility.videoOwnWithoutTimestamp)
        )
    }

    func test_mediaAccessibilityLabel_ownVideoWithCaptionAndDuration_omitsTimestamp() throws {
        let message = makeMessage(
            author: .mock(id: Self.currentUserId, name: "Me"),
            isSentByCurrentUser: true,
            text: "Look at this"
        )
        let view = makeView(for: message)
        let item = makeVideoAttachment(duration: 83)
        let durationText = try XCTUnwrap(view.videoDurationText(for: item))

        XCTAssertEqual(
            view.mediaAccessibilityLabel(for: item, index: 0),
            attachmentPrefixed(1, L10n.Message.Accessibility.videoOwnWithDurationWithoutTimestamp(durationText))
        )
    }

    // MARK: - Duration formatting

    func test_videoDurationText_whenNoDurationExtraData_returnsNil() {
        let message = makeMessage(isSentByCurrentUser: false)
        let view = makeView(for: message)
        let item = makeVideoAttachment(duration: nil)

        XCTAssertNil(view.videoDurationText(for: item))
    }

    func test_videoDurationText_whenImageAttachment_returnsNil() {
        let message = makeMessage(isSentByCurrentUser: false)
        let view = makeView(for: message)
        let item = MediaAttachment(url: testURL, type: .image)

        XCTAssertNil(view.videoDurationText(for: item))
    }

    func test_videoDurationText_whenDurationExtraData_returnsFullStyleFormattedDuration() {
        let message = makeMessage(isSentByCurrentUser: false)
        let view = makeView(for: message)
        let item = makeVideoAttachment(duration: 83)

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .full

        XCTAssertEqual(view.videoDurationText(for: item), formatter.string(from: 83))
    }

    // MARK: - Helpers

    private func makeMessage(
        author: ChatUser = .mock(id: "yoda", name: "Yoda"),
        isSentByCurrentUser: Bool,
        text: String = ""
    ) -> ChatMessage {
        ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: text,
            author: author,
            createdAt: Date(timeIntervalSince1970: 100),
            isSentByCurrentUser: isSentByCurrentUser
        )
    }

    private func makeView(for message: ChatMessage) -> MessageMediaAttachmentsContainerView<DefaultViewFactory> {
        MessageMediaAttachmentsContainerView(
            factory: DefaultViewFactory.shared,
            message: message,
            width: 300
        )
    }

    private func makeVideoAttachment(duration: Double?) -> MediaAttachment {
        let file = AttachmentFile(type: .mp4, size: 0, mimeType: "video/mp4")
        var extraData: [String: RawJSON]?
        if let duration {
            extraData = ["duration": .number(duration)]
        }
        let attachment = ChatMessageVideoAttachment(
            id: .unique,
            type: .video,
            payload: VideoAttachmentPayload(
                title: "test",
                videoRemoteURL: testURL,
                file: file,
                extraData: extraData
            ),
            downloadingState: nil,
            uploadingState: nil
        )
        return MediaAttachment(from: attachment)
    }

    private func expectedTime(for message: ChatMessage) -> String {
        streamChat?.utils.dateFormatter.string(from: message.createdAt) ?? ""
    }

    private func attachmentPrefixed(_ number: Int, _ label: String) -> String {
        "\(L10n.Message.Attachment.accessibilityLabel(number)). \(label)"
    }
}
