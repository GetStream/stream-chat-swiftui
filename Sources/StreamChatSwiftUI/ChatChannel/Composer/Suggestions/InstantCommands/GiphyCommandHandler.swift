//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

/// Handles the giphy command and provides suggestions.
public struct GiphyCommandHandler: CommandHandler {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors

    public let id: String
    public var displayInfo: CommandDisplayInfo?

    private let typingSuggester: TypingSuggester

    public init(
        commandSymbol: String,
        id: String = "/giphy"
    ) {
        self.id = id
        typingSuggester = TypingSuggester(
            options:
            TypingSuggestionOptions(
                symbol: commandSymbol,
                shouldTriggerOnlyAtStart: true
            )
        )
        displayInfo = CommandDisplayInfo(
            displayName: "Giphy",
            icon: images.commandGiphy,
            format: "\(id) [\(L10n.Composer.Commands.Format.text)]",
            isInstant: true
        )
    }

    public func canHandleCommand(in text: String, caretLocation: Int) -> ComposerCommand? {
        if text.hasPrefix(id) {
            return ComposerCommand(
                id: id,
                typingSuggestion: TypingSuggestion(
                    text: text,
                    locationRange: NSRange(
                        location: 0,
                        length: caretLocation
                    )
                ),
                displayInfo: displayInfo
            )
        } else {
            return nil
        }
    }

    public func handleCommand(
        for text: Binding<String>,
        selectedRangeLocation: Binding<Int>,
        command: Binding<ComposerCommand?>,
        extraData: [String: Any]
    ) { /* Handled with attachment actions. */ }

    public func commandHandler(for command: ComposerCommand) -> CommandHandler? {
        nil
    }

    public func showSuggestions(
        for command: ComposerCommand
    ) -> Future<SuggestionInfo, Error> {
        StreamChatError.noSuggestionsAvailable.asFailedPromise()
    }
}
