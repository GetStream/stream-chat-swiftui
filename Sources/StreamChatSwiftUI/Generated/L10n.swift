// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation


// MARK: - Strings

internal enum L10n {
  /// %d of %d
  internal static func currentSelection(_ p1: Int, _ p2: Int) -> String {
    return L10n.tr("Localizable", "current-selection", p1, p2)
  }

  internal enum Alert {
    internal enum Actions {
      /// Cancel
      internal static var cancel: String { L10n.tr("Localizable", "alert.actions.cancel") }
      /// Delete
      internal static var delete: String { L10n.tr("Localizable", "alert.actions.delete") }
      /// Are you sure you want to delete this conversation?
      internal static var deleteChannelMessage: String { L10n.tr("Localizable", "alert.actions.delete-channel-message") }
      /// Delete conversation
      internal static var deleteChannelTitle: String { L10n.tr("Localizable", "alert.actions.delete-channel-title") }
      /// Leave
      internal static var leaveGroupButton: String { L10n.tr("Localizable", "alert.actions.leave-group-button") }
      /// Are you sure you want to leave this group?
      internal static var leaveGroupMessage: String { L10n.tr("Localizable", "alert.actions.leave-group-message") }
      /// Leave group
      internal static var leaveGroupTitle: String { L10n.tr("Localizable", "alert.actions.leave-group-title") }
      /// Are you sure you want to mute this
      internal static var muteChannelTitle: String { L10n.tr("Localizable", "alert.actions.mute-channel-title") }
      /// Ok
      internal static var ok: String { L10n.tr("Localizable", "alert.actions.ok") }
      /// Are you sure you want to unmute this
      internal static var unmuteChannelTitle: String { L10n.tr("Localizable", "alert.actions.unmute-channel-title") }
      /// View info
      internal static var viewInfoTitle: String { L10n.tr("Localizable", "alert.actions.view-info-title") }
    }
    internal enum Error {
      /// The operation couldn't be completed.
      internal static var message: String { L10n.tr("Localizable", "alert.error.message") }
      /// Something went wrong.
      internal static var title: String { L10n.tr("Localizable", "alert.error.title") }
    }
  }

  internal enum Attachment {
    /// Attachment size exceed the limit.
    internal static var maxSizeExceeded: String { L10n.tr("Localizable", "attachment.max-size-exceeded") }
    internal enum MaxSize {
      /// Please select a smaller attachment.
      internal static var message: String { L10n.tr("Localizable", "attachment.max-size.message") }
      /// Attachment size exceed the limit
      internal static var title: String { L10n.tr("Localizable", "attachment.max-size.title") }
    }
  }

  internal enum Channel {
    internal enum Item {
      /// Audio
      internal static var audio: String { L10n.tr("Localizable", "channel.item.audio") }
      /// No messages
      internal static var emptyMessages: String { L10n.tr("Localizable", "channel.item.empty-messages") }
      /// Mute
      internal static var mute: String { L10n.tr("Localizable", "channel.item.mute") }
      /// Channel is muted
      internal static var muted: String { L10n.tr("Localizable", "channel.item.muted") }
      /// Photo
      internal static var photo: String { L10n.tr("Localizable", "channel.item.photo") }
      /// are typing ...
      internal static var typingPlural: String { L10n.tr("Localizable", "channel.item.typing-plural") }
      /// is typing ...
      internal static var typingSingular: String { L10n.tr("Localizable", "channel.item.typing-singular") }
      /// Unmute
      internal static var unmute: String { L10n.tr("Localizable", "channel.item.unmute") }
      /// Video
      internal static var video: String { L10n.tr("Localizable", "channel.item.video") }
      /// Voice Message
      internal static var voiceMessage: String { L10n.tr("Localizable", "channel.item.voice-message") }
    }
    internal enum Name {
      /// and
      internal static var and: String { L10n.tr("Localizable", "channel.name.and") }
      /// and %@ more
      internal static func andXMore(_ p1: Any) -> String {
        return L10n.tr("Localizable", "channel.name.andXMore", String(describing: p1))
      }
      /// user
      internal static var directMessage: String { L10n.tr("Localizable", "channel.name.direct-message") }
      /// group
      internal static var group: String { L10n.tr("Localizable", "channel.name.group") }
      /// NoChannel
      internal static var missing: String { L10n.tr("Localizable", "channel.name.missing") }
    }
    internal enum NoContent {
      /// How about sending your first message to a friend?
      internal static var message: String { L10n.tr("Localizable", "channel.no-content.message") }
      /// Start a chat
      internal static var start: String { L10n.tr("Localizable", "channel.no-content.start") }
      /// Let's start chatting
      internal static var title: String { L10n.tr("Localizable", "channel.no-content.title") }
    }
  }

  internal enum ChatInfo {
    internal enum Files {
      /// Files sent in this chat will appear here.
      internal static var emptyDesc: String { L10n.tr("Localizable", "chat-info.files.empty-desc") }
      /// No files
      internal static var emptyTitle: String { L10n.tr("Localizable", "chat-info.files.empty-title") }
      /// Files
      internal static var title: String { L10n.tr("Localizable", "chat-info.files.title") }
    }
    internal enum Media {
      /// Photos or videos sent in this chat will appear here.
      internal static var emptyDesc: String { L10n.tr("Localizable", "chat-info.media.empty-desc") }
      /// No media
      internal static var emptyTitle: String { L10n.tr("Localizable", "chat-info.media.empty-title") }
      /// Photos & Videos
      internal static var title: String { L10n.tr("Localizable", "chat-info.media.title") }
    }
    internal enum Mute {
      /// Mute Group
      internal static var group: String { L10n.tr("Localizable", "chat-info.mute.group") }
      /// Mute User
      internal static var user: String { L10n.tr("Localizable", "chat-info.mute.user") }
    }
    internal enum PinnedMessages {
      /// Long-press an important message and choose Pin to conversation.
      internal static var emptyDesc: String { L10n.tr("Localizable", "chat-info.pinned-messages.empty-desc") }
      /// No pinned messages
      internal static var emptyTitle: String { L10n.tr("Localizable", "chat-info.pinned-messages.empty-title") }
      /// Pinned Messages
      internal static var title: String { L10n.tr("Localizable", "chat-info.pinned-messages.title") }
    }
    internal enum Rename {
      /// NAME
      internal static var name: String { L10n.tr("Localizable", "chat-info.rename.name") }
      /// Add a group name
      internal static var placeholder: String { L10n.tr("Localizable", "chat-info.rename.placeholder") }
    }
    internal enum Users {
      /// %@ more
      internal static func loadMore(_ p1: Any) -> String {
        return L10n.tr("Localizable", "chat-info.users.loadMore", String(describing: p1))
      }
    }
  }

  internal enum Composer {
    internal enum Checkmark {
      /// Also send in channel
      internal static var channelReply: String { L10n.tr("Localizable", "composer.checkmark.channel-reply") }
      /// Also send as direct message
      internal static var directMessageReply: String { L10n.tr("Localizable", "composer.checkmark.direct-message-reply") }
    }
    internal enum Commands {
      /// Giphy
      internal static var giphy: String { L10n.tr("Localizable", "composer.commands.giphy") }
      /// Mute
      internal static var mute: String { L10n.tr("Localizable", "composer.commands.mute") }
      /// Unmute
      internal static var unmute: String { L10n.tr("Localizable", "composer.commands.unmute") }
      internal enum Format {
        /// text
        internal static var text: String { L10n.tr("Localizable", "composer.commands.format.text") }
        /// @username
        internal static var username: String { L10n.tr("Localizable", "composer.commands.format.username") }
      }
    }
    internal enum Files {
      /// Add more files
      internal static var addMore: String { L10n.tr("Localizable", "composer.files.add-more") }
    }
    internal enum Images {
      /// Change in Settings
      internal static var accessSettings: String { L10n.tr("Localizable", "composer.images.access-settings") }
      /// You have not granted access to the photo library.
      internal static var noAccessLibrary: String { L10n.tr("Localizable", "composer.images.no-access-library") }
    }
    internal enum Picker {
      /// Cancel
      internal static var cancel: String { L10n.tr("Localizable", "composer.picker.cancel") }
      /// File
      internal static var file: String { L10n.tr("Localizable", "composer.picker.file") }
      /// Photo or Video
      internal static var media: String { L10n.tr("Localizable", "composer.picker.media") }
      /// Choose attachment type: 
      internal static var title: String { L10n.tr("Localizable", "composer.picker.title") }
    }
    internal enum Placeholder {
      /// Search GIFs
      internal static var giphy: String { L10n.tr("Localizable", "composer.placeholder.giphy") }
      /// Send a message
      internal static var message: String { L10n.tr("Localizable", "composer.placeholder.message") }
      /// Slow mode ON
      internal static var slowMode: String { L10n.tr("Localizable", "composer.placeholder.slow-mode") }
    }
    internal enum Quoted {
      /// Giphy
      internal static var giphy: String { L10n.tr("Localizable", "composer.quoted.giphy") }
      /// Photo
      internal static var photo: String { L10n.tr("Localizable", "composer.quoted.photo") }
      /// Video
      internal static var video: String { L10n.tr("Localizable", "composer.quoted.video") }
    }
    internal enum Recording {
      /// Slide to cancel
      internal static var slideToCancel: String { L10n.tr("Localizable", "composer.recording.slide-to-cancel") }
      /// Hold to record, release to send
      internal static var tip: String { L10n.tr("Localizable", "composer.recording.tip") }
    }
    internal enum Suggestions {
      internal enum Commands {
        /// Instant Commands
        internal static var header: String { L10n.tr("Localizable", "composer.suggestions.commands.header") }
      }
    }
    internal enum Title {
      /// Edit Message
      internal static var edit: String { L10n.tr("Localizable", "composer.title.edit") }
      /// Reply to Message
      internal static var reply: String { L10n.tr("Localizable", "composer.title.reply") }
    }
  }

  internal enum Dates {
    /// last seen %d days ago
    internal static func timeAgoDaysPlural(_ p1: Int) -> String {
      return L10n.tr("Localizable", "dates.time-ago-days-plural", p1)
    }
    /// last seen one day ago
    internal static var timeAgoDaysSingular: String { L10n.tr("Localizable", "dates.time-ago-days-singular") }
    /// last seen %d hours ago
    internal static func timeAgoHoursPlural(_ p1: Int) -> String {
      return L10n.tr("Localizable", "dates.time-ago-hours-plural", p1)
    }
    /// last seen one hour ago
    internal static var timeAgoHoursSingular: String { L10n.tr("Localizable", "dates.time-ago-hours-singular") }
    /// last seen %d minutes ago
    internal static func timeAgoMinutesPlural(_ p1: Int) -> String {
      return L10n.tr("Localizable", "dates.time-ago-minutes-plural", p1)
    }
    /// last seen one minute ago
    internal static var timeAgoMinutesSingular: String { L10n.tr("Localizable", "dates.time-ago-minutes-singular") }
    /// last seen %d months ago
    internal static func timeAgoMonthsPlural(_ p1: Int) -> String {
      return L10n.tr("Localizable", "dates.time-ago-months-plural", p1)
    }
    /// last seen one month ago
    internal static var timeAgoMonthsSingular: String { L10n.tr("Localizable", "dates.time-ago-months-singular") }
    /// last seen %d seconds ago
    internal static func timeAgoSecondsPlural(_ p1: Int) -> String {
      return L10n.tr("Localizable", "dates.time-ago-seconds-plural", p1)
    }
    /// last seen just one second ago
    internal static var timeAgoSecondsSingular: String { L10n.tr("Localizable", "dates.time-ago-seconds-singular") }
    /// last seen %d weeks ago
    internal static func timeAgoWeeksPlural(_ p1: Int) -> String {
      return L10n.tr("Localizable", "dates.time-ago-weeks-plural", p1)
    }
    /// last seen one week ago
    internal static var timeAgoWeeksSingular: String { L10n.tr("Localizable", "dates.time-ago-weeks-singular") }
  }

  internal enum Message {
    /// Message deleted
    internal static var deletedMessagePlaceholder: String { L10n.tr("Localizable", "message.deleted-message-placeholder") }
    /// Only visible to you
    internal static var onlyVisibleToYou: String { L10n.tr("Localizable", "message.only-visible-to-you") }
    internal enum Actions {
      /// Copy Message
      internal static var copy: String { L10n.tr("Localizable", "message.actions.copy") }
      /// Delete Message
      internal static var delete: String { L10n.tr("Localizable", "message.actions.delete") }
      /// Edit Message
      internal static var edit: String { L10n.tr("Localizable", "message.actions.edit") }
      /// Flag Message
      internal static var flag: String { L10n.tr("Localizable", "message.actions.flag") }
      /// Reply
      internal static var inlineReply: String { L10n.tr("Localizable", "message.actions.inline-reply") }
      /// Mark Unread
      internal static var markUnread: String { L10n.tr("Localizable", "message.actions.mark-unread") }
      /// Pin to conversation
      internal static var pin: String { L10n.tr("Localizable", "message.actions.pin") }
      /// Resend
      internal static var resend: String { L10n.tr("Localizable", "message.actions.resend") }
      /// Thread Reply
      internal static var threadReply: String { L10n.tr("Localizable", "message.actions.thread-reply") }
      /// Unpin from conversation
      internal static var unpin: String { L10n.tr("Localizable", "message.actions.unpin") }
      /// Block User
      internal static var userBlock: String { L10n.tr("Localizable", "message.actions.user-block") }
      /// Mute User
      internal static var userMute: String { L10n.tr("Localizable", "message.actions.user-mute") }
      /// Unblock User
      internal static var userUnblock: String { L10n.tr("Localizable", "message.actions.user-unblock") }
      /// Unmute User
      internal static var userUnmute: String { L10n.tr("Localizable", "message.actions.user-unmute") }
      internal enum Delete {
        /// Are you sure you want to permanently delete this message?
        internal static var confirmationMessage: String { L10n.tr("Localizable", "message.actions.delete.confirmation-message") }
        /// Delete Message
        internal static var confirmationTitle: String { L10n.tr("Localizable", "message.actions.delete.confirmation-title") }
      }
      internal enum Flag {
        /// Do you want to send a copy of this message to a moderator for further investigation?
        internal static var confirmationMessage: String { L10n.tr("Localizable", "message.actions.flag.confirmation-message") }
        /// Flag Message
        internal static var confirmationTitle: String { L10n.tr("Localizable", "message.actions.flag.confirmation-title") }
      }
    }
    internal enum Bounce {
      /// Message was bounced
      internal static var title: String { L10n.tr("Localizable", "message.bounce.title") }
    }
    internal enum Cell {
      /// Edited
      internal static var edited: String { L10n.tr("Localizable", "message.cell.edited") }
      /// Pinned by
      internal static var pinnedBy: String { L10n.tr("Localizable", "message.cell.pinnedBy") }
      /// unknown
      internal static var unknownPin: String { L10n.tr("Localizable", "message.cell.unknownPin") }
    }
    internal enum FileAttachment {
      /// Error occured while previewing the file.
      internal static var errorPreview: String { L10n.tr("Localizable", "message.file-attachment.error-preview") }
    }
    internal enum Gallery {
      /// Photos
      internal static var photos: String { L10n.tr("Localizable", "message.gallery.photos") }
    }
    internal enum GiphyAttachment {
      /// GIPHY
      internal static var title: String { L10n.tr("Localizable", "message.giphy-attachment.title") }
    }
    internal enum Reactions {
      /// You
      internal static var currentUser: String { L10n.tr("Localizable", "message.reactions.currentUser") }
    }
    internal enum Search {
      /// Cancel
      internal static var cancel: String { L10n.tr("Localizable", "message.search.cancel") }
      /// Plural format key: "%#@results@"
      internal static func numberOfResults(_ p1: Int) -> String {
        return L10n.tr("Localizable", "message.search.number-of-results", p1)
      }
      /// Search
      internal static var title: String { L10n.tr("Localizable", "message.search.title") }
    }
    internal enum Sending {
      /// UPLOADING FAILED
      internal static var attachmentUploadingFailed: String { L10n.tr("Localizable", "message.sending.attachment-uploading-failed") }
    }
    internal enum Threads {
      /// Plural format key: "%#@replies@"
      internal static func count(_ p1: Int) -> String {
        return L10n.tr("Localizable", "message.threads.count", p1)
      }
      /// Thread Replies
      internal static var replies: String { L10n.tr("Localizable", "message.threads.replies") }
      /// Thread Reply
      internal static var reply: String { L10n.tr("Localizable", "message.threads.reply") }
      /// with %@
      internal static func replyWith(_ p1: Any) -> String {
        return L10n.tr("Localizable", "message.threads.replyWith", String(describing: p1))
      }
      /// with messages
      internal static var subtitle: String { L10n.tr("Localizable", "message.threads.subtitle") }
    }
    internal enum Title {
      /// %d members, %d online
      internal static func group(_ p1: Int, _ p2: Int) -> String {
        return L10n.tr("Localizable", "message.title.group", p1, p2)
      }
      /// Offline
      internal static var offline: String { L10n.tr("Localizable", "message.title.offline") }
      /// Online
      internal static var online: String { L10n.tr("Localizable", "message.title.online") }
    }
    internal enum Unread {
      /// Plural format key: "%#@unread@"
      internal static func count(_ p1: Int) -> String {
        return L10n.tr("Localizable", "message.unread.count", p1)
      }
    }
  }

  internal enum MessageList {
    /// Plural format key: "%#@messages@"
    internal static func newMessages(_ p1: Int) -> String {
      return L10n.tr("Localizable", "messageList.newMessages", p1)
    }
    internal enum TypingIndicator {
      /// Someone is typing
      internal static var typingUnknown: String { L10n.tr("Localizable", "messageList.typingIndicator.typing-unknown") }
      /// Plural format key: "%1$@%2$#@typing@"
      internal static func users(_ p1: Any, _ p2: Int) -> String {
        return L10n.tr("Localizable", "messageList.typingIndicator.users", String(describing: p1), p2)
      }
    }
  }

  internal enum Reaction {
    internal enum Authors {
      /// Plural format key: "%#@reactions@"
      internal static func numberOfReactions(_ p1: Int) -> String {
        return L10n.tr("Localizable", "reaction.authors.number-of-reactions", p1)
      }
    }
  }

  internal enum Recording {
    internal enum Presentation {
      /// Plural format key: "%#@recording@"
      internal static func name(_ p1: Int) -> String {
        return L10n.tr("Localizable", "recording.presentation.name", p1)
      }
    }
  }
}

// MARK: - Implementation Details

extension L10n {

  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
     let format = Appearance.localizationProvider(key, table)
     return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {
  static let bundle: Bundle = .streamChatUI
}

