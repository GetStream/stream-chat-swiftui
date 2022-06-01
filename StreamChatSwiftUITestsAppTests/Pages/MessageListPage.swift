//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest
import StreamChat

// swiftlint:disable convenience_type

class MessageListPage {
    
    static var cells: XCUIElementQuery {
        app.otherElements.matching(identifier: "MessageContainerView")
    }
    
    static var list: XCUIElement {
        app.scrollViews["ChatChannelView"]
    }
    
    static var typingIndicator: XCUIElement {
        app.otherElements["TypingIndicatorBottomView"]
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
        static var inputField: XCUIElement { app.textViews["ComposerTextInputView"] }
        static var sendButton: XCUIElement { app.buttons["SendMessageButton"] }
        static var mediaButton: XCUIElement { app.buttons["PickerTypeButtonMedia"] }
        static var commandsButton: XCUIElement { app.buttons["PickerTypeButtonCommands"] }
        static var collapsedComposerButton: XCUIElement { app.buttons["PickerTypeButtonCollapsed"] }
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
//            messageCell.buttons["threadReplyCountButton"]
            return app.buttons.firstMatch // DUMMY LINE
        }
//
        static func time(in messageCell: XCUIElement) -> XCUIElement {
//            messageCell.staticTexts["MessageDateView"] // FIXME for participants
            return app.staticTexts.firstMatch // DUMMY LINE
        }
//
        static func author(messageCell: XCUIElement) -> XCUIElement {
//            messageCell.staticTexts["authorNameLabel"]
            return app.staticTexts.firstMatch // DUMMY LINE
        }

        static func text(in messageCell: XCUIElement) -> XCUIElement {
            messageCell.otherElements["MessageView"].staticTexts["MessageTextView"]
        }

        static func quotedText(_ text: String, in messageCell: XCUIElement) -> XCUIElement {
//            messageCell.textViews.matching(NSPredicate(format: "value LIKE '\(text)'")).firstMatch
            return app.textViews.firstMatch // DUMMY LINE
        }

        static func deletedIcon(in messageCell: XCUIElement) -> XCUIElement {
//            messageCell.images["onlyVisibleToYouImageView"]
            return app.images.firstMatch // DUMMY LINE
        }

        static func deletedLabel(in messageCell: XCUIElement) -> XCUIElement {
//            messageCell.staticTexts["onlyVisibleToYouLabel"]
            return app.staticTexts.firstMatch // DUMMY LINE
        }

        static func errorButton(in messageCell: XCUIElement) -> XCUIElement {
//            messageCell.buttons["error indicator"]
            return app.buttons.firstMatch // DUMMY LINE
        }

        static func readCount(in messageCell: XCUIElement) -> XCUIElement {
//            messageCell.staticTexts["MessageReadIndicatorView"]
            return app.staticTexts.firstMatch // DUMMY LINE
        }

        static func statusCheckmark(for status: MessageDeliveryStatus?, in messageCell: XCUIElement) -> XCUIElement {
//            var identifier = "imageView"
//            if let status = status {
//                identifier = "\(identifier)_\(status.rawValue)"
//            }
//            return messageCell.images[identifier]
            return app.images.firstMatch // DUMMY LINE
        }
    }
    
    enum ContextMenu {
        static var actionsView: XCUIElement { app.otherElements["MessageActionsView"] }
        static var reply: XCUIElement { app.otherElements["messageAction-reply_message_action"] }
        static var threadReply: XCUIElement { app.otherElements["messageAction-thread_message_action"] }
        static var copy: XCUIElement { app.otherElements["messageAction-copy_message_action"] }
        static var flag: XCUIElement { app.otherElements["messageAction-flag_message_action"] }
        static var mute: XCUIElement { app.otherElements["messageAction-mute_message_action"] }
        static var unmute: XCUIElement { app.otherElements["messageAction-unmute_message_action"] }
        static var edit: XCUIElement { app.otherElements["messageAction-edit_message_action"] }
        static var delete: XCUIElement { app.otherElements["messageAction-delete_message_action"] }
        static var resend: XCUIElement { app.otherElements["messageAction-resend_message_action"] }
        static var pin: XCUIElement { app.otherElements["messageAction-pin_message_action"] }
        static var unpin: XCUIElement { app.otherElements["messageAction-unpin_message_action"] }
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
//            app.cells.matching(NSPredicate(format: "identifier LIKE 'ChatCommandSuggestionCollectionViewCell'"))
            return app.cells // DUMMY LINE
        }

        static var headerTitle: XCUIElement {
//            app.otherElements["ChatSuggestionsHeaderView"].staticTexts.firstMatch
            return app.otherElements.firstMatch // DUMMY LINE
        }

        static var headerImage: XCUIElement {
//            app.otherElements["ChatSuggestionsHeaderView"].images.firstMatch
            return app.otherElements.firstMatch // DUMMY LINE
        }

        static var giphyImage: XCUIElement {
//            app.images["command_giphy"]
            return app.images.firstMatch // DUMMY LINE
        }
    }
    
}
