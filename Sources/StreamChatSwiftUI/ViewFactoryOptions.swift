//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
import Photos
import StreamChat
import SwiftUI

// MARK: - Channel List Options

public struct ChannelListHeaderViewModifierOptions {
    public let title: String
    
    public init(title: String) {
        self.title = title
    }
}

public struct ChannelListItemOptions<ChannelDestination: View> {
    public let channel: ChatChannel
    public let channelName: String
    public let avatar: UIImage
    public let onlineIndicatorShown: Bool
    public let disabled: Bool
    public let selectedChannel: Binding<ChannelSelectionInfo?>
    public let swipedChannelId: Binding<String?>
    public let channelDestination: @MainActor (ChannelSelectionInfo) -> ChannelDestination
    public let onItemTap: @MainActor (ChatChannel) -> Void
    public let trailingSwipeRightButtonTapped: @MainActor (ChatChannel) -> Void
    public let trailingSwipeLeftButtonTapped: @MainActor (ChatChannel) -> Void
    public let leadingSwipeButtonTapped: @MainActor (ChatChannel) -> Void
    
    public init(
        channel: ChatChannel,
        channelName: String,
        avatar: UIImage,
        onlineIndicatorShown: Bool,
        disabled: Bool,
        selectedChannel: Binding<ChannelSelectionInfo?>,
        swipedChannelId: Binding<String?>,
        channelDestination: @escaping @MainActor (ChannelSelectionInfo) -> ChannelDestination,
        onItemTap: @escaping @MainActor (ChatChannel) -> Void,
        trailingSwipeRightButtonTapped: @escaping @MainActor (ChatChannel) -> Void,
        trailingSwipeLeftButtonTapped: @escaping @MainActor (ChatChannel) -> Void,
        leadingSwipeButtonTapped: @escaping @MainActor (ChatChannel) -> Void
    ) {
        self.channel = channel
        self.channelName = channelName
        self.avatar = avatar
        self.onlineIndicatorShown = onlineIndicatorShown
        self.disabled = disabled
        self.selectedChannel = selectedChannel
        self.swipedChannelId = swipedChannelId
        self.channelDestination = channelDestination
        self.onItemTap = onItemTap
        self.trailingSwipeRightButtonTapped = trailingSwipeRightButtonTapped
        self.trailingSwipeLeftButtonTapped = trailingSwipeLeftButtonTapped
        self.leadingSwipeButtonTapped = leadingSwipeButtonTapped
    }
}

public struct ChannelAvatarViewFactoryOptions {
    public let channel: ChatChannel
    public let options: ChannelAvatarViewOptions
    
    public init(channel: ChatChannel, options: ChannelAvatarViewOptions) {
        self.channel = channel
        self.options = options
    }
}

public struct ChannelListBackgroundOptions {
    public let colors: ColorPalette
    
    public init(colors: ColorPalette) {
        self.colors = colors
    }
}

public struct ChannelListItemBackgroundOptions {
    public let channel: ChatChannel
    public let isSelected: Bool
    
    public init(channel: ChatChannel, isSelected: Bool) {
        self.channel = channel
        self.isSelected = isSelected
    }
}

public struct MoreChannelActionsViewOptions {
    public let channel: ChatChannel
    public let swipedChannelId: Binding<String?>
    public let onDismiss: @MainActor () -> Void
    public let onError: @MainActor (Error) -> Void
    
    public init(
        channel: ChatChannel,
        swipedChannelId: Binding<String?>,
        onDismiss: @escaping @MainActor () -> Void,
        onError: @escaping @MainActor (Error) -> Void
    ) {
        self.channel = channel
        self.swipedChannelId = swipedChannelId
        self.onDismiss = onDismiss
        self.onError = onError
    }
}

public struct SupportedMoreChannelActionsOptions {
    public let channel: ChatChannel
    public let onDismiss: @MainActor () -> Void
    public let onError: @MainActor (Error) -> Void
    
    public init(
        channel: ChatChannel,
        onDismiss: @escaping @MainActor () -> Void,
        onError: @escaping @MainActor (Error) -> Void
    ) {
        self.channel = channel
        self.onDismiss = onDismiss
        self.onError = onError
    }
}

public struct TrailingSwipeActionsViewOptions {
    public let channel: ChatChannel
    public let offsetX: CGFloat
    public let buttonWidth: CGFloat
    public let swipedChannelId: Binding<String?>
    public let leftButtonTapped: @MainActor (ChatChannel) -> Void
    public let rightButtonTapped: @MainActor (ChatChannel) -> Void
    
    public init(
        channel: ChatChannel,
        offsetX: CGFloat,
        buttonWidth: CGFloat,
        swipedChannelId: Binding<String?>,
        leftButtonTapped: @escaping @MainActor (ChatChannel) -> Void,
        rightButtonTapped: @escaping @MainActor (ChatChannel) -> Void
    ) {
        self.channel = channel
        self.offsetX = offsetX
        self.buttonWidth = buttonWidth
        self.swipedChannelId = swipedChannelId
        self.leftButtonTapped = leftButtonTapped
        self.rightButtonTapped = rightButtonTapped
    }
}

public struct LeadingSwipeActionsViewOptions {
    public let channel: ChatChannel
    public let offsetX: CGFloat
    public let buttonWidth: CGFloat
    public let swipedChannelId: Binding<String?>
    public let buttonTapped: @MainActor (ChatChannel) -> Void
    
    public init(
        channel: ChatChannel,
        offsetX: CGFloat,
        buttonWidth: CGFloat,
        swipedChannelId: Binding<String?>,
        buttonTapped: @escaping @MainActor (ChatChannel) -> Void
    ) {
        self.channel = channel
        self.offsetX = offsetX
        self.buttonWidth = buttonWidth
        self.swipedChannelId = swipedChannelId
        self.buttonTapped = buttonTapped
    }
}

public struct ChannelListTopViewOptions {
    public let searchText: Binding<String>
    
    public init(searchText: Binding<String>) {
        self.searchText = searchText
    }
}

public struct SearchResultsViewOptions {
    public let selectedChannel: Binding<ChannelSelectionInfo?>
    public let searchResults: [ChannelSelectionInfo]
    public let loadingSearchResults: Bool
    public let onlineIndicatorShown: @MainActor (ChatChannel) -> Bool
    public let channelNaming: @MainActor (ChatChannel) -> String
    public let imageLoader: @MainActor (ChatChannel) -> UIImage
    public let onSearchResultTap: @MainActor (ChannelSelectionInfo) -> Void
    public let onItemAppear: @MainActor (Int) -> Void
    
    public init(
        selectedChannel: Binding<ChannelSelectionInfo?>,
        searchResults: [ChannelSelectionInfo],
        loadingSearchResults: Bool,
        onlineIndicatorShown: @escaping @MainActor (ChatChannel) -> Bool,
        channelNaming: @escaping @MainActor (ChatChannel) -> String,
        imageLoader: @escaping @MainActor (ChatChannel) -> UIImage,
        onSearchResultTap: @escaping @MainActor (ChannelSelectionInfo) -> Void,
        onItemAppear: @escaping @MainActor (Int) -> Void
    ) {
        self.selectedChannel = selectedChannel
        self.searchResults = searchResults
        self.loadingSearchResults = loadingSearchResults
        self.onlineIndicatorShown = onlineIndicatorShown
        self.channelNaming = channelNaming
        self.imageLoader = imageLoader
        self.onSearchResultTap = onSearchResultTap
        self.onItemAppear = onItemAppear
    }
}

public struct ChannelListSearchResultItemOptions<ChannelDestination: View> {
    public let searchResult: ChannelSelectionInfo
    public let onlineIndicatorShown: Bool
    public let channelName: String
    public let avatar: UIImage
    public let onSearchResultTap: @MainActor (ChannelSelectionInfo) -> Void
    public let channelDestination: @MainActor (ChannelSelectionInfo) -> ChannelDestination
    
    public init(
        searchResult: ChannelSelectionInfo,
        onlineIndicatorShown: Bool,
        channelName: String,
        avatar: UIImage,
        onSearchResultTap: @escaping @MainActor (ChannelSelectionInfo) -> Void,
        channelDestination: @escaping @MainActor (ChannelSelectionInfo) -> ChannelDestination
    ) {
        self.searchResult = searchResult
        self.onlineIndicatorShown = onlineIndicatorShown
        self.channelName = channelName
        self.avatar = avatar
        self.onSearchResultTap = onSearchResultTap
        self.channelDestination = channelDestination
    }
}

// MARK: - Message Options

public struct EmptyMessagesViewOptions {
    public let channel: ChatChannel
    public let colors: ColorPalette
    
    public init(channel: ChatChannel, colors: ColorPalette) {
        self.channel = channel
        self.colors = colors
    }
}

public struct MessageAvatarViewOptions {
    public let userDisplayInfo: UserDisplayInfo
    
    public init(userDisplayInfo: UserDisplayInfo) {
        self.userDisplayInfo = userDisplayInfo
    }
}

public struct QuotedMessageAvatarViewOptions {
    public let userDisplayInfo: UserDisplayInfo
    public let size: CGSize
    
    public init(userDisplayInfo: UserDisplayInfo, size: CGSize) {
        self.userDisplayInfo = userDisplayInfo
        self.size = size
    }
}

public struct ChannelHeaderViewModifierOptions {
    public let channel: ChatChannel
    
    public init(channel: ChatChannel) {
        self.channel = channel
    }
}

public struct ChannelBarsVisibilityViewModifierOptions {
    public let shouldShow: Bool
    
    public init(shouldShow: Bool) {
        self.shouldShow = shouldShow
    }
}

public struct MessageThreadHeaderViewModifierOptions {
    public init() {}
}

public struct MessageListBackgroundOptions {
    public let colors: ColorPalette
    public let isInThread: Bool
    
    public init(colors: ColorPalette, isInThread: Bool) {
        self.colors = colors
        self.isInThread = isInThread
    }
}

public struct MessageContainerViewOptions {
    public let channel: ChatChannel
    public let message: ChatMessage
    public let width: CGFloat?
    public let showsAllInfo: Bool
    public let isInThread: Bool
    public let scrolledId: Binding<String?>
    public let quotedMessage: Binding<ChatMessage?>
    public let onLongPress: @MainActor (MessageDisplayInfo) -> Void
    public let isLast: Bool
    
    public init(
        channel: ChatChannel,
        message: ChatMessage,
        width: CGFloat?,
        showsAllInfo: Bool,
        isInThread: Bool,
        scrolledId: Binding<String?>,
        quotedMessage: Binding<ChatMessage?>,
        onLongPress: @escaping @MainActor (MessageDisplayInfo) -> Void,
        isLast: Bool
    ) {
        self.channel = channel
        self.message = message
        self.width = width
        self.showsAllInfo = showsAllInfo
        self.isInThread = isInThread
        self.scrolledId = scrolledId
        self.quotedMessage = quotedMessage
        self.onLongPress = onLongPress
        self.isLast = isLast
    }
}

public struct MessageTextViewOptions {
    public let message: ChatMessage
    public let isFirst: Bool
    public let availableWidth: CGFloat
    public let scrolledId: Binding<String?>
    
    public init(
        message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) {
        self.message = message
        self.isFirst = isFirst
        self.availableWidth = availableWidth
        self.scrolledId = scrolledId
    }
}

public struct MessageDateViewOptions {
    public let message: ChatMessage
    
    public init(message: ChatMessage) {
        self.message = message
    }
}

public struct MessageAuthorAndDateViewOptions {
    public let message: ChatMessage
    
    public init(message: ChatMessage) {
        self.message = message
    }
}

public struct MessageTranslationFooterViewOptions {
    public let messageViewModel: MessageViewModel
    
    public init(messageViewModel: MessageViewModel) {
        self.messageViewModel = messageViewModel
    }
}

public struct LastInGroupHeaderViewOptions {
    public let message: ChatMessage
    
    public init(message: ChatMessage) {
        self.message = message
    }
}

public struct ImageAttachmentViewOptions {
    public let message: ChatMessage
    public let isFirst: Bool
    public let availableWidth: CGFloat
    public let scrolledId: Binding<String?>
    
    public init(
        message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) {
        self.message = message
        self.isFirst = isFirst
        self.availableWidth = availableWidth
        self.scrolledId = scrolledId
    }
}

public struct GiphyAttachmentViewOptions {
    public let message: ChatMessage
    public let isFirst: Bool
    public let availableWidth: CGFloat
    public let scrolledId: Binding<String?>
    
    public init(
        message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) {
        self.message = message
        self.isFirst = isFirst
        self.availableWidth = availableWidth
        self.scrolledId = scrolledId
    }
}

public struct LinkAttachmentViewOptions {
    public let message: ChatMessage
    public let isFirst: Bool
    public let availableWidth: CGFloat
    public let scrolledId: Binding<String?>
    
    public init(
        message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) {
        self.message = message
        self.isFirst = isFirst
        self.availableWidth = availableWidth
        self.scrolledId = scrolledId
    }
}

public struct FileAttachmentViewOptions {
    public let message: ChatMessage
    public let isFirst: Bool
    public let availableWidth: CGFloat
    public let scrolledId: Binding<String?>
    
    public init(
        message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) {
        self.message = message
        self.isFirst = isFirst
        self.availableWidth = availableWidth
        self.scrolledId = scrolledId
    }
}

public struct VideoAttachmentViewOptions {
    public let message: ChatMessage
    public let isFirst: Bool
    public let availableWidth: CGFloat
    public let scrolledId: Binding<String?>
    
    public init(
        message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) {
        self.message = message
        self.isFirst = isFirst
        self.availableWidth = availableWidth
        self.scrolledId = scrolledId
    }
}

public struct GalleryViewOptions {
    public let mediaAttachments: [MediaAttachment]
    public let message: ChatMessage
    public let isShown: Binding<Bool>
    public let options: MediaViewsOptions
    
    public init(
        mediaAttachments: [MediaAttachment],
        message: ChatMessage,
        isShown: Binding<Bool>,
        options: MediaViewsOptions
    ) {
        self.mediaAttachments = mediaAttachments
        self.message = message
        self.isShown = isShown
        self.options = options
    }
}

public struct GalleryHeaderViewOptions {
    public let title: String
    public let subtitle: String
    public let shown: Binding<Bool>
    
    public init(title: String, subtitle: String, shown: Binding<Bool>) {
        self.title = title
        self.subtitle = subtitle
        self.shown = shown
    }
}

public struct VideoPlayerViewOptions {
    public let attachment: ChatMessageVideoAttachment
    public let message: ChatMessage
    public let isShown: Binding<Bool>
    public let options: MediaViewsOptions
    
    public init(
        attachment: ChatMessageVideoAttachment,
        message: ChatMessage,
        isShown: Binding<Bool>,
        options: MediaViewsOptions
    ) {
        self.attachment = attachment
        self.message = message
        self.isShown = isShown
        self.options = options
    }
}

public struct VideoPlayerHeaderViewOptions {
    public let title: String
    public let subtitle: String
    public let shown: Binding<Bool>
    
    public init(title: String, subtitle: String, shown: Binding<Bool>) {
        self.title = title
        self.subtitle = subtitle
        self.shown = shown
    }
}

public struct VideoPlayerFooterViewOptions {
    public let attachment: ChatMessageVideoAttachment
    public let shown: Binding<Bool>
    
    public init(attachment: ChatMessageVideoAttachment, shown: Binding<Bool>) {
        self.attachment = attachment
        self.shown = shown
    }
}

public struct DeletedMessageViewOptions {
    public let message: ChatMessage
    public let isFirst: Bool
    public let availableWidth: CGFloat
    
    public init(message: ChatMessage, isFirst: Bool, availableWidth: CGFloat) {
        self.message = message
        self.isFirst = isFirst
        self.availableWidth = availableWidth
    }
}

public struct SystemMessageViewOptions {
    public let message: ChatMessage
    
    public init(message: ChatMessage) {
        self.message = message
    }
}

public struct EmojiTextViewOptions {
    public let message: ChatMessage
    public let scrolledId: Binding<String?>
    public let isFirst: Bool
    
    public init(message: ChatMessage, scrolledId: Binding<String?>, isFirst: Bool) {
        self.message = message
        self.scrolledId = scrolledId
        self.isFirst = isFirst
    }
}

public struct VoiceRecordingViewOptions {
    public let message: ChatMessage
    public let isFirst: Bool
    public let availableWidth: CGFloat
    public let scrolledId: Binding<String?>
    
    public init(
        message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) {
        self.message = message
        self.isFirst = isFirst
        self.availableWidth = availableWidth
        self.scrolledId = scrolledId
    }
}

public struct CustomAttachmentViewTypeOptions {
    public let message: ChatMessage
    public let isFirst: Bool
    public let availableWidth: CGFloat
    public let scrolledId: Binding<String?>
    
    public init(
        message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) {
        self.message = message
        self.isFirst = isFirst
        self.availableWidth = availableWidth
        self.scrolledId = scrolledId
    }
}

public struct ScrollToBottomButtonOptions {
    public let unreadCount: Int
    public let onScrollToBottom: @MainActor () -> Void
    
    public init(unreadCount: Int, onScrollToBottom: @escaping @MainActor () -> Void) {
        self.unreadCount = unreadCount
        self.onScrollToBottom = onScrollToBottom
    }
}

public struct DateIndicatorViewOptions {
    public let dateString: String
    
    public init(dateString: String) {
        self.dateString = dateString
    }
}

public struct MessageListDateIndicatorViewOptions {
    public let date: Date
    
    public init(date: Date) {
        self.date = date
    }
}

public struct TypingIndicatorBottomViewOptions {
    public let channel: ChatChannel
    public let currentUserId: UserId?
    
    public init(channel: ChatChannel, currentUserId: UserId?) {
        self.channel = channel
        self.currentUserId = currentUserId
    }
}

public struct GiphyBadgeViewTypeOptions {
    public let message: ChatMessage
    public let availableWidth: CGFloat
    
    public init(message: ChatMessage, availableWidth: CGFloat) {
        self.message = message
        self.availableWidth = availableWidth
    }
}

public struct MessageRepliesViewOptions {
    public let channel: ChatChannel
    public let message: ChatMessage
    public let replyCount: Int
    
    public init(channel: ChatChannel, message: ChatMessage, replyCount: Int) {
        self.channel = channel
        self.message = message
        self.replyCount = replyCount
    }
}

public struct MessageRepliesShownInChannelViewOptions {
    public let channel: ChatChannel
    public let message: ChatMessage
    public let parentMessage: ChatMessage
    public let replyCount: Int
    
    public init(
        channel: ChatChannel,
        message: ChatMessage,
        parentMessage: ChatMessage,
        replyCount: Int
    ) {
        self.channel = channel
        self.message = message
        self.parentMessage = parentMessage
        self.replyCount = replyCount
    }
}

// MARK: - Composer Options

public struct MessageComposerViewTypeOptions {
    public let channelController: ChatChannelController
    public let messageController: ChatMessageController?
    public let quotedMessage: Binding<ChatMessage?>
    public let editedMessage: Binding<ChatMessage?>
    public let onMessageSent: @MainActor () -> Void
    
    public init(
        channelController: ChatChannelController,
        messageController: ChatMessageController?,
        quotedMessage: Binding<ChatMessage?>,
        editedMessage: Binding<ChatMessage?>,
        onMessageSent: @escaping @MainActor () -> Void
    ) {
        self.channelController = channelController
        self.messageController = messageController
        self.quotedMessage = quotedMessage
        self.editedMessage = editedMessage
        self.onMessageSent = onMessageSent
    }
}

public struct LeadingComposerViewOptions {
    public let state: Binding<PickerTypeState>
    public let channelConfig: ChannelConfig?
    
    public init(state: Binding<PickerTypeState>, channelConfig: ChannelConfig?) {
        self.state = state
        self.channelConfig = channelConfig
    }
}

public struct ComposerInputViewOptions {
    public let text: Binding<String>
    public let selectedRangeLocation: Binding<Int>
    public let command: Binding<ComposerCommand?>
    public let addedAssets: [AddedAsset]
    public let addedFileURLs: [URL]
    public let addedCustomAttachments: [CustomAttachment]
    public let quotedMessage: Binding<ChatMessage?>
    public let maxMessageLength: Int?
    public let cooldownDuration: Int
    public let onCustomAttachmentTap: @MainActor (CustomAttachment) -> Void
    public let shouldScroll: Bool
    public let removeAttachmentWithId: @MainActor (String) -> Void
    
    public init(
        text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        command: Binding<ComposerCommand?>,
        addedAssets: [AddedAsset],
        addedFileURLs: [URL],
        addedCustomAttachments: [CustomAttachment],
        quotedMessage: Binding<ChatMessage?>,
        maxMessageLength: Int?,
        cooldownDuration: Int,
        onCustomAttachmentTap: @escaping @MainActor (CustomAttachment) -> Void,
        shouldScroll: Bool,
        removeAttachmentWithId: @escaping @MainActor (String) -> Void
    ) {
        self.text = text
        self.selectedRangeLocation = selectedRangeLocation
        self.command = command
        self.addedAssets = addedAssets
        self.addedFileURLs = addedFileURLs
        self.addedCustomAttachments = addedCustomAttachments
        self.quotedMessage = quotedMessage
        self.maxMessageLength = maxMessageLength
        self.cooldownDuration = cooldownDuration
        self.onCustomAttachmentTap = onCustomAttachmentTap
        self.shouldScroll = shouldScroll
        self.removeAttachmentWithId = removeAttachmentWithId
    }
}

public struct ComposerTextInputViewOptions {
    public let text: Binding<String>
    public let height: Binding<CGFloat>
    public let selectedRangeLocation: Binding<Int>
    public let placeholder: String
    public let editable: Bool
    public let maxMessageLength: Int?
    public let currentHeight: CGFloat
    
    public init(
        text: Binding<String>,
        height: Binding<CGFloat>,
        selectedRangeLocation: Binding<Int>,
        placeholder: String,
        editable: Bool,
        maxMessageLength: Int?,
        currentHeight: CGFloat
    ) {
        self.text = text
        self.height = height
        self.selectedRangeLocation = selectedRangeLocation
        self.placeholder = placeholder
        self.editable = editable
        self.maxMessageLength = maxMessageLength
        self.currentHeight = currentHeight
    }
}

public struct TrailingComposerViewOptions {
    public let enabled: Bool
    public let cooldownDuration: Int
    public let onTap: @MainActor () -> Void
    
    public init(enabled: Bool, cooldownDuration: Int, onTap: @escaping @MainActor () -> Void) {
        self.enabled = enabled
        self.cooldownDuration = cooldownDuration
        self.onTap = onTap
    }
}

public struct ComposerRecordingViewOptions {
    public let viewModel: MessageComposerViewModel
    public let gestureLocation: CGPoint
    
    public init(viewModel: MessageComposerViewModel, gestureLocation: CGPoint) {
        self.viewModel = viewModel
        self.gestureLocation = gestureLocation
    }
}

public struct ComposerRecordingLockedViewOptions {
    public let viewModel: MessageComposerViewModel
    
    public init(viewModel: MessageComposerViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - Attachment Options

public struct AttachmentPickerViewOptions {
    public let attachmentPickerState: Binding<AttachmentPickerState>
    public let filePickerShown: Binding<Bool>
    public let cameraPickerShown: Binding<Bool>
    public let addedFileURLs: Binding<[URL]>
    public let onPickerStateChange: @MainActor (AttachmentPickerState) -> Void
    public let photoLibraryAssets: PHFetchResult<PHAsset>?
    public let onAssetTap: @MainActor (AddedAsset) -> Void
    public let onCustomAttachmentTap: @MainActor (CustomAttachment) -> Void
    public let isAssetSelected: @MainActor (String) -> Bool
    public let addedCustomAttachments: [CustomAttachment]
    public let cameraImageAdded: @MainActor (AddedAsset) -> Void
    public let askForAssetsAccessPermissions: @MainActor () -> Void
    public let isDisplayed: Bool
    public let height: CGFloat
    public let popupHeight: CGFloat
    
    public init(
        attachmentPickerState: Binding<AttachmentPickerState>,
        filePickerShown: Binding<Bool>,
        cameraPickerShown: Binding<Bool>,
        addedFileURLs: Binding<[URL]>,
        onPickerStateChange: @escaping @MainActor (AttachmentPickerState) -> Void,
        photoLibraryAssets: PHFetchResult<PHAsset>?,
        onAssetTap: @escaping @MainActor (AddedAsset) -> Void,
        onCustomAttachmentTap: @escaping @MainActor (CustomAttachment) -> Void,
        isAssetSelected: @escaping @MainActor (String) -> Bool,
        addedCustomAttachments: [CustomAttachment],
        cameraImageAdded: @escaping @MainActor (AddedAsset) -> Void,
        askForAssetsAccessPermissions: @escaping @MainActor () -> Void,
        isDisplayed: Bool,
        height: CGFloat,
        popupHeight: CGFloat
    ) {
        self.attachmentPickerState = attachmentPickerState
        self.filePickerShown = filePickerShown
        self.cameraPickerShown = cameraPickerShown
        self.addedFileURLs = addedFileURLs
        self.onPickerStateChange = onPickerStateChange
        self.photoLibraryAssets = photoLibraryAssets
        self.onAssetTap = onAssetTap
        self.onCustomAttachmentTap = onCustomAttachmentTap
        self.isAssetSelected = isAssetSelected
        self.addedCustomAttachments = addedCustomAttachments
        self.cameraImageAdded = cameraImageAdded
        self.askForAssetsAccessPermissions = askForAssetsAccessPermissions
        self.isDisplayed = isDisplayed
        self.height = height
        self.popupHeight = popupHeight
    }
}

public struct AttachmentSourcePickerViewOptions {
    public let selected: AttachmentPickerState
    public let onPickerStateChange: @MainActor (AttachmentPickerState) -> Void
    
    public init(selected: AttachmentPickerState, onPickerStateChange: @escaping @MainActor (AttachmentPickerState) -> Void) {
        self.selected = selected
        self.onPickerStateChange = onPickerStateChange
    }
}

public struct PhotoAttachmentPickerViewOptions {
    public let assets: PHFetchResultCollection
    public let onAssetTap: @MainActor (AddedAsset) -> Void
    public let isAssetSelected: @MainActor (String) -> Bool
    
    public init(
        assets: PHFetchResultCollection,
        onAssetTap: @escaping @MainActor (AddedAsset) -> Void,
        isAssetSelected: @escaping @MainActor (String) -> Bool
    ) {
        self.assets = assets
        self.onAssetTap = onAssetTap
        self.isAssetSelected = isAssetSelected
    }
}

public struct FilePickerViewOptions {
    public let filePickerShown: Binding<Bool>
    public let addedFileURLs: Binding<[URL]>
    
    public init(filePickerShown: Binding<Bool>, addedFileURLs: Binding<[URL]>) {
        self.filePickerShown = filePickerShown
        self.addedFileURLs = addedFileURLs
    }
}

public struct CameraPickerViewOptions {
    public let selected: Binding<AttachmentPickerState>
    public let cameraPickerShown: Binding<Bool>
    public let cameraImageAdded: @MainActor (AddedAsset) -> Void
    
    public init(
        selected: Binding<AttachmentPickerState>,
        cameraPickerShown: Binding<Bool>,
        cameraImageAdded: @escaping @MainActor (AddedAsset) -> Void
    ) {
        self.selected = selected
        self.cameraPickerShown = cameraPickerShown
        self.cameraImageAdded = cameraImageAdded
    }
}

public struct CustomComposerAttachmentViewOptions {
    public let addedCustomAttachments: [CustomAttachment]
    public let onCustomAttachmentTap: @MainActor (CustomAttachment) -> Void
    
    public init(
        addedCustomAttachments: [CustomAttachment],
        onCustomAttachmentTap: @escaping @MainActor (CustomAttachment) -> Void
    ) {
        self.addedCustomAttachments = addedCustomAttachments
        self.onCustomAttachmentTap = onCustomAttachmentTap
    }
}

public struct CustomAttachmentPreviewViewOptions {
    public let addedCustomAttachments: [CustomAttachment]
    public let onCustomAttachmentTap: @MainActor (CustomAttachment) -> Void
    
    public init(
        addedCustomAttachments: [CustomAttachment],
        onCustomAttachmentTap: @escaping @MainActor (CustomAttachment) -> Void
    ) {
        self.addedCustomAttachments = addedCustomAttachments
        self.onCustomAttachmentTap = onCustomAttachmentTap
    }
}

// MARK: - Message Actions Options

public struct SupportedMessageActionsOptions {
    public let message: ChatMessage
    public let channel: ChatChannel
    public let onFinish: @MainActor (MessageActionInfo) -> Void
    public let onError: @MainActor (Error) -> Void
    
    public init(
        message: ChatMessage,
        channel: ChatChannel,
        onFinish: @escaping @MainActor (MessageActionInfo) -> Void,
        onError: @escaping @MainActor (Error) -> Void
    ) {
        self.message = message
        self.channel = channel
        self.onFinish = onFinish
        self.onError = onError
    }
}

public struct SendInChannelViewOptions {
    public let showReplyInChannel: Binding<Bool>
    public let isDirectMessage: Bool
    
    public init(showReplyInChannel: Binding<Bool>, isDirectMessage: Bool) {
        self.showReplyInChannel = showReplyInChannel
        self.isDirectMessage = isDirectMessage
    }
}

public struct MessageActionsViewOptions {
    public let message: ChatMessage
    public let channel: ChatChannel
    public let onFinish: @MainActor (MessageActionInfo) -> Void
    public let onError: @MainActor (Error) -> Void
    
    public init(
        message: ChatMessage,
        channel: ChatChannel,
        onFinish: @escaping @MainActor (MessageActionInfo) -> Void,
        onError: @escaping @MainActor (Error) -> Void
    ) {
        self.message = message
        self.channel = channel
        self.onFinish = onFinish
        self.onError = onError
    }
}

// MARK: - Reactions Options

public struct ReactionsUsersViewOptions {
    public let message: ChatMessage
    public let maxHeight: CGFloat
    
    public init(message: ChatMessage, maxHeight: CGFloat) {
        self.message = message
        self.maxHeight = maxHeight
    }
}

public struct ReactionsBottomViewOptions {
    public let message: ChatMessage
    public let showsAllInfo: Bool
    public let onTap: @MainActor () -> Void
    public let onLongPress: @MainActor () -> Void
    
    public init(
        message: ChatMessage,
        showsAllInfo: Bool,
        onTap: @escaping @MainActor () -> Void,
        onLongPress: @escaping @MainActor () -> Void
    ) {
        self.message = message
        self.showsAllInfo = showsAllInfo
        self.onTap = onTap
        self.onLongPress = onLongPress
    }
}

public struct MessageReactionViewOptions {
    public let message: ChatMessage
    public let onTapGesture: @MainActor () -> Void
    public let onLongPressGesture: @MainActor () -> Void
    
    public init(
        message: ChatMessage,
        onTapGesture: @escaping @MainActor () -> Void,
        onLongPressGesture: @escaping @MainActor () -> Void
    ) {
        self.message = message
        self.onTapGesture = onTapGesture
        self.onLongPressGesture = onLongPressGesture
    }
}

public struct ReactionsOverlayViewOptions {
    public let channel: ChatChannel
    public let currentSnapshot: UIImage
    public let messageDisplayInfo: MessageDisplayInfo
    public let onBackgroundTap: @MainActor () -> Void
    public let onActionExecuted: @MainActor (MessageActionInfo) -> Void
    
    public init(
        channel: ChatChannel,
        currentSnapshot: UIImage,
        messageDisplayInfo: MessageDisplayInfo,
        onBackgroundTap: @escaping @MainActor () -> Void,
        onActionExecuted: @escaping @MainActor (MessageActionInfo) -> Void
    ) {
        self.channel = channel
        self.currentSnapshot = currentSnapshot
        self.messageDisplayInfo = messageDisplayInfo
        self.onBackgroundTap = onBackgroundTap
        self.onActionExecuted = onActionExecuted
    }
}

public struct ReactionsBackgroundOptions {
    public let currentSnapshot: UIImage
    public let popInAnimationInProgress: Bool
    
    public init(currentSnapshot: UIImage, popInAnimationInProgress: Bool) {
        self.currentSnapshot = currentSnapshot
        self.popInAnimationInProgress = popInAnimationInProgress
    }
}

public struct ReactionsContentViewOptions {
    public let message: ChatMessage
    public let contentRect: CGRect
    public let onReactionTap: @MainActor (MessageReactionType) -> Void
    
    public init(
        message: ChatMessage,
        contentRect: CGRect,
        onReactionTap: @escaping @MainActor (MessageReactionType) -> Void
    ) {
        self.message = message
        self.contentRect = contentRect
        self.onReactionTap = onReactionTap
    }
}

// MARK: - Quoted Message Options

public struct QuotedMessageHeaderViewOptions {
    public let quotedMessage: Binding<ChatMessage?>
    
    public init(quotedMessage: Binding<ChatMessage?>) {
        self.quotedMessage = quotedMessage
    }
}

public struct QuotedMessageViewOptions {
    public let quotedMessage: ChatMessage
    public let fillAvailableSpace: Bool
    public let isInComposer: Bool
    public let scrolledId: Binding<String?>
    
    public init(
        quotedMessage: ChatMessage,
        fillAvailableSpace: Bool,
        isInComposer: Bool,
        scrolledId: Binding<String?>
    ) {
        self.quotedMessage = quotedMessage
        self.fillAvailableSpace = fillAvailableSpace
        self.isInComposer = isInComposer
        self.scrolledId = scrolledId
    }
}

public struct CustomAttachmentQuotedViewOptions {
    public let message: ChatMessage
    
    public init(message: ChatMessage) {
        self.message = message
    }
}

public struct EditedMessageHeaderViewOptions {
    public let editedMessage: Binding<ChatMessage?>
    
    public init(editedMessage: Binding<ChatMessage?>) {
        self.editedMessage = editedMessage
    }
}

// MARK: - Commands Options

public struct CommandsContainerViewOptions {
    public let suggestions: [String: Any]
    public let handleCommand: @MainActor ([String: Any]) -> Void
    
    public init(suggestions: [String: Any], handleCommand: @escaping @MainActor ([String: Any]) -> Void) {
        self.suggestions = suggestions
        self.handleCommand = handleCommand
    }
}

// MARK: - Read Indicator Options

public struct MessageReadIndicatorViewOptions {
    public let channel: ChatChannel
    public let message: ChatMessage
    
    public init(channel: ChatChannel, message: ChatMessage) {
        self.channel = channel
        self.message = message
    }
}

public struct NewMessagesIndicatorViewOptions {
    public let newMessagesStartId: Binding<String?>
    public let count: Int
    
    public init(newMessagesStartId: Binding<String?>, count: Int) {
        self.newMessagesStartId = newMessagesStartId
        self.count = count
    }
}

public struct JumpToUnreadButtonOptions {
    public let channel: ChatChannel
    public let onJumpToMessage: @MainActor () -> Void
    public let onClose: @MainActor () -> Void
    
    public init(
        channel: ChatChannel,
        onJumpToMessage: @escaping @MainActor () -> Void,
        onClose: @escaping @MainActor () -> Void
    ) {
        self.channel = channel
        self.onJumpToMessage = onJumpToMessage
        self.onClose = onClose
    }
}

// MARK: - Poll Options

public struct ComposerPollViewOptions {
    public let channelController: ChatChannelController
    public let messageController: ChatMessageController?
    
    public init(channelController: ChatChannelController, messageController: ChatMessageController?) {
        self.channelController = channelController
        self.messageController = messageController
    }
}

public struct PollViewOptions {
    public let message: ChatMessage
    public let poll: Poll
    public let isFirst: Bool
    
    public init(message: ChatMessage, poll: Poll, isFirst: Bool) {
        self.message = message
        self.poll = poll
        self.isFirst = isFirst
    }
}

// MARK: - Thread Options

public struct ThreadListItemOptions<ThreadDestination: View> {
    public let thread: ChatThread
    public let threadDestination: @MainActor (ChatThread) -> ThreadDestination
    public let selectedThread: Binding<ThreadSelectionInfo?>
    
    public init(
        thread: ChatThread,
        threadDestination: @escaping @MainActor (ChatThread) -> ThreadDestination,
        selectedThread: Binding<ThreadSelectionInfo?>
    ) {
        self.thread = thread
        self.threadDestination = threadDestination
        self.selectedThread = selectedThread
    }
}

public struct ThreadListErrorBannerViewOptions {
    public let onRefreshAction: @MainActor () -> Void
    
    public init(onRefreshAction: @escaping @MainActor () -> Void) {
        self.onRefreshAction = onRefreshAction
    }
}

public struct ThreadListContainerModifierOptions {
    public let viewModel: ChatThreadListViewModel
    
    public init(viewModel: ChatThreadListViewModel) {
        self.viewModel = viewModel
    }
}

public struct ThreadListHeaderViewModifierOptions {
    public let title: String
    
    public init(title: String) {
        self.title = title
    }
}

public struct ThreadListHeaderViewOptions {
    public let viewModel: ChatThreadListViewModel
    
    public init(viewModel: ChatThreadListViewModel) {
        self.viewModel = viewModel
    }
}

public struct ThreadListFooterViewOptions {
    public let viewModel: ChatThreadListViewModel
    
    public init(viewModel: ChatThreadListViewModel) {
        self.viewModel = viewModel
    }
}

public struct ThreadListBackgroundOptions {
    public let colors: ColorPalette
    
    public init(colors: ColorPalette) {
        self.colors = colors
    }
}

public struct ThreadListItemBackgroundOptions {
    public let thread: ChatThread
    public let isSelected: Bool
    
    public init(thread: ChatThread, isSelected: Bool) {
        self.thread = thread
        self.isSelected = isSelected
    }
}

// MARK: - Add Users Options

public struct AddUsersViewOptions {
    public let options: AddUsersOptions
    public let onUserTap: @MainActor (ChatUser) -> Void
    
    public init(options: AddUsersOptions, onUserTap: @escaping @MainActor (ChatUser) -> Void) {
        self.options = options
        self.onUserTap = onUserTap
    }
}

// MARK: - Empty Options (for methods with no parameters)

public struct NoChannelsViewOptions {
    public init() {}
}

public struct LoadingViewOptions {
    public init() {}
}

public struct ChannelListDividerItemOptions {
    public init() {}
}

public struct ChannelListFooterViewOptions {
    public init() {}
}

public struct ChannelListStickyFooterViewOptions {
    public init() {}
}

public struct ChannelListContentModifierOptions {
    public init() {}
}

public struct ChannelListModifierOptions {
    public init() {}
}

public struct ChannelDestinationOptions {
    public init() {}
}

public struct MessageThreadDestinationOptions {
    public init() {}
}

public struct MessageListModifierOptions {
    public init() {}
}

public struct MessageListContainerModifierOptions {
    public init() {}
}

public struct ChannelLoadingViewOptions {
    public init() {}
}

public struct ComposerRecordingTipViewOptions {
    public init() {}
}

public struct ComposerViewModifierOptions {
    public init() {}
}

public struct AssetsAccessPermissionViewOptions {
    public init() {}
}

public struct ThreadDestinationOptions {
    public init() {}
}

public struct NoThreadsViewOptions {
    public init() {}
}

public struct ThreadListLoadingViewOptions {
    public init() {}
}

public struct ThreadListDividerItemOptions {
    public init() {}
}
