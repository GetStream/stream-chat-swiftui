//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

/// Defines methods for handling commands.
public protocol CommandHandler {

    /// Identifier of the command.
    var id: String { get }

    /// Display info for the command.
    var displayInfo: CommandDisplayInfo? { get }

    /// Whether execution of the command replaces sending of a message.
    var replacesMessageSent: Bool { get }

    /// Checks whether the command can be handled.
    /// - Parameters:
    ///  - text: the user entered text.
    ///  - caretLocation: the end location of a selected text range.
    /// - Returns: optional `ComposerCommand` (if the handler can handle the command).
    func canHandleCommand(
        in text: String,
        caretLocation: Int
    ) -> ComposerCommand?

    /// Returns a command handler for a command (if available).
    /// - Parameter command: the command whose handler will be returned.
    /// - Returns: Optional `CommandHandler`.
    func commandHandler(for command: ComposerCommand) -> CommandHandler?

    /// Shows suggestions for the provided command.
    /// - Parameter command: the command whose suggestions will be shown.
    /// - Returns: `Future` with the suggestions, or an error.
    func showSuggestions(
        for command: ComposerCommand
    ) -> Future<SuggestionInfo, Error>

    /// Handles the provided command.
    /// - Parameters:
    ///  - text: the user entered text.
    ///  - selectedRangeLocation: the end location of the selected text.
    ///  - command: binding of the command.
    ///  - extraData: additional data that can be passed from the command.
    func handleCommand(
        for text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        command: Binding<ComposerCommand?>,
        extraData: [String: Any]
    )

    /// Checks whether the command can be executed on message sent.
    /// - Parameter command: the command to be checked.
    /// - Returns: `Bool` whether the command can be executed.
    func canBeExecuted(composerCommand: ComposerCommand) -> Bool

    /// Needs to be implemented if you need some code executed before the message is sent.
    /// - Parameters:
    ///  - composerCommand: the command to be executed.
    ///  - completion: called when the command is executed.
    func executeOnMessageSent(
        composerCommand: ComposerCommand,
        completion: @escaping (Error?) -> Void
    )
}

/// Default implementations.
extension CommandHandler {

    public var replacesMessageSent: Bool {
        false
    }

    public func executeOnMessageSent(
        composerCommand: ComposerCommand,
        completion: @escaping (Error?) -> Void
    ) {
        // optional method.
    }

    public func canBeExecuted(composerCommand: ComposerCommand) -> Bool {
        !composerCommand.typingSuggestion.text.isEmpty
    }
}

/// Model for the composer's commands.
public struct ComposerCommand {
    /// Identifier of the command.
    public let id: String
    /// Typing suggestion that invokes the command.
    public var typingSuggestion: TypingSuggestion
    /// Display info for the command.
    public let displayInfo: CommandDisplayInfo?
    /// Whether execution of the command replaces sending of a message.
    public var replacesMessageSent: Bool = false

    public init(
        id: String,
        typingSuggestion: TypingSuggestion,
        displayInfo: CommandDisplayInfo?,
        replacesMessageSent: Bool = false
    ) {
        self.id = id
        self.typingSuggestion = typingSuggestion
        self.displayInfo = displayInfo
        self.replacesMessageSent = replacesMessageSent
    }
}

/// Provides information about the suggestion.
public struct SuggestionInfo {
    /// Identifies the suggestion.
    public let key: String
    /// Any value that can be passed to the suggestion.
    public let value: Any

    public init(key: String, value: Any) {
        self.key = key
        self.value = value
    }
}

/// Display information about a command.
public struct CommandDisplayInfo {
    public let displayName: String
    public let icon: UIImage
    public let format: String
    public let isInstant: Bool

    public init(
        displayName: String,
        icon: UIImage,
        format: String,
        isInstant: Bool
    ) {
        self.displayName = displayName
        self.icon = icon
        self.format = format
        self.isInstant = isInstant
    }
}

/// Main commands handler - decides which commands to invoke.
/// Command is matched if there's an id matching.
public class CommandsHandler: CommandHandler {

    private let commands: [CommandHandler]
    public let id: String = "main"
    public var displayInfo: CommandDisplayInfo?

    public init(commands: [CommandHandler]) {
        self.commands = commands
    }

    public func canHandleCommand(in text: String, caretLocation: Int) -> ComposerCommand? {
        for command in commands {
            if let composerCommand = command.canHandleCommand(
                in: text,
                caretLocation: caretLocation
            ) {
                return composerCommand
            }
        }

        return nil
    }

    public func commandHandler(for command: ComposerCommand) -> CommandHandler? {
        for handler in commands {
            if handler.commandHandler(for: command) != nil {
                return handler
            }
        }

        return nil
    }

    public func showSuggestions(
        for command: ComposerCommand
    ) -> Future<SuggestionInfo, Error> {
        if let handler = commandHandler(for: command) {
            return handler.showSuggestions(for: command)
        }

        return StreamChatError.noSuggestionsAvailable.asFailedPromise()
    }

    public func handleCommand(
        for text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        command: Binding<ComposerCommand?>,
        extraData: [String: Any]
    ) {
        guard let commandValue = command.wrappedValue else {
            return
        }

        if let handler = commandHandler(for: commandValue), handler.id != id {
            handler.handleCommand(
                for: text,
                selectedRangeLocation: selectedRangeLocation,
                command: command,
                extraData: extraData
            )
        }
    }

    public func executeOnMessageSent(
        composerCommand: ComposerCommand,
        completion: @escaping (Error?) -> Void
    ) {
        if let handler = commandHandler(for: composerCommand) {
            handler.executeOnMessageSent(
                composerCommand: composerCommand,
                completion: completion
            )
        }
    }

    public func canBeExecuted(composerCommand: ComposerCommand) -> Bool {
        if let handler = commandHandler(for: composerCommand), handler.id != id {
            return handler.canBeExecuted(composerCommand: composerCommand)
        }

        return !composerCommand.typingSuggestion.text.isEmpty
    }
}
