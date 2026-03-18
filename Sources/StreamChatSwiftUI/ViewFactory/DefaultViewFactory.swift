//
// Copyright © 2026 Stream.io Inc. All rights reserved.
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
    
    public func makeMoreChannelActionsView(
        options: MoreChannelActionsViewOptions
    ) -> some View {
        MoreChannelActionsView(
            factory: self,
            channel: options.channel,
            channelActions: InjectedValues[\.utils].channelListConfig.supportedMoreChannelActions(
                SupportedMoreChannelActionsOptions(
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
        options: ChannelAvatarViewOptions
    ) -> some View {
        ChannelAvatar(
            channel: options.channel,
            size: options.size
        )
    }
    
    public func makeChannelListBackground(options: ChannelListBackgroundOptions) -> some View {
        Color(InjectedValues[\.colors].background)
            .edgesIgnoringSafeArea(.bottom)
    }

    public func makeChannelListItemBackground(
        options: ChannelListItemBackgroundOptions
    ) -> some View {
        let colors = InjectedValues[\.colors]
        return Color(colors.backgroundElevationElevation0)
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
        EmptyView()
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
            channelNaming: options.channelNaming,
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
            channelName: options.channelName,
            onSearchResultTap: options.onSearchResultTap,
            channelDestination: options.channelDestination
        )
    }
    
    // MARK: messages
    
    public func makeChannelDestination(options: ChannelDestinationOptions) -> @MainActor (ChannelSelectionInfo) -> ChatChannelView<Self> {
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
    
    public func makeMessageThreadDestination(options: MessageThreadDestinationOptions) -> @MainActor (ChatChannel, ChatMessage) -> ChatChannelView<Self> {
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

    public func makeEmptyMessagesView(
        options: EmptyMessagesViewOptions
    ) -> some View {
        Color(InjectedValues[\.colors].background)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityIdentifier("EmptyMessagesView")
    }
    
    public func makeUserAvatarView(options: UserAvatarViewOptions) -> some View {
        UserAvatar(
            user: options.user,
            size: options.size,
            showsIndicator: options.showsIndicator
        )
    }
        
    public func makeChannelHeaderViewModifier(
        options: ChannelHeaderViewModifierOptions
    ) -> some ChatChannelHeaderViewModifier {
        DefaultChannelHeaderModifier(
            factory: self,
            channel: options.channel,
            shouldShowTypingIndicator: options.shouldShowTypingIndicator
        )
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
        Color(InjectedValues[\.colors].backgroundCoreApp)
    }
    
    public func makeMessageItemView(
        options: MessageItemViewOptions
    ) -> some View {
        MessageItemView(
            factory: self,
            channel: options.channel,
            message: options.message,
            width: options.width,
            showsAllInfo: options.showsAllInfo,
            shownAsPreview: options.shownAsPreview,
            isInThread: options.isInThread,
            isLast: options.isLast,
            scrolledId: options.scrolledId,
            quotedMessage: options.quotedMessage,
            onLongPress: options.onLongPress,
            viewModel: options.viewModel
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
        MessageDateView(message: options.message, usesInvertedStyle: options.usesInvertedStyle)
    }
    
    public func makeMessageAuthorAndDateView(options: MessageAuthorAndDateViewOptions) -> some View {
        MessageAuthorAndDateView(message: options.message, usesInvertedStyle: options.usesInvertedStyle)
    }
    
    public func makeLastInGroupHeaderView(options: LastInGroupHeaderViewOptions) -> some View {
        EmptyView()
    }

    public func makeMessageTopView(
        options: MessageTopViewOptions
    ) -> some View {
        MessageTopView(
            message: options.message,
            channel: options.channel,
            messageViewModel: options.messageViewModel,
            usesInvertedStyle: options.usesInvertedStyle
        )
    }

    public func makeMessageAttachmentsView(
        options: MessageAttachmentsViewOptions
    ) -> some View {
        MessageAttachmentsView(
            factory: self,
            message: options.message,
            width: options.availableWidth,
            isFirst: options.isFirst,
            scrolledId: options.scrolledId
        )
    }

    public func makeImageAttachmentView(
        options: ImageAttachmentViewOptions
    ) -> some View {
        MessageMediaAttachmentsContainerView(
            factory: self,
            message: options.message,
            width: options.availableWidth
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
        MessageMediaAttachmentsContainerView(
            factory: self,
            message: options.message,
            width: options.availableWidth
        )
    }
    
    public func makeMediaViewer(
        options: MediaViewerOptions
    ) -> some View {
        MediaViewer(
            viewFactory: self,
            mediaAttachments: options.mediaAttachments,
            author: options.message.author,
            isShown: options.isShown,
            selected: options.options.selectedIndex,
            message: options.message
        )
    }
    
    public func makeMediaViewerHeader(
        options: MediaViewerHeaderOptions
    ) -> some View {
        MediaViewerHeader(title: options.title, subtitle: options.subtitle, isShown: options.shown)
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
        MediaViewerHeader(title: options.title, subtitle: options.subtitle, isShown: options.shown)
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
            factory: self,
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
    
    public func makeInlineTypingIndicatorView(
        options: TypingIndicatorViewOptions
    ) -> some View {
        let users = Array(options.channel.currentlyTypingUsersFiltered(currentUserId: options.currentUserId))
        let typingText = options.channel.typingIndicatorString(currentUserId: options.currentUserId)
        return TypingIndicatorView(users: users, typingText: typingText)
    }
    
    public func makeSubtitleTypingIndicatorView(
        options: SubtitleTypingIndicatorViewOptions
    ) -> some View {
        SubtitleTypingIndicatorView(channel: options.channel)
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
            replyCount: options.replyCount,
            usesInvertedStyle: options.usesInvertedStyle
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
        LeadingComposerView(
            factory: self,
            pickerTypeState: options.state,
            channelConfig: options.channelConfig,
            isCommandActive: options.isCommandActive
        )
    }
    
    @ViewBuilder
    public func makeComposerInputView(
        options: ComposerInputViewOptions
    ) -> some View {
        ComposerInputView(
            factory: self,
            channelController: options.channelController,
            text: options.text,
            selectedRangeLocation: options.selectedRangeLocation,
            command: options.command,
            recordingState: options.recordingState,
            recordingGestureLocation: options.recordingGestureLocation,
            composerAssets: options.composerAssets,
            addedCustomAttachments: options.addedCustomAttachments,
            addedVoiceRecordings: options.addedVoiceRecordings,
            quotedMessage: options.quotedMessage,
            editedMessage: options.editedMessage,
            maxMessageLength: options.maxMessageLength,
            cooldownDuration: options.cooldownDuration,
            hasContent: options.hasContent,
            canSendMessage: options.canSendMessage,
            audioRecordingInfo: options.audioRecordingInfo,
            pendingAudioRecordingURL: options.pendingAudioRecordingURL,
            onCustomAttachmentTap: options.onCustomAttachmentTap,
            removeAttachmentWithId: options.removeAttachmentWithId,
            sendMessage: options.sendMessage,
            onImagePasted: options.onImagePasted,
            startRecording: options.startRecording,
            stopRecording: options.stopRecording,
            confirmRecording: options.confirmRecording,
            discardRecording: options.discardRecording,
            previewRecording: options.previewRecording,
            showRecordingTip: options.showRecordingTip,
            sendInChannelShown: options.sendInChannelShown,
            showReplyInChannel: options.showReplyInChannel
        )
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
            currentHeight: options.currentHeight,
            onImagePasted: options.onImagePasted
        )
    }
    
    public func makeComposerInputTrailingView(
        options: ComposerInputTrailingViewOptions
    ) -> some View {
        TrailingInputComposerView(
            factory: self,
            text: options.$text,
            recordingState: options.$recordingState,
            composerInputState: options.composerInputState,
            startRecording: options.startRecording,
            stopRecording: options.stopRecording,
            showRecordingTip: options.showRecordingTip,
            sendMessage: options.sendMessage
        )
    }
    
    public func makeTrailingComposerView(
        options: TrailingComposerViewOptions
    ) -> some View {
        EmptyView()
            .opacity(0)
            .hidden()
    }

    public func makeSendMessageButton(
        options: SendMessageButtonOptions
    ) -> some View {
        SendMessageButton(
            enabled: options.enabled,
            onTap: options.onTap
        )
    }

    public func makeConfirmEditButton(
        options: ConfirmEditButtonOptions
    ) -> some View {
        ConfirmEditButton(
            enabled: options.enabled,
            onTap: options.onTap
        )
    }
    
    public func makeComposerVoiceRecordingInputView(
        options: ComposerVoiceRecordingInputViewOptions
    ) -> some View {
        ComposerVoiceRecordingInputView(
            factory: self,
            recordingState: options.recordingState,
            audioRecordingInfo: options.audioRecordingInfo,
            pendingAudioRecordingURL: options.pendingAudioRecordingURL,
            gestureLocation: options.gestureLocation,
            stopRecording: options.stopRecording,
            confirmRecording: options.confirmRecording,
            discardRecording: options.discardRecording,
            previewRecording: options.previewRecording
        )
    }
    
    public func makeAttachmentPickerView(
        options: AttachmentPickerViewOptions
    ) -> some View {
        AttachmentPickerView(
            viewFactory: self,
            selectedPickerState: options.attachmentPickerState,
            filePickerShown: options.filePickerShown,
            cameraPickerShown: options.cameraPickerShown,
            onFilesPicked: options.onFilesPicked,
            onPickerStateChange: options.onPickerStateChange,
            photoLibraryAssets: options.photoLibraryAssets,
            onAssetTap: options.onAssetTap,
            onCustomAttachmentTap: options.onCustomAttachmentTap,
            isAssetSelected: options.isAssetSelected,
            addedCustomAttachments: options.addedCustomAttachments,
            cameraImageAdded: options.cameraImageAdded,
            askForAssetsAccessPermissions: options.askForAssetsAccessPermissions,
            isDisplayed: options.isDisplayed,
            height: options.height,
            selectedAssetIds: options.selectedAssetIds,
            channelController: options.channelController,
            messageController: options.messageController,
            canSendPoll: options.canSendPoll,
            instantCommands: options.instantCommands,
            onCommandSelected: options.onCommandSelected
        )
    }

    public func makeAttachmentCommandsPickerView(
        options: AttachmentCommandsPickerViewOptions
    ) -> some View {
        AttachmentCommandsPickerView(
            instantCommands: options.instantCommands,
            onCommandSelected: options.onCommandSelected
        )
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
    
    public func makeCustomAttachmentPickerView(
        options: CustomAttachmentPickerViewOptions
    ) -> some View {
        EmptyView()
    }
    
    public func makeCustomAttachmentPreviewView(
        options: CustomAttachmentPreviewViewOptions
    ) -> some View {
        EmptyView()
    }
    
    public func makeAttachmentTypePickerView(
        options: AttachmentTypePickerViewOptions
    ) -> some View {
        AttachmentTypePickerView(
            selected: options.selected,
            canSendPoll: options.canSendPoll,
            onTap: options.onPickerStateChange
        )
    }
    
    public func makeAttachmentMediaPickerView(
        options: AttachmentMediaPickerViewOptions
    ) -> some View {
        AttachmentMediaPickerView(
            photoLibraryAssets: options.photoLibraryAssets,
            onImageTap: options.onAssetTap,
            imageSelected: options.isAssetSelected,
            selectedAssetIds: options.selectedAssetIds
        )
    }
    
    public func makeAttachmentFilePickerView(
        options: AttachmentFilePickerViewOptions
    ) -> some View {
        AttachmentFilePickerView(
            filePickerShown: options.filePickerShown,
            onFilesPicked: options.onFilesPicked
        )
    }
    
    public func makeAttachmentCameraPickerView(
        options: AttachmentCameraPickerViewOptions
    ) -> some View {
        AttachmentCameraPickerView(
            cameraPickerShown: options.cameraPickerShown,
            cameraImageAdded: options.cameraImageAdded
        )
    }

    public func makeAttachmentPollPickerView(options: AttachmentPollPickerViewOptions) -> some View {
        AttachmentPollPickerView(
            channelController: options.channelController,
            messageController: options.messageController
        )
    }
    
    public func makeSendInChannelView(
        options: SendInChannelViewOptions
    ) -> some View {
        SendInChannelView(
            sendInChannel: options.showReplyInChannel
        )
    }
    
    public func makeMessageActionsView(
        options: MessageActionsViewOptions
    ) -> some View {
        let messageActions = InjectedValues[\.utils].messageListConfig.supportedMessageActions(
            SupportedMessageActionsOptions(
                message: options.message,
                channel: options.channel,
                onFinish: options.onFinish,
                onError: options.onError
            )
        )
        
        return MessageActionsView(messageActions: messageActions)
    }
    
    public func makeBottomReactionsView(
        options: ReactionsBottomViewOptions
    ) -> some View {
        ReactionsContainer(
            message: options.message,
            topPlacement: false,
            onTapGesture: options.onTap,
            onLongPressGesture: options.onLongPress
        )
    }
    
    public func makeMessageReactionView(
        options: MessageReactionViewOptions
    ) -> some View {
        ReactionsContainer(
            message: options.message,
            topPlacement: true,
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
            onReactionTap: options.onReactionTap,
            onMoreReactionsTap: options.onMoreReactionsTap
        )
    }
    
    public func makeReactionsBackgroundView(
        options: ReactionsBackgroundOptions
    ) -> some View {
        Image(uiImage: options.currentSnapshot)
            .overlay(Color.black.opacity(options.popInAnimationInProgress ? 0 : 0.1))
            .blur(radius: options.popInAnimationInProgress ? 0 : 4)
    }
    
    public func makeMoreReactionsView(options: MoreReactionsViewOptions) -> some View {
        MoreReactionsView(onEmojiTap: options.onEmojiTap)
    }

    public func makeReactionsDetailView(options: ReactionsDetailViewOptions) -> some View {
        ReactionsDetailView(message: options.message)
    }

    public func makeComposerQuotedMessageView(
        options: ComposerQuotedMessageViewOptions
    ) -> some View {
        ComposerQuotedMessageView(
            factory: self,
            quotedMessage: options.quotedMessage,
            onDismiss: options.onDismiss
        )
    }

    public func makeChatQuotedMessageView(
        options: ChatQuotedMessageViewOptions
    ) -> some View {
        ChatQuotedMessageView(
            factory: self,
            quotedMessage: options.quotedMessage,
            parentMessage: options.parentMessage,
            availableWidth: options.availableWidth,
            scrolledId: options.scrolledId
        )
    }

    public func makeQuotedMessageView(
        options: QuotedMessageViewOptions
    ) -> some View {
        QuotedMessageView(
            factory: self,
            viewModel: QuotedMessageViewModel(
                message: options.quotedMessage,
                currentUser: chatClient.currentUserController().currentUser,
                outgoing: options.outgoing
            ),
            padding: options.padding
        )
    }

    public func makeComposerEditedMessageView(
        options: ComposerEditedMessageViewOptions
    ) -> some View {
        EditedMessageView(
            factory: self,
            viewModel: EditedMessageViewModel(
                message: options.editedMessage
            ),
            onDismiss: options.onDismiss
        )
    }

    public func makeMessageAttachmentPreviewThumbnailView(
        options: MessageAttachmentPreviewViewOptions
    ) -> some View {
        MessageAttachmentPreviewThumbnailView(thumbnail: options.thumbnail)
    }

    public func makeMessageAttachmentPreviewIconView(
        options: MessageAttachmentPreviewIconViewOptions
    ) -> some View {
        MessageAttachmentPreviewIconView(
            iconImage: InjectedValues[\.utils].messageAttachmentPreviewIconProvider.image(for: options.icon)
        )
    }
    
    public func makeSuggestionsContainerView(
        options: SuggestionsContainerViewOptions
    ) -> some View {
        SuggestionsContainerView(
            factory: self,
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
        return MessageReadIndicatorView(
            readUsers: readUsers,
            localState: options.message.localState,
            usesInvertedStyle: options.usesInvertedStyle
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

    public func makeThreadDestination(options: ThreadDestinationOptions) -> @MainActor (ChatThread) -> ChatChannelView<Self> {
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
        Color(options.colors.backgroundElevationElevation1)
            .edgesIgnoringSafeArea(.bottom)
    }

    public func makeThreadListItemBackground(
        options: ThreadListItemBackgroundOptions
    ) -> some View {
        let colors = InjectedValues[\.colors]
        return Color(colors.backgroundElevationElevation1)
    }

    public func makeThreadListDividerItem(options: ThreadListDividerItemOptions) -> some View {
        Divider()
    }
    
    public func makeAddUsersView(
        options: AddUsersViewOptions
    ) -> some View {
        AddUsersView(loadedUserIds: options.options.loadedUserIds, onConfirm: options.onConfirm)
    }
    
    public func makeAttachmentTextView(
        options: AttachmentTextViewOptions
    ) -> some View {
        AttachmentTextView(factory: self, message: options.message)
    }

    public func makeStreamTextView(
        options: StreamTextViewOptions
    ) -> some View {
        StreamTextView(message: options.message)
    }
}

/// Default class conforming to `ViewFactory`, used throughout the SDK.
public class DefaultViewFactory: ViewFactory {
    @Injected(\.chatClient) public var chatClient
    
    public var styles = RegularStyles()
        
    private init() {
        // Private init.
    }
    
    public static let shared = DefaultViewFactory()
}
