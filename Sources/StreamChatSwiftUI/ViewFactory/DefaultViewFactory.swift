//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Photos
import StreamChat
import SwiftUI

/// Default implementations for the `ViewFactory`.
extension ViewFactory {
    // MARK: channels
    
    public func makeNoChannelsView(options: NoChannelsViewOptions) -> some View {
        NoChannelsView()
    }
    
    public func makeLoadingView(options: LoadingViewOptions) -> some View {
        RedactedLoadingView(factory: self)
    }
    
    public func navigationBarDisplayMode() -> NavigationBarItem.TitleDisplayMode {
        .inline
    }
    
    public func makeChannelListHeaderViewModifier(
        options: ChannelListHeaderViewModifierOptions
    ) -> some ChannelListHeaderViewModifier {
        DefaultChannelListHeaderModifier(title: options.title)
    }
    
    public func supportedMoreChannelActions(
        options: SupportedMoreChannelActionsOptions
    ) -> [ChannelAction] {
        ChannelAction.defaultActions(
            for: options.channel,
            chatClient: chatClient,
            onDismiss: options.onDismiss,
            onError: options.onError
        )
    }
    
    public func makeMoreChannelActionsView(
        options: MoreChannelActionsViewOptions
    ) -> some View {
        MoreChannelActionsView(
            channel: options.channel,
            channelActions: supportedMoreChannelActions(
                options: SupportedMoreChannelActionsOptions(
                    channel: options.channel,
                    onDismiss: options.onDismiss,
                    onError: options.onError
                )
            ),
            swipedChannelId: options.swipedChannelId,
            onDismiss: options.onDismiss
        )
    }
    
    public func makeChannelListItem(
        options: ChannelListItemOptions<ChannelDestination>
    ) -> some View {
        let utils = InjectedValues[\.utils]
        let listItem = ChatChannelNavigatableListItem(
            factory: self,
            channel: options.channel,
            channelName: options.channelName,
            avatar: options.avatar,
            onlineIndicatorShown: options.onlineIndicatorShown,
            disabled: options.disabled,
            handleTabBarVisibility: utils.messageListConfig.handleTabBarVisibility,
            selectedChannel: options.selectedChannel,
            channelDestination: options.channelDestination,
            onItemTap: options.onItemTap
        )
        return ChatChannelSwipeableListItem(
            factory: self,
            channelListItem: listItem,
            swipedChannelId: options.swipedChannelId,
            channel: options.channel,
            numberOfTrailingItems: options.channel.ownCapabilities.contains(.deleteChannel) ? 2 : 1,
            trailingRightButtonTapped: options.trailingSwipeRightButtonTapped,
            trailingLeftButtonTapped: options.trailingSwipeLeftButtonTapped,
            leadingSwipeButtonTapped: options.leadingSwipeButtonTapped
        )
    }
    
    public func makeChannelAvatarView(
        options: ChannelAvatarViewFactoryOptions
    ) -> some View {
        ChannelAvatarView(
            channel: options.channel,
            showOnlineIndicator: options.options.showOnlineIndicator,
            avatar: options.options.avatar,
            size: options.options.size
        )
    }
    
    public func makeChannelListBackground(options: ChannelListBackgroundOptions) -> some View {
        Color(options.colors.background)
            .edgesIgnoringSafeArea(.bottom)
    }

    public func makeChannelListItemBackground(
        options: ChannelListItemBackgroundOptions
    ) -> some View {
        let colors = InjectedValues[\.colors]
        if options.isSelected && isIPad {
            return Color(colors.background6)
        }

        return Color(colors.background)
    }

    public func makeChannelListDividerItem(options: ChannelListDividerItemOptions) -> some View {
        Divider()
    }
    
    public func makeTrailingSwipeActionsView(
        options: TrailingSwipeActionsViewOptions
    ) -> TrailingSwipeActionsView {
        TrailingSwipeActionsView(
            channel: options.channel,
            offsetX: options.offsetX,
            buttonWidth: options.buttonWidth,
            leftButtonTapped: options.leftButtonTapped,
            rightButtonTapped: options.rightButtonTapped
        )
    }
    
    public func makeLeadingSwipeActionsView(
        options: LeadingSwipeActionsViewOptions
    ) -> EmptyView {
        EmptyView()
    }
    
    public func makeChannelListTopView(
        options: ChannelListTopViewOptions
    ) -> some View {
        SearchBar(text: options.searchText)
    }
    
    public func makeChannelListFooterView(options: ChannelListFooterViewOptions) -> some View {
        EmptyView()
    }
    
    public func makeChannelListStickyFooterView(options: ChannelListStickyFooterViewOptions) -> some View {
        EmptyView()
    }
    
    public func makeSearchResultsView(
        options: SearchResultsViewOptions
    ) -> some View {
        SearchResultsView(
            factory: self,
            selectedChannel: options.selectedChannel,
            searchResults: options.searchResults,
            loadingSearchResults: options.loadingSearchResults,
            onlineIndicatorShown: options.onlineIndicatorShown,
            channelNaming: options.channelNaming,
            imageLoader: options.imageLoader,
            onSearchResultTap: options.onSearchResultTap,
            onItemAppear: options.onItemAppear
        )
    }
    
    public func makeChannelListSearchResultItem(
        options: ChannelListSearchResultItemOptions<ChannelDestination>
    ) -> some View {
        SearchResultItem(
            factory: self,
            searchResult: options.searchResult,
            onlineIndicatorShown: options.onlineIndicatorShown,
            channelName: options.channelName,
            avatar: options.avatar,
            onSearchResultTap: options.onSearchResultTap,
            channelDestination: options.channelDestination
        )
    }
    
    public func makeChannelListContentModifier(options: ChannelListContentModifierOptions) -> some ViewModifier {
        EmptyViewModifier()
    }
    
    public func makeChannelListModifier(options: ChannelListModifierOptions) -> some ViewModifier {
        EmptyViewModifier()
    }
    
    // MARK: messages
    
    public func makeChannelDestination(options: ChannelDestinationOptions) -> @MainActor(ChannelSelectionInfo) -> ChatChannelView<Self> {
        { [unowned self] selectionInfo in
            let controller = InjectedValues[\.utils]
                .channelControllerFactory
                .makeChannelController(for: selectionInfo.channel.cid)
            return ChatChannelView(
                viewFactory: self,
                channelController: controller,
                scrollToMessage: selectionInfo.message
            )
        }
    }
    
    public func makeMessageThreadDestination(options: MessageThreadDestinationOptions) -> @MainActor(ChatChannel, ChatMessage) -> ChatChannelView<Self> {
        { [unowned self] channel, message in
            let channelController = InjectedValues[\.utils]
                .channelControllerFactory
                .makeChannelController(for: channel.cid)
            let messageController = chatClient.messageController(
                cid: channel.cid,
                messageId: message.id
            )
            return ChatChannelView(
                viewFactory: self,
                channelController: channelController,
                messageController: messageController,
                scrollToMessage: message
            )
        }
    }

    public func makeMessageListModifier(options: MessageListModifierOptions) -> some ViewModifier {
        EmptyViewModifier()
    }
    
    public func makeMessageListContainerModifier(options: MessageListContainerModifierOptions) -> some ViewModifier {
        EmptyViewModifier()
    }
    
    public func makeMessageViewModifier(for messageModifierInfo: MessageModifierInfo) -> some ViewModifier {
        MessageBubbleModifier(
            message: messageModifierInfo.message,
            isFirst: messageModifierInfo.isFirst,
            injectedBackgroundColor: messageModifierInfo.injectedBackgroundColor,
            cornerRadius: messageModifierInfo.cornerRadius,
            forceLeftToRight: messageModifierInfo.forceLeftToRight
        )
    }

    public func makeBouncedMessageActionsModifier(viewModel: ChatChannelViewModel) -> some ViewModifier {
        BouncedMessageActionsModifier(viewModel: viewModel)
    }

    public func makeEmptyMessagesView(
        options: EmptyMessagesViewOptions
    ) -> some View {
        Color(options.colors.background)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityIdentifier("EmptyMessagesView")
    }
    
    public func makeMessageAvatarView(options: MessageAvatarViewOptions) -> some View {
        MessageAvatarView(avatarURL: options.userDisplayInfo.imageURL, size: options.userDisplayInfo.size ?? .messageAvatarSize)
    }
    
    public func makeQuotedMessageAvatarView(
        options: QuotedMessageAvatarViewOptions
    ) -> some View {
        MessageAvatarView(avatarURL: options.userDisplayInfo.imageURL, size: options.size)
    }
    
    public func makeChannelHeaderViewModifier(
        options: ChannelHeaderViewModifierOptions
    ) -> some ChatChannelHeaderViewModifier {
        DefaultChannelHeaderModifier(factory: self, channel: options.channel)
    }
    
    public func makeChannelBarsVisibilityViewModifier(options: ChannelBarsVisibilityViewModifierOptions) -> some ViewModifier {
        ChangeChannelBarsVisibilityModifier(shouldShow: options.shouldShow)
    }
    
    public func makeChannelLoadingView(options: ChannelLoadingViewOptions) -> some View {
        LoadingView()
    }
    
    public func makeMessageThreadHeaderViewModifier(options: MessageThreadHeaderViewModifierOptions) -> some MessageThreadHeaderViewModifier {
        DefaultMessageThreadHeaderModifier()
    }
    
    public func makeMessageListBackground(
        options: MessageListBackgroundOptions
    ) -> some View {
        Color(options.colors.background)
    }
    
    public func makeMessageContainerView(
        options: MessageContainerViewOptions
    ) -> some View {
        MessageContainerView(
            factory: self,
            channel: options.channel,
            message: options.message,
            width: options.width,
            showsAllInfo: options.showsAllInfo,
            isInThread: options.isInThread,
            isLast: options.isLast,
            scrolledId: options.scrolledId,
            quotedMessage: options.quotedMessage,
            onLongPress: options.onLongPress
        )
    }
    
    public func makeMessageTextView(
        options: MessageTextViewOptions
    ) -> some View {
        MessageTextView(
            factory: self,
            message: options.message,
            isFirst: options.isFirst,
            scrolledId: options.scrolledId
        )
    }
    
    public func makeMessageDateView(options: MessageDateViewOptions) -> some View {
        MessageDateView(message: options.message)
    }
    
    public func makeMessageAuthorAndDateView(options: MessageAuthorAndDateViewOptions) -> some View {
        MessageAuthorAndDateView(message: options.message)
    }
    
    public func makeLastInGroupHeaderView(options: LastInGroupHeaderViewOptions) -> some View {
        EmptyView()
    }

    public func makeMessageTranslationFooterView(
        options: MessageTranslationFooterViewOptions
    ) -> some View {
        MessageTranslationFooterView(
            messageViewModel: options.messageViewModel
        )
    }

    public func makeImageAttachmentView(
        options: ImageAttachmentViewOptions
    ) -> some View {
        ImageAttachmentContainer(
            factory: self,
            message: options.message,
            width: options.availableWidth,
            isFirst: options.isFirst,
            scrolledId: options.scrolledId
        )
    }
    
    public func makeGiphyAttachmentView(
        options: GiphyAttachmentViewOptions
    ) -> some View {
        GiphyAttachmentView(
            factory: self,
            message: options.message,
            width: options.availableWidth,
            isFirst: options.isFirst,
            scrolledId: options.scrolledId
        )
    }
    
    public func makeLinkAttachmentView(
        options: LinkAttachmentViewOptions
    ) -> some View {
        LinkAttachmentContainer(
            factory: self,
            message: options.message,
            width: options.availableWidth,
            isFirst: options.isFirst,
            scrolledId: options.scrolledId
        )
    }
    
    public func makeFileAttachmentView(
        options: FileAttachmentViewOptions
    ) -> some View {
        FileAttachmentsContainer(
            factory: self,
            message: options.message,
            width: options.availableWidth,
            isFirst: options.isFirst,
            scrolledId: options.scrolledId
        )
    }
    
    public func makeVideoAttachmentView(
        options: VideoAttachmentViewOptions
    ) -> some View {
        VideoAttachmentsContainer(
            factory: self,
            message: options.message,
            width: options.availableWidth,
            scrolledId: options.scrolledId
        )
    }
    
    public func makeGalleryView(
        options: GalleryViewOptions
    ) -> some View {
        GalleryView(
            viewFactory: self,
            mediaAttachments: options.mediaAttachments,
            author: options.message.author,
            isShown: options.isShown,
            selected: options.options.selectedIndex,
            message: options.message
        )
    }
    
    public func makeGalleryHeaderView(
        options: GalleryHeaderViewOptions
    ) -> some View {
        GalleryHeaderView(title: options.title, subtitle: options.subtitle, isShown: options.shown)
    }
    
    public func makeVideoPlayerView(
        options: VideoPlayerViewOptions
    ) -> some View {
        VideoPlayerView(
            viewFactory: self,
            attachment: options.attachment,
            author: options.message.author,
            isShown: options.isShown
        )
    }
    
    public func makeVideoPlayerHeaderView(
        options: VideoPlayerHeaderViewOptions
    ) -> some View {
        GalleryHeaderView(title: options.title, subtitle: options.subtitle, isShown: options.shown)
    }
    
    public func makeVideoPlayerFooterView(
        options: VideoPlayerFooterViewOptions
    ) -> some View {
        VideoPlayerFooterView(
            attachment: options.attachment,
            shown: options.shown
        )
    }
    
    public func makeDeletedMessageView(
        options: DeletedMessageViewOptions
    ) -> some View {
        DeletedMessageView(
            message: options.message,
            isFirst: options.isFirst
        )
    }
    
    public func makeSystemMessageView(
        options: SystemMessageViewOptions
    ) -> some View {
        SystemMessageView(message: options.message.text)
    }
    
    public func makeEmojiTextView(
        options: EmojiTextViewOptions
    ) -> some View {
        EmojiTextView(
            factory: self,
            message: options.message,
            scrolledId: options.scrolledId,
            isFirst: options.isFirst
        )
    }
    
    public func makeCustomAttachmentViewType(
        options: CustomAttachmentViewTypeOptions
    ) -> some View {
        EmptyView()
    }
    
    public func makeScrollToBottomButton(
        options: ScrollToBottomButtonOptions
    ) -> some View {
        ScrollToBottomButton(
            unreadCount: options.unreadCount,
            onScrollToBottom: options.onScrollToBottom
        )
    }
    
    public func makeDateIndicatorView(options: DateIndicatorViewOptions) -> some View {
        DateIndicatorView(dateString: options.dateString)
    }
    
    public func makeMessageListDateIndicator(options: MessageListDateIndicatorViewOptions) -> some View {
        DateIndicatorView(date: options.date)
    }
    
    public func makeTypingIndicatorBottomView(
        options: TypingIndicatorBottomViewOptions
    ) -> some View {
        let typingIndicatorString = options.channel.typingIndicatorString(currentUserId: options.currentUserId)
        return TypingIndicatorBottomView(typingIndicatorString: typingIndicatorString)
    }
    
    public func makeGiphyBadgeViewType(
        options: GiphyBadgeViewTypeOptions
    ) -> some View {
        GiphyBadgeView()
    }
    
    public func makeMessageRepliesView(
        options: MessageRepliesViewOptions
    ) -> some View {
        MessageRepliesView(
            factory: self,
            channel: options.channel,
            message: options.message,
            replyCount: options.replyCount
        )
    }
    
    public func makeMessageRepliesShownInChannelView(
        options: MessageRepliesShownInChannelViewOptions
    ) -> some View {
        MessageRepliesView(
            factory: self,
            channel: options.channel,
            message: options.parentMessage,
            replyCount: options.replyCount,
            showReplyCount: false,
            isRightAligned: options.message.isRightAligned
        )
    }
    
    public func makeMessageComposerViewType(
        options: MessageComposerViewTypeOptions
    ) -> MessageComposerView<Self> {
        MessageComposerView(
            viewFactory: self,
            channelController: options.channelController,
            messageController: options.messageController,
            quotedMessage: options.quotedMessage,
            editedMessage: options.editedMessage,
            onMessageSent: options.onMessageSent
        )
    }
    
    public func makeLeadingComposerView(
        options: LeadingComposerViewOptions
    ) -> some View {
        AttachmentPickerTypeView(
            pickerTypeState: options.state,
            channelConfig: options.channelConfig
        )
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    public func makeComposerInputView(
        options: ComposerInputViewOptions
    ) -> some View {
        if options.shouldScroll {
            ScrollView {
                ComposerInputView(
                    factory: self,
                    text: options.text,
                    selectedRangeLocation: options.selectedRangeLocation,
                    command: options.command,
                    addedAssets: options.addedAssets,
                    addedFileURLs: options.addedFileURLs,
                    addedCustomAttachments: options.addedCustomAttachments,
                    quotedMessage: options.quotedMessage,
                    maxMessageLength: options.maxMessageLength,
                    cooldownDuration: options.cooldownDuration,
                    onCustomAttachmentTap: options.onCustomAttachmentTap,
                    removeAttachmentWithId: options.removeAttachmentWithId
                )
            }
            .frame(height: 240)
        } else {
            ComposerInputView(
                factory: self,
                text: options.text,
                selectedRangeLocation: options.selectedRangeLocation,
                command: options.command,
                addedAssets: options.addedAssets,
                addedFileURLs: options.addedFileURLs,
                addedCustomAttachments: options.addedCustomAttachments,
                quotedMessage: options.quotedMessage,
                maxMessageLength: options.maxMessageLength,
                cooldownDuration: options.cooldownDuration,
                onCustomAttachmentTap: options.onCustomAttachmentTap,
                removeAttachmentWithId: options.removeAttachmentWithId
            )
        }
    }
    
    public func makeComposerTextInputView(
        options: ComposerTextInputViewOptions
    ) -> some View {
        ComposerTextInputView(
            text: options.text,
            height: options.height,
            selectedRangeLocation: options.selectedRangeLocation,
            placeholder: options.placeholder,
            editable: options.editable,
            maxMessageLength: options.maxMessageLength,
            currentHeight: options.currentHeight
        )
    }
    
    public func makeTrailingComposerView(
        options: TrailingComposerViewOptions
    ) -> some View {
        TrailingComposerView(onTap: options.onTap)
    }
    
    public func makeComposerRecordingView(
        options: ComposerRecordingViewOptions
    ) -> some View {
        RecordingView(location: options.gestureLocation, audioRecordingInfo: options.viewModel.audioRecordingInfo) {
            options.viewModel.stopRecording()
        }
    }
    
    public func makeComposerRecordingLockedView(
        options: ComposerRecordingLockedViewOptions
    ) -> some View {
        LockedView(viewModel: options.viewModel)
    }
    
    public func makeComposerRecordingTipView(options: ComposerRecordingTipViewOptions) -> some View {
        RecordingTipView()
    }
    
    public func makeComposerViewModifier(options: ComposerViewModifierOptions) -> some ViewModifier {
        EmptyViewModifier()
    }
    
    public func makeAttachmentPickerView(
        options: AttachmentPickerViewOptions
    ) -> some View {
        AttachmentPickerView(
            viewFactory: self,
            selectedPickerState: options.attachmentPickerState,
            filePickerShown: options.filePickerShown,
            cameraPickerShown: options.cameraPickerShown,
            addedFileURLs: options.addedFileURLs,
            onPickerStateChange: options.onPickerStateChange,
            photoLibraryAssets: options.photoLibraryAssets,
            onAssetTap: options.onAssetTap,
            onCustomAttachmentTap: options.onCustomAttachmentTap,
            isAssetSelected: options.isAssetSelected,
            addedCustomAttachments: options.addedCustomAttachments,
            cameraImageAdded: options.cameraImageAdded,
            askForAssetsAccessPermissions: options.askForAssetsAccessPermissions,
            isDisplayed: options.isDisplayed,
            height: options.height
        )
        .offset(y: options.isDisplayed ? 0 : options.popupHeight)
        .animation(.spring())
    }
    
    public func makeVoiceRecordingView(
        options: VoiceRecordingViewOptions
    ) -> some View {
        VoiceRecordingContainerView(
            factory: self,
            message: options.message,
            width: options.availableWidth,
            isFirst: options.isFirst,
            scrolledId: options.scrolledId
        )
    }
    
    public func makeCustomAttachmentView(
        options: CustomComposerAttachmentViewOptions
    ) -> some View {
        EmptyView()
    }
    
    public func makeCustomAttachmentPreviewView(
        options: CustomAttachmentPreviewViewOptions
    ) -> some View {
        EmptyView()
    }
    
    public func makeAttachmentSourcePickerView(
        options: AttachmentSourcePickerViewOptions
    ) -> some View {
        AttachmentSourcePickerView(
            selected: options.selected,
            onTap: options.onPickerStateChange
        )
    }
    
    public func makePhotoAttachmentPickerView(
        options: PhotoAttachmentPickerViewOptions
    ) -> some View {
        AttachmentTypeContainer {
            PhotoAttachmentPickerView(
                assets: options.assets,
                onImageTap: options.onAssetTap,
                imageSelected: options.isAssetSelected
            )
        }
    }
    
    public func makeFilePickerView(
        options: FilePickerViewOptions
    ) -> some View {
        FilePickerDisplayView(
            filePickerShown: options.filePickerShown,
            addedFileURLs: options.addedFileURLs
        )
    }
    
    public func makeCameraPickerView(
        options: CameraPickerViewOptions
    ) -> some View {
        CameraPickerDisplayView(
            selectedPickerState: options.selected,
            cameraPickerShown: options.cameraPickerShown,
            cameraImageAdded: options.cameraImageAdded
        )
    }
    
    public func makeAssetsAccessPermissionView(options: AssetsAccessPermissionViewOptions) -> some View {
        AssetsAccessPermissionView()
    }
    
    public func makeSendInChannelView(
        options: SendInChannelViewOptions
    ) -> some View {
        SendInChannelView(
            sendInChannel: options.showReplyInChannel,
            isDirectMessage: options.isDirectMessage
        )
    }
    
    public func supportedMessageActions(
        options: SupportedMessageActionsOptions
    ) -> [MessageAction] {
        MessageAction.defaultActions(
            factory: self,
            for: options.message,
            channel: options.channel,
            chatClient: chatClient,
            onFinish: options.onFinish,
            onError: options.onError
        )
    }
    
    public func makeMessageActionsView(
        options: MessageActionsViewOptions
    ) -> some View {
        let messageActions = supportedMessageActions(
            options: SupportedMessageActionsOptions(
                message: options.message,
                channel: options.channel,
                onFinish: options.onFinish,
                onError: options.onError
            )
        )
        
        return MessageActionsView(messageActions: messageActions)
    }
    
    public func makeReactionsUsersView(
        options: ReactionsUsersViewOptions
    ) -> some View {
        ReactionsUsersView(
            message: options.message,
            maxHeight: options.maxHeight
        )
    }
    
    public func makeBottomReactionsView(
        options: ReactionsBottomViewOptions
    ) -> some View {
        BottomReactionsView(
            message: options.message,
            showsAllInfo: options.showsAllInfo,
            onTap: options.onTap,
            onLongPress: options.onLongPress
        )
        .id(options.message.reactionScoresId)
    }
    
    public func makeMessageReactionView(
        options: MessageReactionViewOptions
    ) -> some View {
        ReactionsContainer(
            message: options.message,
            onTapGesture: options.onTapGesture,
            onLongPressGesture: options.onLongPressGesture
        )
    }
    
    public func makeReactionsOverlayView(
        options: ReactionsOverlayViewOptions
    ) -> some View {
        ReactionsOverlayView(
            factory: self,
            channel: options.channel,
            currentSnapshot: options.currentSnapshot,
            messageDisplayInfo: options.messageDisplayInfo,
            onBackgroundTap: options.onBackgroundTap,
            onActionExecuted: options.onActionExecuted
        )
    }
    
    public func makeReactionsContentView(
        options: ReactionsContentViewOptions
    ) -> some View {
        ReactionsOverlayContainer(
            message: options.message,
            contentRect: options.contentRect,
            onReactionTap: options.onReactionTap
        )
    }
    
    public func makeReactionsBackgroundView(
        options: ReactionsBackgroundOptions
    ) -> some View {
        Image(uiImage: options.currentSnapshot)
            .overlay(Color.black.opacity(options.popInAnimationInProgress ? 0 : 0.1))
            .blur(radius: options.popInAnimationInProgress ? 0 : 4)
    }
    
    public func makeQuotedMessageHeaderView(
        options: QuotedMessageHeaderViewOptions
    ) -> some View {
        QuotedMessageHeaderView(quotedMessage: options.quotedMessage)
    }
    
    public func makeQuotedMessageView(
        options: QuotedMessageViewOptions
    ) -> some View {
        QuotedMessageViewContainer(
            factory: self,
            quotedMessage: options.quotedMessage,
            fillAvailableSpace: options.fillAvailableSpace,
            forceLeftToRight: options.isInComposer,
            scrolledId: options.scrolledId
        )
    }
    
    public func makeCustomAttachmentQuotedView(options: CustomAttachmentQuotedViewOptions) -> some View {
        EmptyView()
    }
    
    public func makeEditedMessageHeaderView(
        options: EditedMessageHeaderViewOptions
    ) -> some View {
        EditMessageHeaderView(editedMessage: options.editedMessage)
    }
    
    public func makeCommandsContainerView(
        options: CommandsContainerViewOptions
    ) -> some View {
        CommandsContainerView(
            suggestions: options.suggestions,
            handleCommand: options.handleCommand
        )
    }
    
    public func makeMessageReadIndicatorView(
        options: MessageReadIndicatorViewOptions
    ) -> some View {
        let readUsers = options.channel.readUsers(
            currentUserId: chatClient.currentUserId,
            message: options.message
        )
        let showReadCount = options.channel.memberCount > 2 && !options.message.isLastActionFailed
        return MessageReadIndicatorView(
            readUsers: readUsers,
            showReadCount: showReadCount,
            localState: options.message.localState
        )
    }
    
    public func makeNewMessagesIndicatorView(
        options: NewMessagesIndicatorViewOptions
    ) -> some View {
        NewMessagesIndicator(
            newMessagesStartId: options.newMessagesStartId,
            count: options.count
        )
    }
    
    public func makeJumpToUnreadButton(
        options: JumpToUnreadButtonOptions
    ) -> some View {
        VStack {
            JumpToUnreadButton(
                unreadCount: options.channel.unreadCount.messages,
                onTap: options.onJumpToMessage,
                onClose: options.onClose
            )
            .padding(.all, 8)

            Spacer()
        }
    }
    
    public func makeComposerPollView(
        options: ComposerPollViewOptions
    ) -> some View {
        ComposerPollView(channelController: options.channelController, messageController: options.messageController)
    }
    
    public func makePollView(options: PollViewOptions) -> some View {
        PollAttachmentView(factory: self, message: options.message, poll: options.poll, isFirst: options.isFirst)
    }

    // MARK: Threads

    public func makeThreadDestination(options: ThreadDestinationOptions) -> @MainActor(ChatThread) -> ChatChannelView<Self> {
        { [unowned self] thread in
            makeMessageThreadDestination(options: MessageThreadDestinationOptions())(thread.channel, thread.parentMessage)
        }
    }

    public func makeThreadListItem(
        options: ThreadListItemOptions<ThreadDestination>
    ) -> some View {
        let utils = InjectedValues[\.utils]
        return ChatThreadListNavigatableItem(
            thread: options.thread,
            threadListItem: ChatThreadListItem(
                viewModel: .init(thread: options.thread)
            ),
            threadDestination: options.threadDestination,
            selectedThread: options.selectedThread,
            handleTabBarVisibility: utils.messageListConfig.handleTabBarVisibility
        )
    }

    public func makeNoThreadsView(options: NoThreadsViewOptions) -> some View {
        NoThreadsView()
    }

    public func makeThreadsListErrorBannerView(options: ThreadListErrorBannerViewOptions) -> some View {
        ChatThreadListErrorBannerView(action: options.onRefreshAction)
    }

    public func makeThreadListLoadingView(options: ThreadListLoadingViewOptions) -> some View {
        ChatThreadListLoadingView()
    }

    public func makeThreadListContainerViewModifier(options: ThreadListContainerModifierOptions) -> some ViewModifier {
        EmptyViewModifier()
    }

    public func makeThreadListHeaderViewModifier(options: ThreadListHeaderViewModifierOptions) -> some ViewModifier {
        ChatThreadListHeaderViewModifier(title: options.title)
    }

    public func makeThreadListHeaderView(options: ThreadListHeaderViewOptions) -> some View {
        ChatThreadListHeaderView(viewModel: options.viewModel)
    }

    public func makeThreadListFooterView(options: ThreadListFooterViewOptions) -> some View {
        ChatThreadListFooterView(viewModel: options.viewModel)
    }

    public func makeThreadListBackground(options: ThreadListBackgroundOptions) -> some View {
        Color(options.colors.background)
            .edgesIgnoringSafeArea(.bottom)
    }

    public func makeThreadListItemBackground(
        options: ThreadListItemBackgroundOptions
    ) -> some View {
        let colors = InjectedValues[\.colors]
        if options.isSelected && isIPad {
            return Color(colors.background6)
        }

        return Color(colors.background)
    }

    public func makeThreadListDividerItem(options: ThreadListDividerItemOptions) -> some View {
        Divider()
    }
    
    public func makeAddUsersView(
        options: AddUsersViewOptions
    ) -> some View {
        AddUsersView(loadedUserIds: options.options.loadedUsers.map(\.id), onUserTap: options.onUserTap)
    }
}

/// Default class conforming to `ViewFactory`, used throughout the SDK.
public class DefaultViewFactory: ViewFactory {
    @Injected(\.chatClient) public var chatClient
        
    private init() {
        // Private init.
    }
    
    public static let shared = DefaultViewFactory()
}
