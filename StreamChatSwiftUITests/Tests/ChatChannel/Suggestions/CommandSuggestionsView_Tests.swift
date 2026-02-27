//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import XCTest

@MainActor class CommandSuggestionsView_Tests: StreamChatTestCase {
    func test_commandSuggestionView_snapshot() {
        let commandDisplayInfo = CommandDisplayInfo(
            displayName: "Test command",
            icon: UIImage(systemName: "person")!,
            format: "/test [@username]",
            isInstant: false,
            description: "A test command description"
        )

        let view = CommandSuggestionView(displayInfo: commandDisplayInfo)
            .frame(width: defaultScreenSize.width, height: 100)

        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    // MARK: - Regular Style

    func test_commandSuggestionsContainerView_regularStyle() {
        let commands: [CommandHandler] = defaultCommands()
        let view = CommandSuggestionsView(instantCommands: commands, commandSelected: { _ in })
            .modifier(SuggestionsRegularContainerModifier())
            .frame(width: defaultScreenSize.width)

        AssertSnapshot(view, variants: [.defaultLight, .defaultDark])
    }

    // MARK: - Liquid Glass Style

    func test_commandSuggestionsContainerView_liquidGlassStyle() {
        let commands: [CommandHandler] = defaultCommands()
        let view = CommandSuggestionsView(instantCommands: commands, commandSelected: { _ in })
            .modifier(SuggestionsLiquidGlassContainerModifier())
            .frame(width: defaultScreenSize.width)

        AssertSnapshot(view, variants: [.defaultLight, .defaultDark])
    }

    // MARK: - Helpers

    private func defaultCommands(suffix: String = "") -> [CommandHandler] {
        let channelController = ChatChannelTestHelpers.makeChannelController(
            chatClient: chatClient,
            messages: []
        )
        var instantCommands = [CommandHandler]()
        let giphyCommand = GiphyCommandHandler(
            commandSymbol: "/giphy",
            id: "/giphy\(suffix)"
        )
        instantCommands.append(giphyCommand)
        let muteCommand = MuteCommandHandler(
            channelController: channelController,
            commandSymbol: "/mute",
            id: "/mute\(suffix)"
        )
        let unmuteCommand = UnmuteCommandHandler(
            channelController: channelController,
            commandSymbol: "/unmute",
            id: "/unmute\(suffix)"
        )
        instantCommands.append(muteCommand)
        instantCommands.append(unmuteCommand)

        return instantCommands
    }
}
