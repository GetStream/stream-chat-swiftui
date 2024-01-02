//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine
import Foundation
import StreamChat
import StreamChatSwiftUI
import SwiftUI

/// Test commands configuration.
public class TestCommandsConfig: CommandsConfig {

    public init(chatClient: ChatClient) {
        self.chatClient = chatClient
    }

    public let mentionsSymbol: String = "@"
    public let instantCommandsSymbol: String = "/"

    private let chatClient: ChatClient

    public func makeCommandsHandler(
        with channelController: ChatChannelController
    ) -> CommandsHandler {
        let userSearchController = ChatUserSearchController_Mock.mock(client: chatClient)
        userSearchController.users_mock = Self.mockUsers
        let mentionsCommand = MentionsCommandHandler(
            channelController: channelController,
            userSearchController: userSearchController,
            commandSymbol: mentionsSymbol,
            mentionAllAppUsers: false
        )
        let giphyCommand = GiphyCommandHandler(commandSymbol: "/giphy")
        let muteCommand = MuteCommandHandler(
            channelController: channelController,
            commandSymbol: "/mute"
        )
        let unmuteCommand = UnmuteCommandHandler(
            channelController: channelController,
            commandSymbol: "/unmute"
        )
        let mockCommand = MockCommandHandler()
        let instantCommands = InstantCommandsHandler(
            commands: [
                mockCommand,
                giphyCommand,
                muteCommand,
                unmuteCommand
            ]
        )
        return CommandsHandler(commands: [mentionsCommand, instantCommands])
    }

    public static var mockUsers = [
        ChatUser.mock(id: .unique, name: "MartinM"),
        ChatUser.mock(id: .unique, name: "StefanB"),
        ChatUser.mock(id: .unique, name: "MarMit")
    ]
}

class MockCommandHandler: CommandHandler {

    var id: String = "mock"
    var displayInfo: CommandDisplayInfo?

    public var handleCommandCalled = false
    public var executeOnMessageSentCalled = false

    func canHandleCommand(in text: String, caretLocation: Int) -> ComposerCommand? {
        if text.contains("mock") {
            return ComposerCommand(
                id: "mock",
                typingSuggestion: TypingSuggestion(
                    text: text,
                    locationRange: NSRange(location: 0, length: caretLocation)
                ),
                displayInfo: displayInfo,
                replacesMessageSent: true
            )
        } else {
            return nil
        }
    }

    func commandHandler(for command: ComposerCommand) -> CommandHandler? {
        if command.typingSuggestion.text.contains("mock") {
            return self
        } else {
            return nil
        }
    }

    func showSuggestions(for command: ComposerCommand) -> Future<SuggestionInfo, Error> {
        let suggestionInfo = SuggestionInfo(key: "mock", value: [])
        return Future { promise in
            promise(.success(suggestionInfo))
        }
    }

    func handleCommand(
        for text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        command: Binding<ComposerCommand?>,
        extraData: [String: Any]
    ) {
        handleCommandCalled = true
    }

    public var replacesMessageSent: Bool {
        true
    }

    public func executeOnMessageSent(
        composerCommand: ComposerCommand,
        completion: @escaping (Error?) -> Void
    ) {
        executeOnMessageSentCalled = true
    }

    public func canBeExecuted(composerCommand: ComposerCommand) -> Bool {
        !composerCommand.typingSuggestion.text.isEmpty
    }
}
