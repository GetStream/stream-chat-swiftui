//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the commands picker.
public struct AttachmentCommandsPickerView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @EnvironmentObject private var viewModel: MessageComposerViewModel

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(commandItems) { item in
                    InstantCommandView(displayInfo: item.displayInfo)
                        .standardPadding()
                        .contentShape(Rectangle())
                        .highPriorityGesture(
                            TapGesture().onEnded {
                                handleSelection(item)
                            }
                        )
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("AttachmentCommandView_\(item.id)")
                }
            }
        }
        .background(Color(colors.background1))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("AttachmentCommandsPickerView")
    }

    private var commandItems: [CommandItem] {
        let commandSymbol = viewModel.utils.commandsConfig.instantCommandsSymbol
        return [
            CommandItem(
                id: "\(commandSymbol)mute",
                displayInfo: CommandDisplayInfo(
                    displayName: L10n.Composer.Commands.mute,
                    icon: images.commandMute,
                    format: "\(commandSymbol)mute [\(L10n.Composer.Commands.Format.username)]",
                    isInstant: true
                ),
                replacesMessageSent: true
            ),
            CommandItem(
                id: "\(commandSymbol)unmute",
                displayInfo: CommandDisplayInfo(
                    displayName: L10n.Composer.Commands.unmute,
                    icon: images.commandUnmute,
                    format: "\(commandSymbol)unmute [\(L10n.Composer.Commands.Format.username)]",
                    isInstant: true
                ),
                replacesMessageSent: true
            ),
            CommandItem(
                id: "\(commandSymbol)giphy",
                displayInfo: CommandDisplayInfo(
                    displayName: L10n.Composer.Commands.giphy,
                    icon: images.commandGiphy,
                    format: "\(commandSymbol)giphy [\(L10n.Composer.Commands.Format.text)]",
                    isInstant: true
                ),
                replacesMessageSent: false
            )
        ]
    }

    private func handleSelection(_ item: CommandItem) {
        viewModel.pickerTypeState = .expanded(.none)
        viewModel.composerCommand = ComposerCommand(
            id: "instantCommands",
            typingSuggestion: TypingSuggestion.empty,
            displayInfo: nil
        )
        let command = ComposerCommand(
            id: item.id,
            typingSuggestion: TypingSuggestion.empty,
            displayInfo: item.displayInfo,
            replacesMessageSent: item.replacesMessageSent
        )
        viewModel.handleCommand(
            for: $viewModel.text,
            selectedRangeLocation: $viewModel.selectedRangeLocation,
            command: $viewModel.composerCommand,
            extraData: ["instantCommand": command]
        )
        NotificationCenter.default.post(
            name: NSNotification.Name(getStreamFirstResponderNotification),
            object: nil
        )
    }
}

private struct CommandItem: Identifiable {
    let id: String
    let displayInfo: CommandDisplayInfo
    let replacesMessageSent: Bool
}
