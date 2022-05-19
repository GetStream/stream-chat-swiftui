//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import XCTest

// Application
let app = XCUIApplication()

class StreamChatSwiftUITestsAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

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

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
