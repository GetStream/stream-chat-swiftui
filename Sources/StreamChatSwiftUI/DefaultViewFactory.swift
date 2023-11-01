//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import Photos
import StreamChat
import SwiftUI

/// Default implementations for the `ViewFactory`.
extension ViewFactory {
    // MARK: channels
    
    public func makeNoChannelsView() -> some View {
        NoChannelsView()
    }
    
    public func makeLoadingView() -> some View {
        RedactedLoadingView(factory: self)
    }
    
    public func navigationBarDisplayMode() -> NavigationBarItem.TitleDisplayMode {
        .inline
    }
    
    public func makeChannelListHeaderViewModifier(
        title: String
    ) -> some ChannelListHeaderViewModifier {
        DefaultChannelListHeaderModifier(title: title)
    }
    
    public func supportedMoreChannelActions(
        for channel: ChatChannel,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> [ChannelAction] {
        ChannelAction.defaultActions(
            for: channel,
            chatClient: chatClient,
            onDismiss: onDismiss,
            onError: onError
        )
    }
    
    public func makeMoreChannelActionsView(
        for channel: ChatChannel,
        swipedChannelId: Binding<String?>,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> some View {
        MoreChannelActionsView(
            channel: channel,
            channelActions: supportedMoreChannelActions(
                for: channel,
                onDismiss: onDismiss,
                onError: onError
            ),
            swipedChannelId: swipedChannelId,
            onDismiss: onDismiss
        )
    }
    
    public func makeChannelListItem(
        channel: ChatChannel,
        channelName: String,
        avatar: UIImage,
        onlineIndicatorShown: Bool,
        disabled: Bool,
        selectedChannel: Binding<ChannelSelectionInfo?>,
        swipedChannelId: Binding<String?>,
        channelDestination: @escaping (ChannelSelectionInfo) -> ChannelDestination,
        onItemTap: @escaping (ChatChannel) -> Void,
        trailingSwipeRightButtonTapped: @escaping (ChatChannel) -> Void,
        trailingSwipeLeftButtonTapped: @escaping (ChatChannel) -> Void,
        leadingSwipeButtonTapped: @escaping (ChatChannel) -> Void
    ) -> some View {
        let listItem = ChatChannelNavigatableListItem(
            channel: channel,
            channelName: channelName,
            avatar: avatar,
            onlineIndicatorShown: onlineIndicatorShown,
            disabled: disabled,
            selectedChannel: selectedChannel,
            channelDestination: channelDestination,
            onItemTap: onItemTap
        )
        return ChatChannelSwipeableListItem(
            factory: self,
            channelListItem: listItem,
            swipedChannelId: swipedChannelId,
            channel: channel,
            numberOfTrailingItems: channel.ownCapabilities.contains(.deleteChannel) ? 2 : 1,
            trailingRightButtonTapped: trailingSwipeRightButtonTapped,
            trailingLeftButtonTapped: trailingSwipeLeftButtonTapped,
            leadingSwipeButtonTapped: leadingSwipeButtonTapped
        )
    }
    
    public func makeChannelListBackground(colors: ColorPalette) -> some View {
        Color(colors.background)
            .edgesIgnoringSafeArea(.bottom)
    }
    
    public func makeChannelListDividerItem() -> some View {
        Divider()
    }
    
    public func makeTrailingSwipeActionsView(
        channel: ChatChannel,
        offsetX: CGFloat,
        buttonWidth: CGFloat,
        swipedChannelId: Binding<String?>,
        leftButtonTapped: @escaping (ChatChannel) -> Void,
        rightButtonTapped: @escaping (ChatChannel) -> Void
    ) -> some View {
        TrailingSwipeActionsView(
            channel: channel,
            offsetX: offsetX,
            buttonWidth: buttonWidth,
            leftButtonTapped: leftButtonTapped,
            rightButtonTapped: rightButtonTapped
        )
    }
    
    public func makeLeadingSwipeActionsView(
        channel: ChatChannel,
        offsetX: CGFloat,
        buttonWidth: CGFloat,
        swipedChannelId: Binding<String?>,
        buttonTapped: (ChatChannel) -> Void
    ) -> some View {
        EmptyView()
    }
    
    public func makeChannelListTopView(
        searchText: Binding<String>
    ) -> some View {
        SearchBar(text: searchText)
    }
    
    public func makeChannelListFooterView() -> some View {
        EmptyView()
    }
    
    public func makeChannelListStickyFooterView() -> some View {
        EmptyView()
    }
    
    public func makeChannelListSearchResultItem(
        searchResult: ChannelSelectionInfo,
        onlineIndicatorShown: Bool,
        channelName: String,
        avatar: UIImage,
        onSearchResultTap: @escaping (ChannelSelectionInfo) -> Void,
        channelDestination: @escaping (ChannelSelectionInfo) -> ChannelDestination
    ) -> some View {
        SearchResultItem(
            searchResult: searchResult,
            onlineIndicatorShown: onlineIndicatorShown,
            channelName: channelName,
            avatar: avatar,
            onSearchResultTap: onSearchResultTap,
            channelDestination: channelDestination
        )
    }
    
    public func makeChannelListContentModifier() -> some ViewModifier {
        EmptyViewModifier()
    }
    
    public func makeChannelListModifier() -> some ViewModifier {
        EmptyViewModifier()
    }
    
    // MARK: messages
    
    public func makeChannelDestination() -> (ChannelSelectionInfo) -> ChatChannelView<Self> {
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
    
    public func makeMessageThreadDestination() -> (ChatChannel, ChatMessage) -> ChatChannelView<Self> {
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
                messageController: messageController
            )
        }
    }
    
    public func makeMessageListModifier() -> some ViewModifier {
        EmptyViewModifier()
    }
    
    public func makeMessageListContainerModifier() -> some ViewModifier {
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
    
    public func makeEmptyMessagesView(
        for channel: ChatChannel,
        colors: ColorPalette
    ) -> some View {
        Color(colors.background)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityIdentifier("EmptyMessagesView")
    }
    
    public func makeMessageAvatarView(for userDisplayInfo: UserDisplayInfo) -> some View {
        MessageAvatarView(avatarURL: userDisplayInfo.imageURL)
    }
    
    public func makeQuotedMessageAvatarView(
        for userDisplayInfo: UserDisplayInfo,
        size: CGSize
    ) -> some View {
        MessageAvatarView(avatarURL: userDisplayInfo.imageURL, size: size)
    }
    
    public func makeChannelHeaderViewModifier(
        for channel: ChatChannel
    ) -> some ChatChannelHeaderViewModifier {
        DefaultChannelHeaderModifier(channel: channel)
    }
    
    public func makeMessageThreadHeaderViewModifier() -> some MessageThreadHeaderViewModifier {
        DefaultMessageThreadHeaderModifier()
    }
    
    public func makeMessageListBackground(
        colors: ColorPalette,
        isInThread: Bool
    ) -> some View {
        Color(colors.background)
    }
    
    public func makeMessageContainerView(
        channel: ChatChannel,
        message: ChatMessage,
        width: CGFloat?,
        showsAllInfo: Bool,
        isInThread: Bool,
        scrolledId: Binding<String?>,
        quotedMessage: Binding<ChatMessage?>,
        onLongPress: @escaping (MessageDisplayInfo) -> Void,
        isLast: Bool
    ) -> some View {
        MessageContainerView(
            factory: self,
            channel: channel,
            message: message,
            width: width,
            showsAllInfo: showsAllInfo,
            isInThread: isInThread,
            isLast: isLast,
            scrolledId: scrolledId,
            quotedMessage: quotedMessage,
            onLongPress: onLongPress
        )
    }
    
    public func makeMessageTextView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) -> some View {
        MessageTextView(
            factory: self,
            message: message,
            isFirst: isFirst,
            scrolledId: scrolledId
        )
    }
    
    public func makeMessageDateView(for message: ChatMessage) -> some View {
        MessageDateView(message: message)
    }
    
    public func makeMessageAuthorAndDateView(for message: ChatMessage) -> some View {
        MessageAuthorAndDateView(message: message)
    }
    
    public func makeLastInGroupHeaderView(for message: ChatMessage) -> some View {
        EmptyView()
    }
    
    public func makeImageAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) -> some View {
        ImageAttachmentContainer(
            factory: self,
            message: message,
            width: availableWidth,
            isFirst: isFirst,
            scrolledId: scrolledId
        )
    }
    
    public func makeGiphyAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) -> some View {
        GiphyAttachmentView(
            factory: self,
            message: message,
            width: availableWidth,
            isFirst: isFirst,
            scrolledId: scrolledId
        )
    }
    
    public func makeLinkAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) -> some View {
        LinkAttachmentContainer(
            factory: self,
            message: message,
            width: availableWidth,
            isFirst: isFirst,
            scrolledId: scrolledId
        )
    }
    
    public func makeFileAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) -> some View {
        FileAttachmentsContainer(
            factory: self,
            message: message,
            width: availableWidth,
            isFirst: isFirst,
            scrolledId: scrolledId
        )
    }
    
    public func makeVideoAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) -> some View {
        VideoAttachmentsContainer(
            factory: self,
            message: message,
            width: availableWidth,
            scrolledId: scrolledId
        )
    }
    
    public func makeDeletedMessageView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> some View {
        DeletedMessageView(
            message: message,
            isFirst: isFirst
        )
    }
    
    public func makeSystemMessageView(
        message: ChatMessage
    ) -> some View {
        SystemMessageView(message: message.text)
    }
    
    public func makeEmojiTextView(
        message: ChatMessage,
        scrolledId: Binding<String?>,
        isFirst: Bool
    ) -> some View {
        EmojiTextView(
            factory: self,
            message: message,
            scrolledId: scrolledId,
            isFirst: isFirst
        )
    }
    
    public func makeCustomAttachmentViewType(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) -> some View {
        EmptyView()
    }
    
    public func makeScrollToBottomButton(
        unreadCount: Int,
        onScrollToBottom: @escaping () -> Void
    ) -> some View {
        ScrollToBottomButton(
            unreadCount: unreadCount,
            onScrollToBottom: onScrollToBottom
        )
    }
    
    public func makeDateIndicatorView(dateString: String) -> some View {
        DateIndicatorView(dateString: dateString)
    }
    
    public func makeMessageListDateIndicator(date: Date) -> some View {
        DateIndicatorView(date: date)
    }
    
    public func makeTypingIndicatorBottomView(
        channel: ChatChannel,
        currentUserId: UserId?
    ) -> some View {
        let typingIndicatorString = channel.typingIndicatorString(currentUserId: currentUserId)
        return TypingIndicatorBottomView(typingIndicatorString: typingIndicatorString)
    }
    
    public func makeGiphyBadgeViewType(
        for message: ChatMessage,
        availableWidth: CGFloat
    ) -> some View {
        GiphyBadgeView()
    }
    
    public func makeMessageRepliesView(
        channel: ChatChannel,
        message: ChatMessage,
        replyCount: Int
    ) -> some View {
        MessageRepliesView(
            factory: self,
            channel: channel,
            message: message,
            replyCount: replyCount
        )
    }
    
    public func makeMessageComposerViewType(
        with channelController: ChatChannelController,
        messageController: ChatMessageController?,
        quotedMessage: Binding<ChatMessage?>,
        editedMessage: Binding<ChatMessage?>,
        onMessageSent: @escaping () -> Void
    ) -> MessageComposerView<Self> {
        MessageComposerView(
            viewFactory: self,
            channelController: channelController,
            messageController: messageController,
            quotedMessage: quotedMessage,
            editedMessage: editedMessage,
            onMessageSent: onMessageSent
        )
    }
    
    public func makeLeadingComposerView(
        state: Binding<PickerTypeState>,
        channelConfig: ChannelConfig?
    ) -> some View {
        AttachmentPickerTypeView(
            pickerTypeState: state,
            channelConfig: channelConfig
        )
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    public func makeComposerInputView(
        text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        command: Binding<ComposerCommand?>,
        addedAssets: [AddedAsset],
        addedFileURLs: [URL],
        addedCustomAttachments: [CustomAttachment],
        quotedMessage: Binding<ChatMessage?>,
        maxMessageLength: Int?,
        cooldownDuration: Int,
        onCustomAttachmentTap: @escaping (CustomAttachment) -> Void,
        shouldScroll: Bool,
        removeAttachmentWithId: @escaping (String) -> Void
    ) -> some View {
        if shouldScroll {
            ScrollView {
                ComposerInputView(
                    factory: self,
                    text: text,
                    selectedRangeLocation: selectedRangeLocation,
                    command: command,
                    addedAssets: addedAssets,
                    addedFileURLs: addedFileURLs,
                    addedCustomAttachments: addedCustomAttachments,
                    quotedMessage: quotedMessage,
                    maxMessageLength: maxMessageLength,
                    cooldownDuration: cooldownDuration,
                    onCustomAttachmentTap: onCustomAttachmentTap,
                    removeAttachmentWithId: removeAttachmentWithId
                )
            }
            .frame(height: 240)
        } else {
            ComposerInputView(
                factory: self,
                text: text,
                selectedRangeLocation: selectedRangeLocation,
                command: command,
                addedAssets: addedAssets,
                addedFileURLs: addedFileURLs,
                addedCustomAttachments: addedCustomAttachments,
                quotedMessage: quotedMessage,
                maxMessageLength: maxMessageLength,
                cooldownDuration: cooldownDuration,
                onCustomAttachmentTap: onCustomAttachmentTap,
                removeAttachmentWithId: removeAttachmentWithId
            )
        }
    }
    
    public func makeComposerTextInputView(
        text: Binding<String>,
        height: Binding<CGFloat>,
        selectedRangeLocation: Binding<Int>,
        placeholder: String,
        editable: Bool,
        maxMessageLength: Int?,
        currentHeight: CGFloat
    ) -> some View {
        ComposerTextInputView(
            text: text,
            height: height,
            selectedRangeLocation: selectedRangeLocation,
            placeholder: placeholder,
            editable: editable,
            maxMessageLength: maxMessageLength,
            currentHeight: currentHeight
        )
    }
    
    public func makeTrailingComposerView(
        enabled: Bool,
        cooldownDuration: Int,
        onTap: @escaping () -> Void
    ) -> some View {
        Group {
            if cooldownDuration == 0 {
                SendMessageButton(
                    enabled: enabled,
                    onTap: onTap
                )
                .padding(.bottom, 8)
            } else {
                SlowModeView(
                    cooldownDuration: cooldownDuration
                )
            }
        }
    }
    
    public func makeComposerViewModifier() -> some ViewModifier {
        EmptyViewModifier()
    }
    
    public func makeAttachmentPickerView(
        attachmentPickerState: Binding<AttachmentPickerState>,
        filePickerShown: Binding<Bool>,
        cameraPickerShown: Binding<Bool>,
        addedFileURLs: Binding<[URL]>,
        onPickerStateChange: @escaping (AttachmentPickerState) -> Void,
        photoLibraryAssets: PHFetchResult<PHAsset>?,
        onAssetTap: @escaping (AddedAsset) -> Void,
        onCustomAttachmentTap: @escaping (CustomAttachment) -> Void,
        isAssetSelected: @escaping (String) -> Bool,
        addedCustomAttachments: [CustomAttachment],
        cameraImageAdded: @escaping (AddedAsset) -> Void,
        askForAssetsAccessPermissions: @escaping () -> Void,
        isDisplayed: Bool,
        height: CGFloat,
        popupHeight: CGFloat
    ) -> some View {
        AttachmentPickerView(
            viewFactory: self,
            selectedPickerState: attachmentPickerState,
            filePickerShown: filePickerShown,
            cameraPickerShown: cameraPickerShown,
            addedFileURLs: addedFileURLs,
            onPickerStateChange: onPickerStateChange,
            photoLibraryAssets: photoLibraryAssets,
            onAssetTap: onAssetTap,
            onCustomAttachmentTap: onCustomAttachmentTap,
            isAssetSelected: isAssetSelected,
            addedCustomAttachments: addedCustomAttachments,
            cameraImageAdded: cameraImageAdded,
            askForAssetsAccessPermissions: askForAssetsAccessPermissions,
            isDisplayed: isDisplayed,
            height: height
        )
        .offset(y: isDisplayed ? 0 : popupHeight)
        .animation(.spring())
    }
    
    public func makeCustomAttachmentView(
        addedCustomAttachments: [CustomAttachment],
        onCustomAttachmentTap: @escaping (CustomAttachment) -> Void
    ) -> some View {
        EmptyView()
    }
    
    public func makeCustomAttachmentPreviewView(
        addedCustomAttachments: [CustomAttachment],
        onCustomAttachmentTap: @escaping (CustomAttachment) -> Void
    ) -> some View {
        EmptyView()
    }
    
    public func makeAttachmentSourcePickerView(
        selected: AttachmentPickerState,
        onPickerStateChange: @escaping (AttachmentPickerState) -> Void
    ) -> some View {
        AttachmentSourcePickerView(
            selected: selected,
            onTap: onPickerStateChange
        )
    }
    
    public func makePhotoAttachmentPickerView(
        assets: PHFetchResultCollection,
        onAssetTap: @escaping (AddedAsset) -> Void,
        isAssetSelected: @escaping (String) -> Bool
    ) -> some View {
        AttachmentTypeContainer {
            PhotoAttachmentPickerView(
                assets: assets,
                onImageTap: onAssetTap,
                imageSelected: isAssetSelected
            )
        }
    }
    
    public func makeFilePickerView(
        filePickerShown: Binding<Bool>,
        addedFileURLs: Binding<[URL]>
    ) -> some View {
        FilePickerDisplayView(
            filePickerShown: filePickerShown,
            addedFileURLs: addedFileURLs
        )
    }
    
    public func makeCameraPickerView(
        selected: Binding<AttachmentPickerState>,
        cameraPickerShown: Binding<Bool>,
        cameraImageAdded: @escaping (AddedAsset) -> Void
    ) -> some View {
        CameraPickerDisplayView(
            selectedPickerState: selected,
            cameraPickerShown: cameraPickerShown,
            cameraImageAdded: cameraImageAdded
        )
    }
    
    public func makeAssetsAccessPermissionView() -> some View {
        AssetsAccessPermissionView()
    }
    
    public func makeSendInChannelView(
        showReplyInChannel: Binding<Bool>,
        isDirectMessage: Bool
    ) -> some View {
        SendInChannelView(
            sendInChannel: showReplyInChannel,
            isDirectMessage: isDirectMessage
        )
    }
    
    public func supportedMessageActions(
        for message: ChatMessage,
        channel: ChatChannel,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> [MessageAction] {
        MessageAction.defaultActions(
            factory: self,
            for: message,
            channel: channel,
            chatClient: chatClient,
            onFinish: onFinish,
            onError: onError
        )
    }
    
    public func makeMessageActionsView(
        for message: ChatMessage,
        channel: ChatChannel,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> some View {
        let messageActions = supportedMessageActions(
            for: message,
            channel: channel,
            onFinish: onFinish,
            onError: onError
        )
        
        return MessageActionsView(messageActions: messageActions)
    }
    
    public func makeReactionsUsersView(
        message: ChatMessage,
        maxHeight: CGFloat
    ) -> some View {
        ReactionsUsersView(
            message: message,
            maxHeight: maxHeight
        )
    }
    
    public func makeBottomReactionsView(
        message: ChatMessage,
        showsAllInfo: Bool,
        onTap: @escaping () -> Void,
        onLongPress: @escaping () -> Void
    ) -> some View {
        BottomReactionsView(
            message: message,
            showsAllInfo: showsAllInfo,
            onTap: onTap,
            onLongPress: onLongPress
        )
    }
    
    public func makeMessageReactionView(
        message: ChatMessage,
        onTapGesture: @escaping () -> Void,
        onLongPressGesture: @escaping () -> Void
    ) -> some View {
        ReactionsContainer(
            message: message,
            onTapGesture: onTapGesture,
            onLongPressGesture: onLongPressGesture
        )
    }
    
    public func makeReactionsOverlayView(
        channel: ChatChannel,
        currentSnapshot: UIImage,
        messageDisplayInfo: MessageDisplayInfo,
        onBackgroundTap: @escaping () -> Void,
        onActionExecuted: @escaping (MessageActionInfo) -> Void
    ) -> some View {
        ReactionsOverlayView(
            factory: self,
            channel: channel,
            currentSnapshot: currentSnapshot,
            messageDisplayInfo: messageDisplayInfo,
            onBackgroundTap: onBackgroundTap,
            onActionExecuted: onActionExecuted
        )
    }
    
    public func makeReactionsContentView(
        message: ChatMessage,
        contentRect: CGRect,
        onReactionTap: @escaping (MessageReactionType) -> Void
    ) -> some View {
        ReactionsOverlayContainer(
            message: message,
            contentRect: contentRect,
            onReactionTap: onReactionTap
        )
    }
    
    public func makeReactionsBackgroundView(
        currentSnapshot: UIImage,
        popInAnimationInProgress: Bool
    ) -> some View {
        Image(uiImage: currentSnapshot)
            .overlay(Color.black.opacity(popInAnimationInProgress ? 0 : 0.1))
            .blur(radius: popInAnimationInProgress ? 0 : 4)
    }
    
    public func makeQuotedMessageHeaderView(
        quotedMessage: Binding<ChatMessage?>
    ) -> some View {
        QuotedMessageHeaderView(quotedMessage: quotedMessage)
    }
    
    public func makeQuotedMessageView(
        quotedMessage: ChatMessage,
        fillAvailableSpace: Bool,
        isInComposer: Bool,
        scrolledId: Binding<String?>
    ) -> some View {
        QuotedMessageViewContainer(
            factory: self,
            quotedMessage: quotedMessage,
            fillAvailableSpace: fillAvailableSpace,
            forceLeftToRight: isInComposer,
            scrolledId: scrolledId
        )
    }
    
    public func makeEditedMessageHeaderView(
        editedMessage: Binding<ChatMessage?>
    ) -> some View {
        EditMessageHeaderView(editedMessage: editedMessage)
    }
    
    public func makeCommandsContainerView(
        suggestions: [String: Any],
        handleCommand: @escaping ([String: Any]) -> Void
    ) -> some View {
        CommandsContainerView(
            suggestions: suggestions,
            handleCommand: handleCommand
        )
    }
    
    public func makeMessageReadIndicatorView(
        channel: ChatChannel,
        message: ChatMessage
    ) -> some View {
        let readUsers = channel.readUsers(
            currentUserId: chatClient.currentUserId,
            message: message
        )
        let showReadCount = channel.memberCount > 2
        return MessageReadIndicatorView(
            readUsers: readUsers,
            showReadCount: showReadCount,
            localState: message.localState
        )
    }
    
    public func makeNewMessagesIndicatorView(
        newMessagesStartId: Binding<String?>,
        count: Int
    ) -> some View {
        NewMessagesIndicator(
            newMessagesStartId: newMessagesStartId,
            count: count
        )
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
