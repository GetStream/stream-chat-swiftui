//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

@MainActor final class MessageAccessibilityFormatter_Tests: StreamChatTestCase {
    private lazy var formatter = MessageAccessibilityFormatter()

    // MARK: - Sender name

    func test_senderName_whenSentByCurrentUser_returnsYou() {
        let message = makeMessage(isSentByCurrentUser: true)

        XCTAssertEqual(formatter.senderName(for: message), L10n.Message.Accessibility.you)
    }

    func test_senderName_whenFromOtherUser_returnsAuthorName() {
        let message = makeMessage(author: .mock(id: "yoda", name: "Yoda"), isSentByCurrentUser: false)

        XCTAssertEqual(formatter.senderName(for: message), "Yoda")
    }

    func test_senderName_whenFromOtherUserWithoutName_fallsBackToAuthorId() {
        let message = makeMessage(author: .mock(id: "yoda", name: nil), isSentByCurrentUser: false)

        XCTAssertEqual(formatter.senderName(for: message), "yoda")
    }

    // MARK: - Author name

    func test_authorName_usesNameWhenAvailable() {
        let message = makeMessage(author: .mock(id: "yoda", name: "Yoda"), isSentByCurrentUser: false)

        XCTAssertEqual(formatter.authorName(for: message), "Yoda")
    }

    func test_authorName_fallsBackToAuthorIdWhenNameMissing() {
        let message = makeMessage(author: .mock(id: "yoda", name: nil), isSentByCurrentUser: false)

        XCTAssertEqual(formatter.authorName(for: message), "yoda")
    }

    // MARK: - Sent time

    func test_sentTime_matchesUtilsDateFormatter() {
        let message = makeMessage(isSentByCurrentUser: false)

        XCTAssertEqual(formatter.sentTime(for: message), expectedTime(for: message))
    }

    // MARK: - Duration

    func test_duration_returnsFullStyleFormattedDuration() {
        let expected = DateComponentsFormatter.fullStyle.string(from: 83)

        XCTAssertEqual(formatter.duration(from: 83), expected)
    }

    // MARK: - Voice recording

    func test_voiceRecordingLabel_fromOtherUser_includesSenderDurationAndTime() {
        let message = makeMessage(author: .mock(id: "yoda", name: "Yoda"), isSentByCurrentUser: false)

        XCTAssertEqual(
            formatter.voiceRecordingLabel(for: message, duration: "5 seconds"),
            L10n.Message.Accessibility.voiceRecording("Yoda", "5 seconds", expectedTime(for: message))
        )
    }

    func test_voiceRecordingLabel_ownRecording_includesDurationAndTime() {
        let message = makeMessage(author: .mock(id: Self.currentUserId, name: "Me"), isSentByCurrentUser: true)

        XCTAssertEqual(
            formatter.voiceRecordingLabel(for: message, duration: "5 seconds"),
            L10n.Message.Accessibility.voiceRecordingOwn("5 seconds", expectedTime(for: message))
        )
    }

    func test_voiceRecordingLabel_whenDurationMissing_usesEmptyDuration() {
        let message = makeMessage(author: .mock(id: "yoda", name: "Yoda"), isSentByCurrentUser: false)

        XCTAssertEqual(
            formatter.voiceRecordingLabel(for: message, duration: nil),
            L10n.Message.Accessibility.voiceRecording("Yoda", "", expectedTime(for: message))
        )
    }

    // MARK: - Image label

    func test_imageLabel_fromOtherUser_withTimestamp() {
        let message = makeMessage(author: .mock(id: "yoda", name: "Yoda"), isSentByCurrentUser: false)

        XCTAssertEqual(
            formatter.imageLabel(for: message, attachmentNumber: 1, includesTimestamp: true),
            attachmentPrefixed(1, L10n.Message.Accessibility.image("Yoda", expectedTime(for: message)))
        )
    }

    func test_imageLabel_ownImage_withoutTimestamp() {
        let message = makeMessage(author: .mock(id: Self.currentUserId, name: "Me"), isSentByCurrentUser: true)

        XCTAssertEqual(
            formatter.imageLabel(for: message, attachmentNumber: 2, includesTimestamp: false),
            attachmentPrefixed(2, L10n.Message.Accessibility.imageOwnWithoutTimestamp)
        )
    }

    // MARK: - Video label

    func test_videoLabel_fromOtherUser_withDurationAndTimestamp() {
        let message = makeMessage(author: .mock(id: "yoda", name: "Yoda"), isSentByCurrentUser: false)

        XCTAssertEqual(
            formatter.videoLabel(for: message, attachmentNumber: 1, duration: "1 minute", includesTimestamp: true),
            attachmentPrefixed(1, L10n.Message.Accessibility.videoWithDuration("1 minute", "Yoda", expectedTime(for: message)))
        )
    }

    func test_videoLabel_ownVideo_withoutDurationWithoutTimestamp() {
        let message = makeMessage(author: .mock(id: Self.currentUserId, name: "Me"), isSentByCurrentUser: true)

        XCTAssertEqual(
            formatter.videoLabel(for: message, attachmentNumber: 1, duration: nil, includesTimestamp: false),
            attachmentPrefixed(1, L10n.Message.Accessibility.videoOwnWithoutTimestamp)
        )
    }

    // MARK: - Helpers

    private func makeMessage(
        author: ChatUser = .mock(id: "yoda", name: "Yoda"),
        isSentByCurrentUser: Bool
    ) -> ChatMessage {
        ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: author,
            createdAt: Date(timeIntervalSince1970: 100),
            isSentByCurrentUser: isSentByCurrentUser
        )
    }

    private func expectedTime(for message: ChatMessage) -> String {
        streamChat?.utils.dateFormatter.string(from: message.createdAt) ?? ""
    }

    private func attachmentPrefixed(_ number: Int, _ label: String) -> String {
        "\(L10n.Message.Attachment.accessibilityLabel(number)). \(label)"
    }
}

private extension DateComponentsFormatter {
    static let fullStyle: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .full
        return formatter
    }()
}
