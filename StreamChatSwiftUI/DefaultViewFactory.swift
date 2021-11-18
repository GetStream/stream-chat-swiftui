//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Photos
import StreamChat
import SwiftUI

/// Default implementations for the `ViewFactory`.
extension ViewFactory {
    // MARK: channels
    
    public func makeNoChannelsView() -> NoChannelsView {
        NoChannelsView()
    }
    
    public func makeLoadingView() -> LoadingView {
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
    
    public func suppotedMoreChannelActions(
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
    ) -> MoreChannelActionsView {
        MoreChannelActionsView(
            channel: channel,
            channelActions: suppotedMoreChannelActions(
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
    
    public func makeMessageAvatarView(for author: ChatUser) -> MessageAvatarView {
        MessageAvatarView(author: author)
    }
    
    public func makeChannelHeaderViewModifier(
        for channel: ChatChannel
    ) -> some ChatChannelHeaderViewModifier {
        DefaultChannelHeaderModifier(channel: channel)
    }
    
    public func makeMessageTextView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> MessageTextView {
        MessageTextView(message: message, isFirst: isFirst)
    }
    
    public func makeImageAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> ImageAttachmentContainer {
        ImageAttachmentContainer(
            message: message,
            width: availableWidth,
            isFirst: isFirst,
            isGiphy: false
        )
    }
    
    public func makeGiphyAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> ImageAttachmentContainer {
        ImageAttachmentContainer(
            message: message,
            width: availableWidth,
            isFirst: isFirst,
            isGiphy: true
        )
    }
    
    public func makeLinkAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> LinkAttachmentContainer {
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
    ) -> FileAttachmentsContainer {
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
    ) -> VideoAttachmentsContainer {
        VideoAttachmentsContainer(
            message: message,
            width: availableWidth
        )
    }
    
    public func makeDeletedMessageView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> DeletedMessageView {
        DeletedMessageView(
            message: message,
            isFirst: isFirst
        )
    }
    
    public func makeCustomAttachmentViewType(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> EmptyView {
        EmptyView()
    }
    
    public func makeGiphyBadgeViewType(
        for message: ChatMessage,
        availableWidth: CGFloat
    ) -> GiphyBadgeView {
        GiphyBadgeView()
    }
    
    public func makeMessageComposerViewType(
        with channelController: ChatChannelController,
        onMessageSent: @escaping () -> Void
    ) -> MessageComposerView<Self> {
        MessageComposerView(
            viewFactory: self,
            channelController: channelController,
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
        shouldScroll: Bool,
        removeAttachmentWithId: @escaping (String) -> Void
    ) -> some View {
        if shouldScroll {
            ScrollView {
                ComposerInputView(
                    text: text,
                    addedAssets: addedAssets,
                    addedFileURLs: addedFileURLs,
                    removeAttachmentWithId: removeAttachmentWithId
                )
            }
            .frame(height: 240)
        } else {
            ComposerInputView(
                text: text,
                addedAssets: addedAssets,
                addedFileURLs: addedFileURLs,
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
        isAssetSelected: @escaping (String) -> Bool,
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
            isAssetSelected: isAssetSelected,
            cameraImageAdded: cameraImageAdded,
            askForAssetsAccessPermissions: askForAssetsAccessPermissions,
            isDisplayed: isDisplayed,
            height: height
        )
        .offset(y: isDisplayed ? 0 : popupHeight)
        .animation(.spring())
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
    
    public func suppotedMessageActions(
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
        let messageActions = suppotedMessageActions(
            for: message,
            onDismiss: onDismiss,
            onError: onError
        )
        
        return MessageActionsView(messageActions: messageActions)
    }
}

/// Default class conforming to `ViewFactory`, used throughout the SDK.
public class DefaultViewFactory: ViewFactory {
    @Injected(\.chatClient) public var chatClient
    
    private init() {}
    
    public static let shared = DefaultViewFactory()
}
