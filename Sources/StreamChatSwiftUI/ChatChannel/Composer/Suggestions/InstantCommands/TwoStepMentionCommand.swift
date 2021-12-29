//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

/// Base class that supports two step commands, where the second one is mentioning users.
open class TwoStepMentionCommand: CommandHandler {
        
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors
    
    private let channelController: ChatChannelController
    private let mentionsCommandHandler: MentionsCommandHandler
    private let mentionSymbol: String
    
    internal var selectedUser: ChatUser?
    
    public let id: String
    public var displayInfo: CommandDisplayInfo?
    public let replacesMessageSending: Bool = true
                
    init(
        channelController: ChatChannelController,
        commandSymbol: String,
        id: String,
        displayInfo: CommandDisplayInfo? = nil,
        mentionSymbol: String = "@"
    ) {
        self.channelController = channelController
        self.id = id
        self.mentionSymbol = mentionSymbol
        mentionsCommandHandler = MentionsCommandHandler(
            channelController: channelController,
            commandSymbol: mentionSymbol,
            mentionAllAppUsers: false
        )
        self.displayInfo = displayInfo
    }
    
    public func canHandleCommand(in text: String, caretLocation: Int) -> ComposerCommand? {
        if text == id {
            return ComposerCommand(
                id: id,
                typingSuggestion: TypingSuggestion(
                    text: text,
                    locationRange: NSRange(
                        location: 0,
                        length: caretLocation
                    )
                ),
                displayInfo: displayInfo,
                replacesMessageSent: true
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
    ) {
        guard let chatUser = extraData["chatUser"] as? ChatUser,
              let typingSuggestionValue = command.wrappedValue?.typingSuggestion else {
            return
        }
        
        selectedUser = chatUser

        let mentionText = self.mentionText(for: chatUser)
        let newText = (text.wrappedValue as NSString).replacingCharacters(
            in: typingSuggestionValue.locationRange,
            with: mentionText
        )
        text.wrappedValue = newText

        let newCaretLocation =
            selectedRangeLocation.wrappedValue + (mentionText.count - typingSuggestionValue.text.count)
        selectedRangeLocation.wrappedValue = newCaretLocation
    }
    
    public func canBeExecuted(composerCommand: ComposerCommand) -> Bool {
        selectedUser != nil
    }
    
    private func mentionText(for user: ChatUser) -> String {
        if let name = user.name, !name.isEmpty {
            return "\(mentionSymbol)\(name)"
        } else {
            return "\(mentionSymbol)\(user.id)"
        }
    }
    
    public func commandHandler(for command: ComposerCommand) -> CommandHandler? {
        if let selectedUser = selectedUser,
           command.typingSuggestion.text != mentionText(for: selectedUser) {
            self.selectedUser = nil
        }
        return command.id == id ? self : nil
    }
    
    public func showSuggestions(
        for command: ComposerCommand
    ) -> Future<SuggestionInfo, Error> {
        if selectedUser != nil {
            return resolve(
                with: SuggestionInfo(
                    key: "mentions",
                    value: []
                )
            )
        }
        let oldText = command.typingSuggestion.text
        let text = oldText.replacingOccurrences(
            of: mentionSymbol, with: ""
        ).trimmingCharacters(in: .whitespaces)
        let oldRange = command.typingSuggestion.locationRange
        let offset = oldText.count - text.count
        let newRange = NSRange(
            location: 0,
            length: oldRange.location - offset
        )
        let typingSuggestion = TypingSuggestion(text: text, locationRange: newRange)
        let updated = ComposerCommand(
            id: command.id,
            typingSuggestion: typingSuggestion,
            displayInfo: command.displayInfo
        )
        return mentionsCommandHandler.showSuggestions(for: updated)
    }
    
    public var replacesMessageSent: Bool {
        true
    }
    
    public func executeOnMessageSent(
        composerCommand: ComposerCommand,
        completion: @escaping (Error?) -> Void
    ) {
        // Implement in subclasses.
    }
}
