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
      /// Discard Changes
      internal static var discardChanges: String { L10n.tr("Localizable", "alert.actions.discard-changes") }
      /// End
      internal static var end: String { L10n.tr("Localizable", "alert.actions.end") }
      /// Keep Editing
      internal static var keepEditing: String { L10n.tr("Localizable", "alert.actions.keep-editing") }
      /// Leave
      internal static var leaveGroupButton: String { L10n.tr("Localizable", "alert.actions.leave-group-button") }
      /// Are you sure you want to leave this group?
      internal static var leaveGroupMessage: String { L10n.tr("Localizable", "alert.actions.leave-group-message") }
      /// Leave group
      internal static var leaveGroupTitle: String { L10n.tr("Localizable", "alert.actions.leave-group-title") }
      /// Are you sure you want to mute this
      internal static var muteChannelTitle: String { L10n.tr("Localizable", "alert.actions.mute-channel-title") }
      /// OK
      internal static var ok: String { L10n.tr("Localizable", "alert.actions.ok") }
      /// Send
      internal static var send: String { L10n.tr("Localizable", "alert.actions.send") }
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
    internal enum TextField {
      /// Enter a new option
      internal static var pollsNewOption: String { L10n.tr("Localizable", "alert.text-field.polls-new-option") }
    }
    internal enum Title {
      /// Add a comment
      internal static var addComment: String { L10n.tr("Localizable", "alert.title.add-comment") }
      /// Nobody will be able to vote in this poll anymore.
      internal static var endPoll: String { L10n.tr("Localizable", "alert.title.end-poll") }
      /// Suggest an option
      internal static var suggestAnOption: String { L10n.tr("Localizable", "alert.title.suggest-an-option") }
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
      /// Poll
      internal static var poll: String { L10n.tr("Localizable", "channel.item.poll") }
      /// %@ created:
      internal static func pollSomeoneCreated(_ p1: Any) -> String {
        return L10n.tr("Localizable", "channel.item.poll-someone-created", String(describing: p1))
      }
      /// %@ voted:
      internal static func pollSomeoneVoted(_ p1: Any) -> String {
        return L10n.tr("Localizable", "channel.item.poll-someone-voted", String(describing: p1))
      }
      /// You created:
      internal static var pollYouCreated: String { L10n.tr("Localizable", "channel.item.poll-you-created") }
      /// You voted:
      internal static var pollYouVoted: String { L10n.tr("Localizable", "channel.item.poll-you-voted") }
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
    internal enum Polls {
      /// Are you sure you want to discard your poll?
      internal static var actionSheetDiscardTitle: String { L10n.tr("Localizable", "composer.polls.action-sheet-discard-title") }
      /// Add a comment
      internal static var addComment: String { L10n.tr("Localizable", "composer.polls.add-comment") }
      /// Add an option
      internal static var addOption: String { L10n.tr("Localizable", "composer.polls.add-option") }
      /// Anonymous poll
      internal static var anonymousPoll: String { L10n.tr("Localizable", "composer.polls.anonymous-poll") }
      /// Ask a question
      internal static var askQuestion: String { L10n.tr("Localizable", "composer.polls.askQuestion") }
      /// Create Poll
      internal static var createPoll: String { L10n.tr("Localizable", "composer.polls.create-poll") }
      /// This is already an option
      internal static var duplicateOption: String { L10n.tr("Localizable", "composer.polls.duplicate-option") }
      /// Maximum votes per person
      internal static var maximumVotesPerPerson: String { L10n.tr("Localizable", "composer.polls.maximum-votes-per-person") }
      /// Multiple answers
      internal static var multipleAnswers: String { L10n.tr("Localizable", "composer.polls.multiple-answers") }
      /// Options
      internal static var options: String { L10n.tr("Localizable", "composer.polls.options") }
      /// Question
      internal static var question: String { L10n.tr("Localizable", "composer.polls.question") }
      /// Suggest an option
      internal static var suggestOption: String { L10n.tr("Localizable", "composer.polls.suggest-option") }
      /// Type a number from 1 and 10
      internal static var typeNumberFrom1And10: String { L10n.tr("Localizable", "composer.polls.type-number-from-1-and-10") }
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
    /// Today
    internal static var today: String { L10n.tr("Localizable", "dates.today") }
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
      internal enum UserBlock {
        /// Are you sure you want to block this user?
        internal static var confirmationMessage: String { L10n.tr("Localizable", "message.actions.user-block.confirmation-message") }
      }
      internal enum UserUnblock {
        /// Are you sure you want to unblock this user?
        internal static var confirmationMessage: String { L10n.tr("Localizable", "message.actions.user-unblock.confirmation-message") }
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
    internal enum Polls {
      /// Anonymous
      internal static var unknownVoteAuthor: String { L10n.tr("Localizable", "message.polls.unknown-vote-author") }
      /// %d votes
      internal static func votes(_ p1: Int) -> String {
        return L10n.tr("Localizable", "message.polls.votes", p1)
      }
      internal enum Button {
        /// Add a Comment
        internal static var addComment: String { L10n.tr("Localizable", "message.polls.button.addComment") }
        /// End Vote
        internal static var endVote: String { L10n.tr("Localizable", "message.polls.button.endVote") }
        /// See %d More Options
        internal static func seeMoreOptions(_ p1: Int) -> String {
          return L10n.tr("Localizable", "message.polls.button.seeMoreOptions", p1)
        }
        /// Show All
        internal static var showAll: String { L10n.tr("Localizable", "message.polls.button.show-all") }
        /// Suggest an Option
        internal static var suggestAnOption: String { L10n.tr("Localizable", "message.polls.button.suggestAnOption") }
        /// Update Your Comment
        internal static var updateComment: String { L10n.tr("Localizable", "message.polls.button.updateComment") }
        /// Plural format key: "%#@comments@"
        internal static func viewNumberOfComments(_ p1: Int) -> String {
          return L10n.tr("Localizable", "message.polls.button.view-number-of-comments", p1)
        }
        /// View Results
        internal static var viewResults: String { L10n.tr("Localizable", "message.polls.button.viewResults") }
      }
      internal enum Subtitle {
        /// Select one
        internal static var selectOne: String { L10n.tr("Localizable", "message.polls.subtitle.selectOne") }
        /// Select one or more
        internal static var selectOneOrMore: String { L10n.tr("Localizable", "message.polls.subtitle.selectOneOrMore") }
        /// Select up to %d
        internal static func selectUpTo(_ p1: Int) -> String {
          return L10n.tr("Localizable", "message.polls.subtitle.selectUpTo", p1)
        }
        /// Vote ended
        internal static var voteEnded: String { L10n.tr("Localizable", "message.polls.subtitle.voteEnded") }
      }
      internal enum Toolbar {
        /// Poll Comments
        internal static var commentsTitle: String { L10n.tr("Localizable", "message.polls.toolbar.comments-title") }
        /// Poll Options
        internal static var optionsTitle: String { L10n.tr("Localizable", "message.polls.toolbar.options-title") }
        /// Poll Results
        internal static var resultsTitle: String { L10n.tr("Localizable", "message.polls.toolbar.results-title") }
      }
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

  internal enum Thread {
    /// %d new threads
    internal static func newThreads(_ p1: Int) -> String {
      return L10n.tr("Localizable", "thread.new-threads", p1)
    }
    /// Threads
    internal static var title: String { L10n.tr("Localizable", "thread.title") }
    internal enum Error {
      /// Error loading threads
      internal static var message: String { L10n.tr("Localizable", "thread.error.message") }
    }
    internal enum Item {
      /// replied to: %@
      internal static func repliedTo(_ p1: Any) -> String {
        return L10n.tr("Localizable", "thread.item.replied-to", String(describing: p1))
      }
    }
    internal enum NoContent {
      /// No threads here yet...
      internal static var message: String { L10n.tr("Localizable", "thread.no-content.message") }
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

