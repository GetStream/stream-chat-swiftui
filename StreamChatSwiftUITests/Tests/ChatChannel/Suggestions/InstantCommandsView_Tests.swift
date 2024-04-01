//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import XCTest

class InstantCommandsView_Tests: StreamChatTestCase {

    func test_instantCommandsView_snapshot() {
        // Given
        let commandDisplayInfo = CommandDisplayInfo(
            displayName: "Test command",
            icon: UIImage(systemName: "person")!,
            format: "test command",
            isInstant: false
        )

        // When
        let view = InstantCommandView(displayInfo: commandDisplayInfo)
            .frame(width: defaultScreenSize.width, height: 100)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_instantCommandsContainerViewEmpty_snapshot() {
        // Given
        let commands: [CommandHandler] = []

        // When
        let view = InstantCommandsView(instantCommands: commands, commandSelected: { _ in })
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_instantCommandsContainerView_snapshot() {
        // Given
        let commands: [CommandHandler] = defaultCommands()

        // When
        let view = InstantCommandsView(instantCommands: commands, commandSelected: { _ in })
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_instantCommandsContainerMaxSize_snapshot() {
        // Given
        var commands = [CommandHandler]()
        for i in 0..<5 {
            commands.append(contentsOf: defaultCommands(suffix: "\(i)"))
        }

        // When
        let view = InstantCommandsView(instantCommands: commands, commandSelected: { _ in })
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    private func defaultCommands(suffix: String = "") -> [CommandHandler] {
        let chat = chatClient.makeChat(for: .unique)
        var instantCommands = [CommandHandler]()
        let giphyCommand = GiphyCommandHandler(
            commandSymbol: "/giphy",
            id: "/giphy\(suffix)"
        )
        instantCommands.append(giphyCommand)
        let muteCommand = MuteCommandHandler(
            chat: chat,
            commandSymbol: "/mute",
            id: "/mute\(suffix)"
        )
        let unmuteCommand = UnmuteCommandHandler(
            chat: chat,
            commandSymbol: "/unmute",
            id: "/unmute\(suffix)"
        )
        instantCommands.append(muteCommand)
        instantCommands.append(unmuteCommand)

        return instantCommands
    }
}
