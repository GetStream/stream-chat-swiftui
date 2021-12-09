//
// Copyright © 2021 Stream.io Inc. All rights reserved.
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
            onDismiss: onDismiss
        )
    }
    
    public func makeChannelListItem(
        currentChannelId: Binding<String?>,
        channel: ChatChannel,
        channelName: String,
        avatar: UIImage,
        onlineIndicatorShown: Bool,
        disabled: Bool,
        selectedChannel: Binding<ChatChannel?>,
        channelDestination: @escaping (ChatChannel) -> ChannelDestination,
        onItemTap: @escaping (ChatChannel) -> Void,
        onDelete: @escaping (ChatChannel) -> Void,
        onMoreTapped: @escaping (ChatChannel) -> Void
    ) -> ChatChannelSwipeableListItem<ChannelDestination> {
        ChatChannelSwipeableListItem(
            currentChannelId: currentChannelId,
            channel: channel,
            channelName: channelName,
            avatar: avatar,
            onlineIndicatorShown: onlineIndicatorShown,
            disabled: disabled,
            selectedChannel: selectedChannel,
            channelDestination: channelDestination,
            onItemTap: onItemTap,
            onDelete: onDelete,
            onMoreTapped: onMoreTapped
        )
    }
    
    // MARK: messages
    
    public func makeChannelDestination() -> (ChatChannel) -> ChatChannelView<Self> {
        { [unowned self] channel in
            let controller = chatClient.channelController(
                for: channel.cid,
                messageOrdering: .topToBottom
            )
            return ChatChannelView(
                viewFactory: self,
                channelController: controller
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
    
    public func makeMessageTextView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> some View {
        MessageTextView(message: message, isFirst: isFirst)
    }
    
    public func makeImageAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> some View {
        ImageAttachmentContainer(
            message: message,
            width: availableWidth,
            isFirst: isFirst
        )
    }
    
    public func makeGiphyAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> some View {
        GiphyAttachmentView(
            message: message,
            width: availableWidth,
            isFirst: isFirst
        )
    }
    
    public func makeLinkAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> some View {
        LinkAttachmentContainer(
            message: message,
            width: availableWidth,
            isFirst: isFirst
        )
    }
    
    public func makeFileAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> some View {
        FileAttachmentsContainer(
            message: message,
            width: availableWidth,
            isFirst: isFirst
        )
    }
    
    public func makeVideoAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> some View {
        VideoAttachmentsContainer(
            message: message,
            width: availableWidth
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
    
    public func makeCustomAttachmentViewType(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
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
        onMessageSent: @escaping () -> Void
    ) -> MessageComposerView<Self> {
        MessageComposerView(
            viewFactory: self,
            channelController: channelController,
            messageController: messageController,
            onMessageSent: onMessageSent
        )
    }
    
    public func makeLeadingComposerView(
        state: Binding<PickerTypeState>
    ) -> some View {
        AttachmentPickerTypeView(pickerTypeState: state)
            .padding(.bottom, 8)
    }
    
    @ViewBuilder
    public func makeComposerInputView(
        text: Binding<String>,
        addedAssets: [AddedAsset],
        addedFileURLs: [URL],
        addedCustomAttachments: [CustomAttachment],
        onCustomAttachmentTap: @escaping (CustomAttachment) -> Void,
        shouldScroll: Bool,
        removeAttachmentWithId: @escaping (String) -> Void
    ) -> some View {
        if shouldScroll {
            ScrollView {
                ComposerInputView(
                    factory: self,
                    text: text,
                    addedAssets: addedAssets,
                    addedFileURLs: addedFileURLs,
                    addedCustomAttachments: addedCustomAttachments,
                    onCustomAttachmentTap: onCustomAttachmentTap,
                    removeAttachmentWithId: removeAttachmentWithId
                )
            }
            .frame(height: 240)
        } else {
            ComposerInputView(
                factory: self,
                text: text,
                addedAssets: addedAssets,
                addedFileURLs: addedFileURLs,
                addedCustomAttachments: addedCustomAttachments,
                onCustomAttachmentTap: onCustomAttachmentTap,
                removeAttachmentWithId: removeAttachmentWithId
            )
        }
    }
    
    public func makeTrailingComposerView(
        enabled: Bool,
        onTap: @escaping () -> Void
    ) -> some View {
        SendMessageButton(
            enabled: enabled,
            onTap: onTap
        )
        .padding(.bottom, 8)
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
    
    public func supportedMessageActions(
        for message: ChatMessage,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> [MessageAction] {
        MessageAction.defaultActions(
            for: message,
            chatClient: chatClient,
            onDismiss: onDismiss,
            onError: onError
        )
    }
    
    public func makeMessageActionsView(
        for message: ChatMessage,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> some View {
        let messageActions = supportedMessageActions(
            for: message,
            onDismiss: onDismiss,
            onError: onError
        )
        
        return MessageActionsView(messageActions: messageActions)
    }
    
    public func makeMessageReactionView(
        message: ChatMessage
    ) -> some View {
        ReactionsContainer(message: message)
    }
    
    public func makeReactionsOverlayView(
        currentSnapshot: UIImage,
        messageDisplayInfo: MessageDisplayInfo,
        onBackgroundTap: @escaping () -> Void
    ) -> some View {
        ReactionsOverlayView(
            factory: self,
            currentSnapshot: currentSnapshot,
            messageDisplayInfo: messageDisplayInfo,
            onBackgroundTap: onBackgroundTap
        )
    }
}

/// Default class conforming to `ViewFactory`, used throughout the SDK.
public class DefaultViewFactory: ViewFactory {
    @Injected(\.chatClient) public var chatClient
    
    private init() {}
    
    public static let shared = DefaultViewFactory()
}
