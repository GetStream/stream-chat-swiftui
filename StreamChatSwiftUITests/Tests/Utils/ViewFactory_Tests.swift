//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

@MainActor class ViewFactory_Tests: StreamChatTestCase {
    private let message = ChatMessage.mock(
        id: .unique,
        cid: .unique,
        text: "test",
        author: .mock(id: .unique)
    )

    func test_viewFactory_makeEmptyChannelsView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeEmptyChannelsView(options: EmptyChannelsViewOptions())

        // Then
        XCTAssert(view is EmptyChannelsView)
    }

    func test_viewFactory_makeLoadingView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeLoadingView(options: LoadingViewOptions())

        // Then
        XCTAssertNotNil(view)
    }

    func test_viewFactory_makeChannelListHeaderViewModifier() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let viewModifier = viewFactory.makeChannelListHeaderViewModifier(options: ChannelListHeaderViewModifierOptions(title: "Test"))

        // Then
        XCTAssert(viewModifier is DefaultChannelListHeaderModifier)
    }

    func test_viewFactory_makeMoreChannelActionsView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        let channel: ChatChannel = .mockDMChannel()

        // When
        let view = viewFactory.makeMoreChannelActionsView(
            options: MoreChannelActionsViewOptions(
                channel: channel,
                swipedChannelId: .constant(nil),
                onDismiss: {},
                onError: { _ in }
            )
        )

        // Then
        XCTAssert(view is ModifiedContent<MoreChannelActionsView<DefaultViewFactory>, PresentationDetentsModifier>)
    }
    
    func test_viewFactory_makeSearchResultsView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeSearchResultsView(
            options: SearchResultsViewOptions(
                selectedChannel: .constant(nil),
                searchResults: [],
                loadingSearchResults: false,
                channelNaming: { _ in "Test" },
                onSearchResultTap: { _ in },
                onItemAppear: { _ in }
            )
        )
        
        // Then
        XCTAssert(view is SearchResultsView<DefaultViewFactory>)
    }

    func test_viewFactory_makeUserAvatarView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        let user = ChatUser.mock(id: .unique)

        // When
        let view = viewFactory.makeUserAvatarView(options: UserAvatarViewOptions(user: user, size: AvatarSize.medium, showsIndicator: true))

        // Then
        XCTAssert(view is UserAvatar)
    }

    func test_viewFactory_makeChannelHeaderViewModifier() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeChannelHeaderViewModifier(options: ChannelHeaderViewModifierOptions(channel: .mockDMChannel(), shouldShowTypingIndicator: false))

        // Then
        XCTAssert(view is DefaultChannelHeaderModifier<DefaultViewFactory>)
    }

    func test_viewFactory_makeMessageTextView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeMessageTextView(
            options: MessageTextViewOptions(
                message: message,
                formattedText: MessageFormattedText(message.text),
                isFirst: true,
                availableWidth: 300,
                scrolledId: .constant(nil)
            )
        )

        // Then
        XCTAssert(view is MessageTextView<DefaultViewFactory>)
    }

    func test_viewFactory_makeMessageAttachmentsView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeMessageAttachmentsView(
            options: MessageAttachmentsViewOptions(
                message: message,
                formattedText: MessageFormattedText(message.text),
                isFirst: true,
                availableWidth: 300,
                scrolledId: .constant(nil)
            )
        )

        // Then
        XCTAssert(view is MessageAttachmentsView<DefaultViewFactory>)
    }

    func test_viewFactory_makeImageAttachmentView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeImageAttachmentView(
            options: ImageAttachmentViewOptions(
                message: message,
                isFirst: true,
                availableWidth: 300,
                scrolledId: .constant(nil)
            )
        )

        // Then
        XCTAssert(view is MessageMediaAttachmentsContainerView<DefaultViewFactory>)
    }

    func test_viewFactory_makeVideoAttachmentView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeVideoAttachmentView(
            options: VideoAttachmentViewOptions(
                message: message,
                isFirst: true,
                availableWidth: 300,
                scrolledId: .constant(nil)
            )
        )

        // Then
        XCTAssert(view is MessageMediaAttachmentsContainerView<DefaultViewFactory>)
    }

    func test_viewFactory_makeGiphyAttachmentView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeGiphyAttachmentView(
            options: GiphyAttachmentViewOptions(
                message: message,
                isFirst: true,
                availableWidth: 300,
                scrolledId: .constant(nil)
            )
        )

        // Then
        XCTAssert(view is GiphyAttachmentView<DefaultViewFactory>)
    }

    func test_viewFactory_makeLinkAttachmentView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeLinkAttachmentView(
            options: LinkAttachmentViewOptions(
                message: message,
                isFirst: true,
                availableWidth: 300,
                scrolledId: .constant(nil)
            )
        )

        // Then
        XCTAssert(view is LinkAttachmentContainer<DefaultViewFactory>)
    }

    func test_viewFactory_makeFileAttachmentView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeFileAttachmentView(
            options: FileAttachmentViewOptions(
                message: message,
                isFirst: true,
                availableWidth: 300,
                scrolledId: .constant(nil)
            )
        )

        // Then
        XCTAssert(view is FileAttachmentsContainer<DefaultViewFactory>)
    }

    func test_viewFactory_makeDeletedMessageView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeDeletedMessageView(
            options: DeletedMessageViewOptions(
                message: message,
                isFirst: true,
                availableWidth: 300
            )
        )

        // Then
        XCTAssert(view is DeletedMessageView)
    }

    func test_viewFactory_makeCustomAttachmentViewType() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeCustomAttachmentViewType(
            options: CustomAttachmentViewTypeOptions(
                message: message,
                isFirst: true,
                availableWidth: 300,
                scrolledId: .constant(nil)
            )
        )

        // Then
        XCTAssert(view is EmptyView)
    }

    func test_viewFactory_makeGiphyBadgeViewType() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeGiphyBadgeViewType(options: GiphyBadgeViewTypeOptions(message: message, availableWidth: 300))

        // Then
        XCTAssert(view is GiphyBadgeView)
    }

    func test_viewFactory_makeCustomAttachmentPickerView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeCustomAttachmentPickerView(
            options: CustomAttachmentPickerViewOptions(
                addedCustomAttachments: [],
                onCustomAttachmentTap: { _ in }
            )
        )

        // Then
        XCTAssert(view is EmptyView)
    }

    func test_viewFactory_makeCustomAttachmentPreviewView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeCustomAttachmentPreviewView(
            options: CustomAttachmentPreviewViewOptions(
                addedCustomAttachments: [],
                onCustomAttachmentTap: { _ in }
            )
        )

        // Then
        XCTAssert(view is EmptyView)
    }

    func test_viewFactory_makeFilePickerView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeAttachmentFilePickerView(
            options: AttachmentFilePickerViewOptions(
                filePickerShown: .constant(false),
                onFilesPicked: { _ in }
            )
        )

        // Then
        XCTAssert(view is AttachmentFilePickerView)
    }

    func test_viewFactory_makeCameraPickerView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeAttachmentCameraPickerView(
            options: AttachmentCameraPickerViewOptions(
                cameraPickerShown: .constant(false),
                cameraImageAdded: { _ in }
            )
        )

        // Then
        XCTAssert(view is AttachmentCameraPickerView)
    }

    func test_viewFactory_makeMessageActionsView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeMessageActionsView(
            options: MessageActionsViewOptions(
                message: message,
                channel: .mockDMChannel(),
                onFinish: { _ in },
                onError: { _ in }
            )
        )

        // Then
        XCTAssert(view is MessageActionsView)
    }

    func test_viewFactory_makeMessageReactionsView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeMessageReactionView(
            options: MessageReactionViewOptions(
                message: message,
                onTapGesture: {},
                onLongPressGesture: {}
            )
        )

        // Then
        XCTAssert(view is ReactionsContainer)
    }

    func test_viewFactory_makeReactionsOverlayView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeReactionsOverlayView(
            options: ReactionsOverlayViewOptions(
                channel: .mockDMChannel(),
                currentSnapshot: UIImage(systemName: "checkmark")!,
                messageDisplayInfo: .init(
                    message: message,
                    frame: .zero,
                    contentWidth: 300,
                    isFirst: true
                ),
                onBackgroundTap: {},
                onActionExecuted: { _ in }
            )
        )

        // Then
        XCTAssert(view is ReactionsOverlayView<DefaultViewFactory>)
    }

    func test_viewFactory_makeMessageThreadHeaderViewModifier() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let viewModifier = viewFactory.makeMessageThreadHeaderViewModifier(options: MessageThreadHeaderViewModifierOptions())

        // Then
        XCTAssert(viewModifier is DefaultMessageThreadHeaderModifier)
    }

    func test_viewFactory_makeSendInChannelView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeSendInChannelView(
            options: SendInChannelViewOptions(
                showReplyInChannel: .constant(true)
            )
        )

        // Then
        XCTAssert(view is SendInChannelView)
    }

    func test_viewFactory_makeQuotedMessageView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeQuotedMessageView(
            options: .init(
                quotedMessage: message,
                outgoing: true
            )
        )

        // Then
        XCTAssert(view is QuotedMessageView<DefaultViewFactory>)
    }
    
    func test_viewFactory_makeChatQuotedMessageView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeChatQuotedMessageView(
            options: ChatQuotedMessageViewOptions(
                quotedMessage: message,
                parentMessage: .mock(),
                scrolledId: .constant(nil)
            )
        )

        // Then
        XCTAssert(view is ChatQuotedMessageView<DefaultViewFactory>)
    }

    func test_viewFactory_makeComposerQuotedMessageView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeComposerQuotedMessageView(
            options: .init(
                quotedMessage: message,
                onDismiss: {}
            )
        )

        // Then
        XCTAssert(view is ComposerQuotedMessageView<DefaultViewFactory>)
    }

    func test_viewFactory_makeSuggestionsContainerView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeSuggestionsContainerView(options: SuggestionsContainerViewOptions(suggestions: [:]) { _ in })

        // Then
        XCTAssert(view is SuggestionsContainerView<DefaultViewFactory>)
    }

    func test_viewFactory_makeLeadingSwipeActionsView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeLeadingSwipeActionsView(
            options: LeadingSwipeActionsViewOptions(
                channel: .mockDMChannel(),
                offsetX: 80,
                buttonWidth: 40,
                swipedChannelId: .constant(nil),
                buttonTapped: { _ in }
            )
        )

        // Then
        XCTAssert(view is EmptyView)
    }

    func test_viewFactory_makeTrailingSwipeActionsView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeTrailingSwipeActionsView(
            options: TrailingSwipeActionsViewOptions(
                channel: .mockDMChannel(),
                offsetX: 80,
                buttonWidth: 40,
                swipedChannelId: .constant(nil),
                leftButtonTapped: { _ in },
                rightButtonTapped: { _ in }
            )
        )

        // Then
        XCTAssert(view is TrailingSwipeActionsView)
    }

    func test_viewFactory_makeMessageReadIndicatorView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeMessageReadIndicatorView(
            options: MessageReadIndicatorViewOptions(
                channel: .mockDMChannel(),
                message: .mock(id: .unique, cid: .unique, text: "Test", author: .mock(id: .unique))
            )
        )

        // Then
        XCTAssert(view is MessageReadIndicatorView)
    }

    func test_viewFactory_makeSystemMessageView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeSystemMessageView(
            options: SystemMessageViewOptions(
                message: .mock(id: .unique, cid: .unique, text: "Test", author: .mock(id: .unique))
            )
        )

        // Then
        XCTAssert(view is SystemMessageView)
    }

    func test_viewFactory_makeChannelListFooterView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeChannelListFooterView(options: ChannelListFooterViewOptions())

        // Then
        XCTAssert(view is EmptyView)
    }

    func test_viewFactory_makeChannelListStickyFooterView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeChannelListStickyFooterView(options: ChannelListStickyFooterViewOptions())

        // Then
        XCTAssert(view is EmptyView)
    }

    func test_viewFactory_makeChannelListModifier() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let modifier = viewFactory.styles.makeChannelListModifier(options: ChannelListModifierOptions())

        // Then
        XCTAssert(modifier is EmptyViewModifier)
    }

    func test_viewFactory_makeMessageListModifier() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let modifier = viewFactory.styles.makeMessageListModifier(options: MessageListModifierOptions())

        // Then
        XCTAssert(modifier is EmptyViewModifier)
    }

    func test_viewFactory_makeMessageViewModifier() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let modifier = viewFactory.styles.makeMessageViewModifier(
            for: MessageModifierInfo(
                message: message,
                isFirst: false
            )
        )

        // Then
        XCTAssert(modifier is MessageBubbleModifier)
    }

    func test_viewFactory_makeComposerViewModifier() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let modifier = viewFactory.styles.makeComposerViewModifier(options: ComposerViewModifierOptions())

        // Then
        XCTAssert(modifier is ComposerBackgroundRegularViewModifier)
    }

    func test_viewFactory_makeMessageDateView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeMessageDateView(options: MessageDateViewOptions(message: message))

        // Then
        XCTAssert(view is MessageDateView)
    }

    func test_viewFactory_makeMessageAuthorAndDateView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeMessageAuthorAndDateView(options: MessageAuthorAndDateViewOptions(message: message))

        // Then
        XCTAssert(view is MessageAuthorAndDateView)
    }

    func test_viewFactory_makeChannelListContentModifier() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let viewModifier = viewFactory.styles.makeChannelListContentModifier(options: ChannelListContentModifierOptions())

        // Then
        XCTAssert(viewModifier is EmptyViewModifier)
    }

    func test_viewFactory_makeMessageListDateIndicator() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeMessageListDateIndicator(options: MessageListDateIndicatorViewOptions(date: Date()))

        // Then
        XCTAssert(view is DateIndicatorView)
    }

    func test_viewFactory_makeLastInGroupHeaderView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeLastInGroupHeaderView(options: LastInGroupHeaderViewOptions(message: message))

        // Then
        XCTAssert(view is EmptyView)
    }

    func test_viewFactory_makeEmojiTextView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeEmojiTextView(
            options: EmojiTextViewOptions(
                message: message,
                scrolledId: .constant(nil),
                isFirst: true
            )
        )

        // Then
        XCTAssert(view is EmojiTextView<DefaultViewFactory>)
    }

    func test_viewFactory_makeMessageRepliesView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeMessageRepliesView(
            options: MessageRepliesViewOptions(
                channel: ChatChannel.mockDMChannel(),
                message: message,
                replyCount: 2
            )
        )

        // Then
        XCTAssert(view is MessageRepliesView<DefaultViewFactory>)
    }
    
    func test_viewFactory_makeInlineTypingIndicatorView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeInlineTypingIndicatorView(
            options: TypingIndicatorViewOptions(
                channel: .mockDMChannel(),
                currentUserId: nil
            )
        )

        // Then
        XCTAssert(view is TypingIndicatorView)
    }
    
    func test_viewFactory_makeSubtitleTypingIndicatorView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeSubtitleTypingIndicatorView(
            options: SubtitleTypingIndicatorViewOptions(
                channel: .mockDMChannel()
            )
        )

        // Then
        XCTAssertNotNil(view)
    }

    func test_viewFactory_makeReactionsContentView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeReactionsContentView(
            options: ReactionsContentViewOptions(
                message: .mock(),
                contentRect: .zero,
                onReactionTap: { _ in },
                onMoreReactionsTap: {}
            )
        )

        // Then
        XCTAssert(view is ReactionsOverlayContainer)
    }
    
    func test_viewFactory_makeNewMessagesDividerView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeNewMessagesDividerView(
            options: NewMessagesDividerViewOptions(
                newMessagesStartId: .constant(nil),
                count: 2
            )
        )
        
        // Then
        XCTAssert(view is NewMessagesDivider)
    }

    func test_viewFactory_makeThreadRepliesDividerView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeThreadRepliesDividerView(
            options: ThreadRepliesDividerViewOptions(replyCount: 5)
        )
        
        // Then
        XCTAssert(view is ThreadRepliesDivider)
    }
    
    func test_viewFactory_makeComposerTextInputView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeComposerTextInputView(
            options: ComposerTextInputViewOptions(
                text: .constant("test"),
                height: .constant(40),
                selectedRangeLocation: .constant(0),
                placeholder: "Message",
                editable: true,
                maxMessageLength: nil,
                currentHeight: 40,
                onImagePasted: { _ in }
            )
        )
        
        // Then
        XCTAssert(view is ComposerTextInputView)
    }

    func test_viewFactory_makeSendMessageButton() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeSendMessageButton(
            options: SendMessageButtonOptions(
                enabled: true,
                onTap: {}
            )
        )

        // Then
        XCTAssert(view is SendMessageButton)
    }

    func test_viewFactory_makeConfirmEditButton() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeConfirmEditButton(
            options: ConfirmEditButtonOptions(
                enabled: true,
                onTap: {}
            )
        )

        // Then
        XCTAssert(view is ConfirmEditButton)
    }

    func test_viewFactory_makeAttachmentCommandsPickerView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeAttachmentCommandsPickerView(
            options: AttachmentCommandsPickerViewOptions(
                onCommandSelected: { _ in }
            )
        )

        // Then
        XCTAssert(view is AttachmentCommandsPickerView)
    }
    
    func test_viewFactory_makeMessageListContainerModifier() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let modifier = viewFactory.styles.makeMessageListContainerModifier(options: MessageListContainerModifierOptions())

        // Then
        XCTAssert(modifier is EmptyViewModifier)
    }
    
    func test_viewFactory_makeBottomReactionsView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeBottomReactionsView(
            options: ReactionsBottomViewOptions(
                message: .mock(),
                showsAllInfo: true,
                onTap: {},
                onLongPress: {}
            )
        )

        // Then
        XCTAssert(view is ReactionsContainer)
    }
    
    func test_viewFactory_makeComposerVoiceRecordingInputView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeComposerVoiceRecordingInputView(
            options: ComposerVoiceRecordingInputViewOptions(
                recordingState: .recording,
                audioRecordingInfo: .initial,
                pendingAudioRecordingURL: nil,
                gestureLocation: .zero,
                stopRecording: {},
                confirmRecording: {},
                discardRecording: {},
                previewRecording: {}
            )
        )
        
        // Then
        XCTAssert(view is ComposerVoiceRecordingInputView<DefaultViewFactory>)
    }
    
    func test_viewFactory_makeChannelLoadingView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeChannelLoadingView(options: ChannelLoadingViewOptions())

        // Then
        XCTAssert(view is LoadingView)
    }
    
    func test_viewFactory_makePollView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makePollView(
            options: PollViewOptions(
                message: .mock(),
                poll: Poll.mock(),
                isFirst: true,
                availableWidth: 256
            )
        )
        
        // Then
        XCTAssert(view is PollAttachmentView<DefaultViewFactory>)
    }
    
    func test_viewFactory_makeChannelAvatarView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeChannelAvatarView(
            options: ChannelAvatarViewOptions(
                channel: .mockNonDMChannel(),
                size: AvatarSize.medium
            )
        )
        
        // Then
        XCTAssert(view is ChannelAvatar)
    }
    
    func test_viewFactory_makeMediaViewer() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeMediaViewer(
            options: MediaViewerOptions(
                mediaAttachments: [],
                message: .mock(),
                isShown: .constant(true),
                options: .init(selectedIndex: 0)
            )
        )
            
        // Then
        XCTAssert(view is MediaViewer<DefaultViewFactory>)
    }
    
    func test_viewFactory_makeMediaViewerToolbarModifier() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let modifier = viewFactory.makeMediaViewerToolbarModifier(
            options: MediaViewerToolbarModifierOptions(
                title: .unique,
                subtitle: .unique,
                isShown: .constant(true)
            )
        )

        // Then
        XCTAssert(modifier is MediaViewerToolbarModifier)
    }
    
    func test_viewFactory_makeVideoPlayerHeaderView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeVideoPlayerHeaderView(
            options: VideoPlayerHeaderViewOptions(
                title: .unique,
                subtitle: .unique,
                shown: .constant(true)
            )
        )
            
        // Then
        XCTAssert(view is MediaViewerHeader)
    }
    
    func test_viewFactory_makeMemberAddView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeMemberAddView(
            options: MemberAddViewOptions(
                options: .init(loadedUserIds: []),
                onConfirm: { _ in }
            )
        )
        
        // Then
        XCTAssert(view is MemberAddView<DefaultViewFactory>)
    }

    func test_viewFactory_makeStreamTextView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeStreamTextView(options: .init(message: message, formattedText: MessageFormattedText(message.text)))

        // Then
        XCTAssert(view is StreamTextView)
    }

    func test_viewFactory_makeAttachmentTextView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeAttachmentTextView(options: .init(message: message, formattedText: MessageFormattedText(message.text), availableWidth: 300))

        // Then
        XCTAssert(view is AttachmentTextView<DefaultViewFactory>)
    }

    func test_viewFactory_makeReactionsDetailView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeReactionsDetailView(
            options: ReactionsDetailViewOptions(message: message)
        )

        // Then
        XCTAssert(view is ReactionsDetailView<DefaultViewFactory>)
    }

    func test_viewFactory_makeMessageTopView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        let channel = ChatChannel.mockDMChannel()
        let viewModel = MessageViewModel(message: message, channel: channel)

        // When
        let view = viewFactory.makeMessageTopView(
            options: MessageTopViewOptions(
                message: message,
                channel: channel,
                messageViewModel: viewModel
            )
        )

        // Then
        XCTAssert(view is MessageTopView)
    }
}

extension ChannelAction: @retroactive Equatable {
    public static func == (lhs: ChannelAction, rhs: ChannelAction) -> Bool {
        lhs.id == rhs.id
    }
}
