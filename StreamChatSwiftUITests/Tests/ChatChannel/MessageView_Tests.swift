//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatCommonUI
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class MessageView_Tests: StreamChatTestCase {
    override func setUp() {
        super.setUp()

        streamChat = StreamChat(
            chatClient: chatClient,
            utils: Utils(
                mediaLoader: MediaLoader_Mock(),
                messageListConfig: .init(markdownSupportEnabled: true),
                composerConfig: .init(isVoiceRecordingEnabled: true)
            )
        )
    }
    
    func test_messageViewText_snapshot() {
        // Given
        let textMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test message",
            author: .mock(id: .unique)
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: textMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageViewText_sendingFailed_singleLine_snapshot() {
        // Given
        let textMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test message",
            author: .mock(id: .unique),
            localState: .sendingFailed
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: textMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .overlay(SendFailureIndicator())
        .frame(width: defaultScreenSize.width, height: 100)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageViewText_sendingFailed_multiLine_snapshot() {
        // Given
        let textMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hey, did you get a chance to look at the venue options for Saturday?",
            author: .mock(id: .unique),
            localState: .sendingFailed
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: textMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .overlay(SendFailureIndicator())
        .frame(width: defaultScreenSize.width, height: 150)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageViewTextMention_snapshot() {
        // Given
        let textMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hi @Martin, how are you?",
            author: .mock(id: .unique),
            mentionedUsers: [.mock(id: "martin", name: "Martin")]
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: textMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .frame(width: defaultScreenSize.width, height: 100)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageViewTextMentionMultiple_snapshot() {
        // Given
        let textMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hi @Martin and @Alexey, how are you? This is @Martin's test!",
            author: .mock(id: .unique),
            mentionedUsers: [.mock(id: "martin", name: "Martin"), .mock(id: "alexey", name: "Alexey")]
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: textMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .frame(width: defaultScreenSize.width, height: 100)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageViewImage_snapshot() {
        // Given
        let imageMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test message",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.imageAttachments
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: imageMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageViewPortraitImage_snapshot() {
        // Given
        let imageMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test message",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.imageAttachments(
                count: 1,
                originalWidth: 1200,
                originalHeight: 1600
            )
        )

        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: imageMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageViewPortraitImageLongText_snapshot() {
        // Given
        let imageMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "This is a much longer message that should span multiple lines when displayed below the portrait image attachment in the message bubble",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.imageAttachments(
                count: 1,
                originalWidth: 1200,
                originalHeight: 1600
            )
        )

        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: imageMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageViewAttachmentBubble_defaultSingleImageWithoutCaption_snapshot() {
        // Given
        let attachment = AttachmentBubbleSnapshotAttachment.image
        let size = attachmentBubbleSnapshotSize(for: attachment, caption: nil)

        // When
        let view = attachmentBubbleMessageView(
            factory: DefaultViewFactory.shared,
            attachment: attachment,
            caption: nil
        )

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_messageViewAttachmentBubble_defaultSingleVideoWithCaption_snapshot() {
        // Given
        let attachment = AttachmentBubbleSnapshotAttachment.video
        let caption = "Video caption"
        let size = attachmentBubbleSnapshotSize(for: attachment, caption: caption)

        // When
        let view = attachmentBubbleMessageView(
            factory: DefaultViewFactory.shared,
            attachment: attachment,
            caption: caption
        )

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_messageViewAttachmentBubble_customSingleImageWithoutCaption_snapshot() {
        // Given
        let attachment = AttachmentBubbleSnapshotAttachment.image
        let size = attachmentBubbleSnapshotSize(for: attachment, caption: nil)

        // When
        let view = attachmentBubbleMessageView(
            factory: CustomAttachmentBubbleFactory(),
            attachment: attachment,
            caption: nil
        )

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_messageViewAttachmentBubble_customSingleVideoWithoutCaption_snapshot() {
        // Given
        let attachment = AttachmentBubbleSnapshotAttachment.video
        let size = attachmentBubbleSnapshotSize(for: attachment, caption: nil)

        // When
        let view = attachmentBubbleMessageView(
            factory: CustomAttachmentBubbleFactory(),
            attachment: attachment,
            caption: nil
        )

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_messageViewAttachmentBubble_customSingleVoiceWithoutCaption_snapshot() {
        // Given
        let attachment = AttachmentBubbleSnapshotAttachment.voice
        let size = attachmentBubbleSnapshotSize(for: attachment, caption: nil)

        // When
        let view = attachmentBubbleMessageView(
            factory: CustomAttachmentBubbleFactory(),
            attachment: attachment,
            caption: nil
        )

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_messageViewAttachmentBubble_customSingleFileWithoutCaption_snapshot() {
        // Given
        let attachment = AttachmentBubbleSnapshotAttachment.file
        let size = attachmentBubbleSnapshotSize(for: attachment, caption: nil)

        // When
        let view = attachmentBubbleMessageView(
            factory: CustomAttachmentBubbleFactory(),
            attachment: attachment,
            caption: nil
        )

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_messageViewAttachmentBubble_customSingleImageWithCaption_snapshot() {
        // Given
        let attachment = AttachmentBubbleSnapshotAttachment.image
        let caption = "Image caption"
        let size = attachmentBubbleSnapshotSize(for: attachment, caption: caption)

        // When
        let view = attachmentBubbleMessageView(
            factory: CustomAttachmentBubbleFactory(),
            attachment: attachment,
            caption: caption
        )

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_messageViewAttachmentBubble_customSingleVideoWithCaption_snapshot() {
        // Given
        let attachment = AttachmentBubbleSnapshotAttachment.video
        let caption = "Video caption"
        let size = attachmentBubbleSnapshotSize(for: attachment, caption: caption)

        // When
        let view = attachmentBubbleMessageView(
            factory: CustomAttachmentBubbleFactory(),
            attachment: attachment,
            caption: caption
        )

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_messageViewAttachmentBubble_customSingleVoiceWithCaption_snapshot() {
        // Given
        let attachment = AttachmentBubbleSnapshotAttachment.voice
        let caption = "Voice caption"
        let size = attachmentBubbleSnapshotSize(for: attachment, caption: caption)

        // When
        let view = attachmentBubbleMessageView(
            factory: CustomAttachmentBubbleFactory(),
            attachment: attachment,
            caption: caption
        )

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_messageViewAttachmentBubble_customSingleFileWithCaption_snapshot() {
        // Given
        let attachment = AttachmentBubbleSnapshotAttachment.file
        let caption = "File caption"
        let size = attachmentBubbleSnapshotSize(for: attachment, caption: caption)

        // When
        let view = attachmentBubbleMessageView(
            factory: CustomAttachmentBubbleFactory(),
            attachment: attachment,
            caption: caption
        )

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_messageViewAttachmentBubble_customLinkPreview_snapshot() {
        // Given
        let attachment = AttachmentBubbleSnapshotAttachment.link
        let size = attachmentBubbleSnapshotSize(for: attachment, caption: nil)

        // When
        let view = attachmentBubbleMessageView(
            factory: CustomAttachmentBubbleFactory(),
            attachment: attachment,
            caption: nil
        )

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_messageViewAttachmentBubble_customMultiImageWithoutCaption_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: Self.currentUserId, name: "Martin"),
            attachments: ChatChannelTestHelpers.imageAttachments(
                count: 2,
                originalWidth: 1600,
                originalHeight: 1200
            ),
            isSentByCurrentUser: true
        )
        let size = CGSize(width: defaultScreenSize.width, height: 300)

        // When
        let view = MessageView(
            factory: CustomAttachmentBubbleFactory(),
            message: message,
            contentWidth: size.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applySize(size)

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_messageViewImage_snapshot2Images() {
        // Given
        let imageMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test message",
            author: .mock(id: .unique),
            attachments: [
                ChatChannelTestHelpers.imageAttachments[0],
                ChatChannelTestHelpers.imageAttachments[0]
            ]
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: imageMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageViewImage_snapshot3Images() {
        // Given
        let imageMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test message",
            author: .mock(id: .unique),
            attachments: [
                ChatChannelTestHelpers.imageAttachments[0],
                ChatChannelTestHelpers.imageAttachments[0],
                ChatChannelTestHelpers.imageAttachments[0]
            ]
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: imageMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageViewImage_snapshot3ImagesAndVideo() {
        // Given
        let imageMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test message",
            author: .mock(id: .unique),
            attachments: [
                ChatChannelTestHelpers.imageAttachments[0],
                ChatChannelTestHelpers.imageAttachments[0],
                ChatChannelTestHelpers.imageAttachments[0],
                ChatChannelTestHelpers.videoAttachments[0]
            ]
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: imageMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageViewImage_snapshotQuoted() {
        // Given
        let quoted = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "This is a quoted message",
            author: .mock(id: .unique, name: "John Wick")
        )
        let imageMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test message",
            author: .mock(id: .unique),
            quotedMessage: quoted,
            attachments: ChatChannelTestHelpers.imageAttachments
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: imageMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageViewQuoted_singleImageAttachment_snapshot() {
        // Given
        let quoted = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "This is a quoted message",
            author: .mock(id: .unique, name: "John Wick")
        )
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test message",
            author: .mock(id: .unique),
            quotedMessage: quoted,
            attachments: [ChatChannelTestHelpers.imageAttachments[0]]
        )

        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: message,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }

    func test_messageViewQuoted_singleFileAttachment_snapshot() {
        // Given
        let quoted = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "This is a quoted message",
            author: .mock(id: .unique, name: "John Wick")
        )
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test message",
            author: .mock(id: .unique),
            quotedMessage: quoted,
            attachments: [ChatChannelTestHelpers.fileAttachments[0]]
        )

        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: message,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }
    
    func test_messageViewGiphy_snapshot() {
        // Given
        let giphyMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.giphyAttachments
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: giphyMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageViewPendingGiphy_snapshot() {
        // Given
        let giphyAttachments: [AnyChatMessageAttachment] = [
            ChatMessageGiphyAttachment(
                id: .unique,
                type: .giphy,
                payload: GiphyAttachmentPayload(
                    title: "test",
                    previewURL: URL.localYodaImage,
                    actions: [
                        .init(
                            name: "Send",
                            value: "Send",
                            style: .primary,
                            type: .button,
                            text: "Send"
                        ),
                        .init(
                            name: "Shuffle",
                            value: "Shuffle",
                            style: .default,
                            type: .button,
                            text: "Shuffle"
                        ),
                        .init(
                            name: "Cancel",
                            value: "Cancel",
                            style: .default,
                            type: .button,
                            text: "Cancel"
                        )
                    ]
                ),
                downloadingState: nil,
                uploadingState: nil
            )
            .asAnyAttachment
        ]
        let giphyMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            attachments: giphyAttachments
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: giphyMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()
        
        // Then
        AssertSnapshot(view)
    }

    func test_messageViewVideo_snapshot() {
        // Given
        let videoMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.videoAttachments
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: videoMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageViewFile_snapshot() {
        // Given
        let fileMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.fileAttachments
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: fileMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageViewVoiceRecordingFromParticipant_snapshot() {
        // Given
        let voiceMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.voiceRecordingAttachments,
            isSentByCurrentUser: false
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: voiceMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .frame(width: defaultScreenSize.width, height: 130)
        .padding()
        
        // Then
        AssertSnapshot(
            view,
            size: CGSize(width: defaultScreenSize.width, height: 130)
        )
    }
    
    func test_messageViewVoiceRecordingFromMe_snapshot() {
        // Given
        let voiceMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.voiceRecordingAttachments,
            isSentByCurrentUser: true
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: voiceMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .frame(width: defaultScreenSize.width, height: 130)
        .padding()
        
        // Then
        AssertSnapshot(
            view,
            size: CGSize(width: defaultScreenSize.width, height: 130)
        )
    }
    
    func test_messageViewVoiceRecordingWithTextFromParticipant_snapshot() {
        // Given
        let voiceMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.voiceRecordingAttachments,
            isSentByCurrentUser: false
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: voiceMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .frame(width: defaultScreenSize.width, height: 130)
        .padding()
        
        // Then
        AssertSnapshot(
            view,
            size: CGSize(width: defaultScreenSize.width, height: 130)
        )
    }
    
    func test_messageViewVoiceRecordingWithTextFromMe_snapshot() {
        // Given
        let voiceMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.voiceRecordingAttachments,
            isSentByCurrentUser: true
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: voiceMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .frame(width: defaultScreenSize.width, height: 130)
        .padding()
        
        // Then
        AssertSnapshot(
            view,
            size: CGSize(width: defaultScreenSize.width, height: 130)
        )
    }
    
    func test_messageViewVoiceRecordingWithTextFromParticipantMultiple_snapshot() {
        // Given
        let voiceMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.voiceRecordingAttachments(count: 2),
            isSentByCurrentUser: false
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: voiceMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .frame(width: defaultScreenSize.width, height: 250)
        .padding()
        
        // Then
        AssertSnapshot(
            view,
            size: CGSize(width: defaultScreenSize.width, height: 250)
        )
    }
    
    func test_messageViewVoiceRecordingWithTextFromMeMultiple_snapshot() {
        // Given
        let voiceMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.voiceRecordingAttachments(count: 2),
            isSentByCurrentUser: true
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: voiceMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .frame(width: defaultScreenSize.width, height: 250)
        .padding()
        
        // Then
        AssertSnapshot(
            view,
            size: CGSize(width: defaultScreenSize.width, height: 250)
        )
    }
    
    func test_messageViewVoiceRecordingFromMeTheming_snapshot() {
        // Given
        let voiceMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.voiceRecordingAttachments(count: 2),
            isSentByCurrentUser: true
        )
        
        // When
        adjustAppearance { appearance in
            appearance.colorPalette.chatBackgroundOutgoing = .orange
            appearance.colorPalette.backgroundCoreSurfaceStrong = .yellow
            appearance.colorPalette.chatTextOutgoing = .blue
            appearance.colorPalette.textTertiary = .red
            appearance.images.playFill = UIImage(systemName: "star")!
            appearance.images.fileIcons[.aac] = UIImage(systemName: "scribble")!
        }
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: voiceMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .frame(width: defaultScreenSize.width, height: 250)
        .padding()
        
        // Then
        AssertSnapshot(
            view,
            variants: [.defaultLight],
            size: CGSize(width: defaultScreenSize.width, height: 250)
        )
    }

    func test_messageViewVoiceRecordingQuotedFromParticipant_snapshot() {
        // Given
        let quoted = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "This is a quoted message",
            author: .mock(id: .unique, name: "John Wick")
        )
        let voiceMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            quotedMessage: quoted,
            attachments: ChatChannelTestHelpers.voiceRecordingAttachments,
            isSentByCurrentUser: false
        )

        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: voiceMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .frame(width: defaultScreenSize.width, height: 200)
        .padding()

        // Then
        AssertSnapshot(
            view,
            size: CGSize(width: defaultScreenSize.width, height: 200)
        )
    }

    func test_messageViewVoiceRecordingQuotedFromMe_snapshot() {
        // Given
        let quoted = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "This is a quoted message",
            author: .mock(id: .unique, name: "John Wick")
        )
        let voiceMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            quotedMessage: quoted,
            attachments: ChatChannelTestHelpers.voiceRecordingAttachments,
            isSentByCurrentUser: true
        )

        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: voiceMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .frame(width: defaultScreenSize.width, height: 200)
        .padding()

        // Then
        AssertSnapshot(
            view,
            size: CGSize(width: defaultScreenSize.width, height: 200)
        )
    }

    func test_messageViewVoiceRecordingQuotedWithTextFromParticipant_snapshot() {
        // Given
        let quoted = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "This is a quoted message",
            author: .mock(id: .unique, name: "John Wick")
        )
        let voiceMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Check this voice note",
            author: .mock(id: .unique),
            quotedMessage: quoted,
            attachments: ChatChannelTestHelpers.voiceRecordingAttachments,
            isSentByCurrentUser: false
        )

        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: voiceMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .frame(width: defaultScreenSize.width, height: 220)
        .padding()

        // Then
        AssertSnapshot(
            view,
            size: CGSize(width: defaultScreenSize.width, height: 220)
        )
    }

    func test_messageViewVoiceRecordingQuotedWithTextFromMe_snapshot() {
        // Given
        let quoted = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "This is a quoted message",
            author: .mock(id: .unique, name: "John Wick")
        )
        let voiceMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Check this voice note",
            author: .mock(id: .unique),
            quotedMessage: quoted,
            attachments: ChatChannelTestHelpers.voiceRecordingAttachments,
            isSentByCurrentUser: true
        )

        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: voiceMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .frame(width: defaultScreenSize.width, height: 220)
        .padding()

        // Then
        AssertSnapshot(
            view,
            size: CGSize(width: defaultScreenSize.width, height: 220)
        )
    }

    func test_voiceRecordingViewPlaying_snapshot() {
        // Given
        let url = URL(string: "https://example.com/recording.m4a")!
        let recording = AddedVoiceRecording(
            url: url,
            duration: 10,
            waveform: [0, 0.1, 0.4, 0.7, 1.0, 0.8, 0.5, 0.3, 0.6, 0.9]
        )
        let handler = VoiceRecordingHandler()
        handler.isPlaying = true
        handler.context = AudioPlaybackContext(
            assetLocation: url,
            duration: 10,
            currentTime: 4.2,
            state: .playing,
            rate: .normal,
            isSeeking: false
        )

        // When
        let view = VoiceRecordingView(
            handler: handler,
            addedVoiceRecording: recording,
            isSentByCurrentUser: true
        )
        .frame(width: defaultScreenSize.width - 60, height: 48)
        .padding()

        // Then
        AssertSnapshot(
            view,
            variants: [.defaultLight],
            size: CGSize(width: defaultScreenSize.width, height: 80)
        )
    }

    func test_messageViewFileText_snapshot() {
        // Given
        let fileMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Test message",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.fileAttachments
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: fileMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageViewJumboEmoji_snapshot() {
        // Given
        let emojiMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "😀",
            author: .mock(id: .unique)
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: emojiMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_linkAttachmentView_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "https://getstream.io",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.linkAttachments
        )

        // When
        let view = MessageAttachmentsView(
            factory: DefaultViewFactory.shared,
            message: message,
            width: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_linkAttachmentView_customColors_snapshot() {
        // Given
        let colorPalette = Appearance.ColorPalette()
        colorPalette.textPrimary = .blue
        colorPalette.chatTextIncoming = .orange
        colorPalette.backgroundCoreElevation1 = .cyan
        var appearance = Appearance()
        appearance.colorPalette = colorPalette
        streamChat = StreamChat(
            chatClient: chatClient,
            appearance: appearance
        )
        
        // When
        let view = LinkAttachmentView(
            linkAttachment: .mock(
                id: .unique,
                originalURL: URL(string: "https://getstream.io")!,
                title: "Stream",
                text: "Some link text description",
                author: "Nuno Vieira",
                titleLink: nil,
                assetURL: nil,
                previewURL: .localYodaImage
            ),
            width: 200,
            isFirst: true,
            isRightAligned: false
        )
        .frame(width: 200, height: 140)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_linkAttachmentView_shouldNotRenderLinkPreviewWithOtherAttachments() {
        // Given
        let messageWithLinkAndImages = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "https://getstream.io",
            author: .mock(id: .unique),
            attachments: [
                ChatChannelTestHelpers.imageAttachments[0],
                ChatChannelTestHelpers.videoAttachments[0]
            ]
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: messageWithLinkAndImages,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_deletedMessageView_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Deleted message",
            author: .mock(id: .unique)
        )
        
        // When
        let view = DeletedMessageView(message: message, isFirst: true)
            .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_deletedMessageViewContainer_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Deleted message",
            author: .mock(id: .unique)
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: message,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageRepliesView_snapshot() {
        // Given
        let channel = ChatChannel.mockDMChannel()
        let message = ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Message with replies",
            author: .mock(id: .unique),
            threadParticipants: [.mock(id: .unique)]
        )
        
        // When
        let view = MessageRepliesView(
            factory: DefaultViewFactory.shared,
            channel: channel,
            message: message,
            replyCount: 3
        )
        .frame(width: 300, height: 60)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageRepliesViewShownInChannel_snapshot() {
        // Given
        let channel = ChatChannel.mockDMChannel()
        let message = ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Message with replies",
            author: .mock(id: .unique),
            threadParticipants: [.mock(id: .unique)]
        )
        
        // When
        let view = MessageRepliesView(
            factory: DefaultViewFactory.shared,
            channel: channel,
            message: message,
            replyCount: 3,
            showReplyCount: false
        )
        .frame(width: 300, height: 60)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_topLeftView_snapshot() {
        // Given
        let textView = Text("Test")
        
        // Then
        let view = TopLeftView {
            textView
        }
        .applyDefaultSize()
        
        // When
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_linkDetection_markdownPlainAndMention() {
        let mentions = [
            ChatUser.mock(id: "user_id_1", name: nil),
            ChatUser.mock(id: "user_id_2", name: "Name_2")
        ]
        let size = messageViewSize(height: 200)
        let view = messageView(
            size: size,
            mentions: Set(mentions),
            """
            This is [markdown link](https://getstream.io)  
            This is plain link: https://getstream.io  
            This is mention 1: @user_id_1  
            This is mention 2: @Name_2
            """
        )
        AssertSnapshot(view, size: size)
    }
    
    func test_text_withMultiline() {
        let size = messageViewSize(height: 100)
        let view = messageView(
            size: size,
            """
            This is regular text
            This is the second line
            """
        )
        AssertSnapshot(view, size: size)
    }
    
    func test_markdown_disabledWithRegularText() {
        // Given
        let config = MessageListConfig(markdownSupportEnabled: false)
        let utils = Utils(messageListConfig: config)
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        
        let textMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "This is a **bold** text",
            author: .mock(id: .unique)
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: textMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .frame(
            width: defaultScreenSize.width,
            height: 100
        )
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_markdownAndLinkSupport_disabled() {
        // Given
        let config = MessageListConfig(
            localLinkDetectionEnabled: false,
            markdownSupportEnabled: false
        )
        let utils = Utils(messageListConfig: config)
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        
        let textMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Visit Apple, click [here](https://apple.com)",
            author: .mock(id: .unique)
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: textMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .frame(
            width: defaultScreenSize.width,
            height: 100
        )
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_markdown_linkSupportDisabled() {
        // Given
        let config = MessageListConfig(
            localLinkDetectionEnabled: false
        )
        let utils = Utils(messageListConfig: config)
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        
        let textMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "~~A strikethrough example~~",
            author: .mock(id: .unique)
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: textMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .frame(
            width: defaultScreenSize.width,
            height: 100
        )
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_markdown_text() {
        let size = messageViewSize(height: 300)
        let view = messageView(
            size: size,
            """
            This is **bold** text  
            This text is _italicized_  
            This was ~~mistaken~~ text  
            This has backslashes for a newline\\
            This has html line break<br/>Will span two lines  
            ***All this text is important***  
            """
        )
        AssertSnapshot(view, size: size)
    }
    
    func test_markdown_headers() {
        let size = messageViewSize(height: 375)
        let view = messageView(
            size: size,
            """
            # A first level heading
            ## A _second_ level heading
            ### A `third` level heading
            #### A ~fourth~ level heading
            ##### A fifth level heading
            ###### A sixth level heading
            """
        )
        AssertSnapshot(view, size: size)
    }
    
    func test_markdown_unorderedLists() {
        let size = messageViewSize(height: 550)
        let view = messageView(
            size: size,
            """
            Unordered (no nesting)
            
            Fruits:
            - **Oranges** (bold)
            - Apples
            
            Trees:
            * Birch
            * Maple
            
            Animals:
            + Cat
            + _Dog_ (italic)
            + Rabbit
            """
        )
        AssertSnapshot(view, size: size)
    }
    
    func test_markdown_unorderedLists_nested() {
        let size = messageViewSize(height: 200)
        let view = messageView(
            size: size,
            """
            Unordered (nested)
            - First list item
                - First nested
                    - Second nested
            """
        )
        AssertSnapshot(view, size: size)
    }
    
    func test_markdown_orderedList_nested_wrappedTextItem() {
        // Note: alignment after wrapping is not supported (requires paragraph style support)
        let size = messageViewSize(height: 400)
        let view = messageView(
            size: size,
            """
            Unordered (wrapped text)
            - First list item which has a very long text and when wrapped, should be aligned to the same item
                - First nested which has a very long text and when wrapped, should be aligned to the same item
                    - Second nested
            """
        )
        AssertSnapshot(view, size: size)
    }
    
    func test_markdown_orderedLists() {
        let size = messageViewSize(height: 400)
        let view = messageView(
            size: size,
            """
            Ordered (no nesting)
            
            Fruits:
            1. **Oranges** (bold)
            1. Apples
            
            Animals:
            1. Cat
            2. _Dog_ (italic)
            3. Rabbit
            """
        )
        AssertSnapshot(view, size: size)
    }
    
    func test_markdown_orderedLists_nested() {
        let size = messageViewSize(height: 200)
        let view = messageView(
            size: size,
            """
            Unordered (nested)
            1. First list item
                1. First nested
                    1. Second nested
                    2. Second nested (2)
            """
        )
        AssertSnapshot(view, size: size)
    }
    
    func test_markdown_mixedLists_nested() {
        let size = messageViewSize(height: 200)
        let view = messageView(
            size: size,
            """
            Mixed (nested)
            1. First list item
                - First nested
                    1. Second nested
                    2. Second nested (2)
            """
        )
        AssertSnapshot(view, size: size)
    }
    
    func test_markdown_links() {
        let size = messageViewSize()
        let view = messageView(
            size: size,
            """
            Visit Apple, click [here](https://apple.com)
            """
        )
        AssertSnapshot(view, size: size)
    }
    
    func test_markdown_links_customColor() {
        let displayOptions = MessageDisplayOptions { _ in
            [
                NSAttributedString.Key.foregroundColor: UIColor.red
            ]
        }
        let config = MessageListConfig(
            messageDisplayOptions: displayOptions,
            markdownSupportEnabled: true
        )
        let size = messageViewSize()
        let view = messageView(
            size: size,
            config: config,
            """
            Visit Apple, click [here](https://apple.com)
            """
        )
        AssertSnapshot(view, size: size)
    }
    
    func test_markdown_links_markdownDisabled() {
        let config = MessageListConfig(markdownSupportEnabled: false)
        let size = messageViewSize()
        let view = messageView(
            size: size,
            config: config,
            """
            Visit Apple, click [here](https://apple.com)
            """
        )
        AssertSnapshot(view, size: size)
    }
    
    func test_markdown_links_inLists() {
        let size = messageViewSize(height: 200)
        let view = messageView(
            size: size,
            """
            This site is cool: [Stream](https://getstream.io/)
            - *Hey*
                - This [link](https://getstream.io/) is in a list
            """
        )
        AssertSnapshot(view, size: size)
    }
    
    func test_markdown_code() {
        let size = messageViewSize(height: 550)
        let view = messageView(
            size: size,
            """
            This is inline code: `git init`
            
            ### `Inline` in header
            
            Git commands:
            ```
            git status
            git add
            git commit
            ```
            
            Swift:
            ```swift
            func formatted() -> AttributedString {
                // TODO: Implement markdown formatting
            }
            ```
            """
        )
        AssertSnapshot(view, size: size)
    }
    
    func test_code_inlineOnMultipleLines() {
        let size = messageViewSize(height: 250)
        let view = messageView(
            size: size,
            """
            `inline code`
            
            `inline code which
            should render on a single line`
            """
        )
        AssertSnapshot(view, size: size)
    }
    
    func test_markdown_quote() {
        let size = messageViewSize(height: 150)
        let view = messageView(
            size: size,
            """
            Text that is not a quote
            > Text that is a quote
            """
        )
        AssertSnapshot(view, size: size)
    }
    
    func test_markdown_quote_multipleLines() {
        let size = messageViewSize(height: 150)
        let view = messageView(
            size: size,
            """
            Text that is not a quote
            > Quote
            > should
            > render
            > on
            > a
            > single
            > line
            """
        )
        AssertSnapshot(view, size: size)
    }
    
    func test_markdown_quote_separate() {
        let size = messageViewSize(height: 250)
        let view = messageView(
            size: size,
            """
            Text that is not a quote
            > Text that is a quote
            
            > This is a second quote
            
            Another text that is not a quote
            """
        )
        AssertSnapshot(view, size: size)
    }
    
    func test_markdown_thematicBreak() {
        let size = messageViewSize(height: 150)
        let view = messageView(
            size: size,
            """
            ---
            hi!
            """
        )
        AssertSnapshot(view, size: size)
    }
    
    // MARK: -
    
    private func messageViewSize(height: CGFloat = 100.0) -> CGSize {
        CGSize(width: defaultScreenSize.width, height: height)
    }
    
    private func messageView(
        size: CGSize,
        config: MessageListConfig? = nil,
        mentions: Set<ChatUser> = Set(),
        _ text: String
    ) -> some View {
        if let config {
            let utils = Utils(messageListConfig: config)
            streamChat = StreamChat(chatClient: chatClient, utils: utils)
        }
        let textMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: text,
            author: .mock(id: .unique),
            mentionedUsers: mentions
        )
        return MessageView(
            factory: DefaultViewFactory.shared,
            message: textMessage,
            contentWidth: size.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applySize(size)
    }

    private func attachmentBubbleMessageView<Factory: ViewFactory>(
        factory: Factory,
        attachment: AttachmentBubbleSnapshotAttachment,
        caption: String?
    ) -> some View {
        let size = attachmentBubbleSnapshotSize(for: attachment, caption: caption)
        return MessageView(
            factory: factory,
            message: attachmentBubbleMessage(attachment: attachment, caption: caption),
            contentWidth: size.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applySize(size)
    }

    private func attachmentBubbleMessage(
        attachment: AttachmentBubbleSnapshotAttachment,
        caption: String?
    ) -> ChatMessage {
        return ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: caption ?? "",
            author: .mock(id: Self.currentUserId, name: "Martin"),
            attachments: attachment.attachments,
            isSentByCurrentUser: true
        )
    }

    private func attachmentBubbleSnapshotSize(
        for attachment: AttachmentBubbleSnapshotAttachment,
        caption: String?
    ) -> CGSize {
        let hasCaption = caption?.isEmpty == false
        switch attachment {
        case .image, .video:
            return CGSize(width: defaultScreenSize.width, height: hasCaption ? 320 : 300)
        case .link:
            return CGSize(width: defaultScreenSize.width, height: 300)
        case .file, .voice:
            return CGSize(width: defaultScreenSize.width, height: hasCaption ? 220 : 180)
        }
    }
}

private enum AttachmentBubbleSnapshotAttachment {
    case image
    case video
    case voice
    case file
    case link

    var attachments: [AnyChatMessageAttachment] {
        switch self {
        case .image:
            return ChatChannelTestHelpers.imageAttachments(
                count: 1,
                originalWidth: 1600,
                originalHeight: 1200
            )
        case .video:
            return ChatChannelTestHelpers.videoAttachments
        case .voice:
            return ChatChannelTestHelpers.voiceRecordingAttachments
        case .file:
            return ChatChannelTestHelpers.fileAttachments
        case .link:
            return ChatChannelTestHelpers.linkAttachments
        }
    }
}

private final class CustomAttachmentBubbleFactory: ViewFactory {
    @Injected(\.chatClient) var chatClient
    
    var styles: CustomAttachmentBubbleStyles
    
    init(
        stackedBubbleInsets: EdgeInsets = EdgeInsets(top: 8, leading: 12, bottom: 10, trailing: 14),
        stackedBubbleCornerRadius: CGFloat = 6,
        attachmentBubbleInsets: EdgeInsets = EdgeInsets(top: 3, leading: 5, bottom: 7, trailing: 9),
        attachmentBubbleCornerRadius: CGFloat = 4
    ) {
        self.styles = CustomAttachmentBubbleStyles(
            stackedBubbleInsets: stackedBubbleInsets,
            stackedBubbleCornerRadius: stackedBubbleCornerRadius,
            attachmentBubbleInsets: attachmentBubbleInsets,
            attachmentBubbleCornerRadius: attachmentBubbleCornerRadius
        )
    }
}

private final class CustomAttachmentBubbleStyles: DefaultTestStyles {
    let stackedBubbleInsets: EdgeInsets
    let stackedBubbleCornerRadius: CGFloat
    let attachmentBubbleInsets: EdgeInsets
    let attachmentBubbleCornerRadius: CGFloat

    init(
        stackedBubbleInsets: EdgeInsets,
        stackedBubbleCornerRadius: CGFloat,
        attachmentBubbleInsets: EdgeInsets,
        attachmentBubbleCornerRadius: CGFloat
    ) {
        self.stackedBubbleInsets = stackedBubbleInsets
        self.stackedBubbleCornerRadius = stackedBubbleCornerRadius
        self.attachmentBubbleInsets = attachmentBubbleInsets
        self.attachmentBubbleCornerRadius = attachmentBubbleCornerRadius
    }

    func makeMessageStackedAttachmentsBubbleModifier(
        options: MessageStackedAttachmentsBubbleModifierOptions
    ) -> some ViewModifier {
        CustomStackedAttachmentsBubbleModifier(
            options: options,
            bubbleInsets: stackedBubbleInsets,
            cornerRadius: stackedBubbleCornerRadius
        )
    }

    func makeMessageAttachmentBubbleModifier(
        options: MessageAttachmentBubbleModifierOptions
    ) -> some ViewModifier {
        CustomMessageAttachmentBubbleModifier(
            options: options,
            bubbleInsets: attachmentBubbleInsets,
            cornerRadius: attachmentBubbleCornerRadius
        )
    }
}

private struct CustomStackedAttachmentsBubbleModifier: ViewModifier {
    let options: MessageStackedAttachmentsBubbleModifierOptions
    let bubbleInsets: EdgeInsets
    let cornerRadius: CGFloat?

    func body(content: Content) -> some View {
        content
            .padding(bubbleInsets)
            .modifier(
                MessageBubbleModifier(
                    message: options.message,
                    isFirst: options.isFirst,
                    cornerRadius: cornerRadius
                )
            )
    }
}

private struct CustomMessageAttachmentBubbleModifier: ViewModifier {
    @Injected(\.colors) private var colors

    let options: MessageAttachmentBubbleModifierOptions
    let bubbleInsets: EdgeInsets
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content.modifier(
            AttachmentContainerModifier(
                bubbleInsets: bubbleInsets,
                backgroundColor: Color(colors.backgroundCoreSurfaceDefault),
                borderColor: borderColor,
                borderWidth: borderWidth,
                cornerRadius: cornerRadius,
                corners: .allCorners
            )
        )
    }

    private var borderColor: Color {
        switch options.attachmentType {
        case .file:
            return .red
        case .voiceRecording:
            return .green
        case .linkPreview:
            return .purple
        case .image:
            return .blue
        case .video:
            return .orange
        default:
            return Color(colors.accentPrimary)
        }
    }

    private var borderWidth: CGFloat {
        switch options.attachmentType {
        case .linkPreview:
            return 3
        default:
            return 2
        }
    }
}
