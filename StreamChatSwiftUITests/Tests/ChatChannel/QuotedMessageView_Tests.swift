//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class QuotedMessageView_Tests: StreamChatTestCase {
    private let testMessage = ChatMessage.mock(
        id: "test",
        cid: .unique,
        text: "This is a test message 1",
        author: .mock(id: "test", name: "martin")
    )

    func test_quotedMessageViewContainer_snapshot() {
        // Given
        let view = QuotedMessageViewContainer(
            factory: DefaultViewFactory.shared,
            quotedMessage: testMessage,
            fillAvailableSpace: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_quotedMessageView_snapshot() {
        // Given
        let view = QuotedMessageView(
            factory: DefaultViewFactory.shared,
            quotedMessage: testMessage,
            fillAvailableSpace: true,
            forceLeftToRight: true
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_quotedMessageView_deletedSnapshot() {
        // Given
        let viewSize = CGSize(width: 200, height: 50)
        let message = ChatMessage.mock(text: "Hello", deletedAt: .unique)
        let view = QuotedMessageView(
            factory: DefaultViewFactory.shared,
            quotedMessage: message,
            fillAvailableSpace: true,
            forceLeftToRight: true
        )
        .applySize(viewSize)
        
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles, size: viewSize)
    }
    
    func test_quotedMessageView_voiceAttachmentSnapshot() {
        // Given
        let payload = VoiceRecordingAttachmentPayload(
            title: "Recording",
            voiceRecordingRemoteURL: .localYodaImage,
            file: try! .init(url: .localYodaQuote),
            duration: 3,
            waveformData: [0, 0.3, 0.6, 1],
            extraData: nil
        )
        let view = VoiceRecordingPreview(voiceAttachment: payload)
            .frame(width: defaultScreenSize.width, height: 120)
            .padding()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_quotedMessageView_voiceAttachmentWithTextSnapshot() {
        // Given
        let payload = VoiceRecordingAttachmentPayload(
            title: "Recording",
            voiceRecordingRemoteURL: .localYodaImage,
            file: try! .init(url: .localYodaQuote),
            duration: 3,
            waveformData: [0, 0.3, 0.6, 1],
            extraData: nil
        )
        let viewSize = CGSize(width: 200, height: 50)
        let message = ChatMessage.mock(
            text: "Hello, how are you?",
            deletedAt: .unique,
            attachments: [
                ChatMessageVoiceRecordingAttachment(
                    id: .unique,
                    type: .voiceRecording,
                    payload: payload,
                    downloadingState: nil,
                    uploadingState: nil
                ).asAnyAttachment
            ]
        )
        let view = QuotedMessageView(
            factory: DefaultViewFactory.shared,
            quotedMessage: message,
            fillAvailableSpace: true,
            forceLeftToRight: true
        )
        .applySize(viewSize)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    // MARK: - Custom Size Tests
    
    func test_quotedMessageViewContainer_customAttachmentSize_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: "test",
            cid: .unique,
            text: "Image attachment",
            author: .mock(id: "test", name: "martin"),
            attachments: [
                ChatMessageImageAttachment.mock(
                    id: .unique,
                    imageURL: .localYodaImage
                ).asAnyAttachment
            ]
        )
        let customAttachmentSize = CGSize(width: 60, height: 60)
        let view = QuotedMessageViewContainer(
            factory: DefaultViewFactory.shared,
            quotedMessage: message,
            fillAvailableSpace: true,
            scrolledId: .constant(nil),
            attachmentSize: customAttachmentSize
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_quotedMessageViewContainer_customAvatarSize_snapshot() {
        // Given
        let customAvatarSize = CGSize(width: 40, height: 40)
        let view = QuotedMessageViewContainer(
            factory: DefaultViewFactory.shared,
            quotedMessage: testMessage,
            fillAvailableSpace: true,
            scrolledId: .constant(nil),
            quotedAuthorAvatarSize: customAvatarSize
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_quotedMessageView_customAttachmentSize_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: "test",
            cid: .unique,
            text: "Image attachment",
            author: .mock(id: "test", name: "martin"),
            attachments: [
                ChatMessageImageAttachment.mock(
                    id: .unique,
                    imageURL: .localYodaImage
                ).asAnyAttachment
            ]
        )
        let customAttachmentSize = CGSize(width: 50, height: 50)
        let view = QuotedMessageView(
            factory: DefaultViewFactory.shared,
            quotedMessage: message,
            fillAvailableSpace: true,
            forceLeftToRight: true,
            attachmentSize: customAttachmentSize
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_quotedMessageViewContainer_defaultSizes() {
        // Given
        let container = QuotedMessageViewContainer(
            factory: DefaultViewFactory.shared,
            quotedMessage: testMessage,
            fillAvailableSpace: true,
            scrolledId: .constant(nil)
        )
        
        // Then - Default sizes should be applied
        XCTAssertEqual(container.attachmentSize, CGSize(width: 36, height: 36))
        XCTAssertEqual(container.quotedAuthorAvatarSize, CGSize(width: 24, height: 24))
    }
    
    func test_quotedMessageView_defaultAttachmentSize() {
        // Given
        let view = QuotedMessageView(
            factory: DefaultViewFactory.shared,
            quotedMessage: testMessage,
            fillAvailableSpace: true,
            forceLeftToRight: true
        )
        
        // Then - Default attachment size should be applied
        XCTAssertEqual(view.attachmentSize, CGSize(width: 36, height: 36))
    }
    
    func test_quotedMessageView_customContentView_snapshot() {
        // Given - Create a custom football game result attachment
        let footballGamePayload = FootballGameAttachmentPayload(
            homeTeam: "Benfica",
            awayTeam: "Porto",
            homeScore: 2,
            awayScore: 0
        )

        let customAttachment = ChatMessageAttachment<FootballGameAttachmentPayload>(
            id: .unique,
            type: .init(rawValue: "football_game"),
            payload: footballGamePayload,
            downloadingState: nil,
            uploadingState: nil
        ).asAnyAttachment

        let message = ChatMessage.mock(
            id: "test",
            cid: .unique,
            text: "Check out this game result!",
            author: .mock(id: "test", name: "martin"),
            attachments: [customAttachment]
        )
        
        let view = QuotedMessageViewContainer(
            factory: CustomQuotedContentViewFactory.shared,
            quotedMessage: message,
            fillAvailableSpace: false,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}

// MARK: - Custom Football Game Attachment for Custom Quoted Message

private struct FootballGameAttachmentPayload: AttachmentPayload {
    let homeTeam: String
    let awayTeam: String
    let homeScore: Int
    let awayScore: Int

    static let type: AttachmentType = .init(rawValue: "football_game")
}

private class CustomQuotedContentViewFactory: ViewFactory {
    @Injected(\.chatClient) var chatClient
    
    private init() {}
    
    static let shared = CustomQuotedContentViewFactory()
    
    func makeQuotedMessageContentView(
        options: QuotedMessageContentViewOptions
    ) -> some View {
        Group {
            if let footballGameAttachmentPayload = options.quotedMessage
                .attachments(payloadType: FootballGameAttachmentPayload.self)
                .first?
                .payload {
                // Show custom football game result view
                FootballGameQuotedView(payload: footballGameAttachmentPayload)
            } else {
                // Fallback to default content view
                QuotedMessageContentView(
                    factory: self,
                    options: options
                )
            }
        }
    }
}

private struct FootballGameQuotedView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    let payload: FootballGameAttachmentPayload
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .center, spacing: 4) {
                Text("⚽")
                    .font(.title2)
                Text("Match")
                    .font(fonts.footnoteBold)
                    .foregroundColor(Color(colors.textLowEmphasis))
            }
            
            Divider()
                .frame(height: 50)
            
            VStack(spacing: 8) {
                HStack {
                    Text(payload.homeTeam)
                        .font(fonts.bodyBold)
                        .foregroundColor(Color(colors.text))
                    Spacer()
                    Text("\(payload.homeScore)")
                        .font(fonts.title)
                        .foregroundColor(Color(colors.text))
                        .frame(minWidth: 30)
                }
                
                HStack {
                    Text(payload.awayTeam)
                        .font(fonts.bodyBold)
                        .foregroundColor(Color(colors.text))
                    Spacer()
                    Text("\(payload.awayScore)")
                        .font(fonts.title)
                        .foregroundColor(Color(colors.text))
                        .frame(minWidth: 30)
                }
            }
        }
        .padding(8)
        .frame(minWidth: 200)
    }
}
