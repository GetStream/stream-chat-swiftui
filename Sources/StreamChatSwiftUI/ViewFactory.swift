//
// Copyright © 2026 Stream.io Inc. All rights reserved.
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
    
    associatedtype ChannelAvatarViewType: View
    /// Creates the channel avatar view shown in the channel list, search results and the channel header.
    /// - Parameters:
    ///  - channel: the channel where the avatar is displayed.
    ///  - options: the options used to configure the avatar view.
    /// - Returns: view displayed in the channel avatar slot.
    func makeChannelAvatarView(
        for channel: ChatChannel,
        with options: ChannelAvatarViewOptions
    ) -> ChannelAvatarViewType

    associatedtype ChannelListBackground: View
    /// Creates the background for the channel list.
    /// - Parameter colors: the colors used in the SDK.
    /// - Returns: view shown as a background of the channel list.
    func makeChannelListBackground(colors: ColorPalette) -> ChannelListBackground

    associatedtype ChannelListItemBackground: View
    /// Creates the background for the channel list item.
    /// - Parameter channel: The channel which the item view belongs to.
    /// - Parameter isSelected: Whether the current item is selected or not.
    /// - Returns: The view shown as a background of the channel list item.
    func makeChannelListItemBackground(
        channel: ChatChannel,
        isSelected: Bool
    ) -> ChannelListItemBackground

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
    
    associatedtype ChannelListSearchResultsViewType: View
    /// Creates the view shown when the user is searching the channel list.
    /// - Parameters:
    ///  - selectedChannel - binding of the selected channel.
    ///  - searchResults - the search results matching the user query.
    ///  - loadingSearchResults - whether search results are being loaded.
    ///  - onlineIndicatorShown - whether the online indicator is shown.
    ///  - channelNaming - closure for determining the channel name.
    ///  - imageLoader - closure for loading images for channels.
    ///  - onSearchResultTap - call when a search result is tapped.
    ///  - onItemAppear - call when an item appears on the screen.
    /// - Returns: view shown in the channel list search results slot.
    func makeSearchResultsView(
        selectedChannel: Binding<ChannelSelectionInfo?>,
        searchResults: [ChannelSelectionInfo],
        loadingSearchResults: Bool,
        onlineIndicatorShown: @escaping (ChatChannel) -> Bool,
        channelNaming: @escaping (ChatChannel) -> String,
        imageLoader: @escaping (ChatChannel) -> UIImage,
        onSearchResultTap: @escaping (ChannelSelectionInfo) -> Void,
        onItemAppear: @escaping (Int) -> Void
    ) -> ChannelListSearchResultsViewType

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

    associatedtype BouncedMessageActionsModifierType: ViewModifier
    /// Returns a view modifier applied to the bounced message actions.
    ///
    /// This modifier is only used if `Utils.messageListConfig.bouncedMessagesAlertActionsEnabled` is `true`.
    /// By default the flag is true and the bounced actions are shown as an alert instead of a context menu.
    /// - Parameter viewModel: the view model of the chat channel view.
    func makeBouncedMessageActionsModifier(viewModel: ChatChannelViewModel) -> BouncedMessageActionsModifierType

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
    
    associatedtype ChangeBarsVisibilityModifier: ViewModifier
    /// Creates a view modifier that changes the visibility of bars.
    /// - Parameter shouldShow: A Boolean value indicating whether the bars should be shown.
    /// - Returns: A view modifier that changes the visibility of bars.
    func makeChannelBarsVisibilityViewModifier(shouldShow: Bool) -> ChangeBarsVisibilityModifier
    
    associatedtype ChannelLoadingViewType: View
    /// Creates a loading view for the channel.
    func makeChannelLoadingView() -> ChannelLoadingViewType

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

    associatedtype MessageTranslationFooterViewType: View
    /// Creates a view to display translation information below a message if it has been translated.
    /// - Parameters:
    ///   - messageViewModel: The message view model used to display information about the message.
    /// - Returns: A view to display translation information of the message.
    func makeMessageTranslationFooterView(
        messageViewModel: MessageViewModel
    ) -> MessageTranslationFooterViewType

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
    
    associatedtype GalleryViewType: View
    /// Creates the gallery view.
    /// - Parameters:
    ///  - mediaAttachments: the media attachments that will be displayed.
    ///  - message: the message whose attachments will be displayed.
    ///  - isShown: whether the gallery is shown.
    ///  - options: additional options used to configure the gallery view.
    ///  - Returns: view displayed in the gallery slot.
    func makeGalleryView(
        mediaAttachments: [MediaAttachment],
        message: ChatMessage,
        isShown: Binding<Bool>,
        options: MediaViewsOptions
    ) -> GalleryViewType
    
    associatedtype GalleryHeaderViewType: View
    /// Creates the gallery header view presented with a sheet.
    /// - Parameters:
    ///  - title: The title displayed in the header.
    ///  - subtitle: The subtitle displayed in the header.
    ///  - shown: Binding controlling whether the gallery is shown.
    /// - Returns: View displayed in the gallery header slot.
    func makeGalleryHeaderView(
        title: String,
        subtitle: String,
        shown: Binding<Bool>
    ) -> GalleryHeaderViewType
    
    associatedtype VideoPlayerViewType: View
    /// Creates the video player view.
    /// - Parameters:
    ///  - attachment: the video attachment that will be displayed.
    ///  - message: the message whose attachments will be displayed.
    ///  - isShown: whether the video player is shown.
    ///  - options: additional options used to configure the gallery view.
    ///  - Returns: view displayed in the video player slot.
    func makeVideoPlayerView(
        attachment: ChatMessageVideoAttachment,
        message: ChatMessage,
        isShown: Binding<Bool>,
        options: MediaViewsOptions
    ) -> VideoPlayerViewType
    
    associatedtype VideoPlayerHeaderViewType: View
    /// Creates the video player header view presented with a sheet.
    /// - Parameters:
    ///  - title: The title displayed in the header.
    ///  - subtitle: The subtitle displayed in the header.
    ///  - shown: Binding controlling whether the video player is shown.
    /// - Returns: View displayed in the video player header slot.
    func makeVideoPlayerHeaderView(
        title: String,
        subtitle: String,
        shown: Binding<Bool>
    ) -> VideoPlayerHeaderViewType
    
    associatedtype VideoPlayerFooterViewType: View
    /// Creates the video player footer view presented with a sheet.
    /// - Parameters:
    ///  - attachment: the video attachment that will be displayed.
    ///  - shown: Binding controlling whether the video player is shown.
    /// - Returns: View displayed in the video player footer slot.
    func makeVideoPlayerFooterView(
        attachment: ChatMessageVideoAttachment,
        shown: Binding<Bool>
    ) -> VideoPlayerFooterViewType

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
    
    associatedtype VoiceRecordingViewType: View
    /// Creates a view that displays voice recordings.
    /// - Parameters:
    ///   - message: the message that will be displayed.
    ///   - isFirst: whether it is first in the group (latest creation date).
    ///   - availableWidth: the available width for the view.
    ///   - scrolledId: Identifier for the message that should be scrolled to.
    ///  - Returns: view shown in the voice recording slot.
    func makeVoiceRecordingView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) -> VoiceRecordingViewType

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
    
    associatedtype MessageRepliesShownInChannelViewType: View
    /// Creates the message replies view for a reply that is also shown in a channel.
    /// - Parameters:
    ///  - channel: the channel where the message is sent.
    ///  - message: the message that's being replied to.
    ///  - parentMessage: the parent message.
    ///  - replyCount: the current number of replies.
    /// - Returns: view displayed in the message replies view slot.
    func makeMessageRepliesShownInChannelView(
        channel: ChatChannel,
        message: ChatMessage,
        parentMessage: ChatMessage,
        replyCount: Int
    ) -> MessageRepliesShownInChannelViewType

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
    
    associatedtype ComposerRecordingViewType: View
    /// Creates a view shown when the composer is recording a voice message.
    /// - Parameters:
    ///  - viewModel: the composer view model.
    ///  - gestureLocation: the current gesture location point.
    /// - Returns: view shown when the composer is recording.
    func makeComposerRecordingView(
        viewModel: MessageComposerViewModel,
        gestureLocation: CGPoint
    ) -> ComposerRecordingViewType
    
    associatedtype ComposerRecordingLockedViewType: View
    /// Creates a view shown when a voice recording is locked.
    ///  - Parameter viewModel: the composer view model.
    ///  - Returns: view shown in the locked recording slot.
    func makeComposerRecordingLockedView(
        viewModel: MessageComposerViewModel
    ) -> ComposerRecordingLockedViewType
    
    associatedtype ComposerRecordingTipViewType: View
    /// Creates a view shown when a recording tip is displayed.
    /// - Returns: view shown in the recording tip slot.
    func makeComposerRecordingTipView() -> ComposerRecordingTipViewType

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
    
    associatedtype QuotedMessageContentViewType: View
    /// Creates the quoted message content view.
    ///
    /// It is the view that is embedded in quoted message bubble view.
    ///
    /// - Parameters:
    ///  - options: configuration options for the quoted message content view.
    /// - Returns: view displayed in the quoted message content slot.
    func makeQuotedMessageContentView(
        options: QuotedMessageContentViewOptions
    ) -> QuotedMessageContentViewType
    
    associatedtype CustomAttachmentQuotedViewType: View
    /// Creates a quoted view for custom attachments. Returns `EmptyView` by default.
    /// - Parameter message: the quoted message.
    /// - Returns: view shown in quoted messages with custom attachments.
    func makeCustomAttachmentQuotedView(for message: ChatMessage) -> CustomAttachmentQuotedViewType

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
    
    associatedtype JumpToUnreadButtonType: View
    /// Creates a jump to unread button.
    /// - Parameters:
    ///  - channel: the current channel.
    ///  - onJumpToMessage: called when jump to message is tapped.
    ///  - onClose: called when the jump to unread should be dismissed.
    /// - Returns: view shown in the jump to unread slot.
    func makeJumpToUnreadButton(
        channel: ChatChannel,
        onJumpToMessage: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) -> JumpToUnreadButtonType

    associatedtype ComposerPollViewType: View
    /// Creates a composer poll view.
    /// - Returns: view shown in the composer poll slot.
    func makeComposerPollView(
        channelController: ChatChannelController,
        messageController: ChatMessageController?
    ) -> ComposerPollViewType

    associatedtype PollViewType: View
    /// Creates a poll view.
    /// - Parameters:
    ///  - message: the chat message containing the poll.
    ///  - poll: the poll to be displayed.
    ///  - isFirst: a boolean indicating if this is the first poll in the series.
    /// - Returns: view shown in the poll slot.
    func makePollView(
        message: ChatMessage,
        poll: Poll,
        isFirst: Bool
    ) -> PollViewType

    // MARK: - Threads

    associatedtype ThreadDestination: View
    /// Returns a function that creates the thread destination.
    func makeThreadDestination() -> (ChatThread) -> ThreadDestination

    associatedtype ThreadListItemType: View
    /// Creates the thread list item.
    /// - Parameters:
    ///  - thread: The thread being displayed.
    ///  - threadDestination: A closure that creates the thread destination.
    ///  - selectedThread: The binding of the currently selected thread.
    func makeThreadListItem(
        thread: ChatThread,
        threadDestination: @escaping (ChatThread) -> ThreadDestination,
        selectedThread: Binding<ThreadSelectionInfo?>
    ) -> ThreadListItemType

    associatedtype NoThreads: View
    /// Creates the view that is displayed when there are no threads available.
    func makeNoThreadsView() -> NoThreads

    associatedtype ThreadListErrorBannerView: View
    /// Creates the error view that is displayed at the bottom of the thread list.
    /// - Parameter onRefreshAction: The refresh action, to reload the threads.
    /// - Returns: Returns the error view shown as a banner at the bottom of the thread list.
    func makeThreadsListErrorBannerView(onRefreshAction: @escaping () -> Void) -> ThreadListErrorBannerView

    associatedtype ThreadListLoadingView: View
    /// Creates a loading view for the thread list.
    func makeThreadListLoadingView() -> ThreadListLoadingView

    associatedtype ThreadListContainerModifier: ViewModifier
    /// Creates a modifier that wraps the thread list. It can be used to handle additional state changes.
    /// - Parameter viewModel: The view model that manages the state of the thread list.
    func makeThreadListContainerViewModifier(viewModel: ChatThreadListViewModel) -> ThreadListContainerModifier

    associatedtype ThreadListHeaderViewModifier: ViewModifier
    /// Creates the thread list navigation header view modifier.
    ///  - Parameter title: the title displayed in the header.
    func makeThreadListHeaderViewModifier(title: String) -> ThreadListHeaderViewModifier

    associatedtype ThreadListHeaderView: View
    /// Creates the header view for the thread list.
    ///
    /// By default it shows a loading spinner if it is loading the initial threads,
    /// or shows a banner notifying that there are new threads to be fetched.
    func makeThreadListHeaderView(viewModel: ChatThreadListViewModel) -> ThreadListHeaderView

    associatedtype ThreadListFooterView: View
    /// Creates the footer view for the thread list.
    ///
    /// By default shows a loading spinner when loading more threads.
    func makeThreadListFooterView(viewModel: ChatThreadListViewModel) -> ThreadListFooterView

    associatedtype ThreadListBackground: View
    /// Creates the background for the thread list.
    /// - Parameter colors: The colors palette used in the SDK.
    /// - Returns: The view shown as a background of the thread list.
    func makeThreadListBackground(colors: ColorPalette) -> ThreadListBackground

    associatedtype ThreadListItemBackground: View
    /// Creates the background for the thread list item.
    /// - Parameter thread: The thread which the item view belongs to.
    /// - Parameter isSelected: Whether the current item is selected or not.
    /// - Returns: The view shown as a background of the thread list item.
    func makeThreadListItemBackground(
        thread: ChatThread,
        isSelected: Bool
    ) -> ThreadListItemBackground

    associatedtype ThreadListDividerItem: View
    /// Creates the thread list divider item.
    func makeThreadListDividerItem() -> ThreadListDividerItem
    
    associatedtype AddUsersViewType: View
    /// Creates a view for adding users to a chat or channel.
    /// - Parameters:
    ///   - options: Configuration options for the "add users" view, such as loaded user ids.
    ///   - onUserTap: A closure that is called when a `ChatUser` is tapped in the list.
    /// - Returns: The view shown in the add users slot.
    func makeAddUsersView(
        options: AddUsersOptions,
        onUserTap: @escaping (ChatUser) -> Void
    ) -> AddUsersViewType
    
    associatedtype AttachmentTextViewType: View
    /// Creates a view for displaying the text of an attachment.
    /// - Parameter options: Configuration options for the attachment text view, such as message.
    /// - Returns: The view shown in the attachment text slot.
    func makeAttachmentTextView(
        options: AttachmentTextViewOptions
    ) -> AttachmentTextViewType
}
