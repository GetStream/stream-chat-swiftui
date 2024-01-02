//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class CommandsHandler_Tests: StreamChatTestCase {

    func test_commandsHandler_commandCanBeExecuted() {
        // Given
        let commandsHandler = makeCommandsHandler()
        let command = ComposerCommand(
            id: "mentions",
            typingSuggestion: TypingSuggestion(
                text: "hey",
                locationRange: NSRange(location: 1, length: 3)
            ),
            displayInfo: nil
        )

        // When
        let canBeExecuted = commandsHandler.canBeExecuted(composerCommand: command)
        let handler = commandsHandler.commandHandler(for: command)

        // Then
        XCTAssert(canBeExecuted == true)
        XCTAssert(handler != nil)
    }

    func test_commandsHandler_unknownCommand() {
        // Given
        let commandsHandler = makeCommandsHandler()
        let command = ComposerCommand(
            id: "random",
            typingSuggestion: TypingSuggestion(
                text: "",
                locationRange: NSRange(location: 1, length: 3)
            ),
            displayInfo: nil
        )

        // When
        let canBeExecuted = commandsHandler.canBeExecuted(composerCommand: command)
        let handler = commandsHandler.commandHandler(for: command)

        // Then
        XCTAssert(canBeExecuted == false)
        XCTAssert(handler == nil)
    }

    func test_commandsHandler_suggestionsAvailable() {
        // Given
        let commandsHandler = makeCommandsHandler()
        let searchTerm = "mar"
        let command = command(with: searchTerm)

        let expectation = expectation(description: "suggestions")

        // When
        _ = commandsHandler.showSuggestions(for: command).sink { _ in
            log.debug("completed suggestsions test")
        } receiveValue: { info in
            // Then
            XCTAssert(info.key == "mentions")
            let users = info.value as! [ChatUser]
            let first = users[0]
            XCTAssert(first.name!.lowercased().contains(searchTerm))
            XCTAssert(users.count == 2)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func test_commandsHandler_noSuggestionsAvailable() {
        // Given
        let commandsHandler = makeCommandsHandler()
        let searchTerm = "str"
        let command = command(with: searchTerm)

        let expectation = expectation(description: "suggestions")

        // When
        _ = commandsHandler.showSuggestions(for: command).sink { _ in
            log.debug("completed suggestsions test")
        } receiveValue: { info in
            // Then
            XCTAssert(info.key == "mentions")
            let users = info.value as! [ChatUser]
            XCTAssert(users.isEmpty)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func test_commandsHandler_allSuggestionsAvailable() {
        // Given
        let commandsHandler = makeCommandsHandler()
        let searchTerm = ""
        let command = command(
            with: searchTerm,
            range: NSRange(location: 1, length: 0)
        )

        let expectation = expectation(description: "suggestions")

        // When
        _ = commandsHandler.showSuggestions(for: command).sink { _ in
            log.debug("completed suggestsions test")
        } receiveValue: { info in
            // Then
            XCTAssert(info.key == "mentions")
            let users = info.value as! [ChatUser]
            XCTAssert(users.count == 3)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func test_commandsHandler_handleCommandCalled() {
        // Given
        let commandsHandler = makeCommandsHandler()
        let commandDisplayInfo = CommandDisplayInfo(
            displayName: "Mock command",
            icon: UIImage(systemName: "xmark")!,
            format: "mock [sth]",
            isInstant: true
        )
        let searchTerm = "mock"
        let command = command(
            id: searchTerm,
            displayInfo: commandDisplayInfo,
            with: searchTerm,
            range: NSRange(location: 0, length: 4)
        )

        // When
        let instantCommandsHandler = commandsHandler.commandHandler(for: command)
        let handler = instantCommandsHandler?.commandHandler(for: command) as? MockCommandHandler
        commandsHandler.handleCommand(
            for: .constant(searchTerm),
            selectedRangeLocation: .constant(4),
            command: .constant(command),
            extraData: [:]
        )
        commandsHandler.executeOnMessageSent(composerCommand: command, completion: { _ in })

        // Then
        XCTAssert(handler != nil)
        XCTAssert(handler?.handleCommandCalled == true)
        XCTAssert(handler?.executeOnMessageSentCalled == true)
    }

    func test_instantCommandsHandler_info() {
        // Given
        let commandsHandler = makeCommandsHandler()

        // When
        let id = commandsHandler.id
        let displayInfo = commandsHandler.displayInfo

        // Then
        XCTAssert(id == "main")
        XCTAssert(displayInfo == nil)
    }

    // MARK: - private

    private func command(
        id: String = "mentions",
        displayInfo: CommandDisplayInfo? = nil,
        with searchTerm: String,
        range: NSRange = NSRange(location: 1, length: 3)
    ) -> ComposerCommand {
        let command = ComposerCommand(
            id: id,
            typingSuggestion: TypingSuggestion(
                text: searchTerm,
                locationRange: range
            ),
            displayInfo: displayInfo
        )
        return command
    }

    private func makeCommandsHandler() -> CommandsHandler {
        let defaultCommandsConfig = TestCommandsConfig(chatClient: chatClient)
        let channelController = ChatChannelTestHelpers.makeChannelController(
            chatClient: chatClient,
            lastActiveWatchers: TestCommandsConfig.mockUsers
        )
        let commandsHandler = defaultCommandsConfig.makeCommandsHandler(with: channelController)
        return commandsHandler
    }
}
