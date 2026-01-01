//
// Copyright © 2026 Stream.io Inc. All rights reserved.
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
        adjustAppearance { appearance in
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

    func test_linkAttachmentView_customColors_snapshot() {
        // Given
        var colorPalette = ColorPalette()
        colorPalette.messageLinkAttachmentAuthorColor = .orange
        colorPalette.messageLinkAttachmentTitleColor = .blue
        colorPalette.messageLinkAttachmentTextColor = .red
        streamChat = StreamChat(
            chatClient: chatClient,
            appearance: .init(colors: colorPalette)
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
            isFirst: true
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
        let config = MessageListConfig(messageDisplayOptions: displayOptions)
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
}
