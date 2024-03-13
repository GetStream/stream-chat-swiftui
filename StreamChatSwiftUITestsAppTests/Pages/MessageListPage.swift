//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest
import StreamChat
@testable import StreamChatSwiftUI

// swiftlint:disable convenience_type

class MessageListPage {

    static var cells: XCUIElementQuery {
        app.otherElements.matching(identifier: "MessageContainerView")
    }

    static func messageView(for cell: XCUIElement) -> XCUIElement {
        cell.otherElements.matching(identifier: "MessageView").firstMatch
    }

    static var messages: XCUIElementQuery {
        app.otherElements.matching(identifier: "MessageView")
    }

    static var list: XCUIElement {
        app.scrollViews.matching(NSPredicate(format: "identifier LIKE 'MessageListView' or identifier LIKE 'MessageListScrollView'")).firstMatch
    }

    static var typingIndicator: XCUIElement {
        app.staticTexts["TypingIndicatorBottomView"].firstMatch
    }

    static var scrollToBottomButton: XCUIElement {
        app.buttons["ScrollToBottomButton"]
    }
    
    static var scrollToBottomButtonUnreadCount: XCUIElement {
        app.staticTexts["ScrollToBottomButton"]
    }

    enum NavigationBar {

        static var chatAvatar: XCUIElement {
            app.images["ChannelAvatarView"]
        }

        static var chatName: XCUIElement {
            app.staticTexts["ChannelTitleView"].firstMatch
        }

        static var participants: XCUIElement {
            app.staticTexts.matching(identifier: "ChannelTitleView").lastMatch!
        }

        // FIXME
        static var debugMenu: XCUIElement {
            app.buttons[""].firstMatch
        }
    }

    // FIXME
    enum Alert {
        enum Debug {
            // Add member
            static var alert: XCUIElement { app.alerts[""] }
            static var addMember: XCUIElement { alert.buttons[""] }
            static var addMemberTextField: XCUIElement { app.textFields[""] }
            static var addMemberOKButton: XCUIElement { app.alerts[""].buttons[""] }

            // Remove member
            static var removeMember: XCUIElement { alert.buttons[""] }
            static func selectMember(withUserId userId: String) -> XCUIElement {
                app.alerts[""].buttons[userId]
            }

            // Show member info
            static var showMemberInfo: XCUIElement { alert.buttons[""] }
            static var dismissMemberInfo: XCUIElement { app.alerts[""].buttons[""] }

            // Truncate channel
            static var truncateWithMessage: XCUIElement { alert.buttons[""] }
            static var truncateWithoutMessage: XCUIElement { alert.buttons[""] }
        }
    }

    enum Composer {
        static var textView: XCUIElement { inputField }
        static var inputField: XCUIElement { app.textViews["ComposerTextInputView"] }
        static var sendButton: XCUIElement { app.buttons["SendMessageButton"] }
        static var confirmButton: XCUIElement { sendButton }
        static var attachmentButton: XCUIElement { app.buttons["PickerTypeButtonMedia"] }
        static var commandButton: XCUIElement { app.buttons["PickerTypeButtonCommands"] }
        static var collapsedComposerButton: XCUIElement { app.buttons["PickerTypeButtonCollapsed"] }
        static var cooldown: XCUIElement { app.staticTexts["SlowModeView"] }
        static var placeholder: XCUIElement { textView.staticTexts.firstMatch }
        static var cutButton: XCUIElement { app.menuItems.matching(NSPredicate(format: "label LIKE 'Cut'")).firstMatch }
        static var selectAllButton: XCUIElement { app.menuItems.matching(NSPredicate(format: "label LIKE 'Select All'")).firstMatch }
    }

    enum Reactions {
        static var reactionsMessageView: XCUIElement { app.otherElements["ReactionsMessageView"] }
        static var love: XCUIElement { app.otherElements["reaction-love"] }
        static var lol: XCUIElement { app.otherElements["reaction-haha"] }
        static var like: XCUIElement { app.otherElements["reaction-like"] }
        static var sad: XCUIElement { app.otherElements["reaction-sad"] }
        static var wow: XCUIElement { app.otherElements["reaction-wow"] }
    }

    enum Attributes {
        static func reactionButton(in messageCell: XCUIElement) -> XCUIElement {
            messageCell.otherElements["ReactionsContainer"]
        }

        static func threadReplyCountButton(in messageCell: XCUIElement) -> XCUIElement {
            messageCell.buttons["MessageAvatarViewPlaceholder"]
        }

        static func reactions(in messageCell: XCUIElement) -> XCUIElementQuery {
            reactionButton(in: messageCell).images
        }

        static func threadButton(in messageCell: XCUIElement) -> XCUIElement {
            messageCell.otherElements["MessageRepliesView"].firstMatch
        }

        static func time(in messageCell: XCUIElement) -> XCUIElement {
            messageCell.staticTexts["MessageDateView"]
        }

        static func author(messageCell: XCUIElement) -> XCUIElement {
            messageCell.staticTexts["MessageAuthorView"]
        }

        static func text(in messageCell: XCUIElement) -> XCUIElement {
            messageCell.staticTexts["MessageTextView"]
        }

        static func systemMessage(in messageCell: XCUIElement) -> XCUIElement {
            messageCell.staticTexts["SystemMessageView"]
        }

        static func quotedText(_ text: String, in messageCell: XCUIElement) -> XCUIElement {
            messageCell.staticTexts["quotedMessageText"]
        }

        static func deletedText(in messageCell: XCUIElement) -> XCUIElement {
            messageCell.staticTexts["deletedMessageText"]
        }

        static func deletedIcon(in messageCell: XCUIElement) -> XCUIElement {
            messageCell.images["onlyVisibleToYouImageView"]
        }

        static func deletedLabel(in messageCell: XCUIElement) -> XCUIElement {
            messageCell.staticTexts["onlyVisibleToYouLabel"]
        }

        static func errorButton(in messageCell: XCUIElement) -> XCUIElement {
            messageCell.otherElements["SendFailureIndicator"]
        }

        static func readCount(in messageCell: XCUIElement) -> XCUIElement {
            messageCell.staticTexts["readIndicatorCount"]
        }

        // FIXME
        static func statusCheckmark(for status: MessageDeliveryStatus? = nil, in messageCell: XCUIElement) -> XCUIElement {
            messageCell.images["readIndicatorCheckmark"]
        }

        static func giphyButtons(in messageCell: XCUIElement) -> XCUIElementQuery {
            messageCell.buttons.matching(NSPredicate(format: "identifier LIKE 'GiphyAttachmentView'"))
        }

        static func giphySendButton(in messageCell: XCUIElement) -> XCUIElement {
            attachmentActionButton(in: messageCell, label: "Send")
        }

        static func giphyShuffleButton(in messageCell: XCUIElement) -> XCUIElement {
            attachmentActionButton(in: messageCell, label: "Shuffle")
        }

        static func giphyCancelButton(in messageCell: XCUIElement) -> XCUIElement {
            attachmentActionButton(in: messageCell, label: "Cancel")
        }

        static func giphyLabel(in messageCell: XCUIElement) -> XCUIElement {
            messageCell.staticTexts["GiphyAttachmentView"]
        }

        private static func attachmentActionButton(in messageCell: XCUIElement, label: String) -> XCUIElement {
            messageCell.buttons.matching(NSPredicate(
                format: "identifier LIKE 'GiphyAttachmentView' AND label LIKE '\(label)'")).firstMatch
        }

        static var deletedMessagePlaceholder: String {
            L10n.Message.deletedMessagePlaceholder
        }

        static func image(in messageCell: XCUIElement) -> XCUIElement {
            messageCell.images["ImageAttachmentContainer"]
        }

        static func imagePreloader(in messageCell: XCUIElement) -> XCUIElement {
            messageCell.activityIndicators["ImageAttachmentContainer"]
        }

        static func video(in messageCell: XCUIElement) -> XCUIElement {
            messageCell.images["VideoAttachmentsContainer"]
        }

        static func fullscreenImage() -> XCUIElement {
            app.collectionViews.cells.scrollViews.images.firstMatch
        }

        static func files(in messageCell: XCUIElement) -> XCUIElementQuery {
            messageCell.images.matching(NSPredicate(format: "identifier LIKE 'FileAttachmentsContainer'"))
        }

        static func videoPlayer() -> XCUIElement {
            app.otherElements.otherElements.otherElements.matching(NSPredicate(format: "label LIKE 'Video'")).firstMatch
        }

        enum LinkPreview {
            static func link(in messageCell: XCUIElement) -> XCUIElement {
                messageCell.links["LinkAttachmentContainer"]
            }

            static func image(in messageCell: XCUIElement) -> XCUIElement {
                messageCell.otherElements["LinkAttachmentContainer"].images.firstMatch
            }

            static func details(in messageCell: XCUIElement) -> XCUIElementQuery {
                messageCell.staticTexts.matching(NSPredicate(format: "identifier LIKE 'LinkAttachmentContainer'"))
            }

            static func serviceName(in messageCell: XCUIElement) -> XCUIElement {
                let details = details(in: messageCell).waitCount(2)
                if details.count > 2 {
                    return details.firstMatch
                } else {
                    return messageCell.staticTexts["ServiceName is missing"]
                }
            }

            static func title(in messageCell: XCUIElement) -> XCUIElement {
                let details = details(in: messageCell).waitCount(2)
                if details.count > 2 {
                    return details.element(boundBy: 1)
                } else {
                    return details.firstMatch
                }
            }

            static func description(in messageCell: XCUIElement) -> XCUIElement {
                details(in: messageCell).waitCount(2).lastMatch!
            }
        }
    }

    enum ContextMenu {
        case actionsView
        case reply
        case threadReply
        case copy
        case flag
        case mute
        case edit
        case delete
        case hardDelete
        case resend
        case pin
        case unpin

        var element: XCUIElement {
            switch self {
            case .actionsView:
                return Element.actionsView
            case .reply:
                return Element.reply
            case .threadReply:
                return Element.threadReply
            case .copy:
                return Element.copy
            case .flag:
                return Element.flag
            case .mute:
                return Element.mute
            case .edit:
                return Element.edit
            case .delete:
                return Element.delete
            case .hardDelete:
                return Element.hardDelete
            case .resend:
                return Element.resend
            case .pin:
                return Element.pin
            case .unpin:
                return Element.unpin
            }
        }

        struct Element {
            static var actionsView: XCUIElement { app.otherElements["MessageActionsView"] }
            static var reply: XCUIElement { app.otherElements["messageAction-reply_message_action"].images.firstMatch }
            static var threadReply: XCUIElement { app.otherElements["messageAction-thread_message_action"].images.firstMatch }
            static var copy: XCUIElement { app.otherElements["messageAction-copy_message_action"].images.firstMatch }
            static var flag: XCUIElement { app.otherElements["messageAction-flag_message_action"].images.firstMatch }
            static var mute: XCUIElement { app.otherElements["messageAction-mute_message_action"].images.firstMatch }
            static var unmute: XCUIElement { app.otherElements["messageAction-unmute_message_action"].images.firstMatch }
            static var edit: XCUIElement { app.otherElements["messageAction-edit_message_action"].images.firstMatch }
            static var delete: XCUIElement { app.otherElements["messageAction-delete_message_action"].images.firstMatch }
            static var hardDelete: XCUIElement { app.otherElements["messageAction-delete_message_action"].images.firstMatch } // FIXME
            static var resend: XCUIElement { app.otherElements["messageAction-resend_message_action"].images.firstMatch }
            static var pin: XCUIElement { app.otherElements["messageAction-pin_message_action"].images.firstMatch }
            static var unpin: XCUIElement { app.otherElements["messageAction-unpin_message_action"].images.firstMatch }
        }
    }

    enum PopUpButtons {
        static var cancel: XCUIElement {
            app.scrollViews.buttons.matching(NSPredicate(format: "label LIKE 'Cancel'")).firstMatch
        }

        static var delete: XCUIElement {
            app.scrollViews.buttons.matching(NSPredicate(format: "label LIKE 'Delete Message'")).firstMatch
        }
    }

    enum AttachmentMenu {
        static var fileButton: XCUIElement { app.buttons["attachmentPickerFiles"] }
        static var photoOrVideoButton: XCUIElement { app.buttons["attachmentPickerPhotos"] }
        static var cameraButton: XCUIElement { app.buttons["attachmentPickerCamera"] }
        static var cancelButton: XCUIElement {
            app.scrollViews.buttons.matching(NSPredicate(format: "label LIKE 'Cancel'")).firstMatch
        }
        static var images: XCUIElementQuery { app.scrollViews["AttachmentTypeContainer"].images }
    }

    enum ComposerCommands {
        static var cells: XCUIElementQuery {
            app.otherElements.matching(identifier: "InstantCommandView")
        }

        static var headerTitle: XCUIElement {
            app.staticTexts["InstantCommandsHeader"]
        }

        static var headerImage: XCUIElement {
            app.images["InstantCommandsImage"]
        }

        static var giphyImage: XCUIElement {
            app.images["imageGiphy"].firstMatch
        }
    }

    enum ComposerMentions {
        static var cells: XCUIElementQuery {
            app.scrollViews["CommandsContainerView"].otherElements.matching(NSPredicate(format: "identifier LIKE 'MessageAvatarView'"))
        }
    }

}
