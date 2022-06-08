//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import XCTest

final class MessageList_Tests: StreamTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        //addTags([.coreFeatures])
    }

    func test_messageListUpdates_whenUserSendsMessage() {
//        linkToScenario(withId: 25)

        let message = "message"

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        WHEN("user sends a message") {
            userRobot.sendMessage(message)
        }
        THEN("message list updates") {
            userRobot.assertMessage(message)
        }
    }
    
    func testChannelListIdentifiers() {
        app.launch()
        
        StartPage.startButton.safeTap()

        let cell = ChannelListPage.cells.firstMatch

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
        StartPage.startButton.safeTap()
        
        let channelCells = ChannelListPage.cells
        channelCells.firstMatch.safeTap()
        
        let list = MessageListPage.list
        XCTAssert(list.exists)
        
        let cells = MessageListPage.cells
        let first = cells.firstMatch
        XCTAssert(first.exists)
        
        let message = MessageListPage.messageView(for: first)
        message.press(forDuration: 1)
                
        let reactionsMessageView = MessageListPage.Reactions.reactionsMessageView
        XCTAssert(reactionsMessageView.waitForExistence(timeout: 1))

        let reactionLove = MessageListPage.Reactions.love
        XCTAssert(reactionLove.exists)

        let reactionSad = MessageListPage.Reactions.sad
        XCTAssert(reactionSad.exists)

        let reactionWow = MessageListPage.Reactions.wow
        XCTAssert(reactionWow.exists)

        let reactionHaha = MessageListPage.Reactions.lol
        XCTAssert(reactionHaha.exists)

        let reactionLike = MessageListPage.Reactions.like
        XCTAssert(reactionLike.exists)

        let messageActionsView = MessageListPage.ContextMenu.actionsView.element
        XCTAssert(messageActionsView.exists)

        let replyMessageAction = MessageListPage.ContextMenu.reply.element
        XCTAssert(replyMessageAction.exists)

        let threadMessageAction = MessageListPage.ContextMenu.threadReply.element
        XCTAssert(threadMessageAction.exists)

        let pinMessageAction = MessageListPage.ContextMenu.pin.element
        XCTAssert(pinMessageAction.exists)

        let copyMessageAction = MessageListPage.ContextMenu.copy.element
        XCTAssert(copyMessageAction.exists)
        
        /*
        let editMessageAction = MessageListPage.MessageActions.editMessageAction
        XCTAssert(editMessageAction.exists)
        
        let deleteMessageAction = MessageListPage.MessageActions.deleteMessageAction
        XCTAssert(deleteMessageAction.exists)
        
        let chatAvatar = MessageListPage.NavigationBar.chatAvatar
        XCTAssert(chatAvatar.exists)
        
        let sendMessageButton = MessageListPage.Composer.sendButton
        XCTAssert(sendMessageButton.exists)
        
        let commandsButton = MessageListPage.Composer.commandButton
        XCTAssert(commandsButton.exists)
        
        let composerMediaButton = MessageListPage.Composer.attachmentButton
        XCTAssert(composerMediaButton.exists)
                
        composerMediaButton.forceTapElement()
        
        let attachmentPickerPhotos = MessageListPage.AttachmentMenu.photoOrVideoButton
        XCTAssert(attachmentPickerPhotos.waitForExistence(timeout: 1))
        
        let attachmentPickerFiles = MessageListPage.AttachmentMenu.fileButton
        XCTAssert(attachmentPickerFiles.exists)
        
        let attachmentPickerCamera = MessageListPage.AttachmentMenu.cameraButton
        XCTAssert(attachmentPickerCamera.exists)
         
        let threadButton = MessageListPage.Attributes.threadButton(in: first)
        XCTAssert(threadButton.exists)
         
        threadButton.safeTap()
        */
        
        /*
         TODO: Uncomment when we make them work.
         let chatName = MessageListPage.NavigationBar.chatName
         XCTAssert(chatName.exists)
         
         let chatOnlineInfo = MessageListPage.NavigationBar.chatOnlineInfo
         XCTAssert(chatOnlineInfo.exists)
         
         let messageComposer = MessageListPage.Composer.container
         XCTAssert(messageComposer.exists)
         
         */
    }
}
