//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest
import StreamChat

class MessageListPage {
    
    static var cells: XCUIElementQuery {
        app.buttons.matching(identifier: "MessageContainerView")
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
        
        static var container: XCUIElement {
            app.otherElements["MessageComposerView"]
        }
        
        static var sendButton: XCUIElement {
            container.buttons["SendMessageButton"]
        }
        
    }
    
}
