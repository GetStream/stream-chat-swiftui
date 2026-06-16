//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Default implementation of the suggestions container.
struct SuggestionsContainerView<Factory: ViewFactory>: View {
    var factory: Factory
    var suggestions: [String: Any]
    var handleCommand: ([String: Any]) -> Void

    init(
        factory: Factory = DefaultViewFactory.shared,
        suggestions: [String: Any],
        handleCommand: @escaping ([String: Any]) -> Void
    ) {
        self.factory = factory
        self.suggestions = suggestions
        self.handleCommand = handleCommand
    }

    var body: some View {
        ZStack {
            if let mentionSuggestions = suggestions["mentions"] as? [MentionSuggestion] {
                MentionSuggestionsView(
                    factory: factory,
                    suggestions: mentionSuggestions,
                    suggestionSelected: { suggestion in
                        handleCommand(["mentionSuggestion": suggestion])
                    }
                )
                .accessibilityIdentifier("MentionSuggestionsView")
            } else if let suggestedUsers = suggestions["mentions"] as? [ChatUser] {
                UserSuggestionsView(
                    factory: factory,
                    users: suggestedUsers,
                    userSelected: { user in
                        handleCommand(["chatUser": user])
                    }
                )
                .accessibilityIdentifier("UserSuggestionsView")
            }

            if let instantCommands = suggestions["instantCommands"] as? [CommandHandler] {
                CommandSuggestionsView(
                    instantCommands: instantCommands,
                    commandSelected: { command in
                        handleCommand(["instantCommand": command])
                    }
                )
                .accessibilityIdentifier("CommandSuggestionsView")
            }
        }
        .modifier(factory.styles.makeSuggestionsContainerModifier(options: SuggestionsContainerModifierOptions()))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("SuggestionsContainerView")
    }
}
