//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class InstantCommandsHandler_Tests: StreamChatTestCase {

    private var muteCommandHandler: MuteCommandHandler {
        MuteCommandHandler(
            chat: chatClient.makeChat(for: .unique),
            commandSymbol: "/mute"
        )
    }

    func test_instantCommandsHandler_canHandleCommand() {
        // Given
        let symbol = "/giphy"
        let giphyCommand = GiphyCommandHandler(
            commandSymbol: symbol
        )
        let commandsHandler = InstantCommandsHandler(commands: [giphyCommand])
        let typingSuggestion = TypingSuggestion(
            text: symbol,
            locationRange: NSRange(location: 1, length: 0)
        )

        // When
        let command = commandsHandler.canHandleCommand(
            in: typingSuggestion.text,
            caretLocation: typingSuggestion.locationRange.location
        )
        commandsHandler.handleCommand(
            for: .constant(typingSuggestion.text),
            selectedRangeLocation: .constant(typingSuggestion.locationRange.location),
            command: .constant(nil),
            extraData: [:]
        )

        // Then
        XCTAssert(command != nil)
        XCTAssert(command?.id == symbol)
    }

    func test_instantCommandsHandler_handlerForCommand() {
        // Given
        let symbol = "/mute"
        let commandsHandler = InstantCommandsHandler(commands: [muteCommandHandler])
        let typingSuggestion = TypingSuggestion(
            text: symbol,
            locationRange: NSRange(location: 1, length: 4)
        )
        let muteCommand = ComposerCommand(
            id: symbol,
            typingSuggestion: typingSuggestion,
            displayInfo: nil
        )

        // When
        let handler = commandsHandler.commandHandler(for: muteCommand) as? MuteCommandHandler

        // Then
        XCTAssert(handler != nil)
        XCTAssert(muteCommandHandler.id == handler?.id)
    }

    func test_instantCommandsHandler_showSuggestions() async throws {
        // Given
        let giphyCommand = GiphyCommandHandler(commandSymbol: "/giphy")
        let commandsHandler = InstantCommandsHandler(
            commands: [giphyCommand, muteCommandHandler]
        )
        let command = ComposerCommand(
            id: "/",
            typingSuggestion: TypingSuggestion(
                text: "/",
                locationRange: NSRange(location: 1, length: 0)
            ),
            displayInfo: nil
        )

        // When
        let suggestionInfo = try await commandsHandler.showSuggestions(for: command)
        let commands = suggestionInfo.value as! [CommandHandler]
        XCTAssert(commands.count == 2)
        XCTAssert(commands[0].id == giphyCommand.id)
        XCTAssert(commands[1].id == self.muteCommandHandler.id)
    }

    func test_instantCommandsHandler_cantHandleCommand() {
        // Given
        let giphyCommand = GiphyCommandHandler(commandSymbol: "/giphy")
        let commandsHandler = InstantCommandsHandler(
            commands: [giphyCommand, muteCommandHandler]
        )

        // When
        let command = commandsHandler.canHandleCommand(in: "$", caretLocation: 1)

        // Then
        XCTAssert(command == nil)
    }

    func test_instantCommandsHandler_noHandlerAvailable() {
        // Given
        let symbol = "$"
        let giphyCommand = GiphyCommandHandler(commandSymbol: "/giphy")
        let commandsHandler = InstantCommandsHandler(
            commands: [giphyCommand, muteCommandHandler]
        )
        let typingSuggestion = TypingSuggestion(
            text: symbol,
            locationRange: NSRange(location: 1, length: 0)
        )
        let dollarCommand = ComposerCommand(
            id: symbol,
            typingSuggestion: typingSuggestion,
            displayInfo: nil
        )

        // When
        let handler = commandsHandler.commandHandler(for: dollarCommand)

        // Then
        XCTAssert(handler == nil)
    }

    func test_instantCommandsHandler_info() {
        // Given
        let commandsHandler = InstantCommandsHandler(commands: [muteCommandHandler])

        // When
        let id = commandsHandler.id
        let displayInfo = commandsHandler.displayInfo

        // Then
        XCTAssert(id == "instantCommands")
        XCTAssert(displayInfo == nil)
    }
}
