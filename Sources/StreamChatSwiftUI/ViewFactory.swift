//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import Photos
import StreamChat
import SwiftUI

/// Factory used to create views.
public protocol ViewFactory: AnyObject {
    var chatClient: ChatClient { get }
    
    /// Returns the navigation bar display mode.
    func navigationBarDisplayMode() -> NavigationBarItem.TitleDisplayMode
    
    // MARK: - channels
    
    associatedtype HeaderViewModifier: ChannelListHeaderViewModifier
    /// Creates the channel list header view modifier.
    ///  - Parameter title: the title displayed in the header.
    func makeChannelListHeaderViewModifier(title: String) -> HeaderViewModifier
    
    associatedtype NoChannels: View
    /// Creates the view that is displayed when there are no channels available.
    func makeNoChannelsView() -> NoChannels
    
    associatedtype LoadingContent: View
    /// Creates the loading view.
    func makeLoadingView() -> LoadingContent
    
    associatedtype ChannelListItemType: View
    /// Creates the channel list item.
    /// - Parameters:
    ///  - channel: the channel being displayed.
    ///  - channelName: the display name of the channel.
    ///  - avatar: the avatar of the channel.
    ///  - onlineIndicatorShown: whether the online indicator is shown on the avatar.
    ///  - disabled: whether the user interactions with the channel are disabled.
    ///  - selectedChannel: binding of the currently selected channel.
    ///  - swipedChannelId: optional id of the swiped channel id.
    ///  - channelDestination: closure that creates the channel destination.
    ///  - onItemTap: called when an item is tapped.
    ///  - trailingSwipeRightButtonTapped: called when the right button of the trailing swiped area is tapped.
    ///  - trailingSwipeLeftButtonTapped: called when the left button of the trailing swiped area is tapped.
    ///  - leadingSwipeButtonTapped: called when the button of the leading swiped area is tapped.
    func makeChannelListItem(
        channel: ChatChannel,
        channelName: String,
        avatar: UIImage,
        onlineIndicatorShown: Bool,
        disabled: Bool,
        selectedChannel: Binding<ChatChannel?>,
        swipedChannelId: Binding<String?>,
        channelDestination: @escaping (ChatChannel) -> ChannelDestination,
        onItemTap: @escaping (ChatChannel) -> Void,
        trailingSwipeRightButtonTapped: @escaping (ChatChannel) -> Void,
        trailingSwipeLeftButtonTapped: @escaping (ChatChannel) -> Void,
        leadingSwipeButtonTapped: @escaping (ChatChannel) -> Void
    ) -> ChannelListItemType
    
    associatedtype MoreActionsView: View
    /// Creates the more channel actions view.
    /// - Parameters:
    ///  - channel: the channel where the actions are applied.
    ///  - onDismiss: handler when the more actions view is dismissed.
    ///  - onError: handler when an error happened.
    func makeMoreChannelActionsView(
        for channel: ChatChannel,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> MoreActionsView
    
    /// Returns the supported  channel actions.
    /// - Parameters:
    ///  - channel: the channel where the actions are applied.
    ///  - onDismiss: handler when the more actions view is dismissed.
    ///  - onError: handler when an error happened.
    /// - Returns: list of `ChannelAction` items.
    func supportedMoreChannelActions(
        for channel: ChatChannel,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> [ChannelAction]
    
    associatedtype TrailingSwipeActionsViewType: View
    /// Creates the trailing swipe actions view in the channel list.
    /// - Parameters:
    ///  - channel: the channel being swiped.
    ///  - offsetX: the offset of the swipe area in the x-axis.
    ///  - buttonWidth: the width of the button (use if you want dynamic width, based on swiping position).
    ///  - leftButtonTapped: handler when the left button is tapped.
    ///  - rightButtonTapped: handler when the right button is tapped.
    /// - Returns: View displayed in the trailing swipe area of a channel item.
    func makeTrailingSwipeActionsView(
        channel: ChatChannel,
        offsetX: CGFloat,
        buttonWidth: CGFloat,
        leftButtonTapped: @escaping (ChatChannel) -> Void,
        rightButtonTapped: @escaping (ChatChannel) -> Void
    ) -> TrailingSwipeActionsViewType
    
    associatedtype LeadingSwipeActionsViewType: View
    /// Creates the leading swipe actions view in the channel list.
    /// - Parameters:
    ///  - channel: the channel being swiped.
    ///  - offsetX: the offset of the swipe area in the x-axis.
    ///  - buttonWidth: the width of the button (use if you want dynamic width, based on swiping position).
    ///  - buttonTapped: handler when the button is tapped.
    /// - Returns: View displayed in the leading swipe area of a channel item.
    func makeLeadingSwipeActionsView(
        channel: ChatChannel,
        offsetX: CGFloat,
        buttonWidth: CGFloat,
        buttonTapped: @escaping (ChatChannel) -> Void
    ) -> LeadingSwipeActionsViewType
    
    // MARK: - messages
    
    associatedtype ChannelDestination: View
    /// Returns a function that creates the channel destination.
    func makeChannelDestination() -> (ChatChannel) -> ChannelDestination
    
    associatedtype MessageThreadDestination: View
    /// Returns a function that creats the message thread destination.
    func makeMessageThreadDestination() -> (ChatChannel, ChatMessage) -> MessageThreadDestination
    
    associatedtype UserAvatar: View
    /// Creates the message avatar view.
    /// - Parameter author: the message author whose avatar is displayed.
    func makeMessageAvatarView(for author: ChatUser) -> UserAvatar
    
    associatedtype ChatHeaderViewModifier: ChatChannelHeaderViewModifier
    /// Creates the channel header view modifier.
    /// - Parameter channel: the displayed channel.
    func makeChannelHeaderViewModifier(for channel: ChatChannel) -> ChatHeaderViewModifier
    
    associatedtype ThreadHeaderViewModifier: MessageThreadHeaderViewModifier
    /// Creates the message thread header view modifier.
    func makeMessageThreadHeaderViewModifier() -> ThreadHeaderViewModifier
    
    associatedtype MessageTextViewType: View
    /// Creates the message text view.
    /// - Parameters:
    ///   - message: the message that will be displayed.
    ///   - isFirst: whether it is first in the group (latest creation date).
    ///   - availableWidth: the available width for the view.
    ///   - scrolledId: Identifier for the message that should be scrolled to.
    ///  - Returns: view displayed in the text message slot.
    func makeMessageTextView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) -> MessageTextViewType
    
    associatedtype ImageAttachmentViewType: View
    /// Creates the image attachment view.
    /// - Parameters:
    ///   - message: the message that will be displayed.
    ///   - isFirst: whether it is first in the group (latest creation date).
    ///   - availableWidth: the available width for the view.
    ///   - scrolledId: Identifier for the message that should be scrolled to.
    ///  - Returns: view displayed in the image attachment slot.
    func makeImageAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) -> ImageAttachmentViewType
    
    associatedtype GiphyAttachmentViewType: View
    /// Creates the giphy attachment view.
    /// - Parameters:
    ///   - message: the message that will be displayed.
    ///   - isFirst: whether it is first in the group (latest creation date).
    ///   - availableWidth: the available width for the view.
    ///   - scrolledId: Identifier for the message that should be scrolled to.
    ///  - Returns: view displayed in the giphy attachment slot.
    func makeGiphyAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) -> GiphyAttachmentViewType
    
    associatedtype LinkAttachmentViewType: View
    /// Creates the link attachment view.
    /// - Parameters:
    ///   - message: the message that will be displayed.
    ///   - isFirst: whether it is first in the group (latest creation date).
    ///   - availableWidth: the available width for the view.
    ///   - scrolledId: Identifier for the message that should be scrolled to.
    ///  - Returns: view displayed in the link attachment slot.
    func makeLinkAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) -> LinkAttachmentViewType
    
    associatedtype FileAttachmentViewType: View
    /// Creates the file attachment view.
    /// - Parameters:
    ///   - message: the message that will be displayed.
    ///   - isFirst: whether it is first in the group (latest creation date).
    ///   - availableWidth: the available width for the view.
    ///   - scrolledId: Identifier for the message that should be scrolled to.
    ///  - Returns: view displayed in the file attachment slot.
    func makeFileAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) -> FileAttachmentViewType
    
    associatedtype VideoAttachmentViewType: View
    /// Creates the video attachment view.
    /// - Parameters:
    ///   - message: the message that will be displayed.
    ///   - isFirst: whether it is first in the group (latest creation date).
    ///   - availableWidth: the available width for the view.
    ///   - scrolledId: Identifier for the message that should be scrolled to.
    ///  - Returns: view displayed in the video attachment slot.
    func makeVideoAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) -> VideoAttachmentViewType
    
    associatedtype DeletedMessageViewType: View
    /// Creates the deleted message view.
    /// - Parameters:
    ///   - message: the deleted message that will be displayed with indicator.
    ///   - isFirst: whether it is first in the group (latest creation date).
    ///   - availableWidth: the available width for the view.
    ///  - Returns: view displayed in the deleted message slot.
    func makeDeletedMessageView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> DeletedMessageViewType
    
    associatedtype CustomAttachmentViewType: View
    /// Creates custom attachment view.
    /// If support for more than one custom view is needed, just do if-else check inside the view.
    /// - Parameters:
    ///   - message: the message that will be displayed.
    ///   - isFirst: whether it is first in the group (latest creation date).
    ///   - availableWidth: the available width for the view.
    ///  - Returns: view displayed in the custom attachment slot.
    func makeCustomAttachmentViewType(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) -> CustomAttachmentViewType
    
    associatedtype GiphyBadgeViewType: View
    /// Creates giphy badge view.
    /// If support for more than one custom view is needed, just do if-else check inside the view.
    /// - Parameters:
    ///   - message: the message that will be displayed.
    ///   - availableWidth: the available width for the view.
    ///  - Returns: view displayed in the giphy badge slot.
    func makeGiphyBadgeViewType(
        for message: ChatMessage,
        availableWidth: CGFloat
    ) -> GiphyBadgeViewType
    
    associatedtype MessageComposerViewType: View
    /// Creates the message composer view.
    /// - Parameters:
    ///  - channelController: The `ChatChannelController` for the channel.
    ///  - messageController: Optional `ChatMessageController`, if used in a thread.
    ///  - quotedMessage: Optional quoted message, shown in the composer input.
    ///  - editedMessage: Optional message that's being edited.
    ///  - onMessageSent: Called when a message is sent.
    /// - Returns: view displayed in the message composer slot.
    func makeMessageComposerViewType(
        with channelController: ChatChannelController,
        messageController: ChatMessageController?,
        quotedMessage: Binding<ChatMessage?>,
        editedMessage: Binding<ChatMessage?>,
        onMessageSent: @escaping () -> Void
    ) -> MessageComposerViewType
    
    associatedtype LeadingComposerViewType: View
    /// Creates the leading part of the composer view.
    /// - Parameter state: Indicator what's the current picker state (can be ignored for different types of views).
    /// - Returns: view displayed in the leading part of the message composer view.
    func makeLeadingComposerView(
        state: Binding<PickerTypeState>
    ) -> LeadingComposerViewType
    
    /// Creates the composer input view.
    /// - Parameters:
    ///  - text: the text displayed in the input view.
    ///  - selectedRangeLocation: the selected range location of a text.
    ///  - addedAssets: list of the added assets (in case they need to be displayed in the input view).
    ///  - addedFileURLs: list of the added file URLs (in case they need to be displayed in the input view).
    ///  - addedCustomAttachments: list of added custom attachments.
    ///  - quotedMessage: Optional quoted message, shown in the composer input.
    ///  - onCustomAttachmentTap: called when a custom attachment is tapped.
    ///  - shouldScroll: whether the input field is scrollable.
    ///  - removeAttachmentWithId: called when the attachment is removed from the input view.
    /// - Returns: view displayed in the middle area of the message composer view.
    associatedtype ComposerInputViewType: View
    func makeComposerInputView(
        text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        command: Binding<ComposerCommand?>,
        addedAssets: [AddedAsset],
        addedFileURLs: [URL],
        addedCustomAttachments: [CustomAttachment],
        quotedMessage: Binding<ChatMessage?>,
        onCustomAttachmentTap: @escaping (CustomAttachment) -> Void,
        shouldScroll: Bool,
        removeAttachmentWithId: @escaping (String) -> Void
    ) -> ComposerInputViewType
    
    associatedtype TrailingComposerViewType: View
    /// Creates the trailing composer view.
    /// - Parameters:
    ///  - enabled: whether the view is enabled (e.g. button).
    ///  - onTap: called when the view is tapped.
    /// - Returns: view displayed in the trailing area of the message composer view.
    func makeTrailingComposerView(
        enabled: Bool,
        onTap: @escaping () -> Void
    ) -> TrailingComposerViewType
    
    associatedtype AttachmentPickerViewType: View
    /// Creates the attachment picker view.
    /// - Parameters:
    ///  - attachmentPickerState: currently selected attachment picker.
    ///  - filePickerShown: binding controlling the display of the file picker.
    ///  - cameraPickerShown: binding controlling the display of the camera picker.
    ///  - addedFileURLs: list of the added file urls.
    ///  - onPickerStateChange: called when the picker state is changed.
    ///  - photoLibraryAssets: list of assets fetched from the photo library.
    ///  - onAssetTap: called when an asset is tapped on.
    ///  - onCustomAttachmentTap: called when a custom attachment is tapped.
    ///  - isAssetSelected: checks whether an asset is selected.
    ///  - addedCustomAttachments: list of added custom attachments.
    ///  - cameraImageAdded: called when an asset from the camera is added.
    ///  - askForAssetsAccessPermissions: provides access to photos library (and others if needed).
    ///  - isDisplayed: thether the attachment picker view is displayed.
    ///  - height: the current  height of the picker.
    ///  - popupHeight: the  height of the popup when displayed.
    /// - Returns: view displayed in the attachment picker slot.
    func makeAttachmentPickerView(
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
    ) -> AttachmentPickerViewType
    
    associatedtype AttachmentSourcePickerViewType: View
    /// Creates the attachment source picker view.
    /// - Parameters:
    ///  - selected: the selected attachment picker state.
    ///  - onPickerStateChange: called when the picker state is changed.
    /// - Returns: view displayed in the attachment source picker slot.
    func makeAttachmentSourcePickerView(
        selected: AttachmentPickerState,
        onPickerStateChange: @escaping (AttachmentPickerState) -> Void
    ) -> AttachmentSourcePickerViewType
    
    associatedtype PhotoAttachmentPickerViewType: View
    /// Creates the photo attachment picker view.
    /// - Parameters:
    ///  - assets: collection of assets from the user's photo library.
    ///  - onAssetTap: called when an asset is tapped.
    ///  - isAssetSelected: checks whether an asset is selected.
    /// - Returns: view displayed in the photo attachment picker slot.
    func makePhotoAttachmentPickerView(
        assets: PHFetchResultCollection,
        onAssetTap: @escaping (AddedAsset) -> Void,
        isAssetSelected: @escaping (String) -> Bool
    ) -> PhotoAttachmentPickerViewType
    
    associatedtype FilePickerViewType: View
    /// Creates the file picker view.
    /// - Parameters:
    ///  - filePickerShown: binding controlling the display of the file picker.
    ///  - addedFileURLs: binding of the list of added file urls.
    /// - Returns: view displayed in the file picker slot.
    func makeFilePickerView(
        filePickerShown: Binding<Bool>,
        addedFileURLs: Binding<[URL]>
    ) -> FilePickerViewType
    
    associatedtype CameraPickerViewType: View
    /// Creates the camera picker view.
    /// - Parameters:
    ///  - selected: Binding of the selected attachment picker state.
    ///  - cameraPickerShown: binding controlling the display of the camera picker.
    ///  - cameraImageAdded: called when an image is added from the camera.
    /// - Returns: view displayed in the camera picker slot.
    func makeCameraPickerView(
        selected: Binding<AttachmentPickerState>,
        cameraPickerShown: Binding<Bool>,
        cameraImageAdded: @escaping (AddedAsset) -> Void
    ) -> CameraPickerViewType
    
    associatedtype CustomComposerAttachmentViewType: View
    /// Creates a custom attachment view shown in the message composer.
    /// - Parameters:
    ///  - addedCustomAttachments: list of already added custom attachments.
    ///  - onCustomAttachmentTap: called when a custom attachment is tapped.
    /// - Returns: view shown in the custom slot in the message composer.
    func makeCustomAttachmentView(
        addedCustomAttachments: [CustomAttachment],
        onCustomAttachmentTap: @escaping (CustomAttachment) -> Void
    ) -> CustomComposerAttachmentViewType
    
    associatedtype CustomAttachmentPreviewViewType: View
    /// Creates a custom attachment view shown in the preview in the composer input.
    /// - Parameters:
    ///  - addedCustomAttachments: list of already added custom attachments.
    ///  - onCustomAttachmentTap: called when a custom attachment is tapped.
    /// - Returns: view shown in the preview slot for custom composer input.
    func makeCustomAttachmentPreviewView(
        addedCustomAttachments: [CustomAttachment],
        onCustomAttachmentTap: @escaping (CustomAttachment) -> Void
    ) -> CustomAttachmentPreviewViewType
    
    associatedtype AssetsAccessPermissionViewType: View
    /// Creates the assets access permission view.
    func makeAssetsAccessPermissionView() -> AssetsAccessPermissionViewType
    
    /// Returns the supported  message actions.
    /// - Parameters:
    ///  - message: the message where the actions are applied.
    ///  - channel: the channel of the message.
    ///  - onFinish: handler when the action is executed.
    ///  - onError: handler when an error happened.
    /// - Returns: list of `MessageAction` items.
    func supportedMessageActions(
        for message: ChatMessage,
        channel: ChatChannel,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> [MessageAction]
    
    associatedtype SendInChannelViewType: View
    /// Creates the view that allows thread messages to be sent in a channel.
    /// - Parameters:
    ///  - showReplyInChannel: whether the message should be send also in the channel.
    ///  - isDirectMessage: whether the message is direct.
    func makeSendInChannelView(
        showReplyInChannel: Binding<Bool>,
        isDirectMessage: Bool
    ) -> SendInChannelViewType
    
    associatedtype MessageActionsViewType: View
    /// Creates the message actions view.
    /// - Parameters:
    ///  - message: the message where the actions are applied.
    ///  - channel: the channel of the message.
    ///  - onDismiss: handler when the more actions view is dismissed.
    ///  - onError: handler when an error happened.
    /// - Returns: view displayed in the message actions slot.
    func makeMessageActionsView(
        for message: ChatMessage,
        channel: ChatChannel,
        onFinish: @escaping (MessageActionInfo) -> Void,
        onError: @escaping (Error) -> Void
    ) -> MessageActionsViewType
    
    associatedtype MessageReactionViewType: View
    /// Creates the reactions view shown above the message.
    /// - Parameter message: the message for which reactions are shown.
    /// - Returns: view shown in the message reactions slot.
    func makeMessageReactionView(
        message: ChatMessage
    ) -> MessageReactionViewType
    
    associatedtype ReactionsOverlayViewType: View
    /// Creates the reactions overlay view.
    /// - Parameters:
    ///  - channel: the channel of the message.
    ///  - currentSnapshot: current snapshot of the screen (in case blur effect is needed).
    ///  - messageDisplayInfo: information about the displayed message.
    ///  - onBackgroundTap: called when the background is tapped (to dismiss the view).
    ///  - onActionExecuted: called when a message action is executed.
    /// - Returns: view displayed in the reactions overlay slot.
    func makeReactionsOverlayView(
        channel: ChatChannel,
        currentSnapshot: UIImage,
        messageDisplayInfo: MessageDisplayInfo,
        onBackgroundTap: @escaping () -> Void,
        onActionExecuted: @escaping (MessageActionInfo) -> Void
    ) -> ReactionsOverlayViewType
    
    associatedtype QuotedMessageHeaderViewType: View
    /// Creates the quoted message header view in the composer.
    /// - Parameters:
    ///   - quotedMessage: the optional quoted message.
    /// - Returns: view displayed in the slot for quoted message in the composer.
    func makeQuotedMessageHeaderView(
        quotedMessage: Binding<ChatMessage?>
    ) -> QuotedMessageHeaderViewType
    
    associatedtype QuotedMessageComposerViewType: View
    /// Creates the quoted message shown in a composer view.
    /// - Parameter quotedMessage: the quoted message shown in the composer input.
    func makeQuotedMessageComposerView(
        quotedMessage: ChatMessage
    ) -> QuotedMessageComposerViewType
    
    associatedtype EditedMessageHeaderViewType: View
    /// Creates the edited message header view in the composer.
    /// - Parameters:
    ///   - editedMessage: the optional edited message.
    /// - Returns: view displayed in the slot for edited message in the composer.
    func makeEditedMessageHeaderView(
        editedMessage: Binding<ChatMessage?>
    ) -> EditedMessageHeaderViewType
    
    associatedtype CommandsContainerViewType: View
    /// Creates the commands container view, above the composer.
    /// - Parameters:
    ///  - suggestions: key-value based suggestions, depending on the command type.
    ///  - handleCommand: should be invoked by views when a command is executed.
    /// - Returns: view displayed in the commands container slot.
    func makeCommandsContainerView(
        suggestions: [String: Any],
        handleCommand: @escaping ([String: Any]) -> Void
    ) -> CommandsContainerViewType
}
