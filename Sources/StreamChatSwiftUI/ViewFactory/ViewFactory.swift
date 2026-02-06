//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import Photos
import StreamChat
import SwiftUI

/// Factory used to create views.
@MainActor public protocol ViewFactory: AnyObject {
    var chatClient: ChatClient { get }

    associatedtype StylesType: Styles
    var styles: StylesType { get set }

    // MARK: - channels

    associatedtype HeaderViewModifier: ChannelListHeaderViewModifier
    /// Creates the channel list header view modifier.
    ///  - Parameter options: the options for creating the header view modifier.
    func makeChannelListHeaderViewModifier(options: ChannelListHeaderViewModifierOptions) -> HeaderViewModifier

    associatedtype NoChannels: View
    /// Creates the view that is displayed when there are no channels available.
    func makeNoChannelsView(options: NoChannelsViewOptions) -> NoChannels

    associatedtype LoadingContent: View
    /// Creates the loading view.
    func makeLoadingView(options: LoadingViewOptions) -> LoadingContent

    associatedtype ChannelListItemType: View
    /// Creates the channel list item.
    /// - Parameter options: the options for creating the channel list item.
    func makeChannelListItem(options: ChannelListItemOptions<ChannelDestination>) -> ChannelListItemType
    
    associatedtype ChannelAvatarViewType: View
    /// Creates the channel avatar view shown in the channel list, search results and the channel header.
    /// - Parameter options: the options for creating the channel avatar view.
    /// - Returns: view displayed in the channel avatar slot.
    func makeChannelAvatarView(options: ChannelAvatarViewOptions) -> ChannelAvatarViewType

    associatedtype ChannelListBackground: View
    /// Creates the background for the channel list.
    /// - Parameter options: the options for creating the channel list background.
    /// - Returns: view shown as a background of the channel list.
    func makeChannelListBackground(options: ChannelListBackgroundOptions) -> ChannelListBackground

    associatedtype ChannelListItemBackground: View
    /// Creates the background for the channel list item.
    /// - Parameter options: the options for creating the channel list item background.
    /// - Returns: The view shown as a background of the channel list item.
    func makeChannelListItemBackground(options: ChannelListItemBackgroundOptions) -> ChannelListItemBackground

    associatedtype ChannelListDividerItem: View
    /// Creates the channel list divider item.
    func makeChannelListDividerItem(options: ChannelListDividerItemOptions) -> ChannelListDividerItem

    associatedtype MoreActionsView: View
    /// Creates the more channel actions view.
    /// - Parameter options: the options for creating the more channel actions view.
    func makeMoreChannelActionsView(options: MoreChannelActionsViewOptions) -> MoreActionsView

    associatedtype TrailingSwipeActionsViewType: View
    /// Creates the trailing swipe actions view in the channel list.
    /// - Parameter options: the options for creating the trailing swipe actions view.
    /// - Returns: View displayed in the trailing swipe area of a channel item.
    func makeTrailingSwipeActionsView(options: TrailingSwipeActionsViewOptions) -> TrailingSwipeActionsViewType

    associatedtype LeadingSwipeActionsViewType: View
    /// Creates the leading swipe actions view in the channel list.
    /// - Parameter options: the options for creating the leading swipe actions view.
    /// - Returns: View displayed in the leading swipe area of a channel item.
    func makeLeadingSwipeActionsView(options: LeadingSwipeActionsViewOptions) -> LeadingSwipeActionsViewType

    associatedtype ChannelListTopViewType: View
    /// Creates the view shown at the top of the channel list. Suitable for search bar.
    /// - Parameter options: the options for creating the channel list top view.
    /// - Returns: view shown above the channel list.
    func makeChannelListTopView(options: ChannelListTopViewOptions) -> ChannelListTopViewType

    associatedtype ChannelListFooterViewType: View
    /// Creates the view shown at the bottom of the channel list.
    /// - Returns: view shown at the bottom of the channel list.
    func makeChannelListFooterView(options: ChannelListFooterViewOptions) -> ChannelListFooterViewType

    associatedtype ChannelListStickyFooterViewType: View
    /// Creates the view always visible at the bottom of the channel list.
    /// - Returns: view shown at the bottom of the channel list.
    func makeChannelListStickyFooterView(options: ChannelListStickyFooterViewOptions) -> ChannelListStickyFooterViewType
    
    associatedtype ChannelListSearchResultsViewType: View
    /// Creates the view shown when the user is searching the channel list.
    /// - Parameter options: the options for creating the search results view.
    /// - Returns: view shown in the channel list search results slot.
    func makeSearchResultsView(options: SearchResultsViewOptions) -> ChannelListSearchResultsViewType

    associatedtype ChannelListSearchResultItem: View
    /// Creates the search result item in the channel list.
    /// - Parameter options: the options for creating the channel list search result item.
    /// - Returns: view shown in the search results.
    func makeChannelListSearchResultItem(options: ChannelListSearchResultItemOptions<ChannelDestination>) -> ChannelListSearchResultItem

    // MARK: - messages

    associatedtype ChannelDestination: View
    /// Returns a function that creates the channel destination.
    func makeChannelDestination(options: ChannelDestinationOptions) -> @MainActor (ChannelSelectionInfo) -> ChannelDestination

    associatedtype MessageThreadDestination: View
    /// Returns a function that creats the message thread destination.
    func makeMessageThreadDestination(options: MessageThreadDestinationOptions) -> @MainActor (ChatChannel, ChatMessage) -> MessageThreadDestination

    associatedtype EmptyMessagesViewType: View
    /// Returns a view shown when there are no messages in a channel.
    /// - Parameter options: the options for creating the empty messages view.
    /// - Returns: View shown in the empty messages slot.
    func makeEmptyMessagesView(options: EmptyMessagesViewOptions) -> EmptyMessagesViewType

    associatedtype UserAvatarViewType: View
    /// Creates an avatar view for user.
    /// - Parameter options: the options for creating the message avatar view.
    func makeUserAvatarView(options: UserAvatarViewOptions) -> UserAvatarViewType

    associatedtype ChatHeaderViewModifier: ChatChannelHeaderViewModifier
    /// Creates the channel header view modifier.
    /// - Parameter options: the options for creating the channel header view modifier.
    func makeChannelHeaderViewModifier(options: ChannelHeaderViewModifierOptions) -> ChatHeaderViewModifier
    
    associatedtype ChangeBarsVisibilityModifier: ViewModifier
    /// Creates a view modifier that changes the visibility of bars.
    /// - Parameter options: the options for creating the channel bars visibility view modifier.
    /// - Returns: A view modifier that changes the visibility of bars.
    func makeChannelBarsVisibilityViewModifier(options: ChannelBarsVisibilityViewModifierOptions) -> ChangeBarsVisibilityModifier
    
    associatedtype ChannelLoadingViewType: View
    /// Creates a loading view for the channel.
    func makeChannelLoadingView(options: ChannelLoadingViewOptions) -> ChannelLoadingViewType

    associatedtype ThreadHeaderViewModifier: MessageThreadHeaderViewModifier
    /// Creates the message thread header view modifier.
    /// - Parameter options: the options for creating the message thread header view modifier.
    func makeMessageThreadHeaderViewModifier(options: MessageThreadHeaderViewModifierOptions) -> ThreadHeaderViewModifier

    associatedtype MessageListBackground: View
    /// Creates the background for the message list.
    /// - Parameter options: the options for creating the message list background.
    /// - Returns: view shown as a background for the message list.
    func makeMessageListBackground(options: MessageListBackgroundOptions) -> MessageListBackground

    associatedtype MessageContainerViewType: View
    /// Creates the message container view.
    /// - Parameter options: the options for creating the message container view.
    /// - Returns: view shown in the message container slot.
    func makeMessageContainerView(options: MessageContainerViewOptions) -> MessageContainerViewType

    associatedtype MessageTextViewType: View
    /// Creates the message text view.
    /// - Parameter options: the options for creating the message text view.
    ///  - Returns: view displayed in the text message slot.
    func makeMessageTextView(options: MessageTextViewOptions) -> MessageTextViewType

    associatedtype MessageDateViewType: View
    /// Creates a view for the date info shown below a message.
    /// - Parameter options: the options for creating the message date view.
    /// - Returns: view shown in the date indicator slot.
    func makeMessageDateView(options: MessageDateViewOptions) -> MessageDateViewType

    associatedtype MessageAuthorAndDateViewType: View
    /// Creates a view for the date and author info shown below a message.
    /// - Parameter options: the options for creating the message author and date view.
    /// - Returns: view shown in the date and author indicator slot.
    func makeMessageAuthorAndDateView(options: MessageAuthorAndDateViewOptions) -> MessageAuthorAndDateViewType

    associatedtype MessageTranslationFooterViewType: View
    /// Creates a view to display translation information below a message if it has been translated.
    /// - Parameter options: the options for creating the message translation footer view.
    /// - Returns: A view to display translation information of the message.
    func makeMessageTranslationFooterView(options: MessageTranslationFooterViewOptions) -> MessageTranslationFooterViewType

    associatedtype LastInGroupHeaderView: View
    /// Creates a view shown as a header of the last message in a group.
    /// - Parameter options: the options for creating the last in group header view.
    /// - Returns: view shown in the header of the last message.
    func makeLastInGroupHeaderView(options: LastInGroupHeaderViewOptions) -> LastInGroupHeaderView

    associatedtype ImageAttachmentViewType: View
    /// Creates the image attachment view.
    /// - Parameter options: the options for creating the image attachment view.
    ///  - Returns: view displayed in the image attachment slot.
    func makeImageAttachmentView(options: ImageAttachmentViewOptions) -> ImageAttachmentViewType

    associatedtype GiphyAttachmentViewType: View
    /// Creates the giphy attachment view.
    /// - Parameter options: the options for creating the giphy attachment view.
    ///  - Returns: view displayed in the giphy attachment slot.
    func makeGiphyAttachmentView(options: GiphyAttachmentViewOptions) -> GiphyAttachmentViewType

    associatedtype LinkAttachmentViewType: View
    /// Creates the link attachment view.
    /// - Parameter options: the options for creating the link attachment view.
    ///  - Returns: view displayed in the link attachment slot.
    func makeLinkAttachmentView(options: LinkAttachmentViewOptions) -> LinkAttachmentViewType

    associatedtype FileAttachmentViewType: View
    /// Creates the file attachment view.
    /// - Parameter options: the options for creating the file attachment view.
    ///  - Returns: view displayed in the file attachment slot.
    func makeFileAttachmentView(options: FileAttachmentViewOptions) -> FileAttachmentViewType

    associatedtype VideoAttachmentViewType: View
    /// Creates the video attachment view.
    /// - Parameter options: the options for creating the video attachment view.
    ///  - Returns: view displayed in the video attachment slot.
    func makeVideoAttachmentView(options: VideoAttachmentViewOptions) -> VideoAttachmentViewType
    
    associatedtype GalleryViewType: View
    /// Creates the gallery view.
    /// - Parameter options: the options for creating the gallery view.
    ///  - Returns: view displayed in the gallery slot.
    func makeGalleryView(options: GalleryViewOptions) -> GalleryViewType
    
    associatedtype GalleryHeaderViewType: View
    /// Creates the gallery header view presented with a sheet.
    /// - Parameter options: the options for creating the gallery header view.
    /// - Returns: View displayed in the gallery header slot.
    func makeGalleryHeaderView(options: GalleryHeaderViewOptions) -> GalleryHeaderViewType
    
    associatedtype VideoPlayerViewType: View
    /// Creates the video player view.
    /// - Parameter options: the options for creating the video player view.
    ///  - Returns: view displayed in the video player slot.
    func makeVideoPlayerView(options: VideoPlayerViewOptions) -> VideoPlayerViewType
    
    associatedtype VideoPlayerHeaderViewType: View
    /// Creates the video player header view presented with a sheet.
    /// - Parameter options: the options for creating the video player header view.
    /// - Returns: View displayed in the video player header slot.
    func makeVideoPlayerHeaderView(options: VideoPlayerHeaderViewOptions) -> VideoPlayerHeaderViewType
    
    associatedtype VideoPlayerFooterViewType: View
    /// Creates the video player footer view presented with a sheet.
    /// - Parameter options: the options for creating the video player footer view.
    /// - Returns: View displayed in the video player footer slot.
    func makeVideoPlayerFooterView(options: VideoPlayerFooterViewOptions) -> VideoPlayerFooterViewType

    associatedtype DeletedMessageViewType: View
    /// Creates the deleted message view.
    /// - Parameter options: the options for creating the deleted message view.
    ///  - Returns: view displayed in the deleted message slot.
    func makeDeletedMessageView(options: DeletedMessageViewOptions) -> DeletedMessageViewType

    associatedtype SystemMessageViewType: View
    /// Creates the view for displaying system messages.
    /// - Parameter options: the options for creating the system message view.
    /// - Returns: view displayed when a system message appears.
    func makeSystemMessageView(options: SystemMessageViewOptions) -> SystemMessageViewType

    associatedtype EmojiTextViewType: View
    /// Creates the view displaying emojis.
    /// - Parameter options: the options for creating the emoji text view.
    func makeEmojiTextView(options: EmojiTextViewOptions) -> EmojiTextViewType
    
    associatedtype VoiceRecordingViewType: View
    /// Creates a view that displays voice recordings.
    /// - Parameter options: the options for creating the voice recording view.
    ///  - Returns: view shown in the voice recording slot.
    func makeVoiceRecordingView(options: VoiceRecordingViewOptions) -> VoiceRecordingViewType

    associatedtype CustomAttachmentViewType: View
    /// Creates custom attachment view.
    /// If support for more than one custom view is needed, just do if-else check inside the view.
    /// - Parameter options: the options for creating the custom attachment view.
    ///  - Returns: view displayed in the custom attachment slot.
    func makeCustomAttachmentViewType(options: CustomAttachmentViewTypeOptions) -> CustomAttachmentViewType

    associatedtype ScrollToBottomButtonType: View
    /// Creates the scroll to bottom button.
    /// - Parameter options: the options for creating the scroll to bottom button.
    /// - Returns: view displayed in the scroll to bottom slot.
    func makeScrollToBottomButton(options: ScrollToBottomButtonOptions) -> ScrollToBottomButtonType

    associatedtype DateIndicatorViewType: View
    /// Creates the date indicator view.
    /// - Parameter options: the options for creating the date indicator view.
    /// - Returns: view in the date indicator slot.
    func makeDateIndicatorView(options: DateIndicatorViewOptions) -> DateIndicatorViewType

    associatedtype MessageListDateIndicatorViewType: View
    /// Creates the date indicator view in the message list.
    /// - Parameter options: the options for creating the message list date indicator.
    /// - Returns: view shown above messages separated by date.
    func makeMessageListDateIndicator(options: MessageListDateIndicatorViewOptions) -> MessageListDateIndicatorViewType

    associatedtype TypingIndicatorBottomViewType: View
    /// Creates the typing indicator shown at the bottom of a message list.
    /// - Parameter options: the options for creating the typing indicator bottom view.
    /// - Returns: view shown in the typing indicator slot.
    func makeTypingIndicatorBottomView(options: TypingIndicatorBottomViewOptions) -> TypingIndicatorBottomViewType

    associatedtype GiphyBadgeViewType: View
    /// Creates giphy badge view.
    /// If support for more than one custom view is needed, just do if-else check inside the view.
    /// - Parameter options: the options for creating the giphy badge view.
    ///  - Returns: view displayed in the giphy badge slot.
    func makeGiphyBadgeViewType(options: GiphyBadgeViewTypeOptions) -> GiphyBadgeViewType

    associatedtype MessageRepliesViewType: View
    /// Creates the message replies view.
    /// - Parameter options: the options for creating the message replies view.
    /// - Returns: view displayed in the message replies view slot.
    func makeMessageRepliesView(options: MessageRepliesViewOptions) -> MessageRepliesViewType
    
    associatedtype MessageRepliesShownInChannelViewType: View
    /// Creates the message replies view for a reply that is also shown in a channel.
    /// - Parameter options: the options for creating the message replies shown in channel view.
    /// - Returns: view displayed in the message replies view slot.
    func makeMessageRepliesShownInChannelView(options: MessageRepliesShownInChannelViewOptions) -> MessageRepliesShownInChannelViewType

    associatedtype MessageComposerViewType: View
    /// Creates the message composer view.
    /// - Parameter options: the options for creating the message composer view.
    /// - Returns: view displayed in the message composer slot.
    func makeMessageComposerViewType(options: MessageComposerViewTypeOptions) -> MessageComposerViewType

    associatedtype LeadingComposerViewType: View
    /// Creates the leading part of the composer view.
    /// - Parameter options: the options for creating the leading composer view.
    /// - Returns: view displayed in the leading part of the message composer view.
    func makeLeadingComposerView(options: LeadingComposerViewOptions) -> LeadingComposerViewType

    /// Creates the composer input view.
    /// - Parameter options: the options for creating the composer input view.
    /// - Returns: view displayed in the middle area of the message composer view.
    associatedtype ComposerInputViewType: View
    func makeComposerInputView(options: ComposerInputViewOptions) -> ComposerInputViewType
    
    associatedtype ComposerTextInputViewType: View
    /// Creates the composer input view.
    /// - Parameter options: the options for creating the composer text input view.
    /// - Returns: View shown in the composer text input slot.
    func makeComposerTextInputView(options: ComposerTextInputViewOptions) -> ComposerTextInputViewType
    
    associatedtype ComposerInputTrailingViewType: View
    func makeComposerInputTrailingView(options: ComposerInputTrailingViewOptions) -> ComposerInputTrailingViewType

    associatedtype TrailingComposerViewType: View
    /// Creates the trailing composer view.
    /// - Parameter options: the options for creating the trailing composer view.
    /// - Returns: view displayed in the trailing area of the message composer view.
    func makeTrailingComposerView(options: TrailingComposerViewOptions) -> TrailingComposerViewType
    
    associatedtype ComposerRecordingViewType: View
    /// Creates a view shown when the composer is recording a voice message.
    /// - Parameter options: the options for creating the composer recording view.
    /// - Returns: view shown when the composer is recording.
    func makeComposerRecordingView(options: ComposerRecordingViewOptions) -> ComposerRecordingViewType
    
    associatedtype ComposerRecordingLockedViewType: View
    /// Creates a view shown when a voice recording is locked.
    ///  - Parameter options: the options for creating the composer recording locked view.
    ///  - Returns: view shown in the locked recording slot.
    func makeComposerRecordingLockedView(options: ComposerRecordingLockedViewOptions) -> ComposerRecordingLockedViewType
    
    associatedtype ComposerRecordingTipViewType: View
    /// Creates a view shown when a recording tip is displayed.
    /// - Returns: view shown in the recording tip slot.
    func makeComposerRecordingTipView(options: ComposerRecordingTipViewOptions) -> ComposerRecordingTipViewType

    associatedtype AttachmentPickerViewType: View
    /// Creates the attachment picker view.
    /// - Parameter options: the options for creating the attachment picker view.
    /// - Returns: view displayed in the attachment picker slot.
    func makeAttachmentPickerView(options: AttachmentPickerViewOptions) -> AttachmentPickerViewType

    associatedtype AttachmentSourcePickerViewType: View
    /// Creates the attachment source picker view.
    /// - Parameter options: the options for creating the attachment source picker view.
    /// - Returns: view displayed in the attachment source picker slot.
    func makeAttachmentSourcePickerView(options: AttachmentSourcePickerViewOptions) -> AttachmentSourcePickerViewType

    associatedtype PhotoAttachmentPickerViewType: View
    /// Creates the photo attachment picker view.
    /// - Parameter options: the options for creating the photo attachment picker view.
    /// - Returns: view displayed in the photo attachment picker slot.
    func makePhotoAttachmentPickerView(options: PhotoAttachmentPickerViewOptions) -> PhotoAttachmentPickerViewType

    associatedtype FilePickerViewType: View
    /// Creates the file picker view.
    /// - Parameter options: the options for creating the file picker view.
    /// - Returns: view displayed in the file picker slot.
    func makeFilePickerView(options: FilePickerViewOptions) -> FilePickerViewType

    associatedtype CameraPickerViewType: View
    /// Creates the camera picker view.
    /// - Parameter options: the options for creating the camera picker view.
    /// - Returns: view displayed in the camera picker slot.
    func makeCameraPickerView(options: CameraPickerViewOptions) -> CameraPickerViewType

    associatedtype CustomComposerAttachmentViewType: View
    /// Creates a custom attachment view shown in the message composer.
    /// - Parameter options: the options for creating the custom attachment view.
    /// - Returns: view shown in the custom slot in the message composer.
    func makeCustomAttachmentView(options: CustomComposerAttachmentViewOptions) -> CustomComposerAttachmentViewType

    associatedtype CustomAttachmentPreviewViewType: View
    /// Creates a custom attachment view shown in the preview in the composer input.
    /// - Parameter options: the options for creating the custom attachment preview view.
    /// - Returns: view shown in the preview slot for custom composer input.
    func makeCustomAttachmentPreviewView(options: CustomAttachmentPreviewViewOptions) -> CustomAttachmentPreviewViewType

    associatedtype AssetsAccessPermissionViewType: View
    /// Creates the assets access permission view.
    func makeAssetsAccessPermissionView(options: AssetsAccessPermissionViewOptions) -> AssetsAccessPermissionViewType

    associatedtype SendInChannelViewType: View
    /// Creates the view that allows thread messages to be sent in a channel.
    /// - Parameter options: the options for creating the send in channel view.
    func makeSendInChannelView(options: SendInChannelViewOptions) -> SendInChannelViewType

    associatedtype MessageActionsViewType: View
    /// Creates the message actions view.
    /// - Parameter options: the options for creating the message actions view.
    /// - Returns: view displayed in the message actions slot.
    func makeMessageActionsView(options: MessageActionsViewOptions) -> MessageActionsViewType

    associatedtype ReactionsUsersViewType: View
    /// Creates the view that displays users that reacted to a message.
    /// - Parameter options: the options for creating the reactions users view.
    /// - Returns: view displayed in the users reactions slot.
    func makeReactionsUsersView(options: ReactionsUsersViewOptions) -> ReactionsUsersViewType
    
    associatedtype ReactionsBottomViewType: View
    /// Creates a reactions view displayed below the message.
    /// This method is called only if `ReactionsPlacement` is set to `bottom`.
    /// - Parameter options: the options for creating the bottom reactions view.
    /// - Returns: view displayed at the bottom reactions slot.
    func makeBottomReactionsView(options: ReactionsBottomViewOptions) -> ReactionsBottomViewType

    associatedtype MessageReactionViewType: View
    /// Creates the reactions view shown above the message.
    /// - Parameter options: the options for creating the message reaction view.
    /// - Returns: view shown in the message reactions slot.
    func makeMessageReactionView(options: MessageReactionViewOptions) -> MessageReactionViewType

    associatedtype ReactionsOverlayViewType: View
    /// Creates the reactions overlay view.
    /// - Parameter options: the options for creating the reactions overlay view.
    /// - Returns: view displayed in the reactions overlay slot.
    func makeReactionsOverlayView(options: ReactionsOverlayViewOptions) -> ReactionsOverlayViewType

    associatedtype ReactionsBackground: View
    /// Creates the reactions background view.
    /// - Parameter options: the options for creating the reactions background view.
    func makeReactionsBackgroundView(options: ReactionsBackgroundOptions) -> ReactionsBackground

    associatedtype ReactionsContentView: View
    func makeReactionsContentView(options: ReactionsContentViewOptions) -> ReactionsContentView
    
    associatedtype MoreReactionsViewType: View
    /// Creates the more reactions view.
    /// - Parameter options: The options for creating the more reactions view.
    func makeMoreReactionsView(options: MoreReactionsViewOptions) -> MoreReactionsViewType

    associatedtype ComposerQuotedMessageViewType: View
    /// Creates the quoted message view shown in the composer.
    /// - Parameter options: the options for creating the composer quoted message view.
    func makeComposerQuotedMessageView(options: ComposerQuotedMessageViewOptions) -> ComposerQuotedMessageViewType

    associatedtype ChatQuotedMessageViewType: View
    /// Creates the quoted message view shown in the message list.
    /// - Parameter options: the options for creating the chat quoted message view.
    func makeChatQuotedMessageView(options: ChatQuotedMessageViewOptions) -> ChatQuotedMessageViewType

    associatedtype QuotedMessageViewType: View
    /// Creates the base quoted message view used by both composer and message list containers.
    /// - Parameter options: the options for creating the quoted message view.
    func makeQuotedMessageView(options: QuotedMessageViewOptions) -> QuotedMessageViewType

    associatedtype ComposerEditedMessageViewType: View
    /// Creates the edited message view shown in the composer when editing a message.
    /// - Parameter options: the options for creating the composer edited message view.
    func makeComposerEditedMessageView(options: ComposerEditedMessageViewOptions) -> ComposerEditedMessageViewType

    associatedtype MessageAttachmentPreviewViewType: View
    /// Creates the attachment preview view for a message.
    ///
    /// - Parameter options: The options containing the thumbnail to display.
    func makeMessageAttachmentPreviewView(
        options: MessageAttachmentPreviewViewOptions
    ) -> MessageAttachmentPreviewViewType

    associatedtype MessageAttachmentPreviewIconViewType: View
    /// Creates the view for displaying an attachment preview icon in a reference message.
    ///
    /// This view is used to show icons like photo, video, document, etc. in the
    /// subtitle area of quoted messages or edited message previews.
    ///
    /// The options include an icon type. The view is responsible for resolving the icon to an image.
    ///
    /// - Parameter options: The options for creating the attachment preview icon view.
    func makeMessageAttachmentPreviewIconView(options: MessageAttachmentPreviewIconViewOptions) -> MessageAttachmentPreviewIconViewType

    associatedtype CommandsContainerViewType: View
    /// Creates the commands container view, above the composer.
    /// - Parameter options: the options for creating the commands container view.
    /// - Returns: view displayed in the commands container slot.
    func makeCommandsContainerView(options: CommandsContainerViewOptions) -> CommandsContainerViewType

    associatedtype MessageReadIndicatorViewType: View
    /// Creates the message read indicator view.
    /// - Parameter options: the options for creating the message read indicator view.
    /// - Returns: view shown in the message read indicator slot.
    func makeMessageReadIndicatorView(options: MessageReadIndicatorViewOptions) -> MessageReadIndicatorViewType
    
    associatedtype NewMessagesIndicatorViewType: View
    /// Creates a separator view showing the number of new messages in the message list.
    /// - Parameter options: the options for creating the new messages indicator view.
    /// - Returns: view shown in the new messages indicator slot.
    func makeNewMessagesIndicatorView(options: NewMessagesIndicatorViewOptions) -> NewMessagesIndicatorViewType
    
    associatedtype JumpToUnreadButtonType: View
    /// Creates a jump to unread button.
    /// - Parameter options: the options for creating the jump to unread button.
    /// - Returns: view shown in the jump to unread slot.
    func makeJumpToUnreadButton(options: JumpToUnreadButtonOptions) -> JumpToUnreadButtonType

    associatedtype ComposerPollViewType: View
    /// Creates a composer poll view.
    /// - Parameter options: the options for creating the composer poll view.
    /// - Returns: view shown in the composer poll slot.
    func makeComposerPollView(options: ComposerPollViewOptions) -> ComposerPollViewType

    associatedtype PollViewType: View
    /// Creates a poll view.
    /// - Parameter options: the options for creating the poll view.
    /// - Returns: view shown in the poll slot.
    func makePollView(options: PollViewOptions) -> PollViewType

    // MARK: - Threads

    associatedtype ThreadDestination: View
    /// Returns a function that creates the thread destination.
    func makeThreadDestination(options: ThreadDestinationOptions) -> @MainActor (ChatThread) -> ThreadDestination

    associatedtype ThreadListItemType: View
    /// Creates the thread list item.
    /// - Parameter options: the options for creating the thread list item.
    func makeThreadListItem(options: ThreadListItemOptions<ThreadDestination>) -> ThreadListItemType

    associatedtype NoThreads: View
    /// Creates the view that is displayed when there are no threads available.
    func makeNoThreadsView(options: NoThreadsViewOptions) -> NoThreads

    associatedtype ThreadListErrorBannerView: View
    /// Creates the error view that is displayed at the bottom of the thread list.
    /// - Parameter options: the options for creating the threads list error banner view.
    /// - Returns: Returns the error view shown as a banner at the bottom of the thread list.
    func makeThreadsListErrorBannerView(options: ThreadListErrorBannerViewOptions) -> ThreadListErrorBannerView

    associatedtype ThreadListLoadingView: View
    /// Creates a loading view for the thread list.
    func makeThreadListLoadingView(options: ThreadListLoadingViewOptions) -> ThreadListLoadingView

    associatedtype ThreadListContainerModifier: ViewModifier
    /// Creates a modifier that wraps the thread list. It can be used to handle additional state changes.
    /// - Parameter options: the options for creating the thread list container view modifier.
    func makeThreadListContainerViewModifier(options: ThreadListContainerModifierOptions) -> ThreadListContainerModifier

    associatedtype ThreadListHeaderViewModifier: ViewModifier
    /// Creates the thread list navigation header view modifier.
    ///  - Parameter options: the options for creating the thread list header view modifier.
    func makeThreadListHeaderViewModifier(options: ThreadListHeaderViewModifierOptions) -> ThreadListHeaderViewModifier

    associatedtype ThreadListHeaderView: View
    /// Creates the header view for the thread list.
    ///
    /// By default it shows a loading spinner if it is loading the initial threads,
    /// or shows a banner notifying that there are new threads to be fetched.
    /// - Parameter options: the options for creating the thread list header view.
    func makeThreadListHeaderView(options: ThreadListHeaderViewOptions) -> ThreadListHeaderView

    associatedtype ThreadListFooterView: View
    /// Creates the footer view for the thread list.
    ///
    /// By default shows a loading spinner when loading more threads.
    /// - Parameter options: the options for creating the thread list footer view.
    func makeThreadListFooterView(options: ThreadListFooterViewOptions) -> ThreadListFooterView

    associatedtype ThreadListBackground: View
    /// Creates the background for the thread list.
    /// - Parameter options: the options for creating the thread list background.
    /// - Returns: The view shown as a background of the thread list.
    func makeThreadListBackground(options: ThreadListBackgroundOptions) -> ThreadListBackground

    associatedtype ThreadListItemBackground: View
    /// Creates the background for the thread list item.
    /// - Parameter options: the options for creating the thread list item background.
    /// - Returns: The view shown as a background of the thread list item.
    func makeThreadListItemBackground(options: ThreadListItemBackgroundOptions) -> ThreadListItemBackground

    associatedtype ThreadListDividerItem: View
    /// Creates the thread list divider item.
    func makeThreadListDividerItem(options: ThreadListDividerItemOptions) -> ThreadListDividerItem
    
    associatedtype AddUsersViewType: View
    /// Creates a view for adding users to a chat or channel.
    /// - Parameter options: the options for creating the add users view.
    /// - Returns: The view shown in the add users slot.
    func makeAddUsersView(options: AddUsersViewOptions) -> AddUsersViewType
    
    associatedtype AttachmentTextViewType: View
    /// Creates a view for displaying the text of an attachment.
    /// - Parameter options: Configuration options for the attachment text view, such as message.
    /// - Returns: The view shown in the attachment text slot.
    func makeAttachmentTextView(
        options: AttachmentTextViewOptions
    ) -> AttachmentTextViewType
}
