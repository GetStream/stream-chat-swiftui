//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest
import StreamChat

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
        app.scrollViews.firstMatch
    }
    
    static var typingIndicator: XCUIElement {
        app.otherElements["TypingIndicatorBottomView"]
    }
    
    static func reactionsContainer(for message: XCUIElement) -> XCUIElement {
        message.otherElements["ReactionsContainer"]
    }
    
    enum NavigationBar {
        
        static var chatAvatar: XCUIElement {
            app.otherElements.buttons["ChannelAvatarView"]
        }
        
        static var channelTitleView: XCUIElement {
            app.otherElements["ChannelTitleView"]
        }
        
        //TODO: Not working.
        static var chatName: XCUIElement {
            app.otherElements.textViews["chatName"]
        }
        
        //TODO: Not working.
        static var chatOnlineInfo: XCUIElement {
            app.otherElements.textViews["chatOnlineInfo"]
        }
    }
    
    enum Composer {
        
        static var sendButton: XCUIElement {
            app.buttons["SendMessageButton"]
        }
        
        static var mediaButton: XCUIElement {
            app.buttons["PickerTypeButtonMedia"]
        }
        
        static var commandsButton: XCUIElement {
            app.buttons["PickerTypeButtonCommands"]
        }

        static var inputField: XCUIElement {
            app.textViews["ComposerTextInputView"]
        }

        static var collapsedComposerButton: XCUIElement {
            app.buttons["PickerTypeButtonCollapsed"]
        }
        
        static var attachmentPickerPhotos: XCUIElement {
            app.buttons["attachmentPickerPhotos"]
        }
        
        static var attachmentPickerFiles: XCUIElement {
            app.buttons["attachmentPickerFiles"]
        }
        
        static var attachmentPickerCamera: XCUIElement {
            app.buttons["attachmentPickerCamera"]
        }
        
    }
    
    enum Reactions {
        
        static var reactionsMessageView: XCUIElement {
            app.otherElements["ReactionsMessageView"]
        }
        
        static var reactionLove: XCUIElement {
            app.otherElements["reaction-love"]
        }
        
        static var reactionHaha: XCUIElement {
            app.otherElements["reaction-haha"]
        }
        
        static var reactionLike: XCUIElement {
            app.otherElements["reaction-like"]
        }
        
        static var reactionSad: XCUIElement {
            app.otherElements["reaction-sad"]
        }
        
        static var reactionWow: XCUIElement {
            app.otherElements["reaction-wow"]
        }
        
    }

    enum Attributes {

//        static func threadButton(in messageCell: XCUIElement) -> XCUIElement {
//            messageCell.buttons["threadReplyCountButton"]
//        }
//
//        static func time(in messageCell: XCUIElement) -> XCUIElement {
//            messageCell.staticTexts["timestampLabel"]
//        }
//
//        static func author(messageCell: XCUIElement) -> XCUIElement {
//            messageCell.staticTexts["authorNameLabel"]
//        }

        static func text(in messageCell: XCUIElement) -> XCUIElement {
            messageCell.staticTexts["MessageTextView"].firstMatch
        }
//
//        static func quotedText(_ text: String, in messageCell: XCUIElement) -> XCUIElement {
//            messageCell.textViews.matching(NSPredicate(format: "value LIKE '\(text)'")).firstMatch
//        }
//
//        static func deletedIcon(in messageCell: XCUIElement) -> XCUIElement {
//            messageCell.images["onlyVisibleToYouImageView"]
//        }
//
//        static func deletedLabel(in messageCell: XCUIElement) -> XCUIElement {
//            messageCell.staticTexts["onlyVisibleToYouLabel"]
//        }
//
//        static func errorButton(in messageCell: XCUIElement) -> XCUIElement {
//            messageCell.buttons["error indicator"]
//        }
//
//        static func readCount(in messageCell: XCUIElement) -> XCUIElement {
//            messageCell.staticTexts["messageReadСountsLabel"]
//        }
//
//        static func statusCheckmark(for status: MessageDeliveryStatus?, in messageCell: XCUIElement) -> XCUIElement {
//            var identifier = "imageView"
//            if let status = status {
//                identifier = "\(identifier)_\(status.rawValue)"
//            }
//            return messageCell.images[identifier]
//        }
    }
    
    enum MessageActions {
        
        static var messageActionsView: XCUIElement {
            app.otherElements["MessageActionsView"]
        }
        
        static var copyMessageAction: XCUIElement {
            messageActionsView.otherElements["messageAction-copy_message_action"]
        }
        
        static var replyMessageAction: XCUIElement {
            messageActionsView.otherElements["messageAction-reply_message_action"]
        }

        static var threadMessageAction: XCUIElement {
            messageActionsView.otherElements["messageAction-thread_message_action"]
        }
        
        static var editMessageAction: XCUIElement {
            messageActionsView.otherElements["messageAction-edit_message_action"]
        }
        
        static var deleteMessageAction: XCUIElement {
            messageActionsView.otherElements["messageAction-delete_message_action"]
        }
        
        static var muteMessageAction: XCUIElement {
            messageActionsView.otherElements["messageAction-mute_message_action"]
        }
        
        static var unmuteMessageAction: XCUIElement {
            messageActionsView.otherElements["messageAction-unmute_message_action"]
        }
        
        static var flagMessageAction: XCUIElement {
            messageActionsView.otherElements["messageAction-flag_message_action"]
        }
        
        static var pinMessageAction: XCUIElement {
            messageActionsView.otherElements["messageAction-pin_message_action"]
        }
        
        static var unpinMessageAction: XCUIElement {
            messageActionsView.otherElements["messageAction-unpin_message_action"]
        }
        
        static var resendMessageAction: XCUIElement {
            messageActionsView.otherElements["messageAction-resend_message_action"]
        }
    }
    
}
