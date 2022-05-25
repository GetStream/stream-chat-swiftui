//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest
import StreamChat

class MessageListPage {
    
    static var cells: XCUIElementQuery {
        app.otherElements.matching(identifier: "MessageView")
    }
    
    static var list: XCUIElement {
        app.scrollViews.firstMatch
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
    
    enum MessageActions {
        
        static var messageActionsView: XCUIElement {
            app.otherElements["MessageActionsView"]
        }
        
    }
    
}
