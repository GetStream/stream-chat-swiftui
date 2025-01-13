//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class MessageView_Tests: StreamChatTestCase {

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
            author: .mock(id: .unique)
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
        adjustAppearance() { appearance in
            appearance.colors.messageCurrentUserBackground = [.orange]
            appearance.colors.background8 = .yellow
            appearance.colors.voiceMessageControlBackground = .cyan
            appearance.colors.messageCurrentUserTextColor = .blue
            appearance.colors.textLowEmphasis = .red
            appearance.images.playFilled = UIImage(systemName: "star")!
            appearance.images.fileAac = UIImage(systemName: "scribble")!
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
            author: .mock(id: .unique)
        )

        // When
        let view = LinkAttachmentContainer(
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
            author: .mock(id: .unique)
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
            author: .mock(id: .unique)
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
    
    func test_markdown_noLinks() {
        // Given
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
    
    func test_markdown_withLinks() {
        // Given
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
    
    func test_markdown_withLinksDifferentTint() {
        // Given
        let displayOptions = MessageDisplayOptions { _ in
            [
                NSAttributedString.Key.foregroundColor: UIColor.red
            ]
        }
        let config = MessageListConfig(messageDisplayOptions: displayOptions)
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
    
    func test_markdown_disabledWithLinks() {
        // Given
        let config = MessageListConfig(markdownSupportEnabled: false)
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
}
