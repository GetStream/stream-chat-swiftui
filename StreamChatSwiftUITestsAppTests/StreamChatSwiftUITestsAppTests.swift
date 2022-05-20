//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import XCTest

// Application
let app = XCUIApplication()

class StreamChatSwiftUITestsAppTests: XCTestCase {

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        let cell = app.otherElements.buttons["ChatChannelSwipeableListItem"].firstMatch
        cell.tap()

        let messageList = app.scrollViews.firstMatch
        XCTAssert(messageList.waitForExistence(timeout: 1))
        
        measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
            messageList.swipeDown(velocity: .fast)
            stopMeasuring()
            messageList.swipeUp(velocity: .fast)
        }
    }
    
    func testChannelListIdentifiers() {
        app.launch()
        
        let cells = ChannelListPage.cells
        XCTAssert(cells.exists)
        
        let cell = cells.firstMatch
        
        let name = ChannelListPage.Attributes.name(in: cell)
        XCTAssert(name.exists)
        
        let lastMessageTime = ChannelListPage.Attributes.lastMessageTime(in: cell)
        XCTAssert(lastMessageTime.exists)
        
        let lastMessage = ChannelListPage.Attributes.lastMessage(in: cell)
        XCTAssert(lastMessage.exists)
        
        let avatar = ChannelListPage.Attributes.avatar(in: cell)
        XCTAssert(avatar.exists)
    }
    
    func testMessageListIdentifiers() {
        app.launch()
        
        let channelCells = ChannelListPage.cells
        channelCells.firstMatch.tap()
        
        let list = MessageListPage.list
        XCTAssert(list.exists)
        
        let cells = MessageListPage.cells
        XCTAssert(cells.lastMatch!.waitForExistence(timeout: 1))
        
        let chatAvatar = MessageListPage.NavigationBar.chatAvatar
        XCTAssert(chatAvatar.exists)
        
        /*
         TODO: Uncomment when we make them work.
         let chatName = MessageListPage.NavigationBar.chatName
         XCTAssert(chatName.exists)
         
         let chatOnlineInfo = MessageListPage.NavigationBar.chatOnlineInfo
         XCTAssert(chatOnlineInfo.exists)
         
         let messageComposer = MessageListPage.Composer.container
         XCTAssert(messageComposer.exists)
         
         let sendMessageButton = MessageListPage.Composer.sendButton
         XCTAssert(sendMessageButton.exists)
         */
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

public extension XCUIElementQuery {

    var lastMatch: XCUIElement? {
        allElementsBoundByIndex.last
    }

}
