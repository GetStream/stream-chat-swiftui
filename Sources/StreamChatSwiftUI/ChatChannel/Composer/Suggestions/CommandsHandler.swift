//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

/// Defines methods for handling commands.
public protocol CommandHandler {
    
    /// Identifier of the command.
    var id: String { get }
    
    var displayInfo: CommandDisplayInfo? { get }
    
    /// Checks whether the command can be handled.
    /// - Parameters:
    ///  - text: the user entered text.
    ///  - caretLocation: the end location of a selected text range.
    /// - Returns: optional `ComposerCommand` (if the handler can handle the command).
    func canHandleCommand(
        in text: String,
        caretLocation: Int
    ) -> ComposerCommand?
    
    func canShowSuggestions(for command: ComposerCommand) -> CommandHandler?
    
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
    
    func canBeExecuted(composerCommand: ComposerCommand) -> Bool
    
    func executeOnMessageSent(
        composerCommand: ComposerCommand,
        completion: @escaping (Error?) -> Void
    )
}

extension CommandHandler {
    
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
    let id: String
    /// Typing suggestion that invokes the command.
    var typingSuggestion: TypingSuggestion
    let displayInfo: CommandDisplayInfo?
    var replacesMessageSent: Bool = false
}

/// Provides information about the suggestion.
public struct SuggestionInfo {
    /// Identifies the suggestion.
    let key: String
    /// Any value that can be passed to the suggestion.
    let value: Any
}

public struct CommandDisplayInfo {
    let displayName: String
    let icon: UIImage
    let format: String
    let isInstant: Bool
}

/// Main commands handler - decides which commands to invoke.
/// Command is matched if there's an id matching.
public class CommandsHandler: CommandHandler {
    
    private let commands: [CommandHandler]
    public let id: String = "main"
    public var displayInfo: CommandDisplayInfo?
    
    init(commands: [CommandHandler]) {
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
    
    public func canShowSuggestions(for command: ComposerCommand) -> CommandHandler? {
        for handler in commands {
            if handler.canShowSuggestions(for: command) != nil {
                return handler
            }
        }
        
        return nil
    }
    
    public func showSuggestions(
        for command: ComposerCommand
    ) -> Future<SuggestionInfo, Error> {
        if let handler = canShowSuggestions(for: command) {
            return handler.showSuggestions(for: command)
        }
        
        return StreamChatError.wrongConfig.asFailedPromise()
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

        if let handler = canShowSuggestions(for: commandValue), handler.id != id {
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
        if let handler = canShowSuggestions(for: composerCommand) {
            handler.executeOnMessageSent(
                composerCommand: composerCommand,
                completion: completion
            )
        }
    }
    
    public func canBeExecuted(composerCommand: ComposerCommand) -> Bool {
        if let handler = canShowSuggestions(for: composerCommand), handler.id != id {
            return handler.canBeExecuted(composerCommand: composerCommand)
        }
        
        return !composerCommand.typingSuggestion.text.isEmpty
    }
}
