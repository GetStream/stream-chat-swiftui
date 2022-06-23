//
// Copyright © 2022 Stream.io Inc. All rights reserved.
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
        app.scrollViews["ChatChannelView"]
    }
    
    static var typingIndicator: XCUIElement {
        app.otherElements["TypingIndicatorBottomView"].staticTexts.firstMatch
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
    }
    
    enum Composer {
        static var textView: XCUIElement { inputField }
        static var inputField: XCUIElement { app.textViews["ComposerTextInputView"] }
        static var sendButton: XCUIElement { app.buttons["SendMessageButton"] }
        static var confirmButton: XCUIElement { sendButton }
        static var mediaButton: XCUIElement { app.buttons["PickerTypeButtonMedia"] }
        static var commandButton: XCUIElement { app.buttons["PickerTypeButtonCommands"] }
        static var collapsedComposerButton: XCUIElement { app.buttons["PickerTypeButtonCollapsed"] }
        static var cooldown: XCUIElement { app.textViews["ComposerTextInputView"] }
        static var cutButton: XCUIElement { app.menuItems.matching(NSPredicate(format: "label LIKE 'Cut'")).firstMatch }
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
            messageCell.otherElements["MessageView"].staticTexts["MessageTextView"] // TODO: does not work when text equals to emoji
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

        static func statusCheckmark(for status: MessageDeliveryStatus? = nil, in messageCell: XCUIElement) -> XCUIElement {
            messageCell.images["readIndicatorCheckmark"]
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
        
        private static func attachmentActionButton(in messageCell: XCUIElement, label: String) -> XCUIElement {
            messageCell.buttons.matching(NSPredicate(
                format: "identifier LIKE 'GiphyAttachmentView' AND label LIKE '\(label)'")).firstMatch
        }
        
        static var deletedMessagePlaceholder: String {
            L10n.Message.deletedMessagePlaceholder
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
    
}
