//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

protocol CommandHandler {
    
    var id: String { get }
    
    func canHandleCommand(
        in text: String,
        caretLocation: Int
    ) -> ComposerCommand?
    
    func showSuggestions(
        for command: ComposerCommand
    ) -> Future<SuggestionInfo, Never>
    
    func handleCommand(
        for text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        command: Binding<ComposerCommand?>,
        extraData: [String: Any]
    )
}

struct ComposerCommand {
    let id: String
    let typingSuggestion: TypingSuggestion
}

struct SuggestionInfo {
    let key: String
    let value: Any
}

class CommandsHandler: CommandHandler {
    
    private let commands: [CommandHandler]
    let id: String = "main"
    
    init(commands: [CommandHandler]) {
        self.commands = commands
    }
    
    func canHandleCommand(in text: String, caretLocation: Int) -> ComposerCommand? {
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
    
    func showSuggestions(
        for command: ComposerCommand
    ) -> Future<SuggestionInfo, Never> {
        for handler in commands {
            if handler.id == command.id {
                return handler.showSuggestions(for: command)
            }
        }
        
        // TODO: gracefully
        fatalError("misconfiguration of commands")
    }
    
    func handleCommand(
        for text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        command: Binding<ComposerCommand?>,
        extraData: [String: Any]
    ) {
        for handler in commands {
            let commandValue = command.wrappedValue
            if handler.id == commandValue?.id {
                handler.handleCommand(
                    for: text,
                    selectedRangeLocation: selectedRangeLocation,
                    command: command,
                    extraData: extraData
                )
            }
        }
    }
}
