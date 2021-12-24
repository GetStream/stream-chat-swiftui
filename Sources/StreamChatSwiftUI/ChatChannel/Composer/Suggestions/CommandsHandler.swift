//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

protocol CommandHandler {
    
    func canHandleCommand(
        in text: String,
        caretLocation: Int
    ) -> TypingSuggestion?
    
    func showSuggestions(
        for typingSuggestion: TypingSuggestion
    ) -> Future<SuggestionInfo, Never>
    
    func handleCommand(
        for text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        typingSuggestion: Binding<TypingSuggestion?>,
        extraData: [String: Any]
    )
}

struct SuggestionInfo {
    let key: String
    let value: Any
}

class CommandsHandler: CommandHandler {
    
    private let commands: [CommandHandler]
    
    init(commands: [CommandHandler]) {
        self.commands = commands
    }
    
    func canHandleCommand(in text: String, caretLocation: Int) -> TypingSuggestion? {
        for command in commands {
            if let suggestion = command.canHandleCommand(
                in: text,
                caretLocation: caretLocation
            ) {
                return suggestion
            }
        }
        
        return nil
    }
    
    func showSuggestions(
        for typingSuggestion: TypingSuggestion
    ) -> Future<SuggestionInfo, Never> {
        // TODO: picking of command
        commands.first!.showSuggestions(for: typingSuggestion)
    }
    
    func handleCommand(
        for text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        typingSuggestion: Binding<TypingSuggestion?>,
        extraData: [String: Any]
    ) {
        // TODO: picking of command
        commands.first?.handleCommand(
            for: text,
            selectedRangeLocation: selectedRangeLocation,
            typingSuggestion: typingSuggestion,
            extraData: extraData
        )
    }
}
