//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class MuteCommandHandler_Tests: StreamChatTestCase {

    func test_muteCommandHandler_selectingUserToMute() {
        // Given
        let symbol = "/mute"
        let muteCommandHandler = makeMuteCommandHandler()
        let command = ComposerCommand(
            id: symbol,
            typingSuggestion: TypingSuggestion(
                text: "@",
                locationRange: NSRange(location: 1, length: 0)
            ), displayInfo: nil
        )

        // When
        muteCommandHandler.handleCommand(
            for: .constant(symbol),
            selectedRangeLocation: .constant(0),
            command: .constant(command),
            extraData: [
                "chatUser": TestCommandsConfig.mockUsers[0]
            ]
        )
        let canBeExecuted = muteCommandHandler.canBeExecuted(composerCommand: command)

        // Then
        let user = muteCommandHandler.selectedUser
        XCTAssert(user == TestCommandsConfig.mockUsers[0])
        XCTAssert(canBeExecuted == true)
    }

    func test_muteCommandHandler_showSuggestions() {
        // Given
        let muteCommandHandler = makeMuteCommandHandler()
        let command = ComposerCommand(
            id: "/mute",
            typingSuggestion: TypingSuggestion(
                text: "@",
                locationRange: NSRange(location: 1, length: 0)
            ), displayInfo: nil
        )
        let expectation = expectation(description: "suggestions")

        // When
        _ = muteCommandHandler.showSuggestions(for: command).sink { _ in
            log.debug("finished showing suggestions")
        } receiveValue: { suggestionInfo in
            // Then
            let users = suggestionInfo.value as! [ChatUser]
            XCTAssert(users.count == 3)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func test_unmuteCommandHandler_selectingUserToUnmute() {
        // Given
        let symbol = "/unmute"
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let unmuteCommandHandler = UnmuteCommandHandler(
            channelController: channelController,
            commandSymbol: symbol
        )
        let command = ComposerCommand(
            id: symbol,
            typingSuggestion: TypingSuggestion(
                text: "@",
                locationRange: NSRange(location: 1, length: 0)
            ), displayInfo: nil
        )

        // When
        unmuteCommandHandler.handleCommand(
            for: .constant(symbol),
            selectedRangeLocation: .constant(0),
            command: .constant(command),
            extraData: [
                "chatUser": TestCommandsConfig.mockUsers[0]
            ]
        )
        let canBeExecuted = unmuteCommandHandler.canBeExecuted(composerCommand: command)

        // Then
        let user = unmuteCommandHandler.selectedUser
        XCTAssert(user == TestCommandsConfig.mockUsers[0])
        XCTAssert(canBeExecuted == true)
    }

    // MARK: - private

    private func makeMuteCommandHandler(symbol: String = "/mute") -> MuteCommandHandler {
        let channelController = ChatChannelTestHelpers.makeChannelController(
            chatClient: chatClient,
            lastActiveWatchers: TestCommandsConfig.mockUsers
        )
        let muteCommandHandler = MuteCommandHandler(
            channelController: channelController,
            commandSymbol: symbol
        )
        return muteCommandHandler
    }
}
