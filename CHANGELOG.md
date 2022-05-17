# StreamChatSwiftUI iOS SDK CHANGELOG
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

# Upcoming

### 🔄 Changed

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
