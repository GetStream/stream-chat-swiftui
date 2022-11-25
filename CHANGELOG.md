# StreamChatSwiftUI iOS SDK CHANGELOG
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

# Upcoming

### 🐞 Fixed
- Renaming of a channel in ChannelInfo not persisting extra data
- Channel list item swipe gesture collision with native gesture
- Attributes from `MessageActionInfo` are now public

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
