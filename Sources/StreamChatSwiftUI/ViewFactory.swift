//
// Copyright © 2023 Stream.io Inc. All rights reserved.
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
    ///  - selectedChannel: binding of the currently selected channel selection info.
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
        selectedChannel: Binding<ChannelSelectionInfo?>,
        swipedChannelId: Binding<String?>,
        channelDestination: @escaping (ChannelSelectionInfo) -> ChannelDestination,
        onItemTap: @escaping (ChatChannel) -> Void,
        trailingSwipeRightButtonTapped: @escaping (ChatChannel) -> Void,
        trailingSwipeLeftButtonTapped: @escaping (ChatChannel) -> Void,
        leadingSwipeButtonTapped: @escaping (ChatChannel) -> Void
    ) -> ChannelListItemType

    associatedtype ChannelListBackground: View
    /// Creates the background for the channel list.
    /// - Parameter colors: the colors used in the SDK.
    /// - Returns: view shown as a background of the channel list.
    func makeChannelListBackground(colors: ColorPalette) -> ChannelListBackground

    associatedtype ChannelListDividerItem: View
    /// Creates the channel list divider item.
    func makeChannelListDividerItem() -> ChannelListDividerItem

    associatedtype MoreActionsView: View
    /// Creates the more channel actions view.
    /// - Parameters:
    ///  - channel: the channel where the actions are applied.
    ///  - swipedChannelId: optional id of the channel being swiped.
    ///  - onDismiss: handler when the more actions view is dismissed.
    ///  - onError: handler when an error happened.
    func makeMoreChannelActionsView(
        for channel: ChatChannel,
        swipedChannelId: Binding<String?>,
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
    ///  - swipedChannelId: optional id of the channel being swiped.
    ///  - leftButtonTapped: handler when the left button is tapped.
    ///  - rightButtonTapped: handler when the right button is tapped.
    /// - Returns: View displayed in the trailing swipe area of a channel item.
    func makeTrailingSwipeActionsView(
        channel: ChatChannel,
        offsetX: CGFloat,
        buttonWidth: CGFloat,
        swipedChannelId: Binding<String?>,
        leftButtonTapped: @escaping (ChatChannel) -> Void,
        rightButtonTapped: @escaping (ChatChannel) -> Void
    ) -> TrailingSwipeActionsViewType

    associatedtype LeadingSwipeActionsViewType: View
    /// Creates the leading swipe actions view in the channel list.
    /// - Parameters:
    ///  - channel: the channel being swiped.
    ///  - offsetX: the offset of the swipe area in the x-axis.
    ///  - buttonWidth: the width of the button (use if you want dynamic width, based on swiping position).
    ///  - swipedChannelId: optional id of the channel being active swiped.
    ///  - buttonTapped: handler when the button is tapped.
    /// - Returns: View displayed in the leading swipe area of a channel item.
    func makeLeadingSwipeActionsView(
        channel: ChatChannel,
        offsetX: CGFloat,
        buttonWidth: CGFloat,
        swipedChannelId: Binding<String?>,
        buttonTapped: @escaping (ChatChannel) -> Void
    ) -> LeadingSwipeActionsViewType

    associatedtype ChannelListTopViewType: View
    /// Creates the view shown at the top of the channel list. Suitable for search bar.
    /// - Parameter searchText: binding of the search text.
    /// - Returns: view shown above the channel list.
    func makeChannelListTopView(
        searchText: Binding<String>
    ) -> ChannelListTopViewType

    associatedtype ChannelListFooterViewType: View
    /// Creates the view shown at the bottom of the channel list.
    /// - Returns: view shown at the bottom of the channel list.
    func makeChannelListFooterView() -> ChannelListFooterViewType

    associatedtype ChannelListStickyFooterViewType: View
    /// Creates the view always visible at the bottom of the channel list.
    /// - Returns: view shown at the bottom of the channel list.
    func makeChannelListStickyFooterView() -> ChannelListStickyFooterViewType

    associatedtype ChannelListSearchResultItem: View
    /// Creates the search result item in the channel list.
    /// - Parameters:
    ///  - searchResult: the selected search result.
    ///  - onlineIndicatorShown: whether the online indicator is shown.
    ///  - channelName: the name of the channel.
    ///  - avatar: the channel avatar.
    ///  - onSearchResultTap: call when a search result is tapped.
    ///  - channelDestination: provides the channel destination.
    /// - Returns: view shown in the search results.
    func makeChannelListSearchResultItem(
        searchResult: ChannelSelectionInfo,
        onlineIndicatorShown: Bool,
        channelName: String,
        avatar: UIImage,
        onSearchResultTap: @escaping (ChannelSelectionInfo) -> Void,
        channelDestination: @escaping (ChannelSelectionInfo) -> ChannelDestination
    ) -> ChannelListSearchResultItem

    associatedtype ChannelListContentModifier: ViewModifier
    /// Returns a view modifier applied to the channel list content (including both header and footer views).
    func makeChannelListContentModifier() -> ChannelListContentModifier

    associatedtype ChannelListModifier: ViewModifier
    /// Returns a view modifier applied to the channel list.
    func makeChannelListModifier() -> ChannelListModifier

    // MARK: - messages

    associatedtype ChannelDestination: View
    /// Returns a function that creates the channel destination.
    func makeChannelDestination() -> (ChannelSelectionInfo) -> ChannelDestination

    associatedtype MessageThreadDestination: View
    /// Returns a function that creats the message thread destination.
    func makeMessageThreadDestination() -> (ChatChannel, ChatMessage) -> MessageThreadDestination

    associatedtype EmptyMessagesViewType: View
    /// Returns a view shown when there are no messages in a channel.
    /// - Parameters:
    ///  - channel: The channel with no messages.
    ///  - colors: The color palette.
    /// - Returns: View shown in the empty messages slot.
    func makeEmptyMessagesView(
        for channel: ChatChannel,
        colors: ColorPalette
    ) -> EmptyMessagesViewType

    associatedtype MessageListModifier: ViewModifier
    /// Returns a view modifier applied to the message list.
    func makeMessageListModifier() -> MessageListModifier
    
    associatedtype MessageListContainerModifier: ViewModifier
    /// Returns a view modifier applied to the message list container.
    func makeMessageListContainerModifier() -> MessageListContainerModifier

    associatedtype MessageViewModifier: ViewModifier
    /// Returns a view modifier applied to the message view.
    /// - Parameter messageModifierInfo: the message modifier info, that will be applied to the message.
    func makeMessageViewModifier(for messageModifierInfo: MessageModifierInfo) -> MessageViewModifier

    associatedtype UserAvatar: View
    /// Creates the message avatar view.
    /// - Parameter userDisplayInfo: the author's display info.
    func makeMessageAvatarView(for userDisplayInfo: UserDisplayInfo) -> UserAvatar

    associatedtype QuotedUserAvatar: View
    /// Creates the user avatar shown in quoted messages.
    /// - Parameters:
    ///  - userDisplayInfo: the author's display info.
    ///  - size: the required size of the view.
    func makeQuotedMessageAvatarView(
        for userDisplayInfo: UserDisplayInfo,
        size: CGSize
    ) -> QuotedUserAvatar

    associatedtype ChatHeaderViewModifier: ChatChannelHeaderViewModifier
    /// Creates the channel header view modifier.
    /// - Parameter channel: the displayed channel.
    func makeChannelHeaderViewModifier(for channel: ChatChannel) -> ChatHeaderViewModifier

    associatedtype ThreadHeaderViewModifier: MessageThreadHeaderViewModifier
    /// Creates the message thread header view modifier.
    func makeMessageThreadHeaderViewModifier() -> ThreadHeaderViewModifier

    associatedtype MessageListBackground: View
    /// Creates the background for the message list.
    /// - Parameters:
    ///  - colors: the color palette used in the SDK.
    ///  - isInThread: whether the message list is part of a message thread.
    /// - Returns: view shown as a background for the message list.
    func makeMessageListBackground(
        colors: ColorPalette,
        isInThread: Bool
    ) -> MessageListBackground

    associatedtype MessageContainerViewType: View
    /// Creates the message container view.
    /// - Parameters:
    ///  - channel: the chat channel where the message was sent.
    ///  - message: the chat message.
    ///  - width: the available width for the message.
    ///  - showsAllInfo: whether all info is shown for the message (i.e. whether is part of a group or leading message).
    ///  - isInThread: whether the message is part of a message thread.
    ///  - scrolledId: binding of the currently scrolled id. Use it to force scrolling to the particular message.
    ///  - quotedMessage: binding of an optional quoted message.
    ///  - onLongPress: called when the message is long pressed.
    ///  - isLast: whether it is the last message (e.g. to apply extra padding).
    /// - Returns: view shown in the message container slot.
    func makeMessageContainerView(
        channel: ChatChannel,
        message: ChatMessage,
        width: CGFloat?,
        showsAllInfo: Bool,
        isInThread: Bool,
        scrolledId: Binding<String?>,
        quotedMessage: Binding<ChatMessage?>,
        onLongPress: @escaping (MessageDisplayInfo) -> Void,
        isLast: Bool
    ) -> MessageContainerViewType

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

    associatedtype MessageDateViewType: View
    /// Creates a view for the date info shown below a message.
    /// - Parameter message: the chat message for which the date info is displayed.
    /// - Returns: view shown in the date indicator slot.
    func makeMessageDateView(for message: ChatMessage) -> MessageDateViewType

    associatedtype MessageAuthorAndDateViewType: View
    /// Creates a view for the date and author info shown below a message.
    /// - Parameter message: the chat message for which the date and author info is displayed.
    /// - Returns: view shown in the date and author indicator slot.
    func makeMessageAuthorAndDateView(for message: ChatMessage) -> MessageAuthorAndDateViewType

    associatedtype LastInGroupHeaderView: View
    /// Creates a view shown as a header of the last message in a group.
    /// - Parameter message: the chat message for which the header will be displayed.
    /// - Returns: view shown in the header of the last message.
    func makeLastInGroupHeaderView(for message: ChatMessage) -> LastInGroupHeaderView

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

    associatedtype SystemMessageViewType: View
    /// Creates the view for displaying system messages.
    /// - Parameter message: the system message.
    /// - Returns: view displayed when a system message appears.
    func makeSystemMessageView(message: ChatMessage) -> SystemMessageViewType

    associatedtype EmojiTextViewType: View
    /// Creates the view displaying emojis.
    /// - Parameters:
    ///   - message: the deleted message that will be displayed with indicator.
    ///   - scrolledId: Identifier for the message that should be scrolled to.
    ///   - isFirst: whether it is first in the group (latest creation date).
    func makeEmojiTextView(
        message: ChatMessage,
        scrolledId: Binding<String?>,
        isFirst: Bool
    ) -> EmojiTextViewType

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

    associatedtype ScrollToBottomButtonType: View
    /// Creates the scroll to bottom button.
    /// - Parameters:
    ///  - unreadCount: how many messages are unread.
    ///  - onScrollToBottom: called when the button is pressed.
    /// - Returns: view displayed in the scroll to bottom slot.
    func makeScrollToBottomButton(
        unreadCount: Int,
        onScrollToBottom: @escaping () -> Void
    ) -> ScrollToBottomButtonType

    associatedtype DateIndicatorViewType: View
    /// Creates the date indicator view.
    /// - Parameter dateString: the displayed date string.
    /// - Returns: view in the date indicator slot.
    func makeDateIndicatorView(dateString: String) -> DateIndicatorViewType

    associatedtype MessageListDateIndicatorViewType: View
    /// Creates the date indicator view in the message list.
    /// - Parameter date: the date that will be displayed.
    /// - Returns: view shown above messages separated by date.
    func makeMessageListDateIndicator(date: Date) -> MessageListDateIndicatorViewType

    associatedtype TypingIndicatorBottomViewType: View
    /// Creates the typing indicator shown at the bottom of a message list.
    /// - Parameters:
    ///  - channel: the channel where the indicator is shown.
    ///  - currentUserId: the id of the current user.
    /// - Returns: view shown in the typing indicator slot.
    func makeTypingIndicatorBottomView(
        channel: ChatChannel,
        currentUserId: UserId?
    ) -> TypingIndicatorBottomViewType

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

    associatedtype MessageRepliesViewType: View
    /// Creates the message replies view.
    /// - Parameters:
    ///  - channel: the channel where the message is sent.
    ///  - message: the message that's being replied to.
    ///  - replyCount: the current number of replies.
    /// - Returns: view displayed in the message replies view slot.
    func makeMessageRepliesView(
        channel: ChatChannel,
        message: ChatMessage,
        replyCount: Int
    ) -> MessageRepliesViewType

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
    /// - Parameters:
    ///  - state: Indicator what's the current picker state (can be ignored for different types of views).
    ///  - channelConfig: The configuration of a channel.
    /// - Returns: view displayed in the leading part of the message composer view.
    func makeLeadingComposerView(
        state: Binding<PickerTypeState>,
        channelConfig: ChannelConfig?
    ) -> LeadingComposerViewType

    /// Creates the composer input view.
    /// - Parameters:
    ///  - text: the text displayed in the input view.
    ///  - selectedRangeLocation: the selected range location of a text.
    ///  - addedAssets: list of the added assets (in case they need to be displayed in the input view).
    ///  - addedFileURLs: list of the added file URLs (in case they need to be displayed in the input view).
    ///  - addedCustomAttachments: list of added custom attachments.
    ///  - quotedMessage: Optional quoted message, shown in the composer input.
    ///  - maxMessageLength: the maximum allowed message length.
    ///  - cooldownDuration: Duration of cooldown for sending messages, in case slow mode is enabled.
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
        maxMessageLength: Int?,
        cooldownDuration: Int,
        onCustomAttachmentTap: @escaping (CustomAttachment) -> Void,
        shouldScroll: Bool,
        removeAttachmentWithId: @escaping (String) -> Void
    ) -> ComposerInputViewType
    
    associatedtype ComposerTextInputViewType: View
    /// Creates the composer input view.
    /// - Parameters:
    ///  - text: the text displayed in the input view.
    ///  - height: the height of the view.
    ///  - selectedRangeLocation: the selected range location of a text.
    ///  - placeholder: the placeholder shown when there's no text.
    ///  - editable: whether the text view should be editable.
    ///  - maxMessageLength: the maximum allowed message length.
    ///  - currentHeight: the current height of the view.
    /// - Returns: View shown in the composer text input slot.
    func makeComposerTextInputView(
        text: Binding<String>,
        height: Binding<CGFloat>,
        selectedRangeLocation: Binding<Int>,
        placeholder: String,
        editable: Bool,
        maxMessageLength: Int?,
        currentHeight: CGFloat
    ) -> ComposerTextInputViewType

    associatedtype TrailingComposerViewType: View
    /// Creates the trailing composer view.
    /// - Parameters:
    ///  - enabled: whether the view is enabled (e.g. button).
    ///  - cooldownDuration: Duration of cooldown for sending messages, in case slow mode is enabled.
    ///  - onTap: called when the view is tapped.
    /// - Returns: view displayed in the trailing area of the message composer view.
    func makeTrailingComposerView(
        enabled: Bool,
        cooldownDuration: Int,
        onTap: @escaping () -> Void
    ) -> TrailingComposerViewType

    associatedtype ComposerViewModifier: ViewModifier
    /// Creates the composer view modifier, that's applied to the whole composer view.
    func makeComposerViewModifier() -> ComposerViewModifier

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

    associatedtype ReactionsUsersViewType: View
    /// Creates the view that displays users that reacted to a message.
    /// - Parameters:
    ///  - message: the message for which reactions will be shown.
    ///  - maxHeight: the maxHeight of the view.
    /// - Returns: view displayed in the users reactions slot.
    func makeReactionsUsersView(
        message: ChatMessage,
        maxHeight: CGFloat
    ) -> ReactionsUsersViewType
    
    associatedtype ReactionsBottomViewType: View
    /// Creates a reactions view displayed below the message.
    /// This method is called only if `ReactionsPlacement` is set to `bottom`.
    /// - Parameters:
    ///  - message: the message for which reactions will be shown.
    ///  - showsAllInfo: whether all info is shown for this message.
    ///  - onTap: method called when the user taps on a reaction.
    ///  - onLongPress: method called when the user long presses on a reaction.
    /// - Returns: view displayed at the bottom reactions slot.
    func makeBottomReactionsView(
        message: ChatMessage,
        showsAllInfo: Bool,
        onTap: @escaping () -> Void,
        onLongPress: @escaping () -> Void
    ) -> ReactionsBottomViewType

    associatedtype MessageReactionViewType: View
    /// Creates the reactions view shown above the message.
    /// - Parameter message: the message for which reactions are shown.
    /// - Returns: view shown in the message reactions slot.
    func makeMessageReactionView(
        message: ChatMessage,
        onTapGesture: @escaping () -> Void,
        onLongPressGesture: @escaping () -> Void
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

    associatedtype ReactionsBackground: View
    /// Creates the reactions background view.
    /// - Parameters:
    ///  - currentSnapshot: the current snapshot of the message list screen.
    ///  - popInAnimationInProgress: whether the pop in animation is in progress.
    func makeReactionsBackgroundView(
        currentSnapshot: UIImage,
        popInAnimationInProgress: Bool
    ) -> ReactionsBackground

    associatedtype ReactionsContentView: View
    func makeReactionsContentView(
        message: ChatMessage,
        contentRect: CGRect,
        onReactionTap: @escaping (MessageReactionType) -> Void
    ) -> ReactionsContentView

    associatedtype QuotedMessageHeaderViewType: View
    /// Creates the quoted message header view in the composer.
    /// - Parameters:
    ///   - quotedMessage: the optional quoted message.
    /// - Returns: view displayed in the slot for quoted message in the composer.
    func makeQuotedMessageHeaderView(
        quotedMessage: Binding<ChatMessage?>
    ) -> QuotedMessageHeaderViewType

    associatedtype QuotedMessageViewType: View
    /// Creates the quoted message view, shown in the message list and the composer.
    /// - Parameters:
    ///  - quotedMessage: the quoted message.
    ///  - fillAvailableSpace: whether the quoted container should take all the available space.
    ///  - isInComposer: whether the quoted message is shown in the composer.
    ///  - scrolledId: binding of the scroll id, use it to scroll to the original message.
    func makeQuotedMessageView(
        quotedMessage: ChatMessage,
        fillAvailableSpace: Bool,
        isInComposer: Bool,
        scrolledId: Binding<String?>
    ) -> QuotedMessageViewType

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

    associatedtype MessageReadIndicatorViewType: View
    /// Creates the message read indicator view.
    /// - Parameters:
    ///  - channel: the channel where the message was sent.
    ///  - message: the sent message.
    /// - Returns: view shown in the message read indicator slot.
    func makeMessageReadIndicatorView(
        channel: ChatChannel,
        message: ChatMessage
    ) -> MessageReadIndicatorViewType
    
    associatedtype NewMessagesIndicatorViewType: View
    /// Creates a separator view showing the number of new messages in the message list.
    /// - Parameters:
    ///  - newMessagesStartId: the id of the message where the new messages start.
    ///  - count: the number of unread messages.
    /// - Returns: view shown in the new messages indicator slot.
    func makeNewMessagesIndicatorView(
        newMessagesStartId: Binding<String?>,
        count: Int
    ) -> NewMessagesIndicatorViewType
}
