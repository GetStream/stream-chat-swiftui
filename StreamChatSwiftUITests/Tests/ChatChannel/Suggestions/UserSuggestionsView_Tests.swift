//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor
final class UserSuggestionsView_Tests: StreamChatTestCase {
    func test_messageComposerView_emptyMentions() {
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let viewModel = MessageComposerViewModel(channelController: channelController, messageController: nil)
        viewModel.composerCommand = ComposerCommand(
            id: "mentions",
            typingSuggestion: .empty,
            displayInfo: nil
        )

        let view = MessageComposerView(
            viewFactory: factory,
            viewModel: viewModel,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            willSendMessage: {}
        )
        .frame(width: defaultScreenSize.width, height: 200)

        AssertSnapshot(view, variants: [.defaultLight])
    }

    // MARK: - Regular Style

    func test_userSuggestionsView_regularStyle() {
        let users = mockUsers(count: 3)
        let view = UserSuggestionsView(users: users, userSelected: { _ in })
            .modifier(SuggestionsRegularContainerModifier())
            .frame(width: defaultScreenSize.width)

        AssertSnapshot(view)
    }

    // MARK: - Liquid Glass Style

    func test_userSuggestionsView_liquidGlassStyle() {
        let users = mockUsers(count: 3)
        let view = UserSuggestionsView(users: users, userSelected: { _ in })
            .modifier(SuggestionsLiquidGlassContainerModifier())
            .frame(width: defaultScreenSize.width)

        AssertSnapshot(view, variants: [.defaultLight, .defaultDark])
    }

    // MARK: - Helpers

    private func mockUsers(count: Int) -> [ChatUser] {
        let names = ["Elena Barros", "Emma Chen", "Lina Park", "Noah Richter", "Wesley Lau", "Ana Silva", "John Doe", "Jane Smith"]
        return (0..<count).map { i in
            ChatUser.mock(id: "user-\(i)", name: names[i % names.count])
        }
    }
}
