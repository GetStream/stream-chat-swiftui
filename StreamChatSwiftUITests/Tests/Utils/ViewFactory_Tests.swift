//
// Copyright © 2025 Stream.io Inc. All rights reserved.
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

    func test_viewFactory_makeNoChannelsView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeNoChannelsView(options: NoChannelsViewOptions())

        // Then
        XCTAssert(view is NoChannelsView)
    }

    func test_viewFactory_makeLoadingView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeLoadingView(options: LoadingViewOptions())

        // Then
        XCTAssert(view is RedactedLoadingView<DefaultViewFactory>)
    }

    func test_viewFactory_makeChannelListHeaderViewModifier() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let viewModifier = viewFactory.makeChannelListHeaderViewModifier(options: ChannelListHeaderViewModifierOptions(title: "Test"))

        // Then
        XCTAssert(viewModifier is DefaultChannelListHeaderModifier)
    }

    func test_viewFactory_supportedMoreChannelActions() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        let channel: ChatChannel = .mockDMChannel()
        let expected = ChannelAction.defaultActions(
            for: channel,
            chatClient: chatClient,
            onDismiss: {},
            onError: { _ in }
        )

        // When
        let actions = viewFactory.supportedMoreChannelActions(
            options: SupportedMoreChannelActionsOptions(
                channel: channel,
                onDismiss: {},
                onError: { _ in }
            )
        )

        // Then
        XCTAssert(actions == expected)
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
        XCTAssert(view is MoreChannelActionsView)
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
                onlineIndicatorShown: { _ in true },
                channelNaming: { _ in "Test" },
                imageLoader: { _ in UIImage(systemName: "person")! },
                onSearchResultTap: { _ in },
                onItemAppear: { _ in }
            )
        )
        
        // Then
        XCTAssert(view is SearchResultsView<DefaultViewFactory>)
    }

    func test_viewFactory_makeMessageAvatarView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        let userInfo = UserDisplayInfo(
            id: .unique,
            name: .unique,
            imageURL: URL(string: "https://example.com"),
            role: .user
        )

        // When
        let view = viewFactory.makeMessageAvatarView(options: MessageAvatarViewOptions(userDisplayInfo: userInfo))

        // Then
        XCTAssert(view is MessageAvatarView<MessageAvatarDefaultPlaceholderView>)
    }

    func test_viewFactory_makeQuotedMessageAvatarView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        let userInfo = UserDisplayInfo(
            id: .unique,
            name: .unique,
            imageURL: URL(string: "https://example.com"),
            role: .user
        )

        // When
        let view = viewFactory.makeQuotedMessageAvatarView(
            options: QuotedMessageAvatarViewOptions(
                userDisplayInfo: userInfo,
                size: CGSize(width: 16, height: 16)
            )
        )

        // Then
        XCTAssert(view is MessageAvatarView<MessageAvatarDefaultPlaceholderView>)
    }

    func test_viewFactory_makeChannelHeaderViewModifier() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeChannelHeaderViewModifier(options: ChannelHeaderViewModifierOptions(channel: .mockDMChannel()))

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
                isFirst: true,
                availableWidth: 300,
                scrolledId: .constant(nil)
            )
        )

        // Then
        XCTAssert(view is MessageTextView<DefaultViewFactory>)
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
        XCTAssert(view is ImageAttachmentContainer<DefaultViewFactory>)
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
        XCTAssert(view is VideoAttachmentsContainer<DefaultViewFactory>)
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

    func test_viewFactory_makeCustomAttachmentView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeCustomAttachmentView(
            options: CustomComposerAttachmentViewOptions(
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
        let view = viewFactory.makeFilePickerView(
            options: FilePickerViewOptions(
                filePickerShown: .constant(true),
                addedFileURLs: .constant([])
            )
        )

        // Then
        XCTAssert(view is FilePickerDisplayView)
    }

    func test_viewFactory_makeCameraPickerView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeCameraPickerView(
            options: CameraPickerViewOptions(
                selected: .constant(.photos),
                cameraPickerShown: .constant(false),
                cameraImageAdded: { _ in }
            )
        )

        // Then
        XCTAssert(view is CameraPickerDisplayView)
    }

    func test_viewFactory_makeAssetsAccessPermissionView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeAssetsAccessPermissionView(options: AssetsAccessPermissionViewOptions())

        // Then
        XCTAssert(view is AssetsAccessPermissionView)
    }

    func test_viewFactory_supportedMessageActions() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        let expected = MessageAction.defaultActions(
            factory: DefaultViewFactory.shared,
            for: message,
            channel: .mockDMChannel(),
            chatClient: chatClient,
            onFinish: { _ in },
            onError: { _ in }
        )

        // When
        let actions = viewFactory.supportedMessageActions(
            options: SupportedMessageActionsOptions(
                message: message,
                channel: .mockDMChannel(),
                onFinish: { _ in },
                onError: { _ in }
            )
        )

        // Then
        XCTAssert(actions == expected)
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
                showReplyInChannel: .constant(true),
                isDirectMessage: true
            )
        )

        // Then
        XCTAssert(view is SendInChannelView)
    }

    func test_viewFactory_makeQuotedMessageHeaderView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeQuotedMessageHeaderView(
            options: QuotedMessageHeaderViewOptions(
                quotedMessage: .constant(message)
            )
        )

        // Then
        XCTAssert(view is QuotedMessageHeaderView)
    }

    func test_viewFactory_makeQuotedMessageComposerView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeQuotedMessageView(
            options: QuotedMessageViewOptions(
                quotedMessage: message,
                fillAvailableSpace: true,
                isInComposer: false,
                scrolledId: .constant(nil)
            )
        )

        // Then
        XCTAssert(view is QuotedMessageViewContainer<DefaultViewFactory>)
    }

    func test_viewFactory_makeEditedMessageHeaderView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeEditedMessageHeaderView(
            options: EditedMessageHeaderViewOptions(
                editedMessage: .constant(message)
            )
        )

        // Then
        XCTAssert(view is EditMessageHeaderView)
    }

    func test_viewFactory_makeCommandsContainerView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeCommandsContainerView(options: CommandsContainerViewOptions(suggestions: [:]) { _ in })

        // Then
        XCTAssert(view is CommandsContainerView<DefaultViewFactory>)
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

    func test_viewFactory_makeReactionsUsersView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeReactionsUsersView(
            options: ReactionsUsersViewOptions(
                message: .mock(id: .unique, cid: .unique, text: "Test", author: .mock(id: .unique)),
                maxHeight: 280
            )
        )

        // Then
        XCTAssert(view is ReactionsUsersView<DefaultViewFactory>)
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
        XCTAssert(modifier is EmptyViewModifier)
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
    
    func test_viewFactory_makeMessageRepliesShownInChannelView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeMessageRepliesShownInChannelView(
            options: MessageRepliesShownInChannelViewOptions(
                channel: ChatChannel.mockDMChannel(),
                message: message,
                parentMessage: message,
                replyCount: 2
            )
        )

        // Then
        XCTAssert(view is MessageRepliesView<DefaultViewFactory>)
    }

    func test_viewFactory_makeTypingIndicatorBottomView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeTypingIndicatorBottomView(
            options: TypingIndicatorBottomViewOptions(
                channel: .mockDMChannel(),
                currentUserId: nil
            )
        )

        // Then
        XCTAssert(view is TypingIndicatorBottomView)
    }

    func test_viewFactory_makeReactionsContentView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeReactionsContentView(
            options: ReactionsContentViewOptions(
                message: .mock(),
                contentRect: .zero,
                onReactionTap: { _ in }
            )
        )

        // Then
        XCTAssert(view is ReactionsOverlayContainer)
    }
    
    func test_viewFactory_makeNewMessagesIndicatorView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeNewMessagesIndicatorView(
            options: NewMessagesIndicatorViewOptions(
                newMessagesStartId: .constant(nil),
                count: 2
            )
        )
        
        // Then
        XCTAssert(view is NewMessagesIndicator)
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
                placeholder: "Send a message",
                editable: true,
                maxMessageLength: nil,
                currentHeight: 40
            )
        )
        
        // Then
        XCTAssert(view is ComposerTextInputView)
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
        let name = String(describing: type(of: view))

        // Then
        XCTAssert(name.contains("BottomReactionsView"))
    }
    
    func test_viewFactory_makeCustomAttachmentQuotedView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeCustomAttachmentQuotedView(options: CustomAttachmentQuotedViewOptions(message: .mock()))
        
        // Then
        XCTAssert(view is EmptyView)
    }
    
    func test_viewFactory_makeComposerRecordingView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        let controller = ChatChannelTestHelpers.makeChannelController(
            chatClient: chatClient
        )
        let viewModel = MessageComposerViewModel(channelController: controller, messageController: nil)
        
        // When
        let view = viewFactory.makeComposerRecordingView(
            options: ComposerRecordingViewOptions(
                viewModel: viewModel,
                gestureLocation: .zero
            )
        )
        
        // Then
        XCTAssert(view is RecordingView)
    }
    
    func test_viewFactory_makeComposerRecordingTipView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeComposerRecordingTipView(options: ComposerRecordingTipViewOptions())

        // Then
        XCTAssert(view is RecordingTipView)
    }
    
    func test_viewFactory_makeComposerRecordingLockedView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        let controller = ChatChannelTestHelpers.makeChannelController(
            chatClient: chatClient
        )
        let viewModel = MessageComposerViewModel(channelController: controller, messageController: nil)
        
        // When
        let view = viewFactory.makeComposerRecordingLockedView(
            options: ComposerRecordingLockedViewOptions(viewModel: viewModel)
        )
        
        // Then
        XCTAssert(view is LockedView)
    }
    
    func test_viewFactory_makeChannelLoadingView() {
        // Given
        let viewFactory = DefaultViewFactory.shared

        // When
        let view = viewFactory.makeChannelLoadingView(options: ChannelLoadingViewOptions())

        // Then
        XCTAssert(view is LoadingView)
    }
    
    func test_viewFactory_makeComposerPollView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeComposerPollView(
            options: ComposerPollViewOptions(
                channelController: .init(channelQuery: .init(cid: .unique), channelListQuery: nil, client: chatClient),
                messageController: nil
            )
        )
        
        // Then
        XCTAssert(view is ComposerPollView)
    }
    
    func test_viewFactory_makePollView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makePollView(
            options: PollViewOptions(
                message: .mock(),
                poll: Poll.mock(),
                isFirst: true
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
            options: ChannelAvatarViewFactoryOptions(
                channel: .mockNonDMChannel(),
                options: .init(showOnlineIndicator: false)
            )
        )
        
        // Then
        XCTAssert(view is ChannelAvatarView)
    }
    
    func test_viewFactory_makeGalleryView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeGalleryView(
            options: GalleryViewOptions(
                mediaAttachments: [],
                message: .mock(),
                isShown: .constant(true),
                options: .init(selectedIndex: 0)
            )
        )
            
        // Then
        XCTAssert(view is GalleryView<DefaultViewFactory>)
    }
    
    func test_viewFactory_makeGalleryHeaderView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeGalleryHeaderView(
            options: GalleryHeaderViewOptions(
                title: .unique,
                subtitle: .unique,
                shown: .constant(true)
            )
        )
            
        // Then
        XCTAssert(view is GalleryHeaderView)
    }
    
    func test_viewFactory_makeVideoPlayerView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeVideoPlayerView(
            options: VideoPlayerViewOptions(
                attachment: .mock(id: .unique),
                message: .mock(),
                isShown: .constant(true),
                options: .init(selectedIndex: 0)
            )
        )
            
        // Then
        XCTAssert(view is VideoPlayerView<DefaultViewFactory>)
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
        XCTAssert(view is GalleryHeaderView)
    }
    
    func test_viewFactory_makeAddUsersView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeAddUsersView(
            options: AddUsersViewOptions(
                options: .init(loadedUsers: []),
                onUserTap: { _ in }
            )
        )
        
        // Then
        XCTAssert(view is AddUsersView<DefaultViewFactory>)
    }

    func test_viewFactory_makeAttachmentTextView() {
        // Given
        let viewFactory = DefaultViewFactory.shared
        
        // When
        let view = viewFactory.makeAttachmentTextView(options: .init(mesage: message))
        
        // Then
        XCTAssert(view is StreamTextView)
    }
}

extension ChannelAction: @retroactive Equatable {
    public static func == (lhs: ChannelAction, rhs: ChannelAction) -> Bool {
        lhs.id == rhs.id
    }
}
