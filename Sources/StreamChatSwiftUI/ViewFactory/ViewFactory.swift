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

    associatedtype EmptyChannels: View
    /// Creates the view that is displayed when there are no channels available.
    func makeEmptyChannelsView(options: EmptyChannelsViewOptions) -> EmptyChannels

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

    associatedtype MessageItemViewType: View
    /// Creates the message item view.
    /// - Parameter options: the options for creating the message item view.
    /// - Returns: view shown in the message item slot.
    func makeMessageItemView(options: MessageItemViewOptions) -> MessageItemViewType

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

    associatedtype MessageTopViewType: View
    /// Creates the view shown above the message bubble containing message annotations.
    ///
    /// Annotations include: pinned, sent in channel / replied to thread, reminder, and translated.
    /// - Parameter options: The options for creating the message top view.
    /// - Returns: A view displaying all applicable message annotations.
    func makeMessageTopView(options: MessageTopViewOptions) -> MessageTopViewType

    associatedtype LastInGroupHeaderView: View
    /// Creates a view shown as a header of the last message in a group.
    /// - Parameter options: the options for creating the last in group header view.
    /// - Returns: view shown in the header of the last message.
    func makeLastInGroupHeaderView(options: LastInGroupHeaderViewOptions) -> LastInGroupHeaderView

    associatedtype MessageAttachmentsViewType: View
    /// Creates the message attachments view.
    /// - Parameter options: the options for creating the message attachments view.
    func makeMessageAttachmentsView(options: MessageAttachmentsViewOptions) -> MessageAttachmentsViewType

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

    associatedtype MediaViewerType: View
    /// Creates the gallery view.
    /// - Parameter options: the options for creating the gallery view.
    ///  - Returns: view displayed in the gallery slot.
    func makeMediaViewer(options: MediaViewerOptions) -> MediaViewerType
    
    associatedtype MediaViewerToolbarModifierType: ViewModifier
    /// Creates the toolbar modifier applied to the media viewer navigation content.
    /// - Parameter options: the options for creating the media viewer toolbar.
    /// - Returns: ViewModifier applied to the media viewer's navigation content.
    func makeMediaViewerToolbarModifier(options: MediaViewerToolbarModifierOptions) -> MediaViewerToolbarModifierType
    
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

    associatedtype InlineTypingIndicatorViewType: View
    /// Creates the typing indicator shown inline in the message list.
    /// - Parameter options: the options for creating the typing indicator view.
    /// - Returns: view shown in the inline typing indicator slot.
    func makeInlineTypingIndicatorView(options: TypingIndicatorViewOptions) -> InlineTypingIndicatorViewType

    associatedtype SubtitleTypingIndicatorViewType: View
    /// Creates the typing indicator shown in the channel header subtitle area.
    /// - Parameter options: the options for creating the subtitle typing indicator view.
    /// - Returns: view shown in the navigation bar subtitle when users are typing.
    func makeSubtitleTypingIndicatorView(options: SubtitleTypingIndicatorViewOptions) -> SubtitleTypingIndicatorViewType

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

    associatedtype SendMessageButtonType: View
    /// Creates the send message button.
    /// - Parameter options: the options for creating the send message button.
    /// - Returns: view displayed in the send button slot.
    func makeSendMessageButton(options: SendMessageButtonOptions) -> SendMessageButtonType

    associatedtype ConfirmEditButtonType: View
    /// Creates the confirm edit button.
    /// - Parameter options: the options for creating the confirm edit button.
    /// - Returns: view displayed in the confirm edit button slot.
    func makeConfirmEditButton(options: ConfirmEditButtonOptions) -> ConfirmEditButtonType
    
    associatedtype ComposerVoiceRecordingInputViewType: View
    /// Creates a unified voice recording input view shown when the composer
    /// is actively recording, locked, or stopped.
    /// - Parameter options: the options for creating the voice recording input view.
    /// - Returns: view shown in the voice recording input slot.
    func makeComposerVoiceRecordingInputView(options: ComposerVoiceRecordingInputViewOptions) -> ComposerVoiceRecordingInputViewType
    
    associatedtype AttachmentPickerViewType: View
    /// Creates the attachment picker view.
    /// - Parameter options: the options for creating the attachment picker view.
    /// - Returns: view displayed in the attachment picker slot.
    func makeAttachmentPickerView(options: AttachmentPickerViewOptions) -> AttachmentPickerViewType

    associatedtype AttachmentCommandsPickerViewType: View
    /// Creates the attachment commands picker view.
    /// - Parameter options: the options for creating the attachment commands picker view.
    /// - Returns: view displayed in the attachment commands picker slot.
    func makeAttachmentCommandsPickerView(options: AttachmentCommandsPickerViewOptions) -> AttachmentCommandsPickerViewType

    associatedtype AttachmentTypePickerViewType: View
    /// Creates the attachment type picker view.
    /// - Parameter options: the options for creating the attachment type picker view.
    /// - Returns: view displayed in the attachment type picker slot.
    func makeAttachmentTypePickerView(options: AttachmentTypePickerViewOptions) -> AttachmentTypePickerViewType

    associatedtype AttachmentMediaPickerViewType: View
    /// Creates the media attachment picker view.
    /// - Parameter options: the options for creating the media attachment picker view.
    /// - Returns: view displayed in the media attachment picker slot.
    func makeAttachmentMediaPickerView(options: AttachmentMediaPickerViewOptions) -> AttachmentMediaPickerViewType

    associatedtype AttachmentFilePickerViewType: View
    /// Creates the file attachment picker view.
    /// The view handles the prompt and presents the document picker.
    /// - Parameter options: the options for creating the file picker view.
    /// - Returns: view displayed in the file picker slot.
    func makeAttachmentFilePickerView(options: AttachmentFilePickerViewOptions) -> AttachmentFilePickerViewType

    associatedtype AttachmentCameraPickerViewType: View
    /// Creates the camera attachment picker view.
    /// The view handles the prompt, access denied state, and presents the camera.
    /// - Parameter options: the options for creating the camera picker view.
    /// - Returns: view displayed in the camera picker slot.
    func makeAttachmentCameraPickerView(options: AttachmentCameraPickerViewOptions) -> AttachmentCameraPickerViewType

    associatedtype CustomAttachmentPickerViewType: View
    /// Creates a custom attachment picker view shown in the message composer.
    /// - Parameter options: the options for creating the custom attachment picker view.
    /// - Returns: view shown in the custom attachment picker slot.
    func makeCustomAttachmentPickerView(options: CustomAttachmentPickerViewOptions) -> CustomAttachmentPickerViewType

    associatedtype CustomAttachmentPreviewViewType: View
    /// Creates a custom attachment view shown in the preview in the composer input.
    /// - Parameter options: the options for creating the custom attachment preview view.
    /// - Returns: view shown in the preview slot for custom composer input.
    func makeCustomAttachmentPreviewView(options: CustomAttachmentPreviewViewOptions) -> CustomAttachmentPreviewViewType

    associatedtype AttachmentPollPickerViewType: View
    /// Creates the poll attachment picker view.
    /// The view handles the prompt and presents the poll creation view.
    /// - Parameter options: the options for creating the poll picker view.
    /// - Returns: view displayed in the poll picker slot.
    func makeAttachmentPollPickerView(options: AttachmentPollPickerViewOptions) -> AttachmentPollPickerViewType

    associatedtype SendInChannelViewType: View
    /// Creates the view that allows thread messages to be sent in a channel.
    /// - Parameter options: the options for creating the send in channel view.
    func makeSendInChannelView(options: SendInChannelViewOptions) -> SendInChannelViewType

    associatedtype MessageActionsViewType: View
    /// Creates the message actions view.
    /// - Parameter options: the options for creating the message actions view.
    /// - Returns: view displayed in the message actions slot.
    func makeMessageActionsView(options: MessageActionsViewOptions) -> MessageActionsViewType
    
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

    associatedtype ReactionsContentView: View
    func makeReactionsContentView(options: ReactionsContentViewOptions) -> ReactionsContentView
    
    associatedtype MoreReactionsViewType: View
    /// Creates the more reactions view.
    /// - Parameter options: The options for creating the more reactions view.
    func makeMoreReactionsView(options: MoreReactionsViewOptions) -> MoreReactionsViewType

    associatedtype ReactionsDetailViewType: View
    /// Creates the reactions detail view.
    /// - Parameter options: the options for creating the reactions detail view.
    /// - Returns: view displayed in the reactions detail slot.
    func makeReactionsDetailView(options: ReactionsDetailViewOptions) -> ReactionsDetailViewType

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
    func makeMessageAttachmentPreviewThumbnailView(
        options: MessageAttachmentPreviewViewOptions
    ) -> MessageAttachmentPreviewViewType

    associatedtype MessageAttachmentPreviewIconViewType: View
    /// Creates the view for displaying an attachment preview icon.
    ///
    /// This view is used to show icons like photo, video, document, etc.
    ///
    /// - Parameter options: The options for creating the attachment preview icon view.
    func makeMessageAttachmentPreviewIconView(options: MessageAttachmentPreviewIconViewOptions) -> MessageAttachmentPreviewIconViewType

    associatedtype SuggestionsContainerViewType: View
    /// Creates the suggestions container view, above the composer.
    /// - Parameter options: the options for creating the suggestions container view.
    /// - Returns: view displayed in the suggestions container slot.
    func makeSuggestionsContainerView(options: SuggestionsContainerViewOptions) -> SuggestionsContainerViewType

    associatedtype MessageReadIndicatorViewType: View
    /// Creates the message read indicator view.
    /// - Parameter options: the options for creating the message read indicator view.
    /// - Returns: view shown in the message read indicator slot.
    func makeMessageReadIndicatorView(options: MessageReadIndicatorViewOptions) -> MessageReadIndicatorViewType
    
    associatedtype NewMessagesDividerType: View
    /// Creates the divider shown between read and unread messages.
    /// - Parameter options: the options for creating the new messages divider.
    /// - Returns: view shown in the new messages divider slot.
    func makeNewMessagesDividerView(options: NewMessagesDividerViewOptions) -> NewMessagesDividerType

    associatedtype ThreadRepliesDividerType: View
    /// Creates the divider shown between the parent message and replies in a thread.
    /// - Parameter options: the options for creating the thread replies divider.
    /// - Returns: view shown in the thread replies divider slot.
    func makeThreadRepliesDividerView(options: ThreadRepliesDividerViewOptions) -> ThreadRepliesDividerType
    
    associatedtype JumpToUnreadButtonOverlayType: ViewModifier
    /// Creates the jump to unread button overlay modifier.
    /// - Parameter options: the options for creating the jump to unread button overlay.
    /// - Returns: a view modifier that overlays the jump to unread button on the message list.
    func makeJumpToUnreadButtonOverlay(options: JumpToUnreadButtonOptions) -> JumpToUnreadButtonOverlayType

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

    associatedtype EmptyThreads: View
    /// Creates the view that is displayed when there are no threads available.
    func makeEmptyThreadsView(options: EmptyThreadsViewOptions) -> EmptyThreads
    
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
    /// Creates a text caption view displayed below attachments inside ``MessageAttachmentsView``.
    /// - Parameter options: Configuration options for the attachment text view.
    /// - Returns: The text caption view shown beneath attachments.
    func makeAttachmentTextView(
        options: AttachmentTextViewOptions
    ) -> AttachmentTextViewType

    associatedtype StreamTextViewType: View
    /// Creates a reusable text view for displaying message text.
    ///
    /// This view is shared across multiple message layouts, including
    /// standalone text messages and text captions within attachment views.
    /// - Parameter options: Configuration options such as the message to display.
    /// - Returns: The view shown in the text slot.
    func makeStreamTextView(
        options: StreamTextViewOptions
    ) -> StreamTextViewType
}
