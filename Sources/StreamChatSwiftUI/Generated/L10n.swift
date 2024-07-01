// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation


// MARK: - Strings

public enum L10n {
  /// %d of %d
  public static func currentSelection(_ p1: Int, _ p2: Int) -> String {
    return L10n.tr("Localizable", "current-selection", p1, p2)
  }

  public enum Alert {
    public enum Actions {
      /// Cancel
      public static var cancel: String { L10n.tr("Localizable", "alert.actions.cancel") }
      /// Delete
      public static var delete: String { L10n.tr("Localizable", "alert.actions.delete") }
      /// Are you sure you want to delete this conversation?
      public static var deleteChannelMessage: String { L10n.tr("Localizable", "alert.actions.delete-channel-message") }
      /// Delete conversation
      public static var deleteChannelTitle: String { L10n.tr("Localizable", "alert.actions.delete-channel-title") }
      /// Discard Changes
      public static var discardChanges: String { L10n.tr("Localizable", "alert.actions.discard-changes") }
      /// End
      public static var end: String { L10n.tr("Localizable", "alert.actions.end") }
      /// Keep Editing
      public static var keepEditing: String { L10n.tr("Localizable", "alert.actions.keep-editing") }
      /// Leave
      public static var leaveGroupButton: String { L10n.tr("Localizable", "alert.actions.leave-group-button") }
      /// Are you sure you want to leave this group?
      public static var leaveGroupMessage: String { L10n.tr("Localizable", "alert.actions.leave-group-message") }
      /// Leave group
      public static var leaveGroupTitle: String { L10n.tr("Localizable", "alert.actions.leave-group-title") }
      /// Are you sure you want to mute this
      public static var muteChannelTitle: String { L10n.tr("Localizable", "alert.actions.mute-channel-title") }
      /// OK
      public static var ok: String { L10n.tr("Localizable", "alert.actions.ok") }
      /// Send
      public static var send: String { L10n.tr("Localizable", "alert.actions.send") }
      /// Are you sure you want to unmute this
      public static var unmuteChannelTitle: String { L10n.tr("Localizable", "alert.actions.unmute-channel-title") }
      /// View info
      public static var viewInfoTitle: String { L10n.tr("Localizable", "alert.actions.view-info-title") }
    }
    public enum Error {
      /// The operation couldn't be completed.
      public static var message: String { L10n.tr("Localizable", "alert.error.message") }
      /// Something went wrong.
      public static var title: String { L10n.tr("Localizable", "alert.error.title") }
    }
    public enum TextField {
      /// Enter a new option
      public static var pollsNewOption: String { L10n.tr("Localizable", "alert.text-field.polls-new-option") }
    }
    public enum Title {
      /// Add a comment
      public static var addComment: String { L10n.tr("Localizable", "alert.title.add-comment") }
      /// Nobody will be able to vote in this poll anymore.
      public static var endPoll: String { L10n.tr("Localizable", "alert.title.end-poll") }
      /// Suggest an option
      public static var suggestAnOption: String { L10n.tr("Localizable", "alert.title.suggest-an-option") }
    }
  }

  public enum Attachment {
    /// Attachment size exceed the limit.
    public static var maxSizeExceeded: String { L10n.tr("Localizable", "attachment.max-size-exceeded") }
    public enum MaxSize {
      /// Please select a smaller attachment.
      public static var message: String { L10n.tr("Localizable", "attachment.max-size.message") }
      /// Attachment size exceed the limit
      public static var title: String { L10n.tr("Localizable", "attachment.max-size.title") }
    }
  }

  public enum Channel {
    public enum Item {
      /// Audio
      public static var audio: String { L10n.tr("Localizable", "channel.item.audio") }
      /// No messages
      public static var emptyMessages: String { L10n.tr("Localizable", "channel.item.empty-messages") }
      /// Mute
      public static var mute: String { L10n.tr("Localizable", "channel.item.mute") }
      /// Channel is muted
      public static var muted: String { L10n.tr("Localizable", "channel.item.muted") }
      /// Photo
      public static var photo: String { L10n.tr("Localizable", "channel.item.photo") }
      /// %@ created:
      public static func pollSomeoneCreated(_ p1: Any) -> String {
        return L10n.tr("Localizable", "channel.item.poll-someone-created", String(describing: p1))
      }
      /// %@ voted:
      public static func pollSomeoneVoted(_ p1: Any) -> String {
        return L10n.tr("Localizable", "channel.item.poll-someone-voted", String(describing: p1))
      }
      /// You created:
      public static var pollYouCreated: String { L10n.tr("Localizable", "channel.item.poll-you-created") }
      /// You voted:
      public static var pollYouVoted: String { L10n.tr("Localizable", "channel.item.poll-you-voted") }
      /// are typing ...
      public static var typingPlural: String { L10n.tr("Localizable", "channel.item.typing-plural") }
      /// is typing ...
      public static var typingSingular: String { L10n.tr("Localizable", "channel.item.typing-singular") }
      /// Unmute
      public static var unmute: String { L10n.tr("Localizable", "channel.item.unmute") }
      /// Video
      public static var video: String { L10n.tr("Localizable", "channel.item.video") }
      /// Voice Message
      public static var voiceMessage: String { L10n.tr("Localizable", "channel.item.voice-message") }
    }
    public enum Name {
      /// and
      public static var and: String { L10n.tr("Localizable", "channel.name.and") }
      /// and %@ more
      public static func andXMore(_ p1: Any) -> String {
        return L10n.tr("Localizable", "channel.name.andXMore", String(describing: p1))
      }
      /// user
      public static var directMessage: String { L10n.tr("Localizable", "channel.name.direct-message") }
      /// group
      public static var group: String { L10n.tr("Localizable", "channel.name.group") }
      /// NoChannel
      public static var missing: String { L10n.tr("Localizable", "channel.name.missing") }
    }
    public enum NoContent {
      /// How about sending your first message to a friend?
      public static var message: String { L10n.tr("Localizable", "channel.no-content.message") }
      /// Start a chat
      public static var start: String { L10n.tr("Localizable", "channel.no-content.start") }
      /// Let's start chatting
      public static var title: String { L10n.tr("Localizable", "channel.no-content.title") }
    }
  }

  public enum ChatInfo {
    public enum Files {
      /// Files sent in this chat will appear here.
      public static var emptyDesc: String { L10n.tr("Localizable", "chat-info.files.empty-desc") }
      /// No files
      public static var emptyTitle: String { L10n.tr("Localizable", "chat-info.files.empty-title") }
      /// Files
      public static var title: String { L10n.tr("Localizable", "chat-info.files.title") }
    }
    public enum Media {
      /// Photos or videos sent in this chat will appear here.
      public static var emptyDesc: String { L10n.tr("Localizable", "chat-info.media.empty-desc") }
      /// No media
      public static var emptyTitle: String { L10n.tr("Localizable", "chat-info.media.empty-title") }
      /// Photos & Videos
      public static var title: String { L10n.tr("Localizable", "chat-info.media.title") }
    }
    public enum Mute {
      /// Mute Group
      public static var group: String { L10n.tr("Localizable", "chat-info.mute.group") }
      /// Mute User
      public static var user: String { L10n.tr("Localizable", "chat-info.mute.user") }
    }
    public enum PinnedMessages {
      /// Long-press an important message and choose Pin to conversation.
      public static var emptyDesc: String { L10n.tr("Localizable", "chat-info.pinned-messages.empty-desc") }
      /// No pinned messages
      public static var emptyTitle: String { L10n.tr("Localizable", "chat-info.pinned-messages.empty-title") }
      /// Pinned Messages
      public static var title: String { L10n.tr("Localizable", "chat-info.pinned-messages.title") }
    }
    public enum Rename {
      /// NAME
      public static var name: String { L10n.tr("Localizable", "chat-info.rename.name") }
      /// Add a group name
      public static var placeholder: String { L10n.tr("Localizable", "chat-info.rename.placeholder") }
    }
    public enum Users {
      /// %@ more
      public static func loadMore(_ p1: Any) -> String {
        return L10n.tr("Localizable", "chat-info.users.loadMore", String(describing: p1))
      }
    }
  }

  public enum Composer {
    public enum Checkmark {
      /// Also send in channel
      public static var channelReply: String { L10n.tr("Localizable", "composer.checkmark.channel-reply") }
      /// Also send as direct message
      public static var directMessageReply: String { L10n.tr("Localizable", "composer.checkmark.direct-message-reply") }
    }
    public enum Commands {
      /// Giphy
      public static var giphy: String { L10n.tr("Localizable", "composer.commands.giphy") }
      /// Mute
      public static var mute: String { L10n.tr("Localizable", "composer.commands.mute") }
      /// Unmute
      public static var unmute: String { L10n.tr("Localizable", "composer.commands.unmute") }
      public enum Format {
        /// text
        public static var text: String { L10n.tr("Localizable", "composer.commands.format.text") }
        /// @username
        public static var username: String { L10n.tr("Localizable", "composer.commands.format.username") }
      }
    }
    public enum Files {
      /// Add more files
      public static var addMore: String { L10n.tr("Localizable", "composer.files.add-more") }
    }
    public enum Images {
      /// Change in Settings
      public static var accessSettings: String { L10n.tr("Localizable", "composer.images.access-settings") }
      /// You have not granted access to the photo library.
      public static var noAccessLibrary: String { L10n.tr("Localizable", "composer.images.no-access-library") }
    }
    public enum Picker {
      /// Cancel
      public static var cancel: String { L10n.tr("Localizable", "composer.picker.cancel") }
      /// File
      public static var file: String { L10n.tr("Localizable", "composer.picker.file") }
      /// Photo or Video
      public static var media: String { L10n.tr("Localizable", "composer.picker.media") }
      /// Choose attachment type: 
      public static var title: String { L10n.tr("Localizable", "composer.picker.title") }
    }
    public enum Placeholder {
      /// Search GIFs
      public static var giphy: String { L10n.tr("Localizable", "composer.placeholder.giphy") }
      /// Send a message
      public static var message: String { L10n.tr("Localizable", "composer.placeholder.message") }
      /// Slow mode ON
      public static var slowMode: String { L10n.tr("Localizable", "composer.placeholder.slow-mode") }
    }
    public enum Polls {
      /// Are you sure you want to discard your poll?
      public static var actionSheetDiscardTitle: String { L10n.tr("Localizable", "composer.polls.action-sheet-discard-title") }
      /// Add a comment
      public static var addComment: String { L10n.tr("Localizable", "composer.polls.add-comment") }
      /// Add an option
      public static var addOption: String { L10n.tr("Localizable", "composer.polls.add-option") }
      /// Anonymous poll
      public static var anonymousPoll: String { L10n.tr("Localizable", "composer.polls.anonymous-poll") }
      /// Ask a question
      public static var askQuestion: String { L10n.tr("Localizable", "composer.polls.askQuestion") }
      /// Create Poll
      public static var createPoll: String { L10n.tr("Localizable", "composer.polls.create-poll") }
      /// This is already an option
      public static var duplicateOption: String { L10n.tr("Localizable", "composer.polls.duplicate-option") }
      /// Maximum votes per person
      public static var maximumVotesPerPerson: String { L10n.tr("Localizable", "composer.polls.maximum-votes-per-person") }
      /// Multiple answers
      public static var multipleAnswers: String { L10n.tr("Localizable", "composer.polls.multiple-answers") }
      /// Options
      public static var options: String { L10n.tr("Localizable", "composer.polls.options") }
      /// Question
      public static var question: String { L10n.tr("Localizable", "composer.polls.question") }
      /// Suggest an option
      public static var suggestOption: String { L10n.tr("Localizable", "composer.polls.suggest-option") }
      /// Type a number from 1 and 10
      public static var typeNumberFrom1And10: String { L10n.tr("Localizable", "composer.polls.type-number-from-1-and-10") }
    }
    public enum Quoted {
      /// Giphy
      public static var giphy: String { L10n.tr("Localizable", "composer.quoted.giphy") }
      /// Photo
      public static var photo: String { L10n.tr("Localizable", "composer.quoted.photo") }
      /// Video
      public static var video: String { L10n.tr("Localizable", "composer.quoted.video") }
    }
    public enum Recording {
      /// Slide to cancel
      public static var slideToCancel: String { L10n.tr("Localizable", "composer.recording.slide-to-cancel") }
      /// Hold to record, release to send
      public static var tip: String { L10n.tr("Localizable", "composer.recording.tip") }
    }
    public enum Suggestions {
      public enum Commands {
        /// Instant Commands
        public static var header: String { L10n.tr("Localizable", "composer.suggestions.commands.header") }
      }
    }
    public enum Title {
      /// Edit Message
      public static var edit: String { L10n.tr("Localizable", "composer.title.edit") }
      /// Reply to Message
      public static var reply: String { L10n.tr("Localizable", "composer.title.reply") }
    }
  }

  public enum Dates {
    /// last seen %d days ago
    public static func timeAgoDaysPlural(_ p1: Int) -> String {
      return L10n.tr("Localizable", "dates.time-ago-days-plural", p1)
    }
    /// last seen one day ago
    public static var timeAgoDaysSingular: String { L10n.tr("Localizable", "dates.time-ago-days-singular") }
    /// last seen %d hours ago
    public static func timeAgoHoursPlural(_ p1: Int) -> String {
      return L10n.tr("Localizable", "dates.time-ago-hours-plural", p1)
    }
    /// last seen one hour ago
    public static var timeAgoHoursSingular: String { L10n.tr("Localizable", "dates.time-ago-hours-singular") }
    /// last seen %d minutes ago
    public static func timeAgoMinutesPlural(_ p1: Int) -> String {
      return L10n.tr("Localizable", "dates.time-ago-minutes-plural", p1)
    }
    /// last seen one minute ago
    public static var timeAgoMinutesSingular: String { L10n.tr("Localizable", "dates.time-ago-minutes-singular") }
    /// last seen %d months ago
    public static func timeAgoMonthsPlural(_ p1: Int) -> String {
      return L10n.tr("Localizable", "dates.time-ago-months-plural", p1)
    }
    /// last seen one month ago
    public static var timeAgoMonthsSingular: String { L10n.tr("Localizable", "dates.time-ago-months-singular") }
    /// last seen %d seconds ago
    public static func timeAgoSecondsPlural(_ p1: Int) -> String {
      return L10n.tr("Localizable", "dates.time-ago-seconds-plural", p1)
    }
    /// last seen just one second ago
    public static var timeAgoSecondsSingular: String { L10n.tr("Localizable", "dates.time-ago-seconds-singular") }
    /// last seen %d weeks ago
    public static func timeAgoWeeksPlural(_ p1: Int) -> String {
      return L10n.tr("Localizable", "dates.time-ago-weeks-plural", p1)
    }
    /// last seen one week ago
    public static var timeAgoWeeksSingular: String { L10n.tr("Localizable", "dates.time-ago-weeks-singular") }
    /// Today
    public static var today: String { L10n.tr("Localizable", "dates.today") }
  }

  public enum Message {
    /// Message deleted
    public static var deletedMessagePlaceholder: String { L10n.tr("Localizable", "message.deleted-message-placeholder") }
    /// Only visible to you
    public static var onlyVisibleToYou: String { L10n.tr("Localizable", "message.only-visible-to-you") }
    public enum Actions {
      /// Copy Message
      public static var copy: String { L10n.tr("Localizable", "message.actions.copy") }
      /// Delete Message
      public static var delete: String { L10n.tr("Localizable", "message.actions.delete") }
      /// Edit Message
      public static var edit: String { L10n.tr("Localizable", "message.actions.edit") }
      /// Flag Message
      public static var flag: String { L10n.tr("Localizable", "message.actions.flag") }
      /// Reply
      public static var inlineReply: String { L10n.tr("Localizable", "message.actions.inline-reply") }
      /// Mark Unread
      public static var markUnread: String { L10n.tr("Localizable", "message.actions.mark-unread") }
      /// Pin to conversation
      public static var pin: String { L10n.tr("Localizable", "message.actions.pin") }
      /// Resend
      public static var resend: String { L10n.tr("Localizable", "message.actions.resend") }
      /// Thread Reply
      public static var threadReply: String { L10n.tr("Localizable", "message.actions.thread-reply") }
      /// Unpin from conversation
      public static var unpin: String { L10n.tr("Localizable", "message.actions.unpin") }
      /// Block User
      public static var userBlock: String { L10n.tr("Localizable", "message.actions.user-block") }
      /// Mute User
      public static var userMute: String { L10n.tr("Localizable", "message.actions.user-mute") }
      /// Unblock User
      public static var userUnblock: String { L10n.tr("Localizable", "message.actions.user-unblock") }
      /// Unmute User
      public static var userUnmute: String { L10n.tr("Localizable", "message.actions.user-unmute") }
      public enum Delete {
        /// Are you sure you want to permanently delete this message?
        public static var confirmationMessage: String { L10n.tr("Localizable", "message.actions.delete.confirmation-message") }
        /// Delete Message
        public static var confirmationTitle: String { L10n.tr("Localizable", "message.actions.delete.confirmation-title") }
      }
      public enum Flag {
        /// Do you want to send a copy of this message to a moderator for further investigation?
        public static var confirmationMessage: String { L10n.tr("Localizable", "message.actions.flag.confirmation-message") }
        /// Flag Message
        public static var confirmationTitle: String { L10n.tr("Localizable", "message.actions.flag.confirmation-title") }
      }
    }
    public enum Bounce {
      /// Message was bounced
      public static var title: String { L10n.tr("Localizable", "message.bounce.title") }
    }
    public enum Cell {
      /// Edited
      public static var edited: String { L10n.tr("Localizable", "message.cell.edited") }
      /// Pinned by
      public static var pinnedBy: String { L10n.tr("Localizable", "message.cell.pinnedBy") }
      /// unknown
      public static var unknownPin: String { L10n.tr("Localizable", "message.cell.unknownPin") }
    }
    public enum FileAttachment {
      /// Error occured while previewing the file.
      public static var errorPreview: String { L10n.tr("Localizable", "message.file-attachment.error-preview") }
    }
    public enum Gallery {
      /// Photos
      public static var photos: String { L10n.tr("Localizable", "message.gallery.photos") }
    }
    public enum GiphyAttachment {
      /// GIPHY
      public static var title: String { L10n.tr("Localizable", "message.giphy-attachment.title") }
    }
    public enum Polls {
      /// Anonymous
      public static var unknownVoteAuthor: String { L10n.tr("Localizable", "message.polls.unknown-vote-author") }
      /// %d votes
      public static func votes(_ p1: Int) -> String {
        return L10n.tr("Localizable", "message.polls.votes", p1)
      }
      public enum Button {
        /// Add a Comment
        public static var addComment: String { L10n.tr("Localizable", "message.polls.button.addComment") }
        /// End Vote
        public static var endVote: String { L10n.tr("Localizable", "message.polls.button.endVote") }
        /// See %d More Options
        public static func seeMoreOptions(_ p1: Int) -> String {
          return L10n.tr("Localizable", "message.polls.button.seeMoreOptions", p1)
        }
        /// Show All
        public static var showAll: String { L10n.tr("Localizable", "message.polls.button.show-all") }
        /// Suggest an Option
        public static var suggestAnOption: String { L10n.tr("Localizable", "message.polls.button.suggestAnOption") }
        /// Update Your Comment
        public static var updateComment: String { L10n.tr("Localizable", "message.polls.button.updateComment") }
        /// Plural format key: "%#@comments@"
        public static func viewNumberOfComments(_ p1: Int) -> String {
          return L10n.tr("Localizable", "message.polls.button.view-number-of-comments", p1)
        }
        /// View Results
        public static var viewResults: String { L10n.tr("Localizable", "message.polls.button.viewResults") }
      }
      public enum Subtitle {
        /// Select one
        public static var selectOne: String { L10n.tr("Localizable", "message.polls.subtitle.selectOne") }
        /// Select one or more
        public static var selectOneOrMore: String { L10n.tr("Localizable", "message.polls.subtitle.selectOneOrMore") }
        /// Select up to %d
        public static func selectUpTo(_ p1: Int) -> String {
          return L10n.tr("Localizable", "message.polls.subtitle.selectUpTo", p1)
        }
        /// Vote ended
        public static var voteEnded: String { L10n.tr("Localizable", "message.polls.subtitle.voteEnded") }
      }
      public enum Toolbar {
        /// Poll Comments
        public static var commentsTitle: String { L10n.tr("Localizable", "message.polls.toolbar.comments-title") }
        /// Poll Options
        public static var optionsTitle: String { L10n.tr("Localizable", "message.polls.toolbar.options-title") }
        /// Poll Results
        public static var resultsTitle: String { L10n.tr("Localizable", "message.polls.toolbar.results-title") }
      }
    }
    public enum Reactions {
      /// You
      public static var currentUser: String { L10n.tr("Localizable", "message.reactions.currentUser") }
    }
    public enum Search {
      /// Cancel
      public static var cancel: String { L10n.tr("Localizable", "message.search.cancel") }
      /// Plural format key: "%#@results@"
      public static func numberOfResults(_ p1: Int) -> String {
        return L10n.tr("Localizable", "message.search.number-of-results", p1)
      }
      /// Search
      public static var title: String { L10n.tr("Localizable", "message.search.title") }
    }
    public enum Sending {
      /// UPLOADING FAILED
      public static var attachmentUploadingFailed: String { L10n.tr("Localizable", "message.sending.attachment-uploading-failed") }
    }
    public enum Threads {
      /// Plural format key: "%#@replies@"
      public static func count(_ p1: Int) -> String {
        return L10n.tr("Localizable", "message.threads.count", p1)
      }
      /// Thread Replies
      public static var replies: String { L10n.tr("Localizable", "message.threads.replies") }
      /// Thread Reply
      public static var reply: String { L10n.tr("Localizable", "message.threads.reply") }
      /// with %@
      public static func replyWith(_ p1: Any) -> String {
        return L10n.tr("Localizable", "message.threads.replyWith", String(describing: p1))
      }
      /// with messages
      public static var subtitle: String { L10n.tr("Localizable", "message.threads.subtitle") }
    }
    public enum Title {
      /// %d members, %d online
      public static func group(_ p1: Int, _ p2: Int) -> String {
        return L10n.tr("Localizable", "message.title.group", p1, p2)
      }
      /// Offline
      public static var offline: String { L10n.tr("Localizable", "message.title.offline") }
      /// Online
      public static var online: String { L10n.tr("Localizable", "message.title.online") }
    }
    public enum Unread {
      /// Plural format key: "%#@unread@"
      public static func count(_ p1: Int) -> String {
        return L10n.tr("Localizable", "message.unread.count", p1)
      }
    }
  }

  public enum MessageList {
    /// Plural format key: "%#@messages@"
    public static func newMessages(_ p1: Int) -> String {
      return L10n.tr("Localizable", "messageList.newMessages", p1)
    }
    public enum TypingIndicator {
      /// Someone is typing
      public static var typingUnknown: String { L10n.tr("Localizable", "messageList.typingIndicator.typing-unknown") }
      /// Plural format key: "%1$@%2$#@typing@"
      public static func users(_ p1: Any, _ p2: Int) -> String {
        return L10n.tr("Localizable", "messageList.typingIndicator.users", String(describing: p1), p2)
      }
    }
  }

  public enum Reaction {
    public enum Authors {
      /// Plural format key: "%#@reactions@"
      public static func numberOfReactions(_ p1: Int) -> String {
        return L10n.tr("Localizable", "reaction.authors.number-of-reactions", p1)
      }
    }
  }

  public enum Recording {
    public enum Presentation {
      /// Plural format key: "%#@recording@"
      public static func name(_ p1: Int) -> String {
        return L10n.tr("Localizable", "recording.presentation.name", p1)
      }
    }
  }
}

// MARK: - Implementation Details

extension L10n {

  public static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
     let format = Appearance.localizationProvider(key, table)
     return String(format: format, locale: Locale.current, arguments: args)
  }
}

public final class BundleToken {
  static let bundle: Bundle = .streamChatUI
}

