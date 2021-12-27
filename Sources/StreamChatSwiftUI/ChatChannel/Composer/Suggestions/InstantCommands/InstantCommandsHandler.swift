//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

public class InstantCommandsHandler: CommandHandler {
    
    public let id: String
    public var displayInfo: CommandDisplayInfo?
    
    private let typingSuggester = TypingSuggester(
        options:
        TypingSuggestionOptions(
            symbol: "/",
            shouldTriggerOnlyAtStart: true
        )
    )
    private let commands: [CommandHandler]
    
    public init(
        commands: [CommandHandler],
        id: String = "instantCommands"
    ) {
        self.commands = commands
        self.id = id
    }
    
    public func canHandleCommand(in text: String, caretLocation: Int) -> ComposerCommand? {
        // Check for instant commands
        for command in commands {
            if let instantCommand = command.canHandleCommand(
                in: text,
                caretLocation: caretLocation
            ) {
                return instantCommand
            }
        }
        
        // Check for instant commands container
        if let typingSuggestion = typingSuggester.typingSuggestion(
            in: text,
            caretLocation: caretLocation
        ) {
            return ComposerCommand(
                id: id,
                typingSuggestion: typingSuggestion,
                displayInfo: nil
            )
        } else {
            return nil
        }
    }
    
    public func showSuggestions(for command: ComposerCommand) -> Future<SuggestionInfo, Error> {
        let suggestionInfo = SuggestionInfo(key: id, value: commands)
        return resolve(with: suggestionInfo)
    }
    
    public func handleCommand(
        for text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        command: Binding<ComposerCommand?>,
        extraData: [String: Any]
    ) {
        guard let instantCommand = extraData["instantCommand"] as? ComposerCommand else {
            return
        }
        command.wrappedValue = instantCommand
    }
}
