# StreamChatSwiftUI iOS SDK CHANGELOG
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

# Upcoming

### 🔄 Changed

# [4.93.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.93.0)
_November 18, 2025_

### ✅ Added
- Expose `AddedVoiceRecordingsView` [#1049](https://github.com/GetStream/stream-chat-swiftui/pull/1049)
- Expose `FilePickerView.init(fileURLs:)` [#1049](https://github.com/GetStream/stream-chat-swiftui/pull/1049)
- Add `MessageComposerViewModel.updateAddedAssets()` [#1049](https://github.com/GetStream/stream-chat-swiftui/pull/1049)

### 🐞 Fixed
- Fix `Throttler` crash in `ChatChannelViewModel.handleMessageAppear()` [#1050](https://github.com/GetStream/stream-chat-swiftui/pull/1050)
- Remove unnecessary channel query call when leaving the channel view in a mid-page [#1050](https://github.com/GetStream/stream-chat-swiftui/pull/1050)
- Fix crash when force unwrapping `messageDisplayInfo` in `ChatChannelView` [#1052](https://github.com/GetStream/stream-chat-swiftui/pull/1052)

# [4.92.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.92.0)
_November 07, 2025_

### ✅ Added
- Add message highlighting on jumping to a quoted message [#1032](https://github.com/GetStream/stream-chat-swiftui/pull/1032)
- Display double grey checkmark when delivery events are enabled [#1038](https://github.com/GetStream/stream-chat-swiftui/pull/1038)

### 🐞 Fixed
- Fix composer deleting newly entered text after deleting draft text [#1030](https://github.com/GetStream/stream-chat-swiftui/pull/1030)
- Fix mark unread action not shown for messages that are root of a thread in the channel view [#1041](https://github.com/GetStream/stream-chat-swiftui/pull/1041)

# [4.91.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.91.0)
_October 22, 2025_

### ✅ Added
- Add the `makeAttachmentTextView` method to ViewFactory [#1013](https://github.com/GetStream/stream-chat-swiftui/pull/1013)
- Allow dismissing commands overlay when tapping the message list [#1024](https://github.com/GetStream/stream-chat-swiftui/pull/1024)
- Allows dismissing the keyboard attachments picker when tapping the message list [#1024](https://github.com/GetStream/stream-chat-swiftui/pull/1024)
### 🐞 Fixed
- Fix composer not being locked after the channel was frozen [#1015](https://github.com/GetStream/stream-chat-swiftui/pull/1015)
- Fix `PollOptionAllVotesView` not updated on poll cast events [#1025](https://github.com/GetStream/stream-chat-swiftui/pull/1025)
- Fix action sheet not showing when discarding Poll creation on iOS 26 [#1027](https://github.com/GetStream/stream-chat-swiftui/pull/1027)

# [4.90.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.90.0)
_October 08, 2025_

### ✅ Added
- Opens the `commandsHandler` and makes the mention methods public [#979](https://github.com/GetStream/stream-chat-swiftui/pull/979)
- Opens `MarkdownFormatter` so that it can be customised [#978](https://github.com/GetStream/stream-chat-swiftui/pull/978)
- Add participant actions in channel info view [#982](https://github.com/GetStream/stream-chat-swiftui/pull/982)
- Add support for overriding `onImageTap` in `LinkAttachmentView` [#986](https://github.com/GetStream/stream-chat-swiftui/pull/986)
- Add support for customizing text colors in `LinkAttachmentView` [#992](https://github.com/GetStream/stream-chat-swiftui/pull/992)
- Expose `MediaAttachment` properties and initializer [#1000](https://github.com/GetStream/stream-chat-swiftui/pull/1000)
- Add `ColorPalette.navigationBarGlyph` for configuring the glyph color for buttons in navigation bars [#999](https://github.com/GetStream/stream-chat-swiftui/pull/999)
- Allow overriding `ChatChannelInfoViewModel` properties: `shouldShowLeaveConversationButton`, `canRenameChannel`, and `shouldShowAddUserButton` [#995](https://github.com/GetStream/stream-chat-swiftui/pull/995)

### 🐞 Fixed
- Fix openChannel not working when searching or another chat shown [#975](https://github.com/GetStream/stream-chat-swiftui/pull/975)
- Fix crash when using a font that does not support bold or italic trait [#976](https://github.com/GetStream/stream-chat-swiftui/pull/976)
- Fix unread messages banner not shown for one-page channels [#989](https://github.com/GetStream/stream-chat-swiftui/pull/989)
- Fix unread messages banner not shown if the whole channel is unread [#989](https://github.com/GetStream/stream-chat-swiftui/pull/989)
- Fix channel not marking read when passing by the unread message [#989](https://github.com/GetStream/stream-chat-swiftui/pull/989)
- Fix random scroll after marking a message unread [#989](https://github.com/GetStream/stream-chat-swiftui/pull/989)
- Fix marking channel read when the user scrolls to the bottom after marking a message as unread [#989](https://github.com/GetStream/stream-chat-swiftui/pull/989)
- Fix replying to unread messages marking them instantly as read [#989](https://github.com/GetStream/stream-chat-swiftui/pull/989)
- Fix rendering of the add users button on iOS 26 [#999](https://github.com/GetStream/stream-chat-swiftui/pull/999)
- Use `ColorPalette.navigationBarTint` for the background of the add users button [#999](https://github.com/GetStream/stream-chat-swiftui/pull/999)
- Fix showing all the channel members in the more channel actions view [#1001](https://github.com/GetStream/stream-chat-swiftui/pull/1001)

# [4.89.1](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.89.1)
_September 23, 2025_

### 🐞 Fixed
- Fix not importing Foundation in GalleryHeaderViewDateFormatter [#970](https://github.com/GetStream/stream-chat-swiftui/pull/970)

# [4.89.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.89.0)
_September 22, 2025_

### ✅ Added
- Add `toolbarThemed(content:)` for creating custom views with themed navigation bar [#953](https://github.com/GetStream/stream-chat-swiftui/pull/953)
- Add support for downloading file attachments [#952](https://github.com/GetStream/stream-chat-swiftui/pull/952)
### 🐞 Fixed
- Fix updating back button tint with `ColorPalette.navigationBarTintColor` [#953](https://github.com/GetStream/stream-chat-swiftui/pull/953)
- Fix swipe to reply enabled when quoting a message is disabled  [#977](https://github.com/GetStream/stream-chat-swiftui/pull/957)
- Fix composer not showing images in the composer when editing signed attachments [#956](https://github.com/GetStream/stream-chat-swiftui/pull/956)
- Fix replacing an image while editing a message not showing the new image in the message list [#956](https://github.com/GetStream/stream-chat-swiftui/pull/956)
- Improve precision when scrolling to the newest message with long text [#958](https://github.com/GetStream/stream-chat-swiftui/pull/958)
- Fix draft attachments being sent with local file urls to the server [#964](https://github.com/GetStream/stream-chat-swiftui/pull/964)
- Fix keyboard showing with attachment picker when editing a message [#965](https://github.com/GetStream/stream-chat-swiftui/pull/965)
- Fix race condition when clearing text in a regular TextField [#955](https://github.com/GetStream/stream-chat-swiftui/pull/955)
### 🔄 Changed
- Change the gallery header view to show the message timestamp instead of online status [#962](https://github.com/GetStream/stream-chat-swiftui/pull/962)

# [4.88.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.88.0)
_September 10, 2025_

### ✅ Added
- Add `ColorPalette.navigationBarTitle`, `ColorPalette.navigationBarSubtitle`, `ColorPalette.navigationBarTintColor`,  `ColorPalette.navigationBarBackground` [#939](https://github.com/GetStream/stream-chat-swiftui/pull/939)
### 🐞 Fixed
- Long message with a link preview was truncated sometimes [#940](https://github.com/GetStream/stream-chat-swiftui/pull/940)
- Fix quoted message shown in the composer when editing a quoting message [#943](https://github.com/GetStream/stream-chat-swiftui/pull/943)
- Fix pinned messages view not using relative time formatter [#946](https://github.com/GetStream/stream-chat-swiftui/pull/946)

# [4.87.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.87.0)
_September 01, 2025_

### ✅ Added
- Add option to scroll to and open a channel from the channel list [#932](https://github.com/GetStream/stream-chat-swiftui/pull/932)
- Make `MediaItem` and `MediaAttachmentContentView` public to allow customization [#935](https://github.com/GetStream/stream-chat-swiftui/pull/935)

### 🐞 Fixed
- Show attachment title instead of URL in the `FileAttachmentPreview` view [#930](https://github.com/GetStream/stream-chat-swiftui/pull/930)
- Fix overriding title color in `ChannelTitleView` [#931](https://github.com/GetStream/stream-chat-swiftui/pull/931)
- Use channel capabilities for validating delete message action [#933](https://github.com/GetStream/stream-chat-swiftui/pull/933)
- Fix the video attachments now fetch the URL once on appear and pause when swiping to another item in the gallery [#934](https://github.com/GetStream/stream-chat-swiftui/pull/934)

# [4.86.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.86.0)
_August 21, 2025_

### 🐞 Fixed
- Fix inconsistencies in gallery view displaying images and videos [#927](https://github.com/GetStream/stream-chat-swiftui/pull/927)
- Prevent audio messages increasing width in reply mode [#926](https://github.com/GetStream/stream-chat-swiftui/pull/926)

# [4.85.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.85.0)
_August 13, 2025_

### ✅ Added
- Add support for customizing AddUsersView [#911)(https://github.com/GetStream/stream-chat-swiftui/pull/911)

# [4.84.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.84.0)
_August 07, 2025_

### ✅ Added
- Make `AddUsersView` used by `ChatChannelInfoView` public for creating custom info views through composition [#906](https://github.com/GetStream/stream-chat-swiftui/pull/906)
- Expose `ChannelAvatarViewOptions.init` [#908](https://github.com/GetStream/stream-chat-swiftui/pull/908)
### 🐞 Fixed
- Fix WebView error handling to enable mp3 attachments loading [#904](https://github.com/GetStream/stream-chat-swiftui/pull/904)

# [4.83.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.83.0)
_July 29, 2025_

### ✅ Added
- Add support for showing current poll comment on alert [#891](https://github.com/GetStream/stream-chat-swiftui/pull/891)

### 🐞 Fixed
- Fix polls multiple answers minimum value being 1 instead of 2 [#898](https://github.com/GetStream/stream-chat-swiftui/pull/898)

### 🔄 Changed
- Make `ChatChannelInfoView` subviews public for creating custom info views through composition [#892](https://github.com/GetStream/stream-chat-swiftui/pull/892)
  - `ChannelTitleView`
  - `ChannelInfoDivider`
  - `ChatInfoDirectChannelView`
  - `ChatInfoParticipantsView`
- Make `MediaViewsOptions` initializer public [#899](https://github.com/GetStream/stream-chat-swiftui/pull/899)

# [4.82.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.82.0)
_July 16, 2025_

### ✅ Added
- Add support for customising the `MessageAvatarView` placeholder [#878](https://github.com/GetStream/stream-chat-swiftui/pull/878)
- Add `ViewFactory.makeVideoPlayerFooterView` to customize video player footer [#879](https://github.com/GetStream/stream-chat-swiftui/pull/879)
- Add `utils.channelListConfig.channelItemMutedLayoutStyle` [#881](https://github.com/GetStream/stream-chat-swiftui/pull/881)
- Add jumping to pinned message when tapping a message in the pinned messages view [#884](https://github.com/GetStream/stream-chat-swiftui/pull/884)

### 🔄 Changed
- From now on, jumping to a message will centre it in the middle instead of at the top [#884](https://github.com/GetStream/stream-chat-swiftui/pull/884)

# [4.81.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.81.0)
_July 03, 2025_

### ✅ Added
- Add `Utils.channelListConfig.showChannelListDividerOnLastItem` [#869](https://github.com/GetStream/stream-chat-swiftui/pull/869)

### 🐞 Fixed
- Fix tapping on invisible areas on iOS 26 [#868](https://github.com/GetStream/stream-chat-swiftui/pull/868)
- Fix channel view tab bar not hidden on iOS 16.0 [#870](https://github.com/GetStream/stream-chat-swiftui/pull/870)
- Fix message Actions overlay view not dismissed when opening thread [#873](https://github.com/GetStream/stream-chat-swiftui/pull/873)
- Fix mute and unmute commands shown in the composer when removed from Dashboard [#872](https://github.com/GetStream/stream-chat-swiftui/pull/872)

### 🔄 Changed
- Mute and unmute commands are not added by default in the composer [#872](https://github.com/GetStream/stream-chat-swiftui/pull/872)

# [4.80.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.80.0)
_June 17, 2025_

### 🐞 Fixed
- Fix showing unmute user message action just after muting the user [#847](https://github.com/GetStream/stream-chat-swiftui/pull/847)
- Fix rare concurrency crash in `ChannelAvatarsMerger.createMergedAvatar(from:)` [#858](https://github.com/GetStream/stream-chat-swiftui/pull/858)

# [4.79.1](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.79.1)
_June 03, 2025_

### 🐞 Fixed
- Fix `ChatChannelView` keyboard background not using color from palette [#845](https://github.com/GetStream/stream-chat-swiftui/pull/845)
- Fix removing new messages separator when scrolling in the channel view [#846](https://github.com/GetStream/stream-chat-swiftui/pull/846)

# [4.79.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.79.0)
_May 29, 2025_

### ✅ Added
- Add extra data to user display info [#819](https://github.com/GetStream/stream-chat-swiftui/pull/819)
- Make message spacing in message list configurable [#830](https://github.com/GetStream/stream-chat-swiftui/pull/830)
- Show time, relative date, weekday, or short date for last message in channel list and search [#833](https://github.com/GetStream/stream-chat-swiftui/pull/833)
  - Set `ChannelListConfig.messageRelativeDateFormatEnabled` to true for enabling it
- Add `MessageViewModel` to `MessageContainerView` to make it easier to customise presentation logic [#815](https://github.com/GetStream/stream-chat-swiftui/pull/815)
- Add `MessageListConfig.messaeDisplayOptions.showOriginalTranslatedButton` to enable showing original text in translated message [#815](https://github.com/GetStream/stream-chat-swiftui/pull/815)
- Add `Utils.originalTranslationsStore` to keep track of messages that should show the original text [#815](https://github.com/GetStream/stream-chat-swiftui/pull/815)
- Add `ViewFactory.makeGalleryHeaderView` for customising header view in `GalleryView` [#837](https://github.com/GetStream/stream-chat-swiftui/pull/837)
- Add `ViewFactory.makeVideoPlayerHeaderView` for customising header view in `VideoPlayerView` [#837](https://github.com/GetStream/stream-chat-swiftui/pull/837)
- Add `Utils.messagePreviewFormatter` for customising message previews in lists [#839](https://github.com/GetStream/stream-chat-swiftui/pull/839)
### 🐞 Fixed
- Fix swipe to reply enabled when quoting a message is disabled [#824](https://github.com/GetStream/stream-chat-swiftui/pull/824)
- Fix mark unread action not removed when read events are disabled [#823](https://github.com/GetStream/stream-chat-swiftui/pull/823)
- Fix user mentions not working when commands are disabled [#826](https://github.com/GetStream/stream-chat-swiftui/pull/826)
- Fix edit message action shown when user does not have permissions [#835](https://github.com/GetStream/stream-chat-swiftui/pull/835)
- Fix error indicator not shown when editing a message fails [#840](https://github.com/GetStream/stream-chat-swiftui/pull/840)
- Fix read indicator shown for failed edited messages [#840](https://github.com/GetStream/stream-chat-swiftui/pull/840)
- Fix "clock" pending icon not shown when message is syncing (pending to be edited) [#840](https://github.com/GetStream/stream-chat-swiftui/pull/840)

# [4.78.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.78.0)
_April 24, 2025_

### ✅ Added
- Add factory methods for gallery and video player view [#808](https://github.com/GetStream/stream-chat-swiftui/pull/808)
- Add support for editing message attachments [#806](https://github.com/GetStream/stream-chat-swiftui/pull/806)
### 🐞 Fixed
- Fix scrolling to the bottom when editing a message [#806](https://github.com/GetStream/stream-chat-swiftui/pull/806)
- Fix having message edit action on Giphy messages [#806](https://github.com/GetStream/stream-chat-swiftui/pull/806)
- Fix being able to long press an unsent Giphy message [#806](https://github.com/GetStream/stream-chat-swiftui/pull/806)
- Fix being able to swipe to reply an unsent Giphy message [#806](https://github.com/GetStream/stream-chat-swiftui/pull/806)
- Fix translated message showing original text in message actions overlay [#810](https://github.com/GetStream/stream-chat-swiftui/pull/810)

### 🔄 Changed
- Deprecated `ComposerConfig.attachmentPayloadConverter` in favour of `MessageComposerViewModel.convertAddedAssetsToPayloads()` [#806](https://github.com/GetStream/stream-chat-swiftui/pull/806)

# [4.77.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.77.0)
_April 10, 2025_

### ✅ Added
- Allow pasting images to the composer [#797](https://github.com/GetStream/stream-chat-swiftui/pull/797)
- Add `ChatChannelListViewModel.setChannelAlertType` for setting the alert type [#801](https://github.com/GetStream/stream-chat-swiftui/pull/801)
### 🐞 Fixed
- Fix allowing to send Polls when the current user does not have the capability [#798](https://github.com/GetStream/stream-chat-swiftui/pull/798)
- Fix showing a double error indicator when sending attachments without any text [#799](https://github.com/GetStream/stream-chat-swiftui/pull/799)
- Fix showing read indicator when message failed to be sent [#799](https://github.com/GetStream/stream-chat-swiftui/pull/799)
- Fix not showing sending indicator when message is in sending state [#799](https://github.com/GetStream/stream-chat-swiftui/pull/799)
- Fix empty accessibility button shapes shown in navigation link views [#800](https://github.com/GetStream/stream-chat-swiftui/pull/800)

# [4.76.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.76.0)
_March 31, 2025_

### ✅ Added
- Add `minOriginY` to the initializer of `ReactionsOverlayView` for better UI customization [#793](https://github.com/GetStream/stream-chat-swiftui/pull/793)
### 🐞 Fixed
- Fix draft not deleted when attachments are removed from the composer [#791](https://github.com/GetStream/stream-chat-swiftui/pull/791)
### 🔄 Changed
- Made `showErrorPopup` open in `ChatChannelListViewModel` [#794](https://github.com/GetStream/stream-chat-swiftui/pull/794)

# [4.75.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.75.0)
_March 26, 2025_

### ✅ Added
- Add avatar customization in add users popup [#787](https://github.com/GetStream/stream-chat-swiftui/pull/787)
- Add support for Draft Messages when `Utils.messageListConfig.draftMessagesEnabled` is `true` [#775](https://github.com/GetStream/stream-chat-swiftui/pull/775)
- Add draft preview in Channel List and Thread List if drafts are enabled [#775](https://github.com/GetStream/stream-chat-swiftui/pull/775)

# [4.74.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.74.0)
_March 14, 2025_

### ✅ Added
- Feature rich markdown rendering with AttributedString [#757](https://github.com/GetStream/stream-chat-swiftui/pull/757)
- Add `Fonts.title2` for supporting markdown headers [#757](https://github.com/GetStream/stream-chat-swiftui/pull/757)
- Add `resignsFirstResponderOnScrollDown` to `MessageListConfig` [#769](https://github.com/GetStream/stream-chat-swiftui/pull/769)
- Show auto-translated message translations ([learn more](https://getstream.io/chat/docs/ios-swift/translation/#enabling-automatic-translation)) [#776](https://github.com/GetStream/stream-chat-swiftui/pull/776)
### 🐞 Fixed
- Show typing suggestions for names containing whitespace [#781](https://github.com/GetStream/stream-chat-swiftui/pull/781)
### 🔄 Changed
- Uploading a HEIC photo from the library is now converted to JPEG for better compatibility [#767](https://github.com/GetStream/stream-chat-swiftui/pull/767)
- Customizing the message avatar view is reflected in all views that use it [#772](https://github.com/GetStream/stream-chat-swiftui/pull/772)
- Made the sendMessage method in MessageComposerViewModel open [#779](https://github.com/GetStream/stream-chat-swiftui/pull/779)
- Move `ChangeBarsVisibilityModifier` into `ViewFactory` for better customization [#774](https://github.com/GetStream/stream-chat-swiftui/pull/774)
### 🎭 New Localizations
- `message.translatedTo` [#776](https://github.com/GetStream/stream-chat-swiftui/pull/776)

# [4.73.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.73.0)
_February 28, 2025_

### ✅ Added
- Add `Utils.MessageListConfig.bouncedMessagesAlertActionsEnabled` to support bounced actions alert [#764](https://github.com/GetStream/stream-chat-swiftui/pull/764)
- Add `ViewFactory.makeBouncedMessageActionsModifier()` to customize the new bounced actions alert [#764](https://github.com/GetStream/stream-chat-swiftui/pull/764)
### 🐞 Fixed
- Fix visibility of tabbar when reactions are shown [#750](https://github.com/GetStream/stream-chat-swiftui/pull/750)
- Show all members in direct message channel info view [#760](https://github.com/GetStream/stream-chat-swiftui/pull/760)
### 🔄 Changed
- Only show "Pin/Unpin message" Action if user has permission [#749](https://github.com/GetStream/stream-chat-swiftui/pull/749)
- Filter deactivated users in channel info view [#758](https://github.com/GetStream/stream-chat-swiftui/pull/758)
- Bounced message actions will now be shown as an alert instead of a context menu by default [#764](https://github.com/GetStream/stream-chat-swiftui/pull/764)
### 🎭 New Localizations
Add localizable keys for supporting moderation alerts:
- `message.moderation.alert.title`
- `message.moderation.alert.message`
- `message.moderation.alert.resend`
- `message.moderation.alert.edit`
- `message.moderation.alert.delete`
- `message.moderation.alert.cancel`

# [4.72.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.72.0)
_February 04, 2025_

### ✅ Added
- Add factory method to customize the channel avatar [#734](https://github.com/GetStream/stream-chat-swiftui/pull/734)
- Add possibility to replace the no content icons [#740](https://github.com/GetStream/stream-chat-swiftui/pull/740)

### 🐞 Fixed
- Fix hiding message actions when tapping on the add reactions button in the bottom reactions view [#737](https://github.com/GetStream/stream-chat-swiftui/pull/737)

# [4.71.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.71.0)
_January 28, 2025_

### 🐞 Fixed
- Fix thread reply action shown when inside a Thread [#717](https://github.com/GetStream/stream-chat-swiftui/pull/717)
- Improve voice over by adding missing labels, removing decorative images, and setting accessibility actions [#726](https://github.com/GetStream/stream-chat-swiftui/pull/726)
- Fix avatar's background color when changing the navigation bar background color [#725](https://github.com/GetStream/stream-chat-swiftui/pull/725)
### 🔄 Changed
- Deprecate unused `ChatMessage.userDisplayInfo(from:)` which only accessed cached data [#718](https://github.com/GetStream/stream-chat-swiftui/pull/718)
### 🎭 New Localizations
Add localizable keys for supporting accessibility labels:
- `channel.list.scroll-to-bottom.title`
- `channel.header.info.title`
- `message.attachment.accessibility-label`
- `message.read-status.seen-by*`
- `message.cell.sent-at`
- `composer.picker.show-all`
- `composer.audio-recording.*`

# [4.70.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.70.0)
_January 15, 2025_

### ✅ Added
- Use `AppSettings.fileUploadConfig` for setting supported UTI types for the file picker [#713](https://github.com/GetStream/stream-chat-swiftui/pull/713)
- Colors and images for voice recording view [#704](https://github.com/GetStream/stream-chat-swiftui/pull/704)
  - `ColorPalette.voiceMessageControlBackground`
  - `Images.pauseFilled`
- Exposes all the default message actions [#711](https://github.com/GetStream/stream-chat-swiftui/pull/711)
### 🐞 Fixed
- Use bright color for typing indicator animation in dark mode [#702](https://github.com/GetStream/stream-chat-swiftui/pull/702)
- Refresh quoted message preview when the quoted message is deleted [#705](https://github.com/GetStream/stream-chat-swiftui/pull/705)
- Fix composer command view not Themable [#710](https://github.com/GetStream/stream-chat-swiftui/pull/710)
- Fix reactions users view not paginating results [#712](https://github.com/GetStream/stream-chat-swiftui/pull/712)

### 🔄 Changed
- Support theming and update layout of `VoiceRecordingContainerView` [#704](https://github.com/GetStream/stream-chat-swiftui/pull/704)
- Use `ColorPalette.highlightedAccentBackground` for `AudioVisualizationView.highlightedBarColor` [#704](https://github.com/GetStream/stream-chat-swiftui/pull/704)

# [4.69.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.69.0)
_December 18, 2024_

### ✅ Added
- Make `CreatePollView` public [#685](https://github.com/GetStream/stream-chat-swiftui/pull/685)
- Make `ChatChannelListViewModel.searchType` public and observable [#693](https://github.com/GetStream/stream-chat-swiftui/pull/693)
- Allow customizing channel and message search in the `ChatChannelListViewModel` [#690](https://github.com/GetStream/stream-chat-swiftui/pull/690)
  - Allow overriding `ChatChannelListViewModel.performChannelSearch` and `ChatChannelListViewModel.performMessageSearch`
  - Make `ChatChannelListViewModel.channelListSearchController` and `ChatChannelListViewModel.messageSearchController` public
### 🐞 Fixed
- Fix message thread reply footnote view not shown if parent message not in cache [#681](https://github.com/GetStream/stream-chat-swiftui/pull/681)
### ⚡ Performance
- Improve message search performance [#680](https://github.com/GetStream/stream-chat-swiftui/pull/680)
### 🔄 Changed
- Update `VoiceRecordingContainerView` background colors and layout by moving the message text outside of the recording cell [#689](https://github.com/GetStream/stream-chat-swiftui/pull/689/)

# [4.68.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.68.0)
_December 03, 2024_

### 🐞 Fixed
- Fix showing giphy message in the channel list [#669](https://github.com/GetStream/stream-chat-swiftui/pull/669)
- Fix message list scroll not working when drag gestured is initiated from a message [#671](https://github.com/GetStream/stream-chat-swiftui/pull/671)

# [4.67.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.67.0)
_November 25, 2024_

### ✅ Added
- Make `VoiceRecordingButton` public [#658](https://github.com/GetStream/stream-chat-swiftui/pull/658)
- Add config to skip edited label for some messages [#660](https://github.com/GetStream/stream-chat-swiftui/pull/665)
### 🐞 Fixed
- Fix message long press taking too much time to show actions [#648](https://github.com/GetStream/stream-chat-swiftui/pull/648)
- Fix rendering link attachment preview with other attachment types [#659](https://github.com/GetStream/stream-chat-swiftui/pull/659)
- Fix not using colors from the palette in some of the poll views [#661](https://github.com/GetStream/stream-chat-swiftui/pull/661)
- Fix a rare crash when handling list change in the `ChatChannelViewModel` [#663](https://github.com/GetStream/stream-chat-swiftui/pull/663)
### 🔄 Changed
- Message composer now uses `.uploadFile` capability when showing attachment picker icon [#646](https://github.com/GetStream/stream-chat-swiftui/pull/646)
- `ChannelInfoView` now uses `.updateChannelMembers` capability to show "Add Users" button [#651](https://github.com/GetStream/stream-chat-swiftui/pull/651)

# [4.66.0](https://github.com/GetStream/stream-chat-swiftui/releases/tag/4.66.0)
_November 06, 2024_

### ✅ Added
- Add support for Channel Search in the Channel List [#628](https://github.com/GetStream/stream-chat-swiftui/pull/628)
### 🐞 Fixed
- Fix crash when opening message overlay in iPad with a TabBar [#627](https://github.com/GetStream/stream-chat-swiftui/pull/627)
- Only show Leave Group option if the user has leave-channel permission [#633](https://github.com/GetStream/stream-chat-swiftui/pull/633)
- Fix Channel List stuck in Empty View State in rare conditions [#639](https://github.com/GetStream/stream-chat-swiftui/pull/639)
- Fix a bug with photo attachment picker indicator not displaying [#640](https://github.com/GetStream/stream-chat-swiftui/pull/640)

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
