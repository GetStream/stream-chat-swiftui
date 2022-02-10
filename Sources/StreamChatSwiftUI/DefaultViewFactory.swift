//
// Copyright © 2022 Stream.io Inc. All rights reserved.
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
        LoadingView()
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
            trailingRightButtonTapped: trailingSwipeRightButtonTapped,
            trailingLeftButtonTapped: trailingSwipeLeftButtonTapped,
            leadingSwipeButtonTapped: leadingSwipeButtonTapped
        )
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
    
    // MARK: messages
    
    public func makeChannelDestination() -> (ChannelSelectionInfo) -> ChatChannelView<Self> {
        { [unowned self] selectionInfo in
            let controller = chatClient.channelController(
                for: selectionInfo.channel.cid,
                messageOrdering: .topToBottom
            )
            return ChatChannelView(
                viewFactory: self,
                channelController: controller,
                scrollToMessage: selectionInfo.message
            )
        }
    }
    
    public func makeMessageThreadDestination() -> (ChatChannel, ChatMessage) -> ChatChannelView<Self> {
        { [unowned self] channel, message in
            let channelController = chatClient.channelController(
                for: channel.cid,
                messageOrdering: .topToBottom
            )
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
    
    public func makeMessageAvatarView(for author: ChatUser) -> some View {
        MessageAvatarView(author: author)
    }
    
    public func makeChannelHeaderViewModifier(
        for channel: ChatChannel
    ) -> some ChatChannelHeaderViewModifier {
        DefaultChannelHeaderModifier(channel: channel)
    }
    
    public func makeMessageThreadHeaderViewModifier() -> some MessageThreadHeaderViewModifier {
        DefaultMessageThreadHeaderModifier()
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
            message: message,
            isFirst: isFirst,
            scrolledId: scrolledId
        )
    }
    
    public func makeImageAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) -> some View {
        ImageAttachmentContainer(
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
    
    public func makeCustomAttachmentViewType(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) -> some View {
        EmptyView()
    }
    
    public func makeGiphyBadgeViewType(
        for message: ChatMessage,
        availableWidth: CGFloat
    ) -> some View {
        GiphyBadgeView()
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
    
    public func makeQuotedMessageHeaderView(
        quotedMessage: Binding<ChatMessage?>
    ) -> some View {
        QuotedMessageHeaderView(quotedMessage: quotedMessage)
    }
    
    public func makeQuotedMessageComposerView(
        quotedMessage: ChatMessage
    ) -> some View {
        QuotedMessageViewContainer(
            quotedMessage: quotedMessage,
            fillAvailableSpace: true,
            forceLeftToRight: true,
            scrolledId: .constant(nil)
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
            showReadCount: showReadCount
        )
    }
}

/// Default class conforming to `ViewFactory`, used throughout the SDK.
public class DefaultViewFactory: ViewFactory {
    @Injected(\.chatClient) public var chatClient
    
    private init() {}
    
    public static let shared = DefaultViewFactory()
}
