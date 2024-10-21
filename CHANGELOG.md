# StreamChatSwiftUI iOS SDK CHANGELOG
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

# Upcoming

### 🐞 Fixed
- Fix crash when opening message overlay in iPad with a TabBar [#627](https://github.com/GetStream/stream-chat-swiftui/pull/627)

# [4.65.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.65.0)
_October 18, 2024_

### ✅ Added
- New Thread List UI Component [#621](https://github.com/GetStream/stream-chat-swiftui/pull/621)
- Handles marking a thread read in `ChatChannelViewModel` [#621](https://github.com/GetStream/stream-chat-swiftui/pull/621)
- Adds `ViewFactory.makeChannelListItemBackground` [#621](https://github.com/GetStream/stream-chat-swiftui/pull/621)
### 🐞 Fixed
- Fix Channel List loading view shimmering effect not working [#621](https://github.com/GetStream/stream-chat-swiftui/pull/621)
- Fix Channel List not preselecting the Channel on iPad [#621](https://github.com/GetStream/stream-chat-swiftui/pull/621)
### 🔄 Changed
- Channel List Item has now a background color when it is selected on iPad [#621](https://github.com/GetStream/stream-chat-swiftui/pull/621)

# [4.64.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.64.0)
_October 03, 2024_

### 🔄 Changed
- Improves Poll voting UX by making it possible to tap on the whole option as well [#612](https://github.com/GetStream/stream-chat-swiftui/pull/612)
### 🐞 Fixed
- Rare crash when accessing frame of the view [#607](https://github.com/GetStream/stream-chat-swiftui/pull/607)
- `ChatChannelListView` navigation did not trigger when using a custom container and its body reloaded [#609](https://github.com/GetStream/stream-chat-swiftui/pull/609)
- Channel was sometimes not marked as read when tapping the x on the unread message pill in the message list [#610](https://github.com/GetStream/stream-chat-swiftui/pull/610)
- Channel was sometimes not selected if `ChatChannelViewModel.selectedChannelId` was set to a channel created a moments ago [#611](https://github.com/GetStream/stream-chat-swiftui/pull/611)
- Fix the poll vote progress view not having full width when the Poll is closed [#612](https://github.com/GetStream/stream-chat-swiftui/pull/612)
- Fix the last vote author not accurate in the channel preview [#612](https://github.com/GetStream/stream-chat-swiftui/pull/612)

# [4.63.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.63.0)
_September 12, 2024_

### ✅ Added
- Configuration for padding for quoted message views [#598](https://github.com/GetStream/stream-chat-swiftui/pull/598)

### 🔄 Changed
- Improved subtitle info in pinned messages view [#594](https://github.com/GetStream/stream-chat-swiftui/pull/594)
- The `image(for channel: ChatChannel)` in `ChannelHeaderLoader` is now open [#595](https://github.com/GetStream/stream-chat-swiftui/pull/595) 
- FlagMessage Action is now only shown if the user has a permission to perform the action [#599](https://github.com/GetStream/stream-chat-swiftui/pull/599) 

### 🐞 Fixed
- Typing users did not update reliably in the message list [#591](https://github.com/GetStream/stream-chat-swiftui/pull/591)
- Channel was sometimes marked as read when the first unread message was one of the first not visible messages [#593](https://github.com/GetStream/stream-chat-swiftui/pull/593)
- Jump to first unread message button in the message list was not possible to close in some cases [#600](https://github.com/GetStream/stream-chat-swiftui/pull/600)

# [4.62.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.62.0)
_August 16, 2024_

### 🐞 Fixed
- Fix markdown links with query parameters [#581](https://github.com/GetStream/stream-chat-swiftui/pull/581)
	- Limitation: markdown link that includes parameters without protocol prefix is not handled at the moment.
	- Example: [text](link.com?a=b) will not be presented as markdown, while [text](https://link.com?a=b) will be.
- Fix updating of mentioned users when sending a message [#582](https://github.com/GetStream/stream-chat-swiftui/pull/582)

# [4.61.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.61.0)
_July 31, 2024_

### ⚡ Performance
- Optimise channel list view updates [#561](https://github.com/GetStream/stream-chat-swiftui/pull/561)

### 🐞 Fixed
- Media and files attachments not showing in channel info view [#554](https://github.com/GetStream/stream-chat-swiftui/pull/554)
- Bottom reactions configuration not always updating reactions [#557](https://github.com/GetStream/stream-chat-swiftui/pull/557)

### 🔄 Changed
- Channel list views do not use explicit id anymore [#561](https://github.com/GetStream/stream-chat-swiftui/pull/561)
- Deprecate `ChannelAvatarView` initializer `init(avatar:showOnlineIndicator:size:)` in favor of `init(channel:showOnlineIndicator:size:)` [#561](https://github.com/GetStream/stream-chat-swiftui/pull/561)

# [4.60.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.60.0)
_July 19, 2024_

### ✅ Added
- Public init of PhotoAttachmentCell [#544](https://github.com/GetStream/stream-chat-swiftui/pull/544)
- Public init for AudioRecordingInfo [547](https://github.com/GetStream/stream-chat-swiftui/pull/547)

### 🐞 Fixed
- Update of search results when slowly typing [#550](https://github.com/GetStream/stream-chat-swiftui/issues/550)

# [4.59.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.59.0)
_July 10, 2024_

### ✅ Added
- Added message actions for user blocking [#532](https://github.com/GetStream/stream-chat-swiftui/pull/532)

### 🐞 Fixed
- Smoother and more performant view updates in channel and message lists [#522](https://github.com/GetStream/stream-chat-swiftui/pull/522)
- Fix scrolling location when jumping to a message not in the currently loaded message list [#533](https://github.com/GetStream/stream-chat-swiftui/pull/533)
- Fix display of the most votes icon in Polls [#538](https://github.com/GetStream/stream-chat-swiftui/pull/538)
- Fix message author information not reflecting the latest state [#540](https://github.com/GetStream/stream-chat-swiftui/pull/540)

# [4.58.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.58.0)
_June 27, 2024_

### ✅ Added
- Thread replies shown in channel indicator [#518](https://github.com/GetStream/stream-chat-swiftui/pull/518)

### 🐞 Fixed
- Dismiss the channel when leaving a group [#519](https://github.com/GetStream/stream-chat-swiftui/pull/519)
- Dismiss keyboard when tapping on the empty message list [#513](https://github.com/GetStream/stream-chat-swiftui/pull/513)
- Reset composer text when there is provisional text (e.g. Japanese - kana keyboard) but the text is reset to empty string [#512](https://github.com/GetStream/stream-chat-swiftui/pull/512)
- Visibility of the comments button in anonymous polls [#524](https://github.com/GetStream/stream-chat-swiftui/pull/524)

### 🔄 Changed
- Show inline alert banner when encountering a failure while interacting with polls [#504](https://github.com/GetStream/stream-chat-swiftui/pull/504)
- Grouping image and video attachments in the same message [#525](https://github.com/GetStream/stream-chat-swiftui/pull/525)

# [4.57.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.57.0)
_June 07, 2024_

### ✅ Added
- Add support for creating and rendering polls [#495](https://github.com/GetStream/stream-chat-swiftui/pull/495)
- Use max file size for validating attachments defined in Stream's Dashboard [#490](https://github.com/GetStream/stream-chat-swiftui/pull/490)

# [4.56.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.56.0)
_May 21, 2024_

### 🔄 Changed
- Updated StreamChat dependency

### 🐞 Fixed
- Creating merged channel avatars logged a console warning when the source image uses extended color range [#484](https://github.com/GetStream/stream-chat-swiftui/pull/484)

# [4.55.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.55.0)
_May 14, 2024_

### 🔄 Changed
- Updated StreamChat dependency

# [4.54.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.54.0)
_May 06, 2024_

### 🔄 Changed
- Updated StreamChat dependency

# [4.53.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.53.0)
_April 30, 2024_

### ✅ Added
- Highlighting and tapping on user mentions
- Customization of the channel loading view
- Public init of InjectedChannelInfo

# [4.52.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.52.0)
_April 09, 2024_

### ✅ Added
- Added markdown support (enabled by default)
- `LinkAttachmentView` and `LinkDetectionTextView` available for public use

# [4.51.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.51.0)
_March 26, 2024_

### ✅ Added
- Role value in the user display info

### 🐞 Fixed
- Reactions picker for large messages sometimes goes in the safe area
- Loading of pinned messages in the channel info screen

# [4.50.1](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.50.1)
_March 14, 2024_

### 🐞 Fixed
- Message text color when using link detection

# [4.50.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.50.0)
_March 12, 2024_

### ✅ Added
- Link detection in the text views
- Indicator when a message was edited

# [4.49.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.49.0)
_February 28, 2024_

### ✅ Added
- Config the audioRecorder that is used when sending async voice messages

### 🔄 Changed
- Author name display now depends on number of participants, not channel type

### 🐞 Fixed
- Voice recording messages now use the standard message modifier

### 🔄 Changed

# [4.48.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.48.0)
_February 09, 2024_

### ✅ Added
- Factory method for customizing the search results view

### 🔄 Changed
- Updated StreamChat dependency

# [4.47.1](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.47.1)
_January 29, 2024_

### 🐞 Fixed
- Cleanup of audio session only when voice recording is enabled

# [4.47.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.47.0)
_January 09, 2024_

### ✅ Added
- Config for highlighted composer border color
- Config for enforcing unique reactions

### 🐞 Fixed
- Improved loading of gallery images

# [4.46.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.46.0)
_December 21, 2023_

### ✅ Added
- Recording of async voice messages
- Rendering and playing async voice messages

### 🔄 Changed

# [4.45.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.45.0)
_December 13, 2023_

### ✅ Added
- Mark message as unread
- Jump to first unread message
- Factory method to swap jump to unread button

# [4.44.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.44.0)
_December 01, 2023_

### ✅ Added
- Jump to a message that is not on the first page
- Jump to a message in a thread
- Bi-directional scrolling of the message list
- Handling of bounced messages

### 🐞 Fixed
- Some links not being rendered correctly

# [4.43.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.43.0)
_November 20, 2023_

### 🐞 Fixed
- Fix skip slow mode capability not handled

# [4.42.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.42.0)
_November 15, 2023_

### ✅ Added
- Add factory method for custom attachments in quoted messages

### 🐞 Fixed
- Fix marked read while the app is in the background
- Fix recently saved images to camera roll don't show up

# [4.41.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.41.0)
_November 03, 2023_

### ✅ Added
- Config for bottom placement of reactions

### 🐞 Fixed
- Video playing after being dismissed on iOS 17.1

# [4.40.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.40.0)
_October 26, 2023_

### ⚠️ Important

- Dependencies are no longer exposed (this includes Nuke and SwiftyGif). If you were using those dependencies we were exposing, you would need to import them manually. This is due to our newest addition supporting Module Stable XCFramework, see more below in the "Added" section. If you encounter any SPM-related problems, be sure to reset the package caches.

### ✅ Added
- Add message preview with attachments in channel list
- Add support for pre-built XCFramework
- Config for composer text input paddings
- Config for left alignment of messages

### 🔄 Changed
- Made some `ChannelList` and `MessageListView` parameters optional

# [4.39.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.39.0)
_October 06, 2023_

### 🐞 Fixed
- Fixed visibility for deleted messages indicator for current user

### ✅ Added
- Add throttling to mark as read

# [4.38.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.38.0)
_September 29, 2023_

### 🐞 Fixed
- Performance improvements in the low-level client

# [4.37.1](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.37.1)
_September 27, 2023_

### ✅ Added
- Config for changing supported media types in the composer

### 🐞 Fixed
- Play audio in videos when in silent mode

# [4.37.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.37.0)
_September 18, 2023_

### 🔄 Changed
- Updated `StreamChat` dependency

# [4.36.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.36.0)
_August 31, 2023_

### ✅ Added
- Add XCPrivacy manifest [#352](https://github.com/GetStream/stream-chat-swift/pull/352)

### 🔄 Changed
- Reactions popup disabled if channel is frozen

### 🐞 Fixed
- Online indicator updates in the header view
- Reactions overlay interface orientation updates

# [4.35.1](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.35.1)
_August 10, 2023_

### 🔄 Changed

- Updated `StreamChat` dependency

# [4.35.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.35.0)
_August 09, 2023_

### 🔄 Changed
- Video and giphy attachments now use `makeMessageViewModifier`
- Updated scalling of avatar images
- Turn off channel updates when message thread shown

### 🐞 Fixed
- `AttachmentTextView` respects configured body font
- Attachments persisted after message editing

### ✅ Added
- Option to specify bottom offset in `ReactionsOverlayView`

# [4.34.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.34.0)
_July 06, 2023_

### ✅ Added
- Added factory method for customizing the message list container's modifier
- Option to customize the date separation logic in the message list
- Public init for `LinkAttachmentContainer`

# [4.33.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.33.0)
_June 09, 2023_

### 🔄 Changed
- Updated `StreamChat` dependency

# [4.32.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.32.0)
_May 26, 2023_

### 🐞 Fixed
- Fixed the text input cursor when a message is being edited
- Fixed channel list view model always not using passed channel type for deletion
- Fixed warning for empty collection literal in Xcode 14.3

### ✅ Added
- Added a factory method for customizing the composer text input view

### 🔄 Changed
- Exposed mentionedUsers in the MessageComposerViewModel

# [4.31.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.31.0)
_April 25, 2023_

### 🐞 Fixed
- Reaction overlay display in a modal chat view
- Warning about UITextView switching to TextKit 1 compatibility mode
- Unread new messages separator wrong value when date overlay used

# [4.30.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.30.0)
_March 30, 2023_

### ✅ Added
- Added more parameters to the `sendMessage` method in the `MessageComposerViewModel`
- Exposed components from the `ChatChannelInfoView`

# [4.29.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.29.0)
_March 17, 2023_

### 🔄 Changed
- Exposed `SearchResultsView` as a public component
- `isSearching` property in the `ChatChannelListViewModel` is now public
- LazyImage uses image CDN request
- Fallback avatar in `MessageAvatarView`

### 🐞 Fixed
- Channel actions popup wrong appearance using a custom `NavigationView`
- Channel list automatic channel selection disabled for compact iPad screen size
- Mentions of users available in a new line
- Cursor jumps around in the composer when @ mentioning

# [4.28.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.28.0)
_February 28, 2023_

### 🔄 Changed
- Updated `StreamChat` dependency

# [4.27.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.27.0)
_February 17, 2023_

### ✅ Added
- Possibility to customize message reactions top padding (for grid-based reaction containers)
- Custom sorting of reactions
- Added a configurable separator view for new messages
- Possibility to customize the cornerRadius of the `ComposerInputView`
- Possibility to turn off tab bar handling in the message list

### 🐞 Fixed
- Message List layout for iPad in Slide Over mode

# [4.26.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.26.0)
_January 16, 2023_

### ✅ Added
- Config to change the scrolling anchor (top/bottom) on messages
- Pass extra data in attachments
- Custom message grouping by overriding `groupMessages` in `ChatChannelViewModel`

### 🔄 Changed
- `AddedAsset`'s `extraData` property is now of type `[String: RawJSON]`
- New icon for `pendingSend` local message state

# [4.25.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.25.0)
_December 16, 2022_

### ✅ Added
- Support for channel own capabilities in the UI
- Added possibility to override the message id creation with `MessageIdBuilder`

### 🐞 Fixed
- Renaming of a channel in ChannelInfo not persisting extra data
- Channel list item swipe gesture collision with native gesture
- Attributes from `MessageActionInfo` are now public
- Crash on older devices when adding multiple images quickly
- Message text appearing in multiple file attachments from the same message

# [4.24.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.24.0)
_November 16, 2022_

### ✅ Added
- Support for specifying whether ChatChannelListView is embedded in a NavigationView with `embedInNavigationView`

### 🔄 Changed
- Public init for `DefaultChannelListHeaderModifier`
- Updated Nuke dependency

### 🐞 Fixed
- Scroll to bottom when return key is pressed in the composer input view
- Typing indicator not shown when empty message list

# [4.23.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.23.0)
_October 27, 2022_

### ✅ Added
- Support for custom message receipt states
- Scrolling of instant commands
- Config to turn off tab bar visibility handling

### 🔄 Changed
- Updated Nuke dependency to 11.3.0 for SPM
- Removed NukeUI dependency for SPM (now part of Nuke)

# [4.22.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.22.0)
_September 27, 2022_

### ✅ Added
- Configuration for stack based navigation for iPads
- Customization of the reactions background
- Possibility to add custom snapshot generation logic
- Configuration for composer input field max height

### 🐞 Fixed
- iOS 16 keyboard insets issue on pushed screen
- Improved animation for date indicators in message list

# [4.21.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.21.0)
_September 02, 2022_

### ✅ Added
- Configuring avatars visibility in groups
- Method to swap the `MessageRepliesView`
- Public init for `ChatChannelListItem`

### 🔄 Changed
- Message list creation requires `shouldShowTypingIndicator` as a parameter

### 🐞 Fixed
- Channel header sometimes blinks when many messages are sent
- Data race when channels are updated from message list
- Safe unwrapping of current graphics context when showing reactions

# [4.20.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.20.0)
_August 04, 2022_

### ✅ Added
- Exposed a way to customise text message before sending and reading

### 🐞 Fixed
- Fixed a bug with channel list refreshing after deeplinking
- Navigation bar iPad resizing issue
- Fixed a bug with thread with custom attachments dismissed
- Fixed Xcode 14 beta build issues

### 🔄 Changed
- Docs restructuring
- Exposed some view components as public

# [4.19.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.19.0)
_July 21, 2022_

### ✅ Added
- Customizing padding for message bubble modifier
- Customizing padding for message text view
- Possibility to control tab bar visibility
- Configuration of message size via spacing

### 🐞 Fixed
- Fixed a bug with canceled backswipe
- Fixed a bug with channel pop on name editing

### 🔄 Changed
- Docs restructuring
- Exposed some view components as public

# [4.18.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.18.0)
_July 05, 2022_

### ✅ Added
- Automated testing infrastructure
- Config for disabling reaction animations
- Error indicator when max attachment size exceeded
- Factory method to swap the jumbo emoji view

### 🔄 Changed
- Made few view components public

# [4.17.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.17.0)
_June 22, 2022_

### ✅ Added
- Possibility to add a custom view above the oldest message in a group
- Swipe gesture to dismiss image gallery

### 🐞 Fixed
- Memory cache trimming on chat dismiss
- Crash when sending an invalid command

# [4.16.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.16.0)
_June 10, 2022_

### ✅ Added
- Possibility to view channel info on channel options
- Date separators in the message list
- ChatUserNamer to customize user name on typing indicator
- minimumSwipeGestureDistance to control swipe sensitivity
- Pop-out animation to reactions overlay
- maxTimeIntervalBetweenMessagesInGroup to control message grouping logic

### 🐞 Fixed
- Bug about link attachments not opening when the URL was missing the scheme
- Picking images synced with iCloud in the composer
- User mentions not being passed when sending a message
- Incorrect initial height when editing a message
- Composer is hidden when reactions shown

# [4.15.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.15.0)
_May 17, 2022_

### ✅ Added
- Chat info screen
- Possibility to customize empty messages state
- Possibility to customize author and date view in a message
- View model injection in the Message Composer View

### 🐞 Fixed
- Bug with swiping video attachments
- Bug with reactions offset for large number of reactions
- Text input cursor jump
- Text message rendering issue with custom font
- Tap enabled on fourth image in attachments if there's a number overlay

# [4.14.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.14.0)
_April 26, 2022_

### ✅ Added
- Animations for reactions overlay
- Possibility to customize message transitions
- Config for changing reaction colors
- Config for becoming first responder in chat channel
- Config for double tap message overlay
- Config for custom width / count of trailing items in swiped channel
- Config for updating composer frames

### 🐞 Fixed
- Issue with resizing composer with large text
- Updating channel list before coming back to the screen
- Disable the send button when there's only whitespace

# [4.13.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.13.0)
_March 30, 2022_

### ✅ Added
- Implement message resend functionality
- Custom modifiers support for the message view and the composer
- Custom modifiers support for the channel list and the message list
- Changing text color per message sender

### 🐞 Fixed
- Improved TabView appeareance animation
- Channel list performance improvements
- Jumbo emoji reply not shown correctly
- Send message animation improvements

### 🔄 Changed
- Method for creating custom quoted message view

# [4.12.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.12.0)
_March 17, 2022_

### ✅ Added
- Redacted loading view
- Max file size checks
- Inject custom footer view in Channel List
- Config for disabling message overlay

### 🐞 Fixed
- Prevent jumps when new messages are received
- Orientation changes layout

### 🔄 Changed
- Method for creating custom avatar

# [4.11.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.11.0)
_March 02, 2022_

### ✅ Added
- Support for custom backgrounds (image, gradient)
- Animation when sending message
- Possibility to inject view model from the outside

### 🐞 Fixed
- Performance improvements
- Autocomplete keyboard bug
- Swipe gesture resizing message view

### 🔄 Changed
- Method for creating custom avatar

# [4.10.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.10.0)
_February 16, 2022_

### ✅ Added
- Slow mode
- Copying of a message
- Push notifications
- Message list config options

### 🐞 Fixed
- Keyboard not shown while bounce in progress
- Image picker tap target
- Gallery images (screenshots) resize when swiping

# [4.9.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.9.0)
_February 02, 2022_

### ✅ Added
- Pinning of a message
- Display users who reacted to a message
- Message Search
- Customization of channel list separators

### 🐞 Fixed
- Bug with image attachments selection and display
- Reactions issues on iPad

### 🔄 Changed
- Creation method of channel destination

# [4.8.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.8.0)
_January 18, 2022_

### ✅ Added
- Read indicators
- Typing indicators
- Muting users
- Channel config

### 🔄 Changed
- Leading composer view creation

# [4.7.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.7.0)
_January 04, 2022_

### ✅ Added
- Image gallery
- Editing messages
- Mentions
- Composer commands
- Configuration of channel item swipe area

### 🔄 Changed
- Creation of channel items

# [4.6.3](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.6.3)
_December 21, 2021_

### ✅ Added
- Inline replies to messages
- Message threads
- Bug fix for multi-step keyboards

### 🔄 Changed

# [4.6.1](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.6.1)
_December 07, 2021_

### ✅ Added
- Infrastructure improvements (GitHub actions, release scripts)
- Unit tests

### 🐞 Fixed
- Localization improvements

# [4.6.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.6.0)
_December 01, 2021_

### ✅ Added
This is the first version of the SwiftUI SDK for Stream Chat. It includes the following features:

- channel list
- message list
- message composer
- message reactions
- customization of components
- sample app
